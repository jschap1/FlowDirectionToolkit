% Function that allows the user to correct the flow direction data
%
% INPUTS
% loc = location of grid cell whose coordinates you want to change
%
% OUTPUTS
% exit_code

function fd_corrected = modify_flowdir_interactive(fdir, R, res, loc)

xx = loc(1);
yy = loc(2);

replacenum = 1;

points = [xx,yy];

[row,col] = GetIndices(fdir, R, points, res, 0);

fd_corrected = fdir;

for pp=1:length(xx)
    fd_corrected(row(pp),col(pp)) = replacenum(pp);
end

end
