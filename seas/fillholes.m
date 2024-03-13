% FILLHOLES filles missing values of a dataarray columnwise with linear
% interpolations. If data are missing at the edge of the vector, the missing
% values are left untouched, that is, no extrapolations are performed.
%
% Usage: data = fillholes(data)
%
% NOTE: This program is part of the X-13 toolbox, but it is completely
% independent of the Census X-13 program. It is part of the 'seas' addition to
% the toolbox which allows to implement seasonal filters without using the
% Census Bureau programs.
%
% see also guix, x13, makespec, x13spec, x13series, x13composite, 
% x13series.plot,x13composite.plot, x13series.seasbreaks,
% x13composite.seasbreaks, fixedseas, camplet, spr, InstallMissingCensusProgram
%
% Author  : Yvan Lengwiler
% Version : 1.55
%
% If you use this software for your publications, please reference it as:
%
% Yvan Lengwiler, 'X-13 Toolbox for Matlab, Version 1.55', Mathworks File
% Exchange, 2014-2023.
% url: https://ch.mathworks.com/matlabcentral/fileexchange/49120-x-13-toolbox-for-seasonal-filtering

% History:
% 2018-09-19    Version 1.33    First version of the 'seas' part of the X-13
%                               toolbox.

function data = fillholes(data)

    % nothing to do?
    valid = ~isnan(data);
    if all(all(valid))
        return;
    end
    
    % fill the holes columnwise
    x = 1:size(data,1);
    for c = 1:size(data,2)
        fill = interp1(x(valid(:,c)),data(valid(:,c)),x(~valid(:,c)));
        data(~valid(:,c),c) = fill;
    end
    
end
