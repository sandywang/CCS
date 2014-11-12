#!/usr/bin/env bash

##########################################################################################################################
## CCS SCRIPT TO DO FINAL PREPROCESSING STEPS OF RESTING_STATE SCAN
##
## R-fMRI master: Xi-Nian Zuo.
## Email: zuoxn@psych.ac.cn or zuoxinian@gmail.com.
##########################################################################################################################

## subject
subject=$1
## analysisdirectory
dir=$2 ; SUBJECTS_DIR=${dir}
## resting-state filename (no extension)
rest=$3
## name of anatomical directory
anat_dir_name=$4
## name of func directory
func_dir_name=$5
## if refined anat registration with the study-specific symmetric template: remember to put your study-specific
## template in ${dir}/group/template/template_head.nii.gz
done_refine_reg=$6
## standard template
standard_template=$7
## standard surface
fsaverage=$8
## name of reg dir
reg_dir_name=$9

## parameter setup for preproc

## set your desired spatial smoothing FWHM - we use 6 (acquisition voxel size is 3x3x4mm)
FWHM=6 ; sigma=`echo "scale=10 ; ${FWHM}/2.3548" | bc`

if [ $# -lt 8 ];
then
        echo -e "\033[47;35m Usage: $0 subject analysis_dir rest_name anat_dir_name func_dir_name done_refine_reg standard_template (full path) fsaverage (only name) \033[0m"
        exit
fi

echo --------------------------------------------------------
echo !!!! RUNNING FINAL PREPROCESSING OF FUNCTIONAL DATA !!!!
echo --------------------------------------------------------

if [ $# -lt 9 ];
then
        reg_dir_name=reg
fi
## directory setup
func_dir=${dir}/${subject}/${func_dir_name}
func_reg_dir=${func_dir}/reg
anat_dir=${dir}/${subject}/${anat_dir_name}
anat_reg_dir=${anat_dir}/${reg_dir_name}
FC_dir=${func_dir}

if [ ! -f ${FC_dir}/${rest}_pp_nofilt_sm0.nii.gz ]
then
        ## 1.Detrending
        echo "Removing linear and quadratic trends for ${subject}"
        3dTstat -mean -prefix ${FC_dir}/${rest}_res_mean.nii.gz ${FC_dir}/${rest}_res.nii.gz
        3dDetrend -polort 2 -prefix ${FC_dir}/tmp_dt.nii.gz ${FC_dir}/${rest}_res.nii.gz
        3dcalc -a ${FC_dir}/${rest}_res_mean.nii.gz -b ${FC_dir}/tmp_dt.nii.gz -expr 'a+b' -prefix ${FC_dir}/${rest}_pp_nofilt_sm0.nii.gz
        rm -rv ${FC_dir}/tmp_dt.nii.gz
        ## 3. Spatial smoothing
        #volume
        mri_fwhm --i ${FC_dir}/${rest}_pp_nofilt_sm0.nii.gz --o ${FC_dir}/${rest}_pp_nofilt_sm${FWHM}.nii.gz --smooth-only --fwhm ${FWHM} --mask ${func_dir}/${rest}_pp_mask.nii.gz
        #surface
        SUBJECTS_DIR=${dir}
        if [ ! -d ${SUBJECTS_DIR}/${fsaverage} ]
        then
                ln -s ${FREESURFER_HOME}/subjects/${fsaverage} ${SUBJECTS_DIR}/${fsaverage}
        fi

        if [ -f ${func_reg_dir}/bbregister.dof6.dat ]
        then
                for hemi in lh rh
                do
                        mri_vol2surf --mov ${FC_dir}/${rest}_pp_nofilt_sm0.nii.gz --reg ${func_reg_dir}/bbregister.dof6.dat --trgsubject ${fsaverage} --interp trilin --projfrac 0.5 --hemi ${hemi} --o ${FC_dir}/${rest}.pp.nofilt.sm0.${fsaverage}.${hemi}.nii.gz --noreshape --cortex --surfreg sphere.reg
                        mris_fwhm --s ${fsaverage} --hemi ${hemi} --smooth-only --i ${FC_dir}/${rest}.pp.nofilt.sm0.${fsaverage}.${hemi}.nii.gz --fwhm ${FWHM} --o ${FC_dir}/${rest}.pp.nofilt.sm${FWHM}.${fsaverage}.${hemi}.nii.gz --mask ${func_dir}/mask/brain.${fsaverage}.${hemi}.nii.gz
                done
        else
                echo "Please first run bbregister for this subject!"
        fi
        #Volume REG
        echo Warpping 4D timeseries to MNI152 functional space
        for fwhm in sm0 sm6
        do
                if [ ${done_refine_reg} = 'true' ]
                then
                        applywarp --ref=${standard_template} --in=${FC_dir}/${rest}_pp_nofilt_${fwhm}.nii.gz --out=${FC_dir}/${rest}.nofilt.${fwhm}.mni152.nii.gz --warp=${anat_reg_dir}/highres2standard_ref_warp.nii.gz --premat=${func_reg_dir}/example_func2highres.mat
                else
                        applywarp --ref=${standard_template} --in=${FC_dir}/${rest}_pp_nofilt_${fwhm}.nii.gz --out=${FC_dir}/${rest}.nofilt.${fwhm}.mni152.nii.gz --warp=${anat_reg_dir}/highres2standard_warp.nii.gz --premat=${func_reg_dir}/example_func2highres.mat
                fi
        done
fi
