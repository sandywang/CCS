for hemi in lh rh
do
	echo "BA in ${hemi}"
	mri_surf2surf --srcsubject fsaverage --sval-annot /opt/freesurfer51/subjects/fsaverage/label/${hemi}.PALS_B12_Brodmann.annot --trgsubject fsaverage5 --hemi ${hemi} --tval fsaverage5/label/${hemi}.PALS_B12_Brodmann.annot
	mri_surf2surf --srcsubject fsaverage --sval-annot /opt/freesurfer51/subjects/fsaverage/label/${hemi}.PALS_B12_Visuotopic.annot --trgsubject fsaverage5 --hemi ${hemi} --tval fsaverage5/label/${hemi}.PALS_B12_Visuotopic.annot
	mri_surf2surf --srcsubject fsaverage --sval-annot /opt/freesurfer51/subjects/fsaverage/label/${hemi}.PALS_B12_Lobes.annot --trgsubject fsaverage5 --hemi ${hemi} --tval fsaverage5/label/${hemi}.PALS_B12_Lobes.annot
done
