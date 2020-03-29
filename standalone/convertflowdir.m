function fdirnew = convertflowdir(fdir, orig)
% Converts among different types of flow direction conventions
% Always ends up with the VIC routing model convention because that is the
% convention used for correct_flowdir(). Functionality could be expanded in
% the future.
%
% INPUTS
% fdir
% orig: original convention. Can be either 'vic', 'grass', or 'arcmap'
% new: new convention. Can be either 'vic', 'grass', or 'arcmap'
% 
% OUTPUTS
% fdirnew: flow direction file with the new flow direction convention

switch orig
    case 'vic'
        warning('Output convention and input convention are both: vic')
        
        fdirnew = fdir;
        
    case 'grass'
        disp('Converting from GRASS flow direction convention to VIC routing model convention')
        
        fdirnew = fdir;
        fdirnew(fdir==2) = 1;
        fdirnew(fdir==1) = 2;
        fdirnew(fdir==8) = 3;
        fdirnew(fdir==7) = 4;
        fdirnew(fdir==6) = 5;
        fdirnew(fdir==5) = 6;
        fdirnew(fdir==4) = 7;
        fdirnew(fdir==3) = 8;
                
    case 'arcmap'
        
        disp('Converting from ArcMap flow direction convention to VIC routing model convention')
        
        fdirnew = fdir;
        fdirnew(fdir==64) = 1;
        fdirnew(fdir==128) = 2;
        fdirnew(fdir==1) = 3;
        fdirnew(fdir==2) = 4;
        fdirnew(fdir==4) = 5;
        fdirnew(fdir==8) = 6;
        fdirnew(fdir==16) = 7;
        fdirnew(fdir==32) = 8;
        
    otherwise
        error('must specify vic, grass, or arcmap')
end

return