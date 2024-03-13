% NORMALIZE_SEAS computes the additive or multiplicative difference of two time
% series
%
% Usage:
%   adj = normalize_seas(data,trend,[ismult])
%
% data and trend must be a vectors of equal length. ismult is a boolean.
%
% adj ist either data-trens (is ismult is missing or false), and
% data./trend is ismult is true.
%
% NOTE: This file is part of the X-13 toolbox, but it is completely
% independent of the Census X-13 program. It is part of the 'seas' addition
% to the toolbox which allows to implement seasonal filters without using
% the Census Bureau programs.
% The toolbox consists of the following programs, guix, x13, makespec, x13spec,
% x13series, x13composite, x13series.plot,x13composite.plot, x13series.seasbreaks,
% x13composite.seasbreaks, fixedseas, camplet, spr, InstallMissingCensusProgram
% makedates, yqmd, TakeDayOff, EasterDate.
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

function adj = normalize_seas(data,trend,varargin)

    if isempty(varargin)
        ismult = false;
    else
        ismult = varargin{1};
    end
    
    if ismult
        adj = data ./ trend;
    else
        adj = data - trend;
    end
    
end
