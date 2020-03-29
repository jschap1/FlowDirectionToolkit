function [looprow, loopcol] = CheckForLoops(fdir)

% Checks a flow direction map for trivial loops where two adjacent cells feed
% into each other.
%
% INPUTS
% Flow direction raster using VIC flow direction convention (1-8)
%
% OUTPUTS
% Row and column indices of the looping grid cells

[nrow,ncol] = size(fdir);
looprow = NaN;
loopcol = NaN;

for i=1:nrow
    for j=1:ncol
        
        % Identify special cases (corners and edges)
        if i==1 && j==1 % upper left corner
            special = 'UL';
        elseif i==1 && j==ncol % upper right corner
            special = 'UR';
        elseif i==nrow && j==1 % lower left corner
            special = 'LL';
        elseif i==nrow && j==ncol % lower right corner
            special = 'LR';
        elseif i==1 %% top edge
            special = 'T';
        elseif j==ncol %% right edge
            special = 'R';        
        elseif i==nrow %% bottom edge
            special = 'B';
        elseif j==1 %% left edge
            special = 'L';
        end
       
        if ~exist('special', 'var')   
            switch fdir(i,j)
                case 1 % north
                    if fdir(i-1,j) == 5
                        looprow = [looprow, i];
                        loopcol = [loopcol, j];
                    end
                case 2; % northeast
                    if fdir(i-1,j+1) == 6
                        looprow = [looprow, i];
                        loopcol = [loopcol, j];
                    end
                case 3 % east
                    if fdir(i,j+1) == 7
                        looprow = [looprow, i];
                        loopcol = [loopcol, j];
                    end
                case 4 % southeast
                    if fdir(i+1,j+1) == 8
                        looprow = [looprow, i];
                        loopcol = [loopcol, j];
                    end
                case 5; % south
                    if fdir(i+1,j) == 1
                        looprow = [looprow, i];
                        loopcol = [loopcol, j];
                    end
                case 6 % southwest
                    if fdir(i+1,j-1) == 2
                        looprow = [looprow, i];
                        loopcol = [loopcol, j];
                    end
                case 7 % west
                    if fdir(i,j-1) == 3
                        looprow = [looprow, i];
                        loopcol = [loopcol, j];
                    end
                case 8 % northwest
                    if fdir(i-1,j-1) == 4
                        looprow = [looprow, i];
                        loopcol = [loopcol, j];
                    end
            end
        else
            switch special
                case 'UL'
                    switch fdir(i,j)
                        case 3 % east
                            if fdir(i,j+1) == 7
                                looprow = [looprow, i];
                                loopcol = [loopcol, j];
                            end
                        case 4 % southeast
                            if fdir(i+1,j+1) == 8
                                looprow = [looprow, i];
                                loopcol = [loopcol, j];
                            end
                        case 5; % south
                            if fdir(i+1,j) == 1
                                looprow = [looprow, i];
                                loopcol = [loopcol, j];
                            end
                    end                    
                case 'UR'
                    switch fdir(i,j)
                        case 5; % south
                            if fdir(i+1,j) == 1
                                looprow = [looprow, i];
                                loopcol = [loopcol, j];
                            end
                        case 6 % southwest
                            if fdir(i+1,j-1) == 2
                                looprow = [looprow, i];
                                loopcol = [loopcol, j];
                            end
                        case 7 % west
                            if fdir(i,j-1) == 3
                                looprow = [looprow, i];
                                loopcol = [loopcol, j];
                            end
                    end      
                case 'LL'
                    switch fdir(i,j)
                        case 1 % north
                            if fdir(i-1,j) == 5
                                looprow = [looprow, i];
                                loopcol = [loopcol, j];
                            end
                        case 2; % northeast
                            if fdir(i-1,j+1) == 6
                                looprow = [looprow, i];
                                loopcol = [loopcol, j];
                            end
                        case 3 % east
                            if fdir(i,j+1) == 7
                                looprow = [looprow, i];
                                loopcol = [loopcol, j];
                            end
                    end      
                case 'LR'
                    switch fdir(i,j)
                        case 1 % north
                            if fdir(i-1,j) == 5
                                looprow = [looprow, i];
                                loopcol = [loopcol, j];
                            end
                        case 7 % west
                            if fdir(i,j-1) == 3
                                looprow = [looprow, i];
                                loopcol = [loopcol, j];
                            end
                        case 8 % northwest
                            if fdir(i-1,j-1) == 4
                                looprow = [looprow, i];
                                loopcol = [loopcol, j];
                            end
                    end      
                case 'T'
                    switch fdir(i,j)
                        case 3 % east
                            if fdir(i,j+1) == 7
                                looprow = [looprow, i];
                                loopcol = [loopcol, j];
                            end
                        case 4 % southeast
                            if fdir(i+1,j+1) == 8
                                looprow = [looprow, i];
                                loopcol = [loopcol, j];
                            end
                        case 5; % south
                            if fdir(i+1,j) == 1
                                looprow = [looprow, i];
                                loopcol = [loopcol, j];
                            end
                        case 6 % southwest
                            if fdir(i+1,j-1) == 2
                                looprow = [looprow, i];
                                loopcol = [loopcol, j];
                            end
                        case 7 % west
                            if fdir(i,j-1) == 3
                                looprow = [looprow, i];
                                loopcol = [loopcol, j];
                            end
                    end      
                case 'R'
                    switch fdir(i,j)
                        case 1 % north
                            if fdir(i-1,j) == 5
                                looprow = [looprow, i];
                                loopcol = [loopcol, j];
                            end
                        case 5; % south
                            if fdir(i+1,j) == 1
                                looprow = [looprow, i];
                                loopcol = [loopcol, j];
                            end
                        case 6 % southwest
                            if fdir(i+1,j-1) == 2
                                looprow = [looprow, i];
                                loopcol = [loopcol, j];
                            end
                        case 7 % west
                            if fdir(i,j-1) == 3
                                looprow = [looprow, i];
                                loopcol = [loopcol, j];
                            end
                        case 8 % northwest
                            if fdir(i-1,j-1) == 4
                                looprow = [looprow, i];
                                loopcol = [loopcol, j];
                            end
                    end      
                case 'B'
                    switch fdir(i,j)
                        case 1 % north
                            if fdir(i-1,j) == 5
                                looprow = [looprow, i];
                                loopcol = [loopcol, j];
                            end
                        case 2; % northeast
                            if fdir(i-1,j+1) == 6
                                looprow = [looprow, i];
                                loopcol = [loopcol, j];
                            end
                        case 3 % east
                            if fdir(i,j+1) == 7
                                looprow = [looprow, i];
                                loopcol = [loopcol, j];
                            end
                        case 7 % west
                            if fdir(i,j-1) == 3
                                looprow = [looprow, i];
                                loopcol = [loopcol, j];
                            end
                        case 8 % northwest
                            if fdir(i-1,j-1) == 4
                                looprow = [looprow, i];
                                loopcol = [loopcol, j];
                            end
                    end      
                case 'L'
                    switch fdir(i,j)
                        case 1 % north
                            if fdir(i-1,j) == 5
                                looprow = [looprow, i];
                                loopcol = [loopcol, j];
                            end
                        case 2; % northeast
                            if fdir(i-1,j+1) == 6
                                looprow = [looprow, i];
                                loopcol = [loopcol, j];
                            end
                        case 3 % east
                            if fdir(i,j+1) == 7
                                looprow = [looprow, i];
                                loopcol = [loopcol, j];
                            end
                        case 4 % southeast
                            if fdir(i+1,j+1) == 8
                                looprow = [looprow, i];
                                loopcol = [loopcol, j];
                            end
                        case 5; % south
                            if fdir(i+1,j) == 1
                                looprow = [looprow, i];
                                loopcol = [loopcol, j];
                            end
                    end                        
            end
        end
        
    end
end
   
% Remove initial NaN
looprow = looprow(2:end); 
loopcol = loopcol(2:end); 

return