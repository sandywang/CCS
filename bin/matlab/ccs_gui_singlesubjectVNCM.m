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

%% Volume
% compute dc, sc, ec, pc
cent_str = getenv('VolVNCM_State');
cent_idx = str2num(cent_str);
% the thresholds of p-value
p_str = getenv('VolVNCM_P');
p_thr = str2num(p_str);
% the full path of group volume mask
maskfname = [ana_dir '/group/masks/mask_group_bold.nii.gz'];
% the full path of the gray matter template (probability )
gmfname = [ccs_dir '/templates/MNI152_T1_3mm_grey.nii.gz'];
% the threshold of gray matter
gm_thr = 0.20;

ccs_06_singlesubjectVNCM( ana_dir, subs_list, rest_name, func_dir_name, ...
        cent_idx, maskfname, p_thr, gmfname, gm_thr );
