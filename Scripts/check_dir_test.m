% Automatically finds loops in flow direction file
%
% Very useful for setting up VIC routing model

%% test case
flowdir = [4,1,6,1,5;3,5,1,5,7; 3,5,5,7,7; 1,5,3,2,5; 5,7,5,1,1];
outlet = [21, 62]; % latlon
R = makerefmat(60, 20, 1, 1);

%% the real thing

% [flowdir, R] = arcgridread('./Data/IRB/Experimental/modfdir2.asc');
flowdir = fd_corrected;
outlet = [24.7854592676, 68.0301009762];

geotiffwrite('./Data/IRB/Experimental/corrected_VIC_flowdir.tif', flowdir, R)

%%
[x_ind, y_ind] = latlon2pix(R, outlet(1), outlet(2));
xy = [round(x_ind), round(y_ind)];

river = [];
check = [];

river = vertcat(river, outlet);
check = vertcat(check, xy);

while size(check, 1) > 0
    
    [river, check] = find_upstream(river, check, flowdir, R);
    
end

%% add river to flow directions map (plot in correct_flowdir)

[watershed_row, watershed_col] = latlon2pix(R, river(:,1), river(:,2));

[watershed_row, watershed_col];

watershed_row = round(watershed_row);
watershed_col = round(watershed_col);
for k=1:length(watershed_col)
    h_watershed = plot(Domain.X(watershed_row(k), watershed_col(k)), Domain.Y(watershed_row(k), watershed_col(k)), ...
        'or', 'MarkerSize', 8); % open red circles
end

