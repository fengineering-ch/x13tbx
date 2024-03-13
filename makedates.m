% MAKEDATES returns a vector of dates with given frequency.
%
% Usage:
%   d = makedates(startdate,enddate,period,[mult])
%   d = makedates(startdate,length,period,[mult])
%
% startdate and enddate are calendar days indicating when the series should
% start and end. They can be given as simple three-component vectors
% [year,month,day], as datenum numbers, or as datetime variables.
%
% If the first argument is a vector with three components, but the
% second argument is just one number (not a vector with three components), it
% is interpreted as the length of the date vector.
%
% period is one of the following: 'year', 'semester', 'trimester',
% 'quarter', 'month', 'week', 'weekday', or 'day'.
%
% mult is a multiple: using period='day' and mult=3 returns every third
% day. 'day',7 is equivalent to 'week',1, 'month',3 is equivalent to
% 'quarter',1, etc. However, 'week',4 is not equivalent to 'month',1
% because a month does not contain exactly four weeks. mult must be a
% positive integer. Default for mult is 1.
%
% Example 1:
%     d = makedates([2019,2,1],[2020,5,20],'quarter');
%     disp(datestr(d));
%     01-Feb-2019
%     01-May-2019
%     01-Aug-2019
%     01-Nov-2019
%     01-Feb-2020
%     01-May-2020
% Example 2:
%     d = makedates([2019,1,31],[2019,7,15],'month');
%     disp(datestr(d));
%     31-Jan-2019
%     28-Feb-2019
%     31-Mar-2019
%     30-Apr-2019
%     31-May-2019
%     30-Jun-2019
%     Note: If the day in the startdate is the last day of the month, then
%     the last day of the month will be used for all entries.
% Example 3:
%     d = makedates([2019,1,1],[2019,3,31],'week',2);
%     disp(datestr(d));
%     01-Jan-2019
%     15-Jan-2019
%     29-Jan-2019
%     12-Feb-2019
%     26-Feb-2019
%     12-Mar-2019
%     26-Mar-2019
% Example 4:
%     d = makedates([2020,1,15],10,'month',2);
%     disp(datestr(d));
%     15-Jan-2020
%     15-Mar-2020
%     15-May-2020
%     15-Jul-2020
%     15-Sep-2020
%     15-Nov-2020
%     15-Jan-2021
%     15-Mar-2021
%     15-May-2021
%     15-Jul-2021
%
% NOTE: This program is part of the X-13 toolbox, but it is completely
% independent of the Census X-13 program and can be used even if the census
% programs are not installed.
% The toolbox consists of the following programs, guix, x13, makespec, x13spec,
% x13series, x13composite, x13series.plot,x13composite.plot, x13series.seasbreaks,
% x13composite.seasbreaks, fixedseas, camplet, spr, InstallMissingCensusProgram
% makedates, yqmd, TakeDayOff, EasterDate.
%
% Author  : Yvan Lengwiler
% Version : 1.53
%
% If you use this software for your publications, please reference it as:
%
% Yvan Lengwiler, 'X-13 Toolbox for Matlab, Version 1.55', Mathworks File
% Exchange, 2014-2023.
% url: https://ch.mathworks.com/matlabcentral/fileexchange/49120-x-13-toolbox-for-seasonal-filtering

% History:
% 2023-10-19    Version 1.53    Bug fix (dealing with datetime inputs)
% 2020-07-08    Version 1.41    Distinguish better between length and
%                               datenum entry for 'enddate' argument.
% 2020-06-26    Version 1.40    Bug Fixes
% 2020-03-16    Version 1.36    Added length option. Bug fix.
% 2019-08-19    Version 1.33    First version of 'makedates'.

function dates = makedates(startdate,enddate,period,mult)
    
    % pre-treat inputs
    
    if isnumeric(startdate)
        switch numel(startdate)
            case 1 % do nothing, assume its a datenum
            case 2
                startdate = datenum(startdate(1),startdate(2),15);
            case 3
                startdate = datenum(startdate);
            otherwise
                err = MException('X13TBX:makedates:ParseError', ...
                    [e.message, '\nCannot interpret ''startdate = %s''.'], ...
                    string(startdate));
                throw(err);
        end
    elseif isa(startdate,'datetime')
        startdate = datenum(startdate);
    else
        err = MException('X13TBX:makedates:ParseError', ...
            [e.message, '\nCannot interpret ''startdate''.\nThis should\n', ...
            'be a 3-components row vector, a datenum, or a datetime.']);
        throw(err);
    end
    
    isNobsUnknown = true;
    if isnumeric(enddate)
        switch numel(enddate)
            case 1 % can be the length or a datenum
                if enddate < startdate % assume it's the length
                    nobs = enddate;
                    enddate = NaN;
                    isNobsUnknown = false;
                end % assume it's a datenum, then nothing needs to be done here
            case 2
                enddate = datenum(enddate(1),enddate(2),15);
            case 3
                enddate = datenum(enddate);
            otherwise
                err = MException('X13TBX:makedates:ParseError', ...
                    [e.message, '\nCannot interpret ''enddate = %s''.'], ...
                    string(enddate));
                throw(err);
        end
    elseif isa(enddate,'datetime')
        enddate = datenum(enddate);
    else
        err = MException('X13TBX:makedates:ParseError', ...
            [e.message, '\nCannot interpret ''enddate''.\nThis should\n', ...
            'be a 3-components row vector, a datenum, or a datetime.']);
        throw(err);
    end
    
    if nargin<4 || isempty(mult); mult = 1; end
    assert(fix(mult)==mult && mult>0,'X13TBX:MAKEDATES:IllArg', ...
        'The fourth argument (mult) must be a positive integer.');
    
    % if the user specifies the frequency with a number...
    if isnumeric(period)
        if period == 1
            period = 'year';
        elseif period == 2
            period = 'semester';
        elseif period == 3
            period = 'trimester';
        elseif period == 4
            period = 'quarter';
        elseif period == 12
            period = 'month';
        elseif period == 52
            period = 'week';
        elseif period == 260
            period = 'weekday';
        elseif period == 365
            period = 'day';
        end
    end
    
    % select frequency
    legal = {'year','semester','trimester','quarter','month',...
        'week','weekday','day'};
    period = validatestring(period,legal);    % check for valid type
    
    % make output
    freq = [365,365/2,365/3,365/4,28,7,7/5,1]*mult;
    freq = freq(ismember(legal,period));
    if isNobsUnknown
        nobs = ceil((enddate-startdate+1) / freq);
    else
        enddate = startdate + nobs * freq * 1.05 + 100; % ... just for safety
    end
    switch period
        case 'day'
            dates = (startdate:mult:enddate);
        case 'weekday'
            dates = (startdate:enddate);
            remove = (weekday(dates) == 7 | weekday(dates) == 1);
            dates(remove) = [];
            if mult>1
                keep = [1,zeros(1,mult-1)];
                keep = repmat(keep,1,ceil(numel(dates)/mult));
                remove = not(keep);
            end
            dates(remove(1:numel(dates))) = [];
        case 'week'
            dates = (startdate:7*mult:enddate);
        case {'month','quarter','trimester','semester','year'}
            switch period
                case 'quarter';     mult = mult*3;
                case 'trimester';   mult = mult*4;
                case 'semester';    mult = mult*6;
                case 'year';        mult = mult*12;
            end
            dates = NaN(1,nobs);
            dates(1) = startdate;
            lastday = (eomday(year(startdate),month(startdate)) ...
                == day(startdate));
            for c = 2:nobs
                dates(c) = addtodate(dates(c-1),mult,'month');
                if lastday
                    y = year(dates(c)); m = month(dates(c));
                    dates(c) = datenum(y,m,eomday(y,m));
                end
            end
    end
    if isNobsUnknown
        dates(dates > enddate) = [];
    else
        dates(nobs+1:end) = [];
    end
    dates = dates';

end
