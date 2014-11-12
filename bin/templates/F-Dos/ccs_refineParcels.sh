for (( id=1; id < 161; id++ ))
do
	if [ ${id} -lt 10 ];
	then
		mv parcel${id}_2mm.nii.gz parcel00${id}_2mm.nii.gz
		mv parcel${id}_3mm.nii.gz parcel00${id}_3mm.nii.gz	
	else
		if [ ${id} -lt 100 ];
		then
			mv parcel${id}_2mm.nii.gz parcel0${id}_2mm.nii.gz
			mv parcel${id}_3mm.nii.gz parcel0${id}_3mm.nii.gz
		fi
	fi
	#mv fROIs_Dosenbach/fROI_Dosenbach2010_${id}.nii.gz parcel${id}_2mm.nii.gz
	#mv fROIs_Dosenbach/fROI_Dosenbach2010_3mm_${id}.nii.gz parcel${id}_3mm.nii.gz
done
