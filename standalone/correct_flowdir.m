function [fdir, res, X, Y, ind, gage, bb, rivs, R, x, y] = ...
    correct_flowdir(fdirfile, bbfile, rivfile, gagefile, projflag)

% addpath('./matlab')
% fdirfile = './data/proj/fdir.asc';
% bbfile = './data/proj/bb.shp';
% rivfile = './data/proj/rivs.shp';
% gagefile = './data/proj/gauge_xy.txt';
% projflag = 1; % use 0 for geographic coordinates
% plotgrid = 1;

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
% Flow direction file with VIC numbering convention
% Basin polygon outline
% Flag for projected vs. geographic coordinates
% Optional: River network shapefile from an established database
% Optional: Stream gauge locations as a list of (x,y) coordinates.
%
% REQUIREMENTS
% Requires mapping toolbox, arcgridwrite (for writing .asc files)
% Performance is very, very slow and RAM-intensive for large domains
% It is impractical to use this script for domains larger than about 200 by
% 200 pixels.
% 
% AUTHORS
% Concept/original version by Dongyue Li
% Adapted by Jacob Schaperow, Aug. 11, 2017
% Updated 1/29/2019 JRS
% Added error checks 6/12/2019 JRS
% Re-coded as a MATLAB standalone application --- March 2020 JRS
%
% Sample inputs (Upper Tuolumne)
% fdirfile = './Data/Geog/fdir_in.asc';
% bbfile = './Data/Geog/upper_tuolumne_wgs.shp';
% rivfile = './Data/Geog/UT_rivs.shp';
% gagefile = './Data/Geog/gauge_xy.txt';
% projflag = 0; % use 0 for geographic coordinates
% plotgrid = 1;

% cd('/Users/jschap/Documents/Research/SWOTDA_temp/Tuolumne/TuoSub/GIS/grass_workflow/FlowDirectionToolkit')
% cd('/Volumes/HD3/SWOTDA/FDT')

% % Sample inputs (made-up example)
% fdirfile = './Data/Proj/fdir.asc';
% bbfile = './Data/Proj/bb.shp';
% rivfile = './Data/Proj/rivs.shp';
% gagefile = './Data/Proj/gauge_xy.txt';
% projflag = 1;
% plotgrid = 0;

% % Sample inputs (IRB)
% fdirfile = './Delineation/fdir_coarse_remask.tif';
% bbfile = './Delineation/basin_3as.shp';
% rivfile = './Delineation/grwl.shp';
% gagefile = './Delineation/irb_outlet.txt';
% projflag = 0;
% plotgrid = 0;

% fdirfile = 'fdir_coarse.tif';
% bbfile = 'basin_fine.shp';
% rivfile = 'stream_fine_400.shp';
% gagefile = 'outlet_snapped_coarse.txt';
% basinmaskfile = 'uib_mask.tif';


%% Define inputs

% If you wish to subset each file, do so in gdal/ogr ahead of time

% cd('/Users/jschap/Documents/Codes/FlowDirectionToolkit')
% fdirfile = './Data/Proj/fdir.asc';
% bbfile = './Data/Proj/bb.shp';
% rivfile = './Data/Proj/rivs.shp';
% gagefile = './Data/Proj/gauge_xy.txt';
% projflag = 0;
% plotgrid = 1;

% fdirfile = './Data/IRB/Experimental/mod_fdir.asc';
% bbfile = './Data/IRB/Experimental/irb_basin.shp';
% rivfile = './Data/IRB/Experimental/rivers_merit.shp';
% gagefile = './Data/IRB/Experimental/vgagecoords.txt';
% projflag = 0; % projected (1) or geographic (0) coordinates
% plotgrid = 0; % flag for whether or not to plot the grid cells (slow for large basins)

%% Load inputs

temp = split(fdirfile, '.');
extension = temp{end};

if strcmp(extension, 'asc')
    [fdir, R] = arcgridread(fdirfile); % ASCII (projected or geographic)
    xres = R(1,1) - R(1,2);
    yres = R(2,1) - R(1,1);
    
    disp('Loaded ASCII flow direction file')
    if max(R(:)) <= 360 && min(R(:)) >=-360
        disp('Coordinates are geographic')
    else
        disp('Coordinates are projected')
    end
    
elseif strcmp(extension, 'tif')
    [fdir, R] = geotiffread(fdirfile);
    if (projflag==1) % projected
        xres = R.CellExtentInWorldX; % GeoTiff, projected
        yres = R.CellExtentInWorldY;
    else % geographic
        % Add this functionality % GeoTiff, geographic
        xres = R.CellExtentInLongitude;
        yres = R.CellExtentInLatitude;  
    end
    disp('Loaded GeoTiff flow direction file')
    if ~projflag
        disp('Coordinates are geographic')
    else
        disp('Coordinates are projected')
    end
    
else
    disp('Irregular extension. Assuming ASCII GRID file.')
    [fdir, R] = arcgridread(fdirfile);
    xres = R(1,1) - R(1,2);
    yres = R(2,1) - R(1,1);
    
    disp('Loaded ASCII flow direction file')
    if max(R(:)) <= 360 && min(R(:)) >=-360
        disp('Coordinates are geographic')
    else
        disp('Coordinates are projected')
    end
end

% Check that the grid cells are square
if (abs((xres-yres)/xres))<=0.05 % arbitrary, but useful, threshold
    disp('x and y resolution are approximately equal')
    res = xres;
else
    disp('x and y resolution are different')
    disp('correct_flowdir is not set up for this case.')
end

disp('Assuming VIC flow direction convention. Use convertflowdir() to convert if necessary')
% Convert to VIC routing model flow direction convention, if necessary
% fdir = convertflowdir(fdir, 'grass');
fdir(fdir==-32768) = NaN;

if ~isempty(gagefile)
    disp('Loading gage locations')
    gage = load(gagefile);
    [row_ind, col_ind] = GetIndices(fdir, R, gage, res, projflag);
else
    gage = [];
    row_ind = [];
    col_ind = [];
end
ind = [row_ind, col_ind]; % raster indices where gages are located
    
% Get locations of basin mask (only the pixels whose values are 1)
mask = ones(size(fdir));
[nrow, ncol] = size(mask);
    
if ~projflag
    [minlat, minlon] = pix2latlon(R,nrow,1);
    [maxlat, maxlon] = pix2latlon(R,1,ncol);
    lat = maxlat:-res:minlat;
    lon = minlon:res:maxlon;
    [Domain.X,Domain.Y] = meshgrid(lon,lat);
    x = lon;
    y = lat;
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

bb = bb(1); % in case there are multiple shapefiles here...

% basinmask = geotiffread(basinmaskfile);
% basinmask(basinmask~=1) = 0;
% basinmask = single(basinmask);
% fdir = single(fdir);
% 
% % Mask out the part of the flow directions file you care about
% fdir = basinmask.*fdir;

%% Initial plot

% plotflowdir(fdir, res, Domain.X, Domain.Y, ind, gage, bb, rivs, plotgrid, target_axis);
% xlabel('Easting')
% ylabel('Northing')

X = Domain.X;
Y = Domain.Y;

% disp([min(X(:)),max(X(:))])

% set(target_axis, 'XLim', [min(Domain.X(:)),max(Domain.X(:))])
% set(target_axis, 'YLim', [min(Domain.Y(:)),max(Domain.Y(:))])

% hold on

end