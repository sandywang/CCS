function err = ccs_06_singlesubjectDMRIparcels( ana_dir, sub_list, dti_dir_name, ccs_matlab_dir)
%LFCD_06_SINGLESUBJECTDMRIPARCELS Computing the 165 parcels for each subject.
%   ana_dir -- full path of the analysis directory
%   sub_list -- full path of the list of subjects
%   dti_dir_name -- the name of functional directory
%   ccs_matlab_dir -- the name of ccs matlab scripts directory (full path).
%
% Author: Xi-Nian Zuo at IPCAS, Dec., 08, 2012.

if nargin < 4
    disp('Usage: ccs_06_singlesubjectDMRIparcels( ana_dir, sub_list, dti_dir_name, ccs_matlab_dir)')
    exit
end
%% load basic information about the parcellation
Destrieux83ROI = importdata([ccs_matlab_dir '/etc/Destrieux2010.dat']); %1-74 cortical pacels; 75-81 subcortical parcels; 82 cerebelum; 83 brain stem
Destrieux165parcels = importdata([ccs_matlab_dir '/etc/parcels165.list']);
fsLUT = importdata([ccs_matlab_dir '/etc/FreeSurferColorLUT.part']);
LUTdat = fsLUT.textdata; LUTstr = LUTdat(:,2); 
numROI = numel(Destrieux83ROI); numPARCEL = numel(Destrieux165parcels);
%% SUBINFO
subs = importdata(sub_list); nsubs = numel(subs);
if ~iscell(subs)
    subs = num2cell(subs);
end
%% LOOP SUBJECTS
for sid=1:nsubs
    if isnumeric(subs{sid})
        disp(['Generate 165 parcels for ' num2str(subs{sid}) ' ...'])
        dti_dir = [ana_dir '/' num2str(subs{sid}) '/' dti_dir_name];
    else
        disp(['Generate 165 parcels for ' subs{sid} ' ...'])
        dti_dir = [ana_dir '/' subs{sid} '/' dti_dir_name];
    end
    mkdir([dti_dir '/segment'], '/parcels165')
    %aparc+aseg
    faparc_aseg = [dti_dir '/segment/aparc.a2009s+aseg2diff.nii.gz'];
    aparchdr = load_nifti(faparc_aseg); aparcvol = aparchdr.vol;
    %mask
    fmask = [dti_dir '/b0_brain_mask.nii.gz'];
    maskhdr = load_nifti(fmask); 
    maskvol = maskhdr.vol;
    for k=1:numROI
    	label = Destrieux83ROI{k};
        if k < 75
        	%left hemi
            tmp_id = ccs_strfind(LUTstr, ['ctx_lh_' label]);
            label_val = str2double(LUTdat(tmp_id, 1));
            tmpvol = zeros(size(maskvol));
            tmpvol(aparcvol==label_val) = 1;
            tmpvol = tmpvol.*maskvol;
            maskhdr.vol = tmpvol;
            if k < 10
            	fout = [dti_dir '/segment/parcels165/mask00' num2str(k) '_ctx_lh_' label '.nii.gz'];
            else
            	fout = [dti_dir '/segment/parcels165/mask0' num2str(k) '_ctx_lh_' label '.nii.gz'];
            end
            err = save_nifti(maskhdr, fout);
            %right hemi
            tmp_id = ccs_strfind(LUTstr, ['ctx_rh_' label]);
            label_val = str2double(LUTdat(tmp_id, 1));
            tmpvol = zeros(size(maskvol));
            tmpvol(aparcvol==label_val) = 1;
            tmpvol = tmpvol.*maskvol;
            maskhdr.vol = tmpvol;
            if k < 18
            	fout = [dti_dir '/segment/parcels165/mask0' num2str(k+82) '_ctx_rh_' label '.nii.gz'];
            else
            	fout = [dti_dir '/segment/parcels165/mask' num2str(k+82) '_ctx_rh_' label '.nii.gz'];
            end
            err = save_nifti(maskhdr, fout);
        else
        	if k < 83
                %left hemi
                tmp_id = ccs_strfind(LUTstr, ['Left-' label]);
                label_val = str2double(LUTdat(tmp_id, 1));
                tmpvol = zeros(size(maskvol));
                tmpvol(aparcvol==label_val) = 1;
                tmpvol = tmpvol.*maskvol;
                maskhdr.vol = tmpvol;
                fout = [dti_dir '/segment/parcels165/mask0' num2str(k) '_Left-' label '.nii.gz'];
                err = save_nifti(maskhdr, fout);
                %right hemi
                tmp_id = ccs_strfind(LUTstr, ['Right-' label]);
                label_val = str2double(LUTdat(tmp_id, 1));
                tmpvol = zeros(size(maskvol));
                tmpvol(aparcvol==label_val) = 1;
                tmpvol = tmpvol.*maskvol;
                maskhdr.vol = tmpvol;
                fout = [dti_dir '/segment/parcels165/mask' num2str(k+82) '_Right-' label '.nii.gz'];
                err = save_nifti(maskhdr, fout);
            else
            	% brain-stem
                tmp_id = ccs_strfind(LUTstr, label);
                label_val = str2double(LUTdat(tmp_id, 1));
                tmpvol = zeros(size(maskvol));
                tmpvol(aparcvol==label_val) = 1;
                tmpvol = tmpvol.*maskvol;
                maskhdr.vol = tmpvol;
                fout = [dti_dir '/segment/parcels165/mask' num2str(k+82) '_' label '.nii.gz'];
                err = save_nifti(maskhdr, fout);
            end
        end
    end
    %merge all parcels into a single parcellation file
    if isnumeric(subs{sid})
        disp(['Generate a single parcellation file for 165 parcels: ' num2str(subs{sid}) ' ...'])
    else
        disp(['Generate a single parcellation file for 165 parcels: ' subs{sid} ' ...'])
    end
    maskvol = maskvol.*0;
    for k=1:numPARCEL
    	fparcel = [dti_dir '/segment/parcels165/' Destrieux165parcels{k}];
        parcelhdr = load_nifti(fparcel);
        parcelvol = parcelhdr.vol;
        maskvol(parcelvol > 0) = k;
    end
    maskhdr.datatype = 4;
    maskhdr.vol = maskvol;
    fout = [dti_dir '/segment/parcels165.nii.gz'];
	err = save_nifti(maskhdr, fout);
end