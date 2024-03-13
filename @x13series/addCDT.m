% ADDCDT removes outliers and holday corrections from dat and stores the result
% as a new variable called cdt ('corrected data').
%
% Usage:
%   obj = addCDT(obj)
%   obj = addCDT(obj,'...');
%   obj = addCDT(obj,'...','...', ...);
%
% obj must be a x13series object. (x13composites are not supported.) If only the
% obj is given as argument, then the following series (if present) are removed
% from the data: 'ls','ao','tc','hol','td'. Alternatively, the user can also
% provide a list of series to remove from the data, e.g. addCDT(obj,'ls') will
% remove only level shifts ('ls') from the data. The result is stored as
% obj.cdt.
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
% 2017-06-24    Version 1.32    First Version of addCTD.

function obj = addCDT(obj,varargin)

    % remove existing cdt
    if ismember('cdt',obj.listofitems)
        obj = obj.rmitem('cdt');
    end
    
    % find list of variables to use for the correction
    if isempty(varargin)
        list = {'ls','ao','tc','hol','td'};
    else
        list = varargin;
    end
    descr = list{end};
    for c = numel(list)-1:-1:1
        descr = [list{c},', ',descr]; %#ok<AGROW>
    end
    descr = ['data corrected for ',descr];

    idx = ismember(list,obj.listofitems);
    list = list(idx);

    % get uncorrected data
    try
        cdt   = obj.dat.dat;
        dates = obj.dat.dates;
    catch
        cdt   = obj.cms.cms;
        dates = obj.cms.dates;
    end
    
    % make the correction
    if obj.isLog
        for l = 1:numel(list)
            d = intersect(dates,obj.(list{l}).dates);
            idx1 = ismember(dates,d);
            idx2 = ismember(obj.(list{l}).dates,d);
            cdt(idx1) = cdt(idx1) ./ obj.(list{l}).(list{l})(idx2);
        end
    else
        for l = 1:numel(list)
            d = intersect(dates,obj.(list{l}).dates);
            idx1 = ismember(dates,d);
            idx2 = ismember(obj.(list{l}).dates,d);
            cdt(idx1) = cdt(idx1) - obj.(list{l}).(list{l})(idx2);
        end
    end
    
    % add new variable to the x13series object
    obj = obj.addvariable('cdt', dates, cdt, {'cdt'}, 1, descr);
    
end
