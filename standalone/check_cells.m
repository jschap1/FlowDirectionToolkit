function exit_code = check_cells(target_axis, X, Y, fdir)

% Checks for trivial loops (cells that flow into one another) and cells
% that flow off the edge of the domain, and highlights them on the map
% 
% INPUTS
% target_axis = axes for plotting
% X = x coordinates
% Y = y coordinates
% fdir = flow direction map
%
% OUTPUTS
% exit_code = 1 for success
%
% TODO: get legend to work

[looprow, loopcol] = CheckForTrivialLoops(fdir);
[edgerow, edgecol] = CheckIfFlowOffEdge(fdir);

% Highlight the cells that loop
hold(target_axis, 'on')
for k=1:length(looprow)  
    plot(X(looprow(k),loopcol(k)),Y(looprow(k),loopcol(k)), ...
        'og','MarkerSize',8, 'Parent', target_axis); % (Open green circles)
end
% loop_child_ind = length(target_axis.Children);

for k=1:length(edgerow)
    plot(X(edgerow(k),edgecol(k)),Y(edgerow(k),edgecol(k)), ...
        '*g','MarkerSize',8, 'Parent', target_axis); % (Green asterisks)
end
% edge_child_ind = length(target_axis.Children);
% 
% legend([target_axis.Children(loop_child_ind), ...
%     target_axis.Children(edge_child_ind)], ...
%     'Looping','Flows off edge')

% legend([tar/get_axis(), target_axis()], 'Looping','Flows off edge')

% How to label specific plots on on axis:
% x=1:10; y=2*x+3;
% plot(x,y)
% target_axis = gca;
% grid(target_axis, 'on');
% hold(target_axis, 'on');
% plot(target_axis, x, 2*x)
% plot(target_axis, x, -2*x);
% legend([target_axis.Children(3), target_axis.Children(1)], 'line A', 'line C')
% order of indices goes from most-recently created to least-recently created

exit_code = 1;

end