% Delineate watershed from flow directions and check for loops
%
% INPUTS
% fdirfile = name of flow direction file
% outlet = outlet location
% basin = basin boundary shapefile
% riv = river shapefile
% X, Y = domain
%
% OUTPUTS
% basin

outlet = [82.16, 32.84];

function basin = delineate_and_find_loops(fdirfile, outlet, X, Y, basin, rivs)

% load flow direction file
temp = split(fdirfile, '.');
extension = temp{end};
if strcmp(extension, 'asc')
    [fdir, R] = arcgridread(fdirfile);
    xres = R(1,1) - R(1,2);
    yres = R(2,1) - R(1,1);
elseif strcmp(extension, 'tif')
    [fdir, R] = geotiffread(fdirfile);
    if (projflag==1) % projected
        xres = R.CellExtentInWorldX;
        yres = R.CellExtentInWorldY;
    else % geographic
        error('latlon func not available yet')
    end
else
    disp('Irregular extension. Assuming ASCII GRID file.')
    [fdir, R] = arcgridread(fdirfile);
    xres = R(1,1) - R(1,2);
    yres = R(2,1) - R(1,1);
end
if (abs((xres-yres)/xres))<=0.05 % arbitrary, but useful, threshold
    disp('x and y resolution are approximately equal')
    res = xres;
else
    disp('x and y resolution are different')
    disp('correct_flowdir is not set up for this case.')
end

% get raster indices where gages are located
[row_ind, col_ind] = GetIndices(fdir, R, outlet, res);

% plot flow directions, show outlet
plotgrid = 0;
plotflowdir(fdir, res, X, Y, [row_ind, col_ind], outlet, basin, rivs, plotgrid)

% start at outlet, add neighboring cells to basin

% save indices of outlet pixel
init_row_ind = row_ind;
init_col_ind = col_ind;
% get flow direction at outlet pixel
fd = fdir(init_row_ind, init_col_ind);
% check flow directions of neighboring cells
inc.row = [1,1,0,-1,-1,-1,0,1];
inc.col = [0,1,1,1,0,-1,-1,-1];
fd_key = [5,6,7,8,1,2,3,4];
river = zeros(size(fdir)); % keep track of cells upstream of outlet
river(init_row_ind, init_col_ind) = 1;
for i=1:8
    row_ind = row_ind + inc.row(i);
    col_ind = col_ind + inc.col(i);
    fd = fdir(row_ind, col_ind);
    
    % check if flowing into current cell
    if fd == fd_key(i)
        disp('Cell flows into the current cell')
        river(row_ind, col_ind) = 1;
    end
    
    % effective use of recursion would help out a lot here
    
end

% continue checking neighboring cells until

% a) there is a loop

% b) there are no more cells flowing into any of the boundary cells

% Highlight basin

% Highlight looping cells, if they exist

return