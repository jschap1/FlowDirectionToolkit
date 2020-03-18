function [wrongdirrow, wrongdircol] = CheckIfWrongDir(fdir, fd_riv)

% Checks a flow direction map for cells flowing a different direction than
% the true river network would imply
%
% INPUTS
% Flow direction raster using VIC flow direction convention (1-8)
% river network shapefile
%
% OUTPUTS
% Row and column indices of the grid cells in disagreement with the true 
% river network

[nrow,ncol] = size(fdir);
wrongdirrow = NaN;
wrongdircol = NaN;

% Loop over cells with fd_riv values
[ind1, ind2] = find(~isnan(fd_riv));
cellinds = [ind1, ind2];
for c=cellinds'
    % compare fdir and fd_riv 
    i=c(1);
    j=c(2);
    if fdir(i,j) ~= fd_riv(i,j)
        wrongdirrow = [wrongdirrow, i];
        wrongdircol = [wrongdircol, j]; 
    end
end

% Remove initial NaN
wrongdirrow = wrongdirrow(2:end); 
wrongdircol = wrongdircol(2:end); 

return