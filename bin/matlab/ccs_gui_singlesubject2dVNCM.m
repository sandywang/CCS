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

%% Surface VNCM
% compute dc, sc, ec, pc
cent_str = getenv('SurVNCM_State');
cent_idx = str2num(cent_str);
% the thresholds of p-value
p_str = getenv('SurVNCM_P');
p_thr = str2num(p_str);
% group mask
grp_mask_lh = [ana_dir '/group/masks/lh.' gmask_prefix '.' fsaverage '.nii.gz'];
grp_mask_rh = [ana_dir '/group/masks/rh.' gmask_prefix '.' fsaverage '.nii.gz'];

err = ccs_06_singlesubject2dVNCM(ana_dir, subs_list, rest_name, func_dir_name, ...
        cent_idx, fs_home, fsaverage, p_thr, grp_mask_lh, grp_mask_rh, 'false');
