function potential_outlet = find_potential_outlet(r,c,f,facc_fine, flowacc_rank)

[nf, mf] = size(facc_fine);

gridcell = zeros(f,f); % flow acc values on the edges of the the coarse pixel

% top
rr = (r-1)*f+1;
cc = (c-1)*f+1:c*f;
gridcell(1,:) = facc_fine(rr,cc);

% bottom
rr = r*f;
cc = (c-1)*f+1:c*f;
gridcell(end,:) = facc_fine(rr,cc);

% right
rr = (r-1)*f+1:r*f;
cc = c*f;
gridcell(:,end) = facc_fine(rr,cc);

% left
rr = (r-1)*f+1:r*f;
cc = (c-1)*f+1;
gridcell(:,1) = facc_fine(rr,cc);

% [~, loc] = max(gridcell(:));

[vals, loc] = sort(gridcell(:));

% Check if cell is out of bounds. If so, move on to next grid cell.

% Otherwise, we have found the location of the outlet pixel within the grid cell
% this is the potential outlet pixel for the coarse grid cell

if sum(isnan(gridcell))>=numel(gridcell)/2

    potential_outlet = NaN;
    
else
    
    % linear index of the fine pixel that is the potential outlet for the
    % grid cell
    
    % if the cell with the maximum value was not found to be appropriate, 
    % we can use flowacc_rank to choose the pixel with the next highest flow 
    % accumulation value

    [loc_r, loc_c] = ind2sub([f,f], loc(flowacc_rank)); % local row and column

    % convert from local loc to fine pixel index out of the whole fine grid
    glob_r = (r-1)*f + loc_r;
    glob_c = (c-1)*f + loc_c;
    
    potential_outlet = sub2ind([nf, mf], glob_r, glob_c);
    
end

return