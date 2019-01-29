function [fdir, wrongdirrow, wrongdircol] = CorrectIfWrongDir(fdir, fd_riv)

% Checks a flow direction map for cells flowing a different direction than
% the true river network would imply and updates the flow direction.
% 
% Similar in concept to CheckIfWrongDir, with a step at the end
% to make the corrections.
%
% INPUTS
% Flow direction raster using VIC flow direction convention (1-8)
% river network shapefile
%
% OUTPUTS
% Corrected flow direction raster
% Row and column indices of corrected grid cells

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
        
        % make the correction only if the change does not create a loop
        fdir_copy = fdir;
        fdir_copy(i,j) = fd_riv(i,j);
        [looprow, ~] = CheckForTrivialLoops(fdir_copy);
        if isempty(looprow)
            fdir(i,j) = fd_riv(i,j);
        end
                
        wrongdirrow = [wrongdirrow, i];
        wrongdircol = [wrongdircol, j]; 
        
    end
end

% Remove initial NaN
wrongdirrow = wrongdirrow(2:end); 
wrongdircol = wrongdircol(2:end); 

return
