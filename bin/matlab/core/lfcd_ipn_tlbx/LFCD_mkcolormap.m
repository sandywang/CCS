%% Generate a colormap from a image including the colorbar (e.g., from a
%% paper) for AFNI visualization.
function [cmap_out, cmap] = LFCD_mkcolormap(fIMAGE, nseg)
% fIMAGE - A colorbar image from published papers or other softwares.
% nseg - number of color segments (default 0)
% Three steps to go:
%   1). dlmwrite('figure/cmap_heritp.txt',cmap_her4,' ')
%   2). MakeColorMap -f cmap_heritp.txt -nc 256 -ah cmap_heritp > cmap_heritp.pal
%   3). Modify the head line in cmap_heritp.pal to "cmap_heritp:red_to_blue"
% Xi-Nian Zuo: NYU Child Study Center/IPCAS LFCD.
if nargin < 2 ; nseg = 0; end
cmap_img = imread(fIMAGE);
[nr, nc] = size(cmap_img);
if nc > nr % A horizonal colorbar
    nr_rs = round(nr*256/nc);
    cmap_rs = imresize(cmap_img,[nr_rs 256]);
    cmap = squeeze(cmap_rs(round(nr_rs/2),:,:));
else       % A veritical colorbar
    nc_rs = round(nc*256/nr);
    cmap_rs = imresize(cmap_img,[256 nc_rs]);
    cmap = squeeze(cmap_rs(:,round(nc_rs/2),:));
    cmap = cmap(end:-1:1,:);
end
cmap = double(cmap)/256;
if nseg > 0
    cmap_out = zeros(nseg, 3);
    step = fix(256/nseg);
    for k = 1:nseg
        cmap_out(k,:) = cmap(round(0.5*(2*k-1)*step), :);
    end
else
    cmap_out = cmap;
end