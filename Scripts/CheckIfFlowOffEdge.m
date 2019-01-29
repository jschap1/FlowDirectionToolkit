function [edgerow, edgecol] = CheckIfFlowOffEdge(f);

% Checks a flow direction map for cells that flow off the edge
%
% INPUTS
% Flow direction raster using VIC flow direction convention (1-8)
%
% OUTPUTS
% Row and column indices of the flowing-off-edge grid cells

[nrow,ncol] = size(f);
edgerow = NaN;
edgecol = NaN;

% Checks each cell, determines if it is an edge cell, determines if it is
% flowing off the edge.

% Check for cells flowing into NaN cells
for i=2:(nrow-1)
    for j=2:(ncol-1)
        
        if isnan(f(i,j+1)) && f(i,j)==3 % E
            edgerow = [edgerow, i];
            edgecol = [edgecol, j];
        elseif isnan(f(i+1,j+1)) && f(i,j)==4 % SE
            edgerow = [edgerow, i];
            edgecol = [edgecol, j];            
        elseif isnan(f(i+1,j)) && f(i,j)==5 % S
            edgerow = [edgerow, i];
            edgecol = [edgecol, j];            
        elseif isnan(f(i+1,j-1)) && f(i,j)==6 % SW
            edgerow = [edgerow, i];
            edgecol = [edgecol, j];            
        elseif isnan(f(i,j-1)) && f(i,j)==7 % W
            edgerow = [edgerow, i];
            edgecol = [edgecol, j];            
        elseif isnan(f(i-1,j-1)) && f(i,j)==8 % NW
            edgerow = [edgerow, i];
            edgecol = [edgecol, j];            
        elseif isnan(f(i-1,j)) && f(i,j)==1 % N
            edgerow = [edgerow, i];
            edgecol = [edgecol, j];            
        elseif isnan(f(i-1,j+1)) && f(i,j)==2 % NE
            edgerow = [edgerow, i];
            edgecol = [edgecol, j]; 
        end
        
    end
end

% Check edges (i=1 & nrow, j=1 & ncol)
for i=[1,nrow];
    for j=1:ncol
            if i==1 && (f(i,j)==1 || f(i,j)==2 || f(i,j)==8)
                edgerow = [edgerow, i];
                edgecol = [edgecol, j];             
            elseif i==nrow && (f(i,j)==6 || f(i,j)==5 || f(i,j)==4)
                edgerow = [edgerow, i];
                edgecol = [edgecol, j];  
            end
    end
end

for j=[1, ncol]
    for i=1:nrow
            if j==1 && (f(i,j)==6 || f(i,j)==7 || f(i,j)==8)
                edgerow = [edgerow, i];
                edgecol = [edgecol, j];             
            elseif j==ncol && (f(i,j)==2 || f(i,j)==3 || f(i,j)==4)
                edgerow = [edgerow, i];
                edgecol = [edgecol, j];             
            end
    end
end

% Remove initial NaN
edgerow = edgerow(2:end); 
edgecol = edgecol(2:end); 

return