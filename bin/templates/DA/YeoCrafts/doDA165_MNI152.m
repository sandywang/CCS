%% dir settings (may not usable for you and you have to change them...)
clear all; clc
work_dir = '/Volumes/RAID/projects/indi/NKI-RS/scripts';
ccs_bash_dir = [work_dir '/ccs_beta'];
ccs_matlab_dir = [ccs_bash_dir '/matlab'];
fs_home = '/opt/freesurfer51'; fsaverage = 'fsaverage';
%The path to matlab function in Freesurfer release
addpath([fs_home '/matlab']) ; addpath(ccs_matlab_dir)

%% Set up the surface grid space
fannot = [fs_home '/subjects/' fsaverage '/label/lh.aparc.a2009s.annot'];
[vertices_lh, label_lh, colortable_lh] = read_annotation(fannot);
fannot = [fs_home '/subjects/' fsaverage '/label/rh.aparc.a2009s.annot'];
[vertices_rh, label_rh, colortable_rh] = read_annotation(fannot);
clear fannot ; nVertices_rh = numel(vertices_rh); nVertices_lh = numel(vertices_lh);
nVertices = nVertices_lh + nVertices_rh;
Destrieux83ROI = importdata([ccs_matlab_dir '/etc/Destrieux2010.dat']); %1-74 cortical pacels; 75-81 subcortical parcels; 82 cerebelum; 83 brain stem
Destrieux165parcels = importdata([ccs_matlab_dir '/etc/parcels165.list']);
fsLUT = importdata([ccs_matlab_dir '/etc/FreeSurferColorLUT.part']);
LUTdat = fsLUT.textdata; LUTstr = LUTdat(:,2); 
numROI = numel(Destrieux83ROI); numPARCEL = numel(Destrieux165parcels);
DA_lh = zeros(nVertices_lh,1); DA_rh = zeros(nVertices_rh,1);
for k=1:74
    tmpName1 = Destrieux83ROI{k};
    for pp=1:76
        %lh
           tmpName2 = colortable_lh.struct_names{pp};
           if strcmp(tmpName1, tmpName2)
               idxParcel = find(label_lh==colortable_lh.table(pp,5));
               DA_lh(idxParcel) = k;
           end
           %rh
           tmpName2 = colortable_rh.struct_names{pp};
           if strcmp(tmpName1, tmpName2)
               idxParcel = find(label_rh==colortable_rh.table(pp,5));
               DA_rh(idxParcel) = k + 82;
           end
    end
end

%% Project to MNI152 256 iso1mm space
MNI_mask = [ccs_bash_dir '/templates/DA/YeoCrafts/MNI_cortex_estimate.150.nii.gz'];
index_volume = [ccs_bash_dir '/templates/DA/YeoCrafts/' ...
    '1000sub.FSL_MNI152.1mm.full_vertex_map.500.nii.gz'];
output = Projectfsaverage2MNI(DA_lh, DA_rh, MNI_mask, index_volume);
MRIwrite(output, 'MNI152.DA165.cortex.1mm.nii.gz');
