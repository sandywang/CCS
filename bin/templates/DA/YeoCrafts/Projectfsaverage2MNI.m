% Usage: output = Projectfsaverage2MNI(lh_surf, rh_surf, MNI_mask, index_volume, delimiter)
%
% Function projects surface data to the volume
% Also see reverse transform ProjectMNI2fsaverage2
% 
% 
% ------------------------------------------------------------
% EXAMPLE USAGE: Project cortical gyral labels to MNI template
% ------------------------------------------------------------
% >> lh_avg_mesh = ReadNCAvgMesh('lh', 'fsaverage', 'inflated', 'aparc.annot');
% >> rh_avg_mesh = ReadNCAvgMesh('rh', 'fsaverage', 'inflated', 'aparc.annot');
% >> output = Projectfsaverage2MNI(lh_avg_mesh.MARS_label', rh_avg_mesh.MARS_label');
% >> MRIwrite(output, 'test.nii.gz');
% 
%
% -----------
% DEFINITIONS
% -----------
% lh_surf      = data matrix from left hemi : num_vertices x data_dimension
% rh_surf      = data matrix from right hemi: num_vertices x data_dimension   
% output_file  = volumetric output filename
% MNI_mask     = filename of binary mask in MNI space 
%                (default = $CODE_DIR/extras/surf2surf_gui_data/CorrespondenceFreeSurferVolSurfSpace/coord_vol2surf/MNI_cortex_estimate.150.nii.gz)
%                If set to 'NONE' means do not specify a mask 
% index_volume = filename of volume that specifies for each voxel in volumetric space, corresponding vertex number in surface space. 
%                Positive indices correspond to left hemi vertices. Negative indices correspond to right hemi vertices. 
%                e.g., value of 23 corresponds to vertex 23 on left hemi. value of -23 corresponds to vertex 23 of right hemi.
%                (default = $CODE_DIR/extras/surf2surf_gui_data/CorrespondenceFreeSurferVolSurfSpace/coord_vol2surf/1000sub.FSL_MNI152.1mm.full_vertex_map.500.nii.gz')
% delimiter    = values outside MNI mask is set to delimiter value (default = 0)
% 
% The default MNI_mask and index_volume corresponds to MNI template 
% $CODE_DIR/templates/volume/FSL_MNI152_FS4.5.0/mri/norm.nii.gz, which is 
% the FSL MNI 1mm template "freesurfer conformed" to 256 x 256 x 256 resolution.
%
%
% ------------------------
% CREATION OF INDEX_VOLUME
% ------------------------
% The default index_volume is computed by running 1000 subjects and FSL MNI152 template through recon-all. 
% Warps between fsaverage <-> each subject native anatomical space <->
% freesurfer nonlinear volumetric space <-> MNI152 template are then
% averaged across 1000 subjects. Since only cortical voxels have valid surface correspondence, 
% we also keep track of the number of subjects, whose cortical surface maps to a single voxel.
% For voxels which are mapped onto by less than 500 subjects, we assign them a cortical membership based on the closest voxel which does. 
%
%
% ------------------------
% CREATION OF MNI MASK
% ------------------------
% The default MNI_mask is a loose cortical mask. Running the MNI template through the recon-all pipeline 
% gives a cortex.nii.gz mask which severe underestimates cortical voxels. We produce MNI_cortex_estimate.150.nii.gz as follows
% 
%   1) Create intermediate MNI cortical mask, where a voxel is considered a cortical voxel if the cortex 
%      of at least 150 subjects maps to the voxel OR if recon-all of MNI template decides the voxel is a
%      cortical voxel. 
% 
%   2) Smooth intermediate mask: my_smooth3(double(mask), 'box', 5)
%
%   3) Threshold at 0.5
% 
%   4) Use aparc+aseg of MNI template to mask out voxels that are for sure non cortex, i.e, 
%        aparc_aseg = MRIread('$CODE_DIR/templates/volume/FSL_MNI152_FS/mri/aparc+aseg.mgz');
%        aparc_aseg = ((aparc_aseg.vol < 1000) & (aparc_aseg.vol > 0) & (aparc_aseg.vol ~= 41) & (aparc_aseg.vol ~= 2));
%        mask(aparc_aseg) = 0;
% 
%   5) Fill holes: imfill(mask, 'holes')
%
%   6) Remove islands using bwlabeln and removing islands less than 100
%
%   7) Visual inspection to see if it looks ok --> MNI_cortex_estimate.150.nii.gz
%
% ----------
% References
% ----------
%     1) Yeo BTT, Krienen FM, Sepulcre J, Sabuncu MR, Lashkari L, Hollinshead M, Roffman JL, Smoller JW, Zöllei L, Polimeni JM, Fischl B, Liu H, Buckner RL. 
%        The organization of the human cerebral cortex revealed by intrinsic functional connectivity. 
%        J Neurophysiology, 106(3):1125?1165, 2011
%
%     2) Buckner RL, Krienen FM, Castellanos A, Diaz JC, Yeo BTT. 
%        The organization of the human cerebellum revealed by intrinsic functional connectivity. 
%        J Neurophysiology, 106(5):2322-2345, 2011
% 
%     3) Choi EY, Yeo BTT, Buckner RL.
%        The organization of the human striatum revealed by intrinsic functional connectivity. 
%        J Neurophysiology, 108(8):2242-2263, 2012 

%=========================================================================
%
%  Copyright (c) 2013 Thomas Yeo
%  All rights reserved.
%
%Redistribution and use in source and binary forms, with or without
%modification, are permitted provided that the following conditions are met:
%
%    * Redistributions of source code must retain the above copyright notice,
%      this list of conditions and the following disclaimer.
%
%    * Redistributions in binary form must reproduce the above copyright notice,
%      this list of conditions and the following disclaimer in the documentation
%      and/or other materials provided with the distribution.
%
%    * Neither the names of the copyright holders nor the names of future
%      contributors may be used to endorse or promote products derived from this
%      software without specific prior written permission.
%
%THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
%ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
%WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
%DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
%ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
%(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
%LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
%ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
%(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
%SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.    
%
%=========================================================================

function output = Projectfsaverage2MNI(lh_surf, rh_surf, MNI_mask, index_volume, delimiter)

if(nargin < 3)
    % loose mask
    MNI_mask = fullfile(getenv('CODE_DIR'), 'extras/surf2surf_gui_data/CorrespondenceFreeSurferVolSurfSpace/coord_vol2surf/', 'MNI_cortex_estimate.150.nii.gz');
end

if(nargin < 4)
    index_volume = fullfile(getenv('CODE_DIR'), 'extras/surf2surf_gui_data/CorrespondenceFreeSurferVolSurfSpace/coord_vol2surf/', '1000sub.FSL_MNI152.1mm.full_vertex_map.500.nii.gz');
end

if(nargin < 5)
    delimiter = 0;
else
    if(ischar(delimiter))
        delimiter = str2num(delimiter);
    end
end

% read index volume
index = MRIread(index_volume);
pos_index = find(index.vol > 0);
neg_index = find(index.vol < 0);

% Check index volume
if(sum(index.vol == 0) > 0)
   error('There are index with 0 values'); 
end

if((max(abs(index.vol(:))) > size(lh_surf, 1)) || (max(abs(index.vol(:))) > size(rh_surf, 1)))
    error('Index volume is indexing into surface that is higher resolution than surface data');
end

% read mask
if(~strcmp(MNI_mask, 'NONE'))
    mask = MRIread(MNI_mask);
    
    if((size(mask.vol, 1) ~= size(index.vol, 1)) || (size(mask.vol, 2) ~= size(index.vol, 2)) || (size(mask.vol, 3) ~= size(index.vol, 3))) 
       error('mask not the same size as index volume'); 
    end
    
    if(max(abs(mask.vox2ras(:) - index.vox2ras(:))) > 1e-5)
       warning('mask and index volume has different header information. Are you sure they are in the same space?');
    end
end

% Perform projection
output = index;
output.vol = zeros([size(index.vol) size(lh_surf, 2)]);
dummy = zeros(size(index.vol));
for i = 1:size(lh_surf, 2)
    dummy(pos_index) = lh_surf(index.vol(pos_index), i);
    dummy(neg_index) = rh_surf(abs(index.vol(neg_index)), i);
    
    if(~strcmp(MNI_mask, 'NONE'))
        dummy(mask.vol == 0) = delimiter;
    end
    output.vol(:, :, :, i) = dummy;
end







