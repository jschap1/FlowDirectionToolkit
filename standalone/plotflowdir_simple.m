function h = plotflowdir_simple(fdir, res, X, Y, ind, plotgrid)

% Tool for visualizing flow direction file to ensure that it is consistent
% with stream network data. Plots the following:
% - flow direction (with arrows)
% - stream network
% - basin boundary
%
% INPUTS
% fdir, flow direction raster (plain text format, VIC routing model numbering convention)
% ind, the [row, col] indices where the gauges are in the flow direction file
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
  
plot(basin.X,basin.Y,'k-', 'LineWidth', 2)

% Plot rivers from database
for i=1:length(rivs)
    plot(rivs(i).X,rivs(i).Y,'r-', 'LineWidth', 2)
end

quiver(X,Y,u,v)
hold on
for i=1:size(ind,1) % Plot gage locations
    hold on
    plot(gage(i,1),gage(i,2),'bo','linewidth',2)
    hold on
end
hold off

return