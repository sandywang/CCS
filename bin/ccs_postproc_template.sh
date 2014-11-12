#!/usr/bin/env bash

##########################################################################################################################
## SCRIPT TO RUN GENERAL RESTING-STATE PREPROCESSING
##
## Written by the R-fMRI master: Xi-Nian Zuo.
## Email: zuoxn@psych.ac.cn.
## 
##########################################################################################################################

##########################################################################################################################
## PARAMETERS
###########################################################################################################################

## directory where scripts are located
scripts_dir=/lfcd_app/ccs
## full/path/to/site
analysisdirectory=/home/xinian/projects/trt
## full/path/to/site/subject_list
subject_list=${analysisdirectory}/scripts/subjects.list
## name of resting-state scan (no extension)
rest_name=rest
## anat_dir_name
anat_dir_name=anat
## func_dir_name
func_dir_name=func
## standard brain
standard_template=${scripts_dir}/templates/MNI152_T1_3mm_brain.nii.gz
##########################################################################################################################


##########################################################################################################################
##---START OF SCRIPT----------------------------------------------------------------------------------------------------##
##########################################################################################################################

## ALFF
TR=2.0
do_refine_reg=false
gs_removal=false
anat_reg_dir_name=reg
##
${scripts_dir}/ccs_06_singlesubjectALFF.sh ${analysisdirectory} ${subject_list} ${rest_name} ${TR} ${anat_dir_name} ${func_dir_name} ${do_refine_reg} ${standard_template} ${gs_removal} ${anat_reg_dir_name}

## ICA
numIC=20
anat_reg_dir_name=reg
###
${scripts_dir}/ccs_06_singlesubjectICA.sh ${analysisdirectory} ${subject_list} ${rest_name} ${anat_dir_name} ${func_dir_name} ${do_refine_reg} ${numIC} ${standard_template} ${anat_reg_dir_name}


## ReHo
do_refine_reg=false
gs_removal=false
anat_reg_dir_name=reg
###
${scripts_dir}/ccs_06_singlesubjectReHo.sh ${analysisdirectory} ${subject_list} ${rest_name} ${anat_dir_name} ${func_dir_name} ${do_refine_reg} ${standard_template} ${anat_reg_dir_name}

## RSFC
seed_list=${scripts_dir}/samples_script/dmn.list
gs_removal=true
anat_reg_dir_name=reg
###
${scripts_dir}/ccs_06_singlesubjectSFC.sh ${analysisdirectory} ${subject_list} ${rest_name} ${anat_dir_name} ${func_dir_name} ${do_refine_reg} ${seed_list} ${gs_removal} ${standard_template} ${anat_reg_dir_name}

## VMHC
use_spec_template=false
template_name=MNI152_T1_2mm
gs_removal=true
anat_reg_dir_name=reg
###
${scripts_dir}/ccs_06_singlesubjectVMHC.sh ${analysisdirectory} ${subject_list} ${rest_name} ${anat_dir_name} ${func_dir_name} ${use_spec_template} ${template_name} ${gs_removal} ${scripts_dir} ${anat_reg_dir_name}
##
gs_removal=true
seed_vmhc_list=${scripts_dir}/samples_script/vmhc.list
${scripts_dir}/ccs_06_singlesubjectVMHC-SFC.sh ${analysisdirectory} ${subject_list} ${rest_name} ${anat_dir_name} ${func_dir_name} ${seed_vmhc_list} ${gs_removal} ${standard_template} ${anat_reg_dir_name}

