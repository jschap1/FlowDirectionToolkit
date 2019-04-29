% Correct Flow Direction
%
% FEATURES
% Plots map of basin, flow network, flow direction file, and gauge locations
% Can be used to make manual corrections to the flow direction file in
% order to get better agreement between automatically delineated river
% networks and true river locations.
% Highlights cells that flow into each other
% Highlights cells that flow off the edge
% Highlights cells that flow in the 'wrong' direction compared to 'truth' data
% Plans for future upgrades:
% Add ability to check for nontrivial loops
% Develop workflow for checking partial domains.
%
% INPUTS
% Flow direction file
% Basin polygon outline
% Flag for projected vs. geographic coordinates
% Optional: River network shapefile from an established database
% Optional: Stream gauge locations as a list of (x,y) coordinates.
%
% REQUIREMENTS
% Requires mapping toolbox.
% Performance is very slow and RAM-intensive for large domains
% It is impractical to use this script for domains larger than about 200 by
% 200 pixels
% 
% AUTHORS
% Written by Dongyue Li
% Modified by Jacob Schaperow, Aug. 11, 2017
% Updated 1/29/2019 JRS
%
% Sample inputs
% fdirfile = './Data/Geog/fdir_in.asc';
% bbfile = './Data/Geog/upper_tuolumne_wgs.shp';
% rivfile = './Data/Geog/UT_rivs.shp';
% gagefile = './Data/Geog/gauge_xy.txt';
% projflag = 0; % use 0 for geographic coordinates

clear, clc
cd /Users/jschap/Documents/Codes/FlowDirectionToolkit/
addpath('./Scripts')

%% INPUTS

% If you wish to subset each file, do so in gdal/ogr ahead of time

fdirfile = '/Volumes/HD3/SWOTDA/Data/UMRB/ROUT/umrb.flowdir';
bbfile = '/Volumes/HD3/SWOTDA/Data/UMRB/Basin/basin.wgs.shp';
rivfile = '/Volumes/HD3/SWOTDA/Data/UMRB/River/river_wgs.shp';
gagefile = [];
projflag = 0;

%%

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

% Convert to VIC routing model flow direction convention, if necessary
% fdir = convertflowdir(fdir, 'grass');

if ~isempty(gagefile)
    gage = load(gagefile);
    [row_ind, col_ind] = GetIndices(fdir, R, gage, res);
    disp('Note that GetIndices only works for latlon coordinates, currently.')
else
    gage = [];
    row_ind = [];
    col_ind = [];
end
ind = [row_ind, col_ind]; % raster indices where gages are located
    
% Get lat/lon of basin mask (only the pixels whose values are 1)
mask = ones(size(fdir));
[nrow, ncol] = size(mask);
    
if ~projflag
    [minlat, minlon] = pix2latlon(R,nrow,1);
    [maxlat, maxlon] = pix2latlon(R,1,ncol);
    lat = maxlat:-res:minlat;
    lon = minlon:res:maxlon;
    [Domain.X,Domain.Y] = meshgrid(lon,lat);
else
%     aa = repmat(1:ncol, nrow, 1); % THIS EFFICIENCY MOD IS NOT WORKING
%     row = aa(:)';
%     col = repmat(1:nrow, 1, ncol);
%     [x,y] = pix2map(R, row, col);
%     [Domain.X,Domain.Y] = meshgrid(x,y); 
    % this produces two square nrow*ncol matrices. Much too big in many cases.
    x = NaN(ncol,1);
    y = NaN(nrow,1);
    for row=1:nrow
        for col=1:ncol
            [x(col), y(row)] = pix2map(R,row,col);
        end
    end
    [Domain.X,Domain.Y] = meshgrid(x,y);
end

% if maxlat < 0 && minlat <0 
%     lat = maxlat:-res:minlat;
% elseif maxlat>0 && minlat > 0
%     lat = minlat:res:maxlat;
% else
%     disp('domain includes both positive and negative latitudes')
%     error('correct_flowdir is not set up for this case')
% end
% Figure this out:

rivs = shaperead(rivfile);
bb = shaperead(bbfile);

%% Initial plot

h = plotflowdir(fdir, res, Domain.X, Domain.Y, ind, gage, bb, rivs);
axis([-97.34, -85.90, 36.96, 47.78])

[looprow, loopcol] = CheckForTrivialLoops(fdir);
[edgerow, edgecol] = CheckIfFlowOffEdge(fdir);

% While this currently works OK, there is probably too much tendency to 
% classify rivers as flowing diagonally. Best to just flag cells for manual change.
fd_riv = GetRiverDir(fdir, R, rivs, res); 
[wrongdirrow, wrongdircol] = CheckIfWrongDir(fdir, fd_riv);
% ABOVE LINES ARE NOT WORKING WITH THE PROJECTED DATA

% Option to correct these cells automatically (use at own risk...)
% [fd_corrected, wrongdirrow, wrongdircol] = CorrectIfWrongDir(fdir, fd_riv);

% Highlight the cells that loop
hold on,
for k=1:length(looprow)  
    h2 = plot(Domain.X(looprow(k),loopcol(k)),Domain.Y(looprow(k),loopcol(k)), ...
        'og','MarkerSize',8); % (Open green circles)
end
for k=1:length(edgerow)
    h3 = plot(Domain.X(edgerow(k),edgecol(k)),Domain.Y(edgerow(k),edgecol(k)), ...
        '*g','MarkerSize',8); % (Green asterisks)
end
for k=1:length(wrongdirrow)
    h4 = plot(Domain.X(wrongdirrow(k),wrongdircol(k)),Domain.Y(wrongdirrow(k),wrongdircol(k)), ...
        'ok','MarkerSize',8); % (Open black circles)    
end
if exist('h2')
    legend([h2 h3 h4], 'Looping','Flows off edge','Disagrees w river data')
else
    legend([h3 h4], 'Flows off edge','Disagrees w river data');
end


%% Do the correction

% This is really not a fun method. 
% One little mistake and you have to start over.
% Need to automate this.

f1 = './Data/Geog/xcoords2change.txt';
f2 = './Data/Geog/ycoords2change.txt';

% This is set up so you can interrupt your selection of pixels to modify,
% and continue by re-running this section of code. Thus 'append'.

% As you go, write down the numbers corresponding to the new flow
% directions you wish to change to. (See next section/replacenum)

fID1 = fopen(f1, 'a');
fID2 = fopen(f2, 'a');

[xx,yy] = ginput();

fprintf(fID1,'%7.4f \n',xx);
fprintf(fID2,'%6.4f \n',yy);

fclose(fID1);
fclose(fID2);

%%

% Write down the flow direction numbers to replace with 
replacenum = [4 3 2 4 2 4 2 4 3 -5];

% Load coordinates of pixels to change
xx = load(f1);
yy = load(f2);

%% Find indices of points to change

points = [xx,yy];
[row,col] = GetIndices(fdir, R, points, res);

%% Change the values

fd_corrected = fdir;

for pp=1:length(xx)
    fd_corrected(row(pp),col(pp)) = replacenum(pp);
end

%% Check that the changes are good

h = plotflowdir(fd_corrected, res, Domain.X, Domain.Y, ind, gage, bb, rivs);

[looprow, loopcol] = CheckForTrivialLoops(fd_corrected);
[edgerow, edgecol] = CheckIfFlowOffEdge(fd_corrected);

fd_riv = GetRiverDir(fd_corrected, R, rivs, res); 
[wrongdirrow, wrongdircol] = CheckIfWrongDir(fd_corrected, fd_riv);

hold on,
for k=1:length(looprow)  
    h2 = plot(Domain.X(looprow(k),loopcol(k)),Domain.Y(looprow(k),loopcol(k)), ...
        'og','MarkerSize',8); % (Open green circles)
end
for k=1:length(edgerow)
    h3 = plot(Domain.X(edgerow(k),edgecol(k)),Domain.Y(edgerow(k),edgecol(k)), ...
        '*g','MarkerSize',8); % (Green asterisks)
end
for k=1:length(wrongdirrow)
    h4 = plot(Domain.X(wrongdirrow(k),wrongdircol(k)),Domain.Y(wrongdirrow(k),wrongdircol(k)), ...
        'ok','MarkerSize',8); % (Open black circles)    
end
if exist('h2')
    legend([h2 h3 h4], 'Looping','Flows off edge','Disagrees w river data')
elseif exist('h3')
    legend(h4, 'Flows off edge');
end

% Add flow directions derived from the river network to plot
% plot_flow_dirs_only(Domain.X, Domain.Y, fd_riv)

%% Save the modified flow direction file

if strcmp(extension, 'asc')
    arcgridwrite('mod_fdir.asc', x, y, fd_corrected);
elseif strcmp(extension, 'tif')
    geotiffwrite('mod_fdir.tif', fd_corrected, R);
end
