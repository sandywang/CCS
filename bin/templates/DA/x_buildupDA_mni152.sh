mkdir -p volumes_mni152
k=1
fslmaths /opt/fsl/data/standard/MNI152_T1_1mm.nii.gz -mul 0 MNI152_DA165_1mm.nii.gz
for parcel in `cat /Volumes/RAID/projects/indi/NKI-RS/scripts/ccs_beta/matlab/etc/Destrieux2010_aparc.dat`
do
	echo ${parcel}
	for hemi in lh rh
	do
		mri_label2vol --label labels/${hemi}.${parcel}.label --temp /opt/freesurfer51/subjects/fsaverage/mri/brainmask.mgz --subject fsaverage --hemi ${hemi} --proj frac 0 1 0.01 --identity --o volumes/${hemi}.${parcel}.nii.gz
		3dresample -master /opt/fsl/data/standard/MNI152_T1_1mm.nii.gz -inset volumes/${hemi}.${parcel}.nii.gz -rmode NN -prefix volumes_mni152/${hemi}.${parcel}.nii.gz	
	done
	fslmaths volumes_mni152/lh.${parcel}.nii.gz -mul ${k} -add MNI152_DA165_1mm.nii.gz MNI152_DA165_1mm.nii.gz 
	let p=k+74 ; echo $p
	fslmaths volumes_mni152/rh.${parcel}.nii.gz -mul ${p} -add MNI152_DA165_1mm.nii.gz MNI152_DA165_1mm.nii.gz
	let k=k+1 ; echo $k
done
