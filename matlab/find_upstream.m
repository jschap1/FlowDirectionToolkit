% Finds upstream pixels flowing into the current pixel and checks for loops
%
% Adapted from Mu Xiao's check.dir Python code

function [river, check] = find_upstream(river, check, flowdir, R)

% x = row (i), convention
% y = col (j), convention

xy = check(1,:);
check(1,:) = [];
ii = xy(1);
jj = xy(2);

% if the code doesn't work properly, try changing the sign on row_shift
row_shift = -[1,1,0,-1,-1,-1,0,1];

col_shift = [0,1,1,1,0,-1,-1,-1];
fl = [5,6,7,8,1,2,3,4];
[nrow, ncol] = size(flowdir);

% cycle through the cells around flowdir(ii, jj)
% flowdir(ii-1:ii+1, jj-1:jj+1)
% for i=1:8
%     flowdir(ii+row_shift(i), jj+col_shift(i))
% end

for i=1:8
    
    ii_i = ii + row_shift(i);
    jj_i = jj + col_shift(i);

    % check if the cell is on the edge of the domain
    if ii_i == 0 || ii_i > nrow
        continue
    end
    if jj_i == 0 || jj_i > ncol
        continue
    end
          
    if flowdir(ii_i, jj_i) == fl(i)
    % if flowdir(nrow - ii_i + 1, jj_i) == fl(i)    
        xyi = [ii_i, jj_i];
        [lat_i, lon_i] = pix2latlon(R, ii_i, jj_i);
        latlon = [lat_i, lon_i];
        if any(sum(river==latlon, 2)==2) % check if the pixel is in the river
            disp('There is a loop')
            
            % report location of loop
            disp(['latlon = ' num2str(latlon)])
            
        else
            river = vertcat(river, latlon);
            check = vertcat(check, xyi);
        end
    end
    
end

return