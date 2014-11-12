clear all; clc ;
% ccs directory
ccs_dir = getenv('ScriptDir');
% analysis directory
ana_dir = getenv('ADir');
% subjects list
subs_list = getenv('SubjList');
% func dir name
func_dir_name = getenv('FuncDir');
% func rest name
rest_name = getenv('FuncName');
% group mask prefix
gmask_prefix = 'group_surface';
% freesurfer directory path
fs_home = getenv('FREESURFER_HOME');
% surface template
fsaverage = getenv('StandardSurface');
%%
grpmask_dir = [ana_dir '/group/masks'];
grptemplate_dir = [ana_dir '/group/templates'];
%% Adding paths to matlab
ccs_matlab = [ccs_dir '/matlab'];
addpath(genpath(ccs_matlab)) %ccs matlab scripts
addpath(genpath([fs_home '/matlab'])) %freesurfer matlab scripts

%% Generating surface masks
gmask = ccs_07_grp_SurfMask( ana_dir, subs_list, func_dir_name, grpmask_dir, ...
    gmask_prefix, fs_home, fsaverage );
numvertex = ccs_SurfMaskView(grpmask_dir, gmask_prefix, fs_home, fsaverage);

%% ALFF
TR = 2.5;
err = ccs_06_singlesubject2dALFF(ana_dir, subs_list, rest_name, TR, ...
        func_dir_name, fs_home, fsaverage);

%% ReHo
fs_vertex_adj = [ccs_matlab '/core/lfcd_ipn_tlbx/mat/' fsaverage '_adj.mat'];
%ReHo1
err = ccs_06_singlesubject2dReHo(ana_dir, subs_list, rest_name, ...
    func_dir_name, fsaverage, fs_vertex_adj, 1);
%ReHo2
err = ccs_06_singlesubject2dReHo(ana_dir, subs_list, rest_name, ...
    func_dir_name, fsaverage, fs_vertex_adj, 2);

%% GRAPH
gs_removal = 'false';
grp_mask_lh = [ana_dir '/group/masks/lh.' gmask_prefix '.' fsaverage '.nii.gz'];
grp_mask_rh = [ana_dir '/group/masks/rh.' gmask_prefix '.' fsaverage '.nii.gz'];
%
fgmask_surf ={grp_mask_lh, grp_mask_rh};

err = ccs_06_singlesubjectRFMRIparcels(ana_dir, subs1_list, func_dir_name, ...
    rest_name, ccs_dir, gs_removal, fsaverage, fgmask_surf);

%% RSFC
% NEED TO RUN ccs_06_singlesubjectRFMRIparcels FIRST
seeds_name = {'G_cingul-Post-dorsal'}; 
seeds_hemi = {'lh'};
err = ccs_06_singlesubject2dSFC( ana_dir, subs_list, rest_name, func_dir_name, ...
        seeds_name, seeds_hemi, fs_home, fsaverage);

%% Surface VNCM
% compute dc, sc, ec, pc
cent_idx = [1 0 1 0]; 
% the thresholds of p-value
p_thr = [0.001];
% group mask
grp_mask_lh = [ana_dir '/group/masks/lh.' gmask_prefix '.' fsaverage '.nii.gz'];
grp_mask_rh = [ana_dir '/group/masks/rh.' gmask_prefix '.' fsaverage '.nii.gz'];

err = ccs_06_singlesubject2dVNCM(ana_dir, subs_list, rest_name, func_dir_name, ...
        cent_idx, fs_home, fsaverage, p_thr, grp_mask_lh, grp_mask_rh, 'false');
    
%% Volume
% compute dc, sc, ec, pc
cent_idx = [1 0 1 0]; 
% the thresholds of p-value
p_thr = [0.001];
% the full path of group volume mask
maskfname = [ana_dir '/group/masks/mask_4mm.nii.gz'];
% the full path of the gray matter template (probability )
gmfname = [ccs_dir '/templates/MNI152_T1_4mm_grey.nii.gz'];
% the threshold of gray matter
gm_thr = 0.20;

ccs_06_singlesubjectVNCM( ana_dir, sub_list, rest_name, func_dir_name, ...
        cent_idx, maskfname, p_thr, gmfname, gm_thr );
