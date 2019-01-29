function [row,col] = GetIndices(Z, R, points, res)

% Finds indices in a raster where user-defined points are located.
% Uses a lookup table approach, with the hypothetical table: [lat lon pixels]
%
% Based on find_stnloc script. Tested Aug. 18, 2017.
%
% INPUTS
% Z, a raster file
% R, spatial referencing matrix (e.g. from arcgridread)
% points, the coordinates of the user-defined points (e.g. gauge locs)
% res, resolution of the flow direction file
%
% OUTPUTS
% row, col

[nrows, ncols] = size(Z);
[A,B] = meshgrid(1:nrows, 1:ncols);
A=cat(2,A',B');
pixels=reshape(A,[],2);
[lat, lon] = pix2latlon(R,pixels(:,1),pixels(:,2));

npoints = size(points,1);
row = NaN(npoints,1);
col = NaN(npoints,1);

for p = 1:npoints
    1;
    
% Find the indices for each gage:

    for i=1:length(lat)

    % finds the lookup table entry corresponding to the gauge location 
    % and reads off the pixel indices  

        diff = abs(points(p,1) - lon(i));
        diff = max(abs(points(p,2) - lat(i)),diff);
        if diff <= res/2
            row(p) = pixels(i,1);
            col(p) = pixels(i,2);
            break;
        end

    end

end

end