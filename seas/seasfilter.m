% SEASFILTER splits data using splitperiods, smoothes them with trendfilter,
% and joins them together again with joinperiods.
%
% Usage:
%   f = seasfilter(data,p)
%   f = seasfilter(data,p,varargin)
%
% data is a column vector or an array of column vactors containing the data.
% p is the periodicity of the data (so for instance, if you work with monthly
% observations, p would be 12).
% Additional arguments can be given that are passed on to trendfilter.
%
% seasfilter performs a smoothing of the data for each period separately (so for
% the sequence of observations in Januar, in February, etc, separately). In the
% contect of seasonal filtering, this procedure smoothes the SI-components
% (difference between the data and the trend), which are then called seasonal
% factors.
%
% Example:
% data = sin(0.75*pi*(1:120)/120)';
% s = [-0.2 0 0 0.1 0.4 0.6 0.2 -0.4 -0.3 -0.5 0 0.3];
% s = repmat(s',10,1);
% r = randn(120,1);
% noisy = data + s*0.5 + r*0.2;
% tr = trendfilter(noisy,'epanech',25);
% si = normalize_seas(noisy,tr);
% sf = seasfilter(si,12,'spline',0.02);
% sa = normalize_seas(data,sf);
% figure('Position',[416 128 560 673]);
% subplot(2,1,1); plot([data,tr,sa],'linewidth',1); grid on;
% subplot(2,1,2); plot(sf,'linewidth',1); grid on;
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
% 2018-10-03    Version 1.33    First version of the 'seas' part of the X-13
%                               toolbox.


function f = seasfilter(data,p,varargin)
    [nobs,nseries] = size(data);
    f = nan(nobs,nseries);
    for c = 1:nseries
        temp   = splitperiods(data(:,c),p);
        temp   = trendfilter(temp,varargin{:});
        f(:,c) = joinperiods(temp,nobs);
    end
end
