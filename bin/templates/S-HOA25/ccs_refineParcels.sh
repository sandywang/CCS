for (( id=1; id < 49; id++ ))
do
	if [ ${id} -lt 10 ]; 
	then
		mv lh_cort_${id}_2mm.nii.gz lh_cort_0${id}_2mm.nii.gz
		mv lh_cort_${id}_3mm.nii.gz lh_cort_0${id}_3mm.nii.gz
		mv rh_cort_${id}_2mm.nii.gz rh_cort_0${id}_2mm.nii.gz
		mv rh_cort_${id}_3mm.nii.gz rh_cort_0${id}_3mm.nii.gz
	fi
	#mv probParcUnits/left_prob_cortical_${id}.nii.gz lh_cort_${id}_2mm.nii.gz
	#mv probParcUnits/right_prob_cortical_${id}.nii.gz rh_cort_${id}_2mm.nii.gz
	#mv probParcUnits/left_prob_cortical_${id}_3mm.nii.gz lh_cort_${id}_3mm.nii.gz
	#mv probParcUnits/right_prob_cortical_${id}_3mm.nii.gz rh_cort_${id}_3mm.nii.gz
	
done
#for id in 10 11 12 13 16 17 18 26 
#do
#	mv probParcUnits/left_prob_subcortical_${id}.nii.gz lh_subcort_${id}_2mm.nii.gz
#        mv probParcUnits/left_prob_subcortical_${id}_3mm.nii.gz lh_subcort_${id}_3mm.nii.gz
#done
#for id in 16 49 50 51 52 53 54 58
#do
#	mv probParcUnits/right_prob_subcortical_${id}.nii.gz rh_subcort_${id}_2mm.nii.gz
#        mv probParcUnits/right_prob_subcortical_${id}_3mm.nii.gz rh_subcort_${id}_3mm.nii.gz
#done
