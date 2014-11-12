for hemi in lh rh
do
	for nws in 7 17
	do
		echo "Network size: ${nws} in ${hemi}"
		mri_surf2surf --srcsubject fsaverage5 --sval-annot fsaverage5/${hemi}.Yeo2011_${nws}Networks_N1000.split_components.annot --trgsubject fsaverage6 --hemi ${hemi} --tval fsaverage6/${hemi}.Yeo2011_${nws}Networks_N1000.split_components.annot
	done
done
