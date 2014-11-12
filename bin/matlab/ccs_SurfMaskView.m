function [numvertex]=ccs_SurfMaskView(grpmask_dir, gmask_prefix, fs_home, fsaverage)
% LFCD_07_GROUPSURFMASK Computing the masks on the surface for group-level analyses.
%   grpmask_dir -- full path of the group mask directory 
%   gmask_prefix -- the prefix of mask name
%   fs_home -- freesurfer home directory
%   fsaverage -- the fsaverage file name
%
% Author: Xi-Nian Zuo at IPCAS, Dec., 17, 2011.
% Ting Xu updated, Jul. 15, 2014

if nargin < 4
    disp('Usage: ccs_SurfMaskView(grpmask_dir, gmask_prefix, fs_home, fsaverage )')
    exit
end
s = SurfStatReadSurf( {... 
    [fs_home '/subjects/' fsaverage '/surf/lh.inflated'], ...
    [fs_home '/subjects/' fsaverage '/surf/rh.inflated']} );
%
hdr = load_nifti([grpmask_dir '/lh.' gmask_prefix '.' fsaverage '.nii.gz']);
lh_gmask = squeeze(hdr.vol);
hdr = load_nifti([grpmask_dir '/rh.' gmask_prefix '.' fsaverage '.nii.gz']);
rh_gmask = squeeze(hdr.vol);
gmask = [lh_gmask; rh_gmask];
figure('Units', 'pixels', 'Position', [100 100 800 800]); axis off
SurfStatView(gmask, s, 'FCONN Masks');
colormap([[0.5 0.5 0.5]; [1 0 0]]) ; SurfStatColLim( [0 1.5] );
set(gcf, 'PaperPositionMode', 'auto');
print('-djpeg', '-r300', [grpmask_dir '/figures.inflated.' gmask_prefix '.' fsaverage '.jpg']);
close;
numvertex = nnz(gmask);
