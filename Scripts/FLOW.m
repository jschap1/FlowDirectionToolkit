% Dai Yamazaki's FLOW flow direction upscaling algorithm
%
% Inputs
% f = aggregation factor
%
% Notation
% "grid cell" = coarse resolution
% "pixel" = fine resolution
%
% This code is buggy and unfinished, but I made a good start
% The real issue with upscaling flow directions this way is that it does
% not lend itself for use with D8 routing models like the Lohmann routing
% model. It is useful for delineating watersheds and calculating upstream
% area, though. Or there could be non-D8 routing models.
%
% This is a pretty complicated upscaling method. It may be fine to use
% something simpler, like the papers cited in Yamazaki et al. (2009) that
% stick with D8 flow directions, at the cost of some accuracy.
%
% SAMPLE INPUTS
% [fd_fine, R] = arcgridread('/Users/jschap/Documents/Research/SWOTDA_temp/Tuolumne/TuoSub/GIS/fdir.asc');
% facc_fine = geotiffread('/Users/jschap/Documents/Research/SWOTDA_temp/Tuolumne/TuoSub/GIS/facc.tif');
% facc_fine = double(facc_fine);
% facc_fine(facc_fine<=-9999) = NaN;

function fd_coarse = FLOW(fd_fine, facc_fine, f, R)

%% Preprocessing

[nf, mf] = size(fd_fine); % get rows and columns
oldres = R(2,1); % get resolution
newres = f*oldres;

l = oldres*nf;
w = oldres*mf;

% get coarse resolution rows and columns
nc = (l/newres); 
mc = ceil(w/newres); 

% make the new grid

fd_coarse = zeros(nc, mc);

% go through each grid cell and find the pixels along the edge
% find the pixel along the edge with the highest flow accumulation value
% store the fine-grid coordinates of this "potential outlet" cell

%% Calculate potential outlet locations for each grid cell

potential_outlets = zeros(nc, mc); % linear index of potential outlet pixel
facc_rank = 1; % option to exclude certain pixels from consideration

for r=1:nc
    for c=1:mc     
        potential_outlets(r,c) = find_potential_outlet(r, c, f, facc_fine, facc_rank);
    end
end

%% River Tracing

% From the outlet pixel of the target grid cell to the next potential outlet pixel

% using VIC convention for flow directions
% convert if necessary
% fd_fine = convertflowdir(fd_fine, 'arcmap');

river_channel_length = zeros(nc, mc);
next_potential_outlet = zeros(nc, mc);

for r=1:nc
    for c=1:mc
        
        % Check if outside the target area
        % Could improve this using masks, probably
        if isnan(potential_outlets(r, c))
            continue;
        end
        
        % Get current pixel indices
        [rf, cf] = ind2sub([nf, mf], potential_outlets(r,c)); 
        river_pixels = [rf, cf];
                    
        river_flag = 1;
        
        % Calculate length of the river channel along the way
        r_length = 0;
        
        while river_flag
            
            % Find the next pixel in the river
            fd = fd_fine(rf, cf);
            
            % if the river pixel would go outside the domain, stop
            if rf > nf || cf > mf || isnan(fd)
                disp('This pixel flows outside the domain')
                next_potential_outlet(r,c) = 9999;
                break
            end            
            
            switch fd
                case 1
                    next_river_pixel = [rf-1, cf]; % N
                    r_length = r_length + 1;
                case 2
                    next_river_pixel = [rf-1, cf+1]; % NE
                    r_length = r_length + sqrt(2);
                case 3
                    next_river_pixel = [rf, cf+1]; % E
                    r_length = r_length + 1;
                case 4
                    next_river_pixel = [rf+1, cf+1]; % SE
                    r_length = r_length + sqrt(2);
                case 5
                    next_river_pixel = [rf+1, cf]; % S
                    r_length = r_length + 1;
                case 6
                    next_river_pixel = [rf+1, cf-1]; % SW
                    r_length = r_length + sqrt(2);
                case 7
                    next_river_pixel = [rf, cf-1]; % W
                    r_length = r_length + 1;
                case 8
                    next_river_pixel = [rf-1, cf-1]; % NW
                    r_length = r_length + sqrt(2);
            end        

            river_pixels(end+1,:) = next_river_pixel;
            rf = next_river_pixel(1);
            cf = next_river_pixel(2);
                        
            % if the river pixel is also a potential outlet, stop
            lin_ind = sub2ind([nf, mf], rf, cf); % linear index of current pixel
            
            if ismember(lin_ind, potential_outlets)
                disp('This is a potential outlet pixel');
                next_potential_outlet(r,c) = lin_ind;
                river_flag = 0;
            end
        
            river_channel_length(r,c) = r_length;
            
        end
        
    end
end
        
% At this point, we have a list of river pixels from the target
% cell to the first potential outlet pixel downstream

%% Check that the length is sufficiently long
% in order to confirm or revise the potential outlet locations

% Is the length long enough?
threshold = 1; % can mess around with this value
true_outlet = zeros(nc, mc); % initialize confirmed outlet locations

accept = 1;
for r=1:nc
    for c=1:mc

        if river_channel_length(r,c) == 0
            disp('Gridcell is not in domain')
            continue;
        elseif river_channel_length(r,c) < threshold
            accept = 0; % reject                   
        end

        % If the river channel length was not long enough, 
        % find another potential outlet pixel
        while accept == 0
            
            disp('Finding a new potential outlet')
            facc_rank = facc_rank + 1; % go to the next highest flowacc value
            potential_outlets(r,c) = find_potential_outlet(r,c,f, facc_fine, facc_rank);
            
            if river_channel_length(r,c) >= threshold
                accept = 1;
            end
            
            % Look at the pixels on the border of the target cell
            % Choose the pixel with the largest flowacc value
            % excluding the previous choice of potential outlet pixel
            % Repeat this until the river channel length is long enough
            
            % It's going to be easier to do this by writing a separate
            % function for this step and also the step at the beginning
            % This function should allow exclusion of certain points in the
            % case that it has been run already | it could return an
            % ordered list and we could choose the next highest value on
            % that list
            
        end

        % Otherwise, confirm the outlet pixel
        if accept == 1
            true_outlet(r,c) = potential_outlets(r,c);
        end

    end
end

%% Make the upscaled flow direction map

fdir_coarse = zeros(nc,mc);
downstream_cell = zeros(nc,mc);

for r=1:nc
    for c=1:mc
        
        % the downstream cell is the cell in which the true_outlet at the
        % end of the river that we traced out is located
        % Need to store the downstream cell values in the second part of
        % this script for use here.
        
        downstream_cell(r,c) = 1;
        
    end
end


end