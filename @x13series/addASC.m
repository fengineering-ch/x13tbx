% ADDASC computes the absolute seasonal contribution in an x13series object and
% places it into the object as new variable called asc ('absolute seasonal
% contribution').
%
% Usage:
%   obj = addASC(obj)
%
% obj must be a x13series object with some form of seasonal adjustment (X11,
% SEATS, FIXEDSEAS, or CAMPLET). x13composites are not supported. The returned
% obj contains a new series, called obj.asc. This series contains the absolute
% seasonal contribution.
%
% If the seasonal adjustment is additive, the absolute seasonal contribution is
% simply the seasonal factor (and there is not much point in applying addASC).
% If the seasonal adjustment is multiplicative, however, then asc = (sf-1)*tr,
% where sf is the multiplicative seasonal factor and tr is the trend component.
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
% 2017-06-24    Version 1.32    First Version of addASC.

function obj = addASC(obj)

    if ismember('asc',obj.listofitems)
        obj = obj.rmitem('asc');
    end
    
    if isempty(obj.isLog)
        e = MException('AddAbsoluteSeasonality:NotAdditiveOrMultiplicative', ...
            ['Seasonal adjustment is neither additive not multiplicative. ', ...
            'Cannot proceed']);
        throw(e);
    else
        success = true;
        if ~obj.isLog
            if ismember('d10',obj.listofitems)
                obj = obj.addvariable('asc', obj.d10.dates, obj.d10.d10, ...
                    {'asc'}, 1, 'absolute seasonal contribution (= seasonal factor)');
            elseif ismember('s10',obj.listofitems)
                obj = obj.addvariable('asc', obj.s10.dates, obj.s10.s10, ...
                    {'asc'}, 1, 'absolute seasonal contribution (= seasonal factor)');
            elseif ismember('sf',obj.listofitems)
                obj = obj.addvariable('asc', obj.sf.dates, obj.sf.sf, ...
                    {'asc'}, 1, 'absolute seasonal contribution (= seasonal factor)');
            elseif ismember('csf',obj.listofitems)
                obj = obj.addvariable('asc', obj.csf.dates, obj.csf.csf, ...
                    {'asc'}, 1, 'absolute seasonal contribution (= seasonal factor)');
            else
                success = false;
            end
        else
            if all(ismember({'d10','d12'},obj.listofitems))
                asc = (obj.d10.d10-1) .* obj.d12.d12;
                obj = obj.addvariable('asc', obj.d10.dates, asc, ...
                    {'asc'}, 1, 'absolute seasonal contribution, (S-1)*T');
            elseif all(ismember({'s10','s12'},obj.listofitems))
                asc = (obj.s10.s10-1) .* obj.s12.s12;
                obj = obj.addvariable('asc', obj.s10.dates, asc, ...
                    {'asc'}, 1, 'absolute seasonal contribution, (S-1)*T');
            elseif all(ismember({'sf','tr'},obj.listofitems))
                asc = (obj.sf.sf-1) .* obj.tr.tr;
                obj = obj.addvariable('asc', obj.sf.dates, asc, ...
                    {'asc'}, 1, 'absolute seasonal contribution, (S-1)*T');
            elseif all(ismember({'csf','csa'},obj.listofitems))
                asc = (obj.csf.csf-1) .* obj.csa.csa;
                obj = obj.addvariable('asc', obj.csf.dates, asc, ...
                    {'asc'}, 1, 'absolute seasonal contribution, (S-1)*SA');
            else
                success = false;
            end
        end
    end
    
    if ~success
        e = MException('AddAbsoluteSeasonality:NoValidSeasAdj', ...
            ['No valid seasonal adjustment was found. You need to run x13 ', ...
            'first with the X11 or SEATS or FIXEDSEAS or CAMPLET option set.']);
        throw(e);
    end
    
end
