#!/usr/bin/env bash

##########################################################################################################################
## CCS SCRIPT TO PREPROCESS THE DTI SCAN (INTEGRATE AFNI AND FSL)
##
## R-fMRI master: Xi-Nian Zuo. Aug. 13, 2011.
##
## Email: zuoxn@psych.ac.cn or zuoxinian@gmail.com.
##########################################################################################################################

## subject
subject=$1
## analysisdirectory
dir=$2
## name of the resting-state scan
dti=$3
## name of the func directory
dti_dir_name=$4
## number of repeated directions
dir_rep=$5
## number of repeated B0 directions
b0_rep=$6
## name of anatomical directory
anat_dir_name=$7

## directory setup
dti_dir=${dir}/${subject}/${dti_dir_name}
anat_dir=${dir}/${subject}/${anat_dir_name}

if [ $# -lt 7 ];
then
        echo -e "\033[47;35m Usage: $0 subject analysis_dir dti_name dti_dir_name dir_rep b0_rep anat_dir_name \033[0m "
        exit
fi

echo ---------------------------------------
echo !!!! PREPROCESSING DIFFUSION SCAN !!!!
echo ---------------------------------------

cwd=$( pwd )
cd ${dti_dir}

## 0. Getting the basic parameters
echo "Getting the basic parameters"
n_vols=`fslnvols ${dti}.nii.gz` ; 
echo "there are ${n_vols} vols"
N=$(echo "scale=0; ${n_vols}/${dir_rep}"|bc) ; 
echo "there are ${N} directions"

## 1. Eddy Correction
echo "Eddy correcting ${subject}"
eddy_correct ${dti}.nii.gz data_eddy.nii.gz 0

## 2. Extract B0 brain and Unique diffusion images
echo "B0 brain extraction"
fslroi ${dti}.nii.gz b0.nii.gz 0 ${b0_rep}
fslroi data_eddy.nii.gz data.nii.gz 0 ${N} 
if [ ${dir_rep} -gt 1 ]
then
        for (( id=2; id<=${dir_rep}; id++ ))
        do
                vol_pos=$(echo "scale=0; ${N}*(${id}-1)"|bc) ;
		echo "B0: $id, ${vol_pos}"
                fslroi data_eddy.nii.gz tmp.nii.gz ${vol_pos} ${N}
                fslmaths data.nii.gz -add tmp.nii.gz data.nii.gz
		fslroi ${dti}.nii.gz tmp0.nii.gz ${vol_pos} ${b0_rep}
                fslmaths b0.nii.gz -add tmp0.nii.gz b0.nii.gz
        done
        fslmaths data.nii.gz -div ${dir_rep} data.nii.gz
	fslmaths b0.nii.gz -div ${dir_rep} b0.nii.gz
        rm -rv tmp.nii.gz tmp0.nii.gz
fi
if [ ${b0_rep} -gt 1 ]
then
	fslmaths b0.nii.gz -Tmean b0.nii.gz
fi
bet b0.nii.gz b0_brain.nii.gz -f 0.2 -m

## 3. Refine the B0 brain and mask
echo "Refining the B0 brain and its mask with the T1 image"
mkdir -p ${dti_dir}/reg
flirt -ref ${anat_dir}/reg/highres_rpi.nii.gz -in b0_brain -out ${dti_dir}/reg/b02highres4mask -omat ${dti_dir}/reg/b02highres4mask.mat -cost corratio -dof 6 -interp trilinear #here should use highres_rpi
## Create mat file for conversion from subject's anatomical to diffusion
convert_xfm -inverse -omat ${dti_dir}/reg/highres2b04mask.mat ${dti_dir}/reg/b02highres4mask.mat
flirt -ref b0 -in ${anat_dir}/reg/highres_rpi.nii.gz -out tmpT1.nii.gz -applyxfm -init ${dti_dir}/reg/highres2b04mask.mat -interp trilinear
fslmaths tmpT1.nii.gz -bin -dilM ${dti_dir}/reg/brainmask2b0.nii.gz ; rm -v tmp*.nii.gz
fslmaths b0_brain_mask.nii.gz -mul ${dti_dir}/reg/brainmask2b0.nii.gz b0_brain_mask.nii.gz -odt char
fslmaths b0.nii.gz -mas b0_brain_mask.nii.gz b0_brain.nii.gz

## 4. DTI fitting (FSL)
echo "DTI tensor fitting (FSL)"
more bval | cut -d ' ' -f1-${N} > bval_cut
more bvec | cut -d ' ' -f1-${N} > bvec_cut
echo "Fitting DTI parameters for ${subject}"
dtifit --data=data.nii.gz --out=dtifit --mask=b0_brain_mask.nii.gz --bvecs=bvec_cut --bvals=bval_cut
mkdir -p fdt ; mv dtifit_* fdt/

## 5. DTK fitting
echo "DTI tensor fitting (DTK)"
mkdir -p dtk ; cd dtk
rm -v gradient.txt ; 1dtranspose ../bvec_cut gradient.txt ; 
Nb0=$(echo "scale=0; ${b0_rep}+1"|bc) ; 
bvalue=`more ../bval | cut -d ' ' -f${Nb0}-${Nb0}`; #need test!
dti_recon ../data.nii.gz dtifit -gm gradient.txt -b ${bvalue} -b0 ${b0_rep} -it nii.gz -ot nii.gz

## 6. DTK fiber tracking (some parameters need to be decided finally)
echo "DTI fiber tracking (DTK)"
mkdir -p ../track ; cd ../track
dti_tracker ../dtk/dtifit tracks.trk -it nii.gz -at 45 -rseed 8 -m ../b0_brain_mask.nii.gz -m2 ../dtk/dtifit_fa.nii.gz 0.1
spline_filter tracks.trk 0.5 tracks_spline.trk
