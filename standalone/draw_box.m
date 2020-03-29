function exit_code = draw_box(target_axis, clicked_coords, X, Y)

% find the nearest grid cell to the clicked coordinates

x_vals = X(1,:)'; % grid cell centers (x)
y_vals = Y(:,1); % grid cell centers (y)

interval = abs(x_vals(2)-x_vals(1))/2;

% The y-coordinate needs some finangling due to way the map is plotted
x1 = clicked_coords(1); % x-coord
y1 = clicked_coords(2); % y-coord

% y1 = clicked_coords(2) + max(y_vals) - 1.5*interval;
% y1 = clicked_coords(2) + 1+2*interval;

% y1 = max(y_vals) + interval/2 - clicked_coords(2); % y-coord

[~, x_ind] = min(abs(x1-x_vals));
[~, y_ind] = min(abs(y1-y_vals));

X1 = x_vals(x_ind);
Y1 = y_vals(y_ind);

% plot a box around that grid cell

lw = 1.5;
hold(target_axis, 'on')
plot(target_axis, [X1-interval,X1+interval,...
    X1+interval,X1-interval,X1-interval],...
    [Y1-interval,Y1-interval,...
    Y1+interval,Y1+interval,Y1-interval],'cyan-', 'linewidth', lw)

exit_code = 0;

end