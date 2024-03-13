% PREADJUSTONEPERIOD replaces the seasonally unadjusted data for one month or
% one quarter, respectively, by the adjusted data, and then recomputes the
% seasonal adjustment.
%
% Usage:
%   obj = preadjustOnePeriod(obj,p)
%
% obj is a x13series (x13composites are not supported) that contains some
% seasonal adjustment. p is an integer between 1 and obj.period. p can also be a
% vector of such integers.
% 
% Example: Let obj be an x13series object with monthly periodicity and seasonal
% adjustment. Then, obj = preadjustOnePeriod(obj,12) will replace the December
% values with the seasonally adjusted data, and recompute the seasonal
% adjustment. The procedure also removes all outliers (such as ao or ls or hol)
% using addCDT.
%
% Procedure: The first step is to use addCDT to remove the outliers. The second
% step is to use addASC to compute the additive seasonal contribution (asc).
% Then, the asc of the particular period(s) is removed from the data and the
% seasonal adjustment is computed again.
%
% NOTE: This file is part of the X-13 toolbox.
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
% 2017-06-24    Version 1.32    First Version of preadjustOnePeriod.

function obj = preadjustOnePeriod(obj,p)

    % compute cdt and extract corrected data
    obj   = addCDT(obj);
    obj   = addASC(obj);
    dat   = obj.cdt.cdt;
    dates = obj.cdt.dates;

    % remove outliers and calendar effects from specification (they should have
    % been taken care of already)
    spec = makespec(obj.specgiven, ...
        'NO OUTLIERS', ...
        'regression','aictest'  ,[], ...
        'regression','variables',[], ...
        'regression','save'     ,[], ...
        'regression','print'    ,[]);

    % adjust name of series
    switch obj.period
        case 12
            pname = {'January, ','February, ','March, ','April, ','May, ', ...
                'June, ','July, ','August, ','September, ','October, ', ...
                'November, ','December, '};
            pname = [pname{p}];
            pname(end-1:end) = [];
        case 4
            pname = {'First, ','Second, ','Third, ','Fourth, '};
            pname = [pname{p}];
            pname = [pname(1:end-2),' Quarter'];
        otherwise
            pname = sprintf('#%i, ',p);
            pname = ['Period ',pname(1:end-2)];
    end
    name = sprintf('%s (%s pre-adjusted)', obj.name, pname);
    spec = x13spec(spec, ...
        'series','name',name, ...
        'series','file',[]);
    if ismember('cms',obj.listofitems)  % this is the composite series
        inherit = {'decimals','modelspan','appendfcst','appendbcst','type'};
        for h = 1:numel(inherit)
            if ismember(inherit{h},fieldnames(spec.composite))
                spec = x13spec(spec, ...
                    'series', inherit{h}, spec.composite.(inherit{h}));
            end
        end
        spec = x13spec(spec, 'composite',[],[]);
    end
    
    % replace the particular month in the cdt by the seasonally adjusted values
    switch obj.period
        case 4
            idx = ismember(yqmd(dates,'q'),p);
        case 12
            idx = ismember(yqmd(dates,'m'),p);
        otherwise
            idx = false(numel(dat),1);
            for pp = 1:numel(p)
                idx(p(pp):obj.period:numel(dat)) = true;
            end
    end
    dat(idx) = dat(idx) - obj.asc.asc(idx);
    
    % perform X-13 again
    obj = x13([dates,dat],spec);

end
