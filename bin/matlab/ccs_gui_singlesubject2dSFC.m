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

%% RSFC
% NEED TO RUN ccs_06_singlesubjectRFMRIparcels FIRST
list_file=getenv('SurFC_ListFile')
fp=fopen(list_file, 'r');
M=textscan(fp, '%s');
lines=M{1};
fclose(fp);
seeds_name=cell(size(lines));
seeds_hemi=cell(size(lines));
for i=1:numel(lines)
    line=lines{i};
    tokens=regexp(line, '^(.*), *(.*)$', 'tokens');
    list=tokens{1};
    seeds_name{i, 1}=list{1, 1};
    seeds_hemi{i, 1}=list{1, 2};
end

err = ccs_06_singlesubject2dSFC( ana_dir, subs_list, rest_name, func_dir_name, ...
        seeds_name, seeds_hemi, fs_home, fsaverage);
