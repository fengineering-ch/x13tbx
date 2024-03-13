% WMEAN computes a weighted mean.
%
% wmean.m provides the same functionality as conv.m (a convolution), with
% the following differences:
% - The treatment at the edge of the sample is different. Only those weights
%   are used that correspond to existing data.
% - The sum of the used weights is normalized to one.
% - wmean returns the same number of components as data has.
%
% Usage: s = wmean(data,w,[direction])
%
%   data    An array of data, organized columnwise.
%   w       a vector with an odd number of values.
%   direction is one of 'centered', 'backwards', or 'forward'. Default is
%           'centered'.
%   s       s is the convolution of data and w.
%
% If direction is set to 'backwards' ('forward'), all the weigths in the
% right (left) half of w are set to zero, leading to a non-centerd weighted
% average.
%
% So s(t) = s(t-b:t+b)*w, if the length of w is 2b+1. If some of the data
% are outside the support, they are truncated for the computation.
% Moreover, the result s(s) is divided by the sum of the weights in w that
% are used (i.e. not truncated), thereby ensuring that the result is a
% proper weighted mean.
%
% Example: Let data be some column vector containing a timeseries. Then,
%   s = wmean(data,[1 1 1 1 1])
% returns a moving average of data with a bandwidth of 5.
%   load unemp;
%   plot(unemp.dates,[unemp.data,wmean(unemp.data,[1 1 1 1 1])]);
%
% NOTE: This program is part of the X-13 toolbox, but it is completely
% independent of the Census X-13 program. It is part of the 'seas' addition
% to the toolbox which allows to implement seasonal filters without using
% the Census Bureau programs.
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
% 2019-10-17    Version 1.34    Adderd direction option.
% 2018-09-19    Version 1.33    First version of the 'seas' part of the X-13
%                               toolbox.

function s = wmean(data,w,direction)

    laglead = (numel(w)-1)/2;
    assert(laglead == fix(laglead), ...
        'Weights vector must contain an odd number of components.');
    
    if nargin<3
        direction = 'centered';
    end
    direction = validatestring(direction, ...
        {'centered','backward','forward'});
    switch direction
        case 'centered'
            % do nothing
        case 'backward'
            w(1:laglead) = 0;
        case 'forward'
            w(laglead+2:end) = 0;
    end
    
    [nobs,nseries] = size(data);
    s = nan(nobs,nseries);
    for c = 1:nseries
        for z = 1:nobs
            thisw = w(:);
            fromIdx = z-laglead;
            toIdx = z+laglead;
            if fromIdx < 1
                thisw = thisw(2-fromIdx:end);
                fromIdx = 1;
            end
            if toIdx > nobs
                thisw = thisw(1:end-(toIdx-nobs));
                toIdx = nobs;
            end
            thisdata = data(fromIdx:toIdx,c);
            valid = ~isnan(thisdata);
            s(z,c) = sum(thisdata(valid) .* thisw(valid)) / sum(thisw(valid));
        end
    end

end
