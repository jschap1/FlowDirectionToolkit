function [h] = plotflowdir(fdir, res, X, Y, ind, gage, basin, rivs, plotgrid, target_axis, fs)

% Tool for visualizing flow direction file to ensure that it is consistent
% with stream network data. Plots the following:
% - flow direction (with arrows)
% - stream network
% - basin boundary
%
% INPUTS
% fdir, flow direction raster (plain text format, VIC routing model numbering convention)
% X, Y, meshgrid of coordinates over the domain extent
% ind, the [row, col] indices where the gauges are in the flow direction file
% gage, gage locations
% basin, basin shapefile
% rivs, river shapefile
% plotgrid, flag for whether or not to plot the grid

% OUTPUTS
% h, figure

[nrow,ncol] = size(fdir);

u=zeros(size(fdir,1),size(fdir,2));
v=u;
for i=1:size(u,1)
    for j=1:size(u,2)
        
        if fdir(i,j)==1
            u(i,j)=0;
            v(i,j)=1;
        end
        
        if fdir(i,j)==2
            u(i,j)=1;
            v(i,j)=tand(45);
        end
        
        if fdir(i,j)==3
            u(i,j)=1;
            v(i,j)=0;
        end
        
        if fdir(i,j)==4
            u(i,j)=1;
            v(i,j)=-tand(45);
        end
        
        if fdir(i,j)==5
            u(i,j)=0;
            v(i,j)=-1;
        end
        
        if fdir(i,j)==6
            u(i,j)=-1;
            v(i,j)=-tand(45);
        end
        
        if fdir(i,j)==7
            u(i,j)=-1;
            v(i,j)=0;
        end
        
        if fdir(i,j)==8
            u(i,j)=-1;
            v(i,j)=tand(45);
        end
        
    end
end
  
% If this block is plotting the basin upside-down, try reversing the order of
% the Y vector.
interval=res/2;

% h = target_axis;

% hold on
if plotgrid % this can be computationally intensive to display
    for i=1:size(X,1)
        for j=1:size(X,2)
            % draws grid
            if fdir(i,j)>=0 % condition for being in the basin boundary
                plot([X(i,j)-interval,X(i,j)+interval,...
                    X(i,j)+interval,X(i,j)-interval,X(i,j)-interval],...
                    [Y(i,j)-interval,Y(i,j)-interval,...
                    Y(i,j)+interval,Y(i,j)+interval,Y(i,j)-interval],'k-', 'Parent', target_axis)            
                hold(target_axis, 'on');
            end
        end
    end
end

plot(basin.X,basin.Y,'k-', 'LineWidth', 2, 'Parent', target_axis, 'Tag', 'basin')

% Plot rivers from database
for i=1:length(rivs)
    plot(target_axis, rivs(i).X,rivs(i).Y,'r-', 'LineWidth', 2)
end

quiver(target_axis, X,Y,u,v)
hold(target_axis, 'on');
for i=1:size(ind,1) % Plot gage locations
%     if ~isnan(ind(i,1))
%         plot(X(1,ind(i,1)),Y(nrow-ind(i,2)+1),'r*')
%     else
%         warning('gage location not in basin')
%     end
    hold(target_axis, 'on');
    plot(target_axis, gage(i,1),gage(i,2),'bo','linewidth',2)
    hold(target_axis, 'on');
end
hold(target_axis, 'off');

set(target_axis, 'fontsize', fs)

return