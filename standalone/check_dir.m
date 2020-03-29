% Delineate watershed from flow directions and check for loops
%
% INPUTS
% name of flow direction file
% outlet location
%
% OUTPUTS
% basin

function basin = delineate_and_find_loops(fdirfile, outlet)

% get pixel coordinates of outlet

fdirfile = './Data/IRB/Experimental/irb.flowdir.asc';
[flowdir, R] = arcgridread(fdirfile);


[row_ind, col_ind] = GetIndices(flowdir, R, outlet, res);

if ~isempty(gagefile)
    disp('Note that GetIndices only works for latlon coordinates, currently.')
    gage = load(gagefile);
    [row_ind, col_ind] = GetIndices(fdir, R, gage, res);
else
    gage = [];
    row_ind = [];
    col_ind = [];
end
ind = [row_ind, col_ind]; % raster indices where gages are located

% plot flow directions, show outlet

% start at outlet, add neighboring cells to basin

% continue checking neighboring cells until

% a) there is a loop

% b) there are no more cells flowing into any of the boundary cells

% Highlight basin

% Highlight looping cells, if they exist

return


% check for loops in flow direction file
% adapted from Mu Xiao's Python code
% --> attempted to do this, but it is not my coding style, which makes this
% difficult. 
%
% WORK IN PROGRESS

fdirfile = './Data/IRB/Experimental/irb.flowdir.asc';
[flowdir, R] = arcgridread(fdirfile);

header = get_arc_header(fdirfile);


function [lon, lat] = int_2_lon_lat(xylist, headers)

    ix = xylist(1); % column index in flow direction file (stnloc)
    iy = xylist(2); % row index in flow direction file (stnloc)
    ncols = headers(1);
    nrows = headers(2);
    cellsize = headers(3);
    xllcorner = headers(4);
    yllcorner = headers(5);
    NODATA_value = headers(6);
    
    lat = cellsize*(iy-1+0.5)+yllcorner;
    lon = cellsize*(ix-1+0.5)+xllcorner;
    
return

function [river, check] = find_upstr(river, check, flowdir, header)

xy = check(1);
% 	check.remove(xy)
ix = ();
iy = ();
[lon, lat] = int_2_lon_lat([ix, iy], header);
    
% VIC routing model flow direction conventions
yd = [1,1,0,-1,-1,-1,0,1];
xd = [0,1,1,1,0,-1,-1,-1];
fl = [5,6,7,8,1,2,3,4];

% search for loops
for i=1:length(yd)
    xi = ix + xd(i);
    yi = iy + yd(i);
    
    if flowdir(nrows - yi, xi - 1) == fl(i)
        % xyi = str(str(xi)+'_'+str(yi))
        [lon_ind, lat_ind] = int_2_lon_lat([xi,yi], headers);
        % latlon = "{0:.5f}".format(lati)+'_'+"{0:.5f}".format(loni)
%         if latlon in river
%             1;
%         end
    
end

% 	for i in range(len(yd)):
% 		xi = ix+xd[i]
% 		yi = iy+yd[i]
% 		if flowdir[nrows-yi, xi-1] == fl[i]:
% 			xyi = str(str(xi)+'_'+str(yi))
% 			[loni, lati] = int_2_lon_lat([xi,yi], headers)
% 			latlon = "{0:.5f}".format(lati)+'_'+"{0:.5f}".format(loni)
% 			if latlon in river:
% 				print 'ERROR: infinite loop in channel network, please check the flowing cells in flow direction file'
% 				print latlon+' and '+"{0:.5f}".format(lat)+'_'+"{0:.5f}".format(lon)
% 				exit()
% 			else:
% 				river.append(latlon)
% 				check.append(xyi)

return

% def find_upstr(river, check, flowdir, headers):
% 	xy = check[0]
% 	check.remove(xy)
% 	ix = int(xy.split('_')[0])
% 	iy = int(xy.split('_')[1])
% 	[lon, lat] = int_2_lon_lat([ix,iy], headers)
% 	yd = [1,1,0,-1,-1,-1,0,1]
% 	xd = [0,1,1,1,0,-1,-1,-1]
% 	fl = [5,6,7,8,1,2,3,4]
% 	for i in range(len(yd)):
% 		xi = ix+xd[i]
% 		yi = iy+yd[i]
% 		if flowdir[nrows-yi, xi-1] == fl[i]:
% 			xyi = str(str(xi)+'_'+str(yi))
% 			[loni, lati] = int_2_lon_lat([xi,yi], headers)
% 			latlon = "{0:.5f}".format(lati)+'_'+"{0:.5f}".format(loni)
% 			if latlon in river:
% 				print 'ERROR: infinite loop in channel network, please check the flowing cells in flow direction file'
% 				print latlon+' and '+"{0:.5f}".format(lat)+'_'+"{0:.5f}".format(lon)
% 				exit()
% 			else:
% 				river.append(latlon)
% 				check.append(xyi)
% 	return river,check

function header = get_arc_header(fdirfile)

    fID = fopen(fdirfile);

    l1 = fgetl(fID);
    tmp = strsplit(l1, ' ');
    ncols = str2double(tmp{2});

    l2 = fgetl(fID);
    tmp = strsplit(l2, ' ');
    nrows = str2double(tmp{2});

    l3 = fgetl(fID);
    tmp = strsplit(l3, ' ');
    xllcorner = str2double(tmp{2});

    l4 = fgetl(fID);
    tmp = strsplit(l4, ' ');
    yllcorner = str2double(tmp{2});

    l5 = fgetl(fID);
    tmp = strsplit(l5, ' ');
    cellsize = str2double(tmp{2});

    l6 = fgetl(fID);
    tmp = strsplit(l6, ' ');
    NODATA_value = str2double(tmp{2});

    fclose(fID);
    header = [ncols,nrows,xllcorner,yllcorner,cellsize,NODATA_value]';

end


%% Scrap
% 
% %% 
% 
% 
% # x,y order as the stn file goes
% index = 26
% indey = 29 
% 
% index = 25
% indey = 31
% 
% index = 21 
% indey = 81
% 
% index = 71
% indey = 94
% 
% index = int(args.indx)
% indey = int(args.indy)
% 
% # index = 19 # infinite loop in flow dir
% # indey = 89 
% 
% xy = str(str(index)+'_'+str(indey))
% [lon, lat] = int_2_lon_lat([index,indey], headers)
% 
% river = []
% check = []
% print 'outlet point is', lon,lat
% print 'begin searching...'
% river.append("{0:.5f}".format(lat)+'_'+\
%              "{0:.5f}".format(lon))
% check.append(xy)
% 
% while len(check)>0:
% 	[river, check] = find_upstr(river, check, flowdir, headers)
% 
% print len(river)
% for f in river:
% 	print f
% 
% 
% 
% #!/usr/local/bin/python
% 
% import numpy as np
% import pandas as pd
% import argparse
% from sys import exit
% 
% ########### HEADER STARTS ############
% 
% def int_2_lon_lat(xylist, headers):
% 	ix = xylist[0]
% 	iy = xylist[1]
% 	ncols = headers[0]
%         nrows = headers[1]
%         xllcorner = headers[2]
%         yllcorner = headers[3]
%         cellsize = headers[4]
%         NODATA_value = headers[5]
%         lat = cellsize*(iy-1+0.5)+yllcorner
%         lon = cellsize*(ix-1+0.5)+xllcorner
% 	return [lon, lat]
% 
% def find_upstr(river, check, flowdir, headers):
% 	xy = check[0]
% 	check.remove(xy)
% 	ix = int(xy.split('_')[0])
% 	iy = int(xy.split('_')[1])
% 	[lon, lat] = int_2_lon_lat([ix,iy], headers)
% 	yd = [1,1,0,-1,-1,-1,0,1]
% 	xd = [0,1,1,1,0,-1,-1,-1]
% 	fl = [5,6,7,8,1,2,3,4]
% 	for i in range(len(yd)):
% 		xi = ix+xd[i]
% 		yi = iy+yd[i]
% 		if flowdir[nrows-yi, xi-1] == fl[i]:
% 			xyi = str(str(xi)+'_'+str(yi))
% 			[loni, lati] = int_2_lon_lat([xi,yi], headers)
% 			latlon = "{0:.5f}".format(lati)+'_'+"{0:.5f}".format(loni)
% 			if latlon in river:
% 				print 'ERROR: infinite loop in channel network, please check the flowing cells in flow direction file'
% 				print latlon+' and '+"{0:.5f}".format(lat)+'_'+"{0:.5f}".format(lon)
% 				exit()
% 			else:
% 				river.append(latlon)
% 				check.append(xyi)
% 	return river,check
% 
% ########## HEADER END ############

