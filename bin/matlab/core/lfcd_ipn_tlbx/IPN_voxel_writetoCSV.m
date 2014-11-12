function IPN_voxel_writetoCSV(CIJ, fname, labels, coords, arcs)
%IPN_WRITETOGEXF         Write to Gephi format
%
%   IPN_writetoGEXF(CIJ, fname, labels, coords, arcs);
%
%   This function writes a Gephi .gexf file from a MATLAB matrix
%
%   Inputs:     CIJ,        adjacency matrix (diagnals are zeros)
%               fname,      filename minus .gexf extension
%               labels,     labels for nodes, cell
%               coords,     (X,Y) coordinates
%               arcs,       1 for directed network
%                           0 for an undirected network
%
%   Xi-Nian Zuo, New York University, 2010.
%   Xi-Nian Zuo, IPCAS, 2013.


N = size(CIJ,1); 
[i, j, val] = find(CIJ) ;
edge_list = [i, j, val];
Nedge = size(edge_list,1);

%% HEADER: nodes
fid = fopen(cat(2,fname,'_nodes.csv'), 'w');
hdl = 'Id Label X Y';
fprintf(fid, '%s\n', hdl);
for i = 1:N
    fprintf(fid, '%d %s %f %f \n', i, labels{i}, coords(i,1), coords(i,2));
end
fclose(fid);
%% HEADER: edges
fid = fopen(cat(2,fname,'_edges.csv'), 'w');
if ~arcs
    hdl = 'Source Target Type';    
    fprintf(fid, '%s\n', hdl);
    for k=1:Nedge
        fprintf(fid, '%d %d %s\n', edge_list(k,1), edge_list(k,2), 'Undirected');
    end
    fclose(fid);
else
    hdl = 'Source Target Weight Type';    
    fprintf(fid, '%s\n', hdl);
    for k=1:Nedge
        fprintf(fid, '%d %d %s\n', edge_list(k,1), edge_list(k,2), edge_list(k,3), 'Directed');
    end
    fclose(fid);
end