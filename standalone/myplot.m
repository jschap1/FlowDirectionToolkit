function h = myplot(fdirfile, target_axis)

[fd, R, lon, lat] = geotiffread2(fdirfile);
h = plotraster(lon, lat, fd, 'Flow Direction', 'Lon', 'Lat', 1, target_axis);

% x = 0:100;
% y = log(x);

% plot(target_axis, x, y)
% grid(target_axis, 'on')

end