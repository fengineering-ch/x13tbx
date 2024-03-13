% SPLITPERIODS splits one vector of data into several columns, each containing a
% particular seasonal component.
%
% Usage: sdata = splitperiods(data,p)
%
% data      A column vector containing a time series.
% p         The period of observation of the data.
% sdata     an array with p columns, each containing a part of data.
%
% Example: Let data contain monthly observations of some variable. Here, we use
% the US civilian unemployment rate:
%
%   load unemp; d = unemp.data; n = numel(d);
%   m = splitperiods(d,12);
%
% Now sdata contains 12 columns. The first contains all observations from
% January, the second from February, etc.
%
%   nanmean(m)
%
%   Columns 1 through 7
%     6.8769    6.7615    6.5231    6.0436    6.0436    6.4718    6.4359
%   Columns 8 through 12
%     6.2026    6.0763    5.9579    6.0105    6.0158
% 
% These are the average unemployment rate over the whole sample of years,
% separately for each month.
%
% We can also plot the data month-wise
%
%   plot(m,'linewidth',1); grid on;
%   legend('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct', ...
%       'Nov','Dec');
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

function data = splitperiods(data,p)
    t = p - mod(numel(data)-1,p)-1;     % add nans to make length of data ...
    data(end+1:end+t) = nan;            % ... a multiple of p
    data = reshape(data,p,[])';         % col 1 = month 1 etc, rows are years
end
