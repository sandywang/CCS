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
addpath(genpath(ccs_matlab)); %ccs matlab scripts
addpath(genpath([fs_home '/matlab'])); %freesurfer matlab scripts

%% Generating surface masks
gmask = ccs_07_grp_SurfMask( ana_dir, subs_list, func_dir_name, grpmask_dir, ...
    gmask_prefix, fs_home, fsaverage );
numvertex = ccs_SurfMaskView(grpmask_dir, gmask_prefix, fs_home, fsaverage);

