#!/usr/bin/env bash
in_path=$1
out_path=$2

oldpwd=$( pwd )
cd ${in_path}

for subj in `ls -d */`
do
    out_subpath=${out_path}/${subj}anat
    mkdir -p ${out_subpath}
    fslmerge -t ${out_subpath}/mprage.nii.gz ${subj}/co*.img
done
