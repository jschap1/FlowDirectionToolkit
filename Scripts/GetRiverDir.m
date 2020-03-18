function fd = GetRiverDir(fdir, R, rivs, res, projflag)

% Gets the 'true' flow direction of cells with river passing through them. 
% Calculation of angle theta assumes river vectors are listed in downstream direction. 
% Otherwise, need to flip the river vectors.
%
% Can take a few seconds to a few minutes for larger domains
%
% INPUTS
% Flow direction raster using VIC flow direction convention (1-8)
% river network shapefile
% res = resolution
%
% OUTPUTS
% fd = array with the flow direction value obtained from the
% river dataset where available, and NaN elsewhere

numsegs = length(rivs);
[nrow, ncol] = size(fdir);

% Check that rivers are in downstream order
% If nec., flip river segments so they are listed in downstream direction
% for j=1:numsegs
%     % flip them
% end

% Check that rivers are listed from longest to shortest
total_length = NaN(numsegs,1);
old_length = 1e12;
in_order = 1;
for j=1:numsegs
    x = rivs(j).X(1:end-1);
    y = rivs(j).Y(1:end-1);
    d = diff([x(:) y(:)]);
    total_length(j) = sum(sqrt(sum(d.*d,2)));
    if total_length(j)>old_length && in_order==1
        in_order = 0;
    end
    old_length = total_length(j);
end
% If they are not, put them in order
if in_order == 0
    disp('rivers are not listed from longest to shortest. Sorting.');
    [~,order]=sort(total_length,'descend');
    rivs_copy = rivs;
    for j=1:numsegs
        rivs(j).X = rivs_copy(order(j)).X;
        rivs(j).Y = rivs_copy(order(j)).Y;
    end
end

theta = NaN(nrow, ncol);

% Do for each segment of the river file
for j=1:numsegs

% Remove NaNs
rivs(j).X = rivs(j).X(1:end-1);
rivs(j).Y = rivs(j).Y(1:end-1);
    
numintervals = length(rivs(j).X)-1;

for k=1:numintervals
	points_in_cell = [rivs(j).X(k), rivs(j).Y(k)];
	[row, col] = GetIndices(fdir, R, points_in_cell, res, projflag);
	r=row; c=col; ind = 1;
	while ((row==r && col==c) && (k+ind)<=length(rivs(j).Y))
		next_point = [rivs(j).X(k+ind), rivs(j).Y(k+ind)];
		[row, col] = GetIndices(fdir, R, next_point, res, projflag);
		if (row==r && col==c)
			points_in_cell = [next_point; points_in_cell];
		end
		ind = ind + 1;
	end
	if size(points_in_cell, 1) > 2 && isnan(theta(r,c))
		u = points_in_cell(1,1) - points_in_cell(end,1);
		v = points_in_cell(1,2) - points_in_cell(end,2);
		theta(r, c) = atan2(v,u)*180/pi;
	elseif size(points_in_cell, 1) < 2
		
		firstpoint = points_in_cell;
		lastpoint = [rivs(j).X(k+1), rivs(j).Y(k+1)];
		% Get length of interval
		len = sqrt((lastpoint(2) - firstpoint(2))^2 + (lastpoint(1) - firstpoint(1))^2);
		% Divide into enough intervals to have two points in every cell the river passes through
		n_split = 2*ceil(2*len/res);
        
		% Replace the river segment with the new river segment that has at least two points in each cell
        if firstpoint(1) ~= lastpoint(1)
            x = linspace(firstpoint(1), lastpoint(1), n_split);
            y = firstpoint(2) + (lastpoint(2) - firstpoint(2)).*(x - firstpoint(1))./(lastpoint(1) - firstpoint(1));
        else % special case if the first and last points have the same x location
            y = linspace(firstpoint(2), lastpoint(2), n_split);
            x = firstpoint(1) + (lastpoint(1) - firstpoint(1)).*(y - firstpoint(2))./(lastpoint(2) - firstpoint(2));
        end
        
		for p = 1:(length(x)-1)
			[row, col] = GetIndices(fdir, R, [x(p) y(p)], res, projflag);
            [nextrow, nextcol] = GetIndices(fdir, R, [x(p+1) y(p+1)], res, projflag);
            if (row==nextrow && col==nextcol) && isnan(theta(row,col))
                u = x(p+1) - x(p);
                v = y(p+1) - y(p);
                theta(row, col) = atan2(v,u)*180/pi;
            end
		end
		
	elseif  size(points_in_cell, 1) == 2 && isnan(theta(r,c))
		u = rivs(j).X(k+1) - rivs(j).X(k);
		v = rivs(j).Y(k+1) - rivs(j).Y(k);
		theta(r, c) = atan2(v,u)*180/pi; % units of degrees
	end
	
end

end

% Assign flow directions using VIC modeling numbering convention
fd = NaN(size(theta));
fd(theta >= 112.5 & theta <157.5) = 8;
fd(theta >= 157.5 | theta <= -157.5) = 7;
fd(theta <= -112.5 & theta > -157.5) = 6;
fd(theta <= -67.5 & theta > -112.5) = 5;
fd(theta <= -22.5 & theta > -67.5) = 4;
fd(theta <= 22.5 & theta > -22.5) = 3;
fd(theta < 67.5 & theta >= 22.5) = 2;
fd(theta >= 67.5 & theta <112.5) = 1;
	
return