% TAKEDAYOFF helps you define special variables for regressions in seasonal
% adjustment that indicate whether holidays are located such that people might
% have an incentive to take a day off (i.e. on a Tuesday or Thursday).
%
% Usage:
%   spec = TakeDayOff(specialdays,filename,specialweekdays,fromYear,toYear)
%
% specialday    This is a matrix with three columns and a maximum of five rows.
%               The first column is the month, the second the day, and the
%               third the length of the holiday. Default is [12 24 2],
%               indicating Christmas (two days starting on Dec 24). If you also
%               want to test for, say, 4th of July, use this: [12 24 2; 7 4 1].
% filename      The name of the file created on hard drive that contains the
%               user variables (and that are read by the x13as.exe program).
%               Default is '_user.dat'
% specialweekdays    List of two integers, indicating the weekdays to test for
%               at the beginning of a special day and at the end of it. Default
%               is [3 5], so that the program tests if the beginning is a
%               Tuesday (3) and the end is a Thursday (5).
% fromYear, toYear   The user variable is created for this interval of years.
%               Default is from 1900 to 2200.
% spec          A x13spec object to be integrated into your x13 run.
%
% Example:
%   userspec = TakeDayOff();
%   disp(userspec);
% 
% This produces
% ==============================================================================
%  X-13/X-12 specification object
% ..............................................................................
%  - regression
%     - user : (Dec24Tue Dec25Thu)
%     - file : _user.dat
%     - format : datevalue
%     - usertype : (holiday holiday)
%     - aictest : user
%     - save : hol
%
% This spec can be used by saying:
%   spec = makespec('DEFAULT',userspec);
%   x = x13(dates,data,spec);
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
% 2018-09-08    Version 1.33    First version.

function userspec = TakeDayOff(specialdays,filename,specialweekdays,fromYear,toYear)  

    % verify user input

    if nargin < 1 || isempty(specialdays)
        specialdays = [12 24 2];    % X'mas
    end
    
    mspecial = specialdays(:,1);    % month of special event
    dspecial = specialdays(:,2);    % day of special event
    lspecial = specialdays(:,3);    % length of special event (in days)
    nvar = size(specialdays,1);
    
    if nvar > 5
        error('X13TBX:TAKEDAYOFF:TooManyHolidays', ...
            'At most 5 holidays can be specified.');
    end
    
    if nargin < 2 || isempty(filename)
        filename = '_user.dat';
    end
    
    if nargin < 3 || isempty(specialweekdays)
        Tue = 3; Thu = 5;
    else
        assert(numel(specialweekdays) == 2 && ...
            all(isnumeric(specialweekdays)) && ...
            max(specialweekdays - fix(specialweekdays)) == 0 && ...
            all(specialweekdays >= 1 & specialweekdays <= 7), ...
            'X13TBX:TAKEDAYOFF:illarg',['specialweekdays must ', ...
                'contain exactly two integers between 1 and 7.']);
        Tue = specialweekdays(1); Thu = specialweekdays(2);
    end
    
    if nargin < 4 || isempty(fromYear)
        fromYear = 1900;
    end
    
    if nargin < 5 || isempty(toYear)
        toYear = 2200;
    end
    
    % create variable
    
    all_y = (fromYear:toYear)';
    numyear = numel(all_y); numdates = 12*numyear;
    all_m = repmat((1:12)',numyear,1);
    all_ym = repmat(all_y',12,1); all_ym = [all_ym(:),all_m];

    val = zeros(numdates,nvar);
    names = cell(1,nvar*2);
    
    for b = 1:nvar
        
        alldates = datenum([all_ym, ...
            repmat(dspecial(b),numdates,1)]);
        specialdates = datenum([all_y, ...
            repmat([mspecial(b),dspecial(b)],numyear,1)]);
        hit = ismember(alldates,specialdates);
        hit(weekday(alldates) ~= Tue) = false;
        val(hit,2*b-1) = 1;
        names{2*b-1} = mdstr(dspecial(b),mspecial(b),Tue);

        alldates = alldates + lspecial(b) - 1;
        specialdates = specialdates + lspecial(b) - 1;
        hit = ismember(alldates,specialdates);
        hit(weekday(alldates) ~= Thu) = false;
        val(hit,2*b) = 1;
        names{2*b} = mdstr(day(specialdates(1)), ...
            month(specialdates(1)),Thu);
        
        if b == 1
            usertype = 'holiday holiday';
        else
            usertype = sprintf('%s %s%i %s%i', ...
                usertype,'holiday',b,'holiday',b);
        end            
    
    end
    
    % write file to disk (for later import by x13as.exe)
    
    f = [all_ym,val];               % matrix to be written into file
    dlmwrite(filename,f,char(9));   % tab-separated file (tab = char(9))
    
    % create x13spec object
    
    names = ['(',strjoin(names,' '),')'];
    usertype = ['(',usertype,')'];
    
    userspec = x13spec( ...
        'regression', 'user'    , names, ...
        'regression', 'file'    , filename, ...
        'regression', 'format'  , 'datevalue', ...
        'regression', 'usertype', usertype, ...
        'regression', 'aictest' , 'user', ...
        'regression', 'save'    , 'hol');
    
    % -------------------------------------------------------------------------
    
    function str = mdstr(dd,mm,wd)
        dd = ['0',int2str(dd)];
        dd = dd(end-1:end);
        switch mm
            case  1; mm = 'Jan';
            case  2; mm = 'Feb';
            case  3; mm = 'Mar';
            case  4; mm = 'Apr';
            case  5; mm = 'May';
            case  6; mm = 'Jun';
            case  7; mm = 'Jul';
            case  8; mm = 'Aug';
            case  9; mm = 'Sep';
            case 10; mm = 'Oct';
            case 11; mm = 'Nov';
            case 12; mm = 'Dec';
        end
        switch wd
            case  1; wd = 'Sun';
            case  2; wd = 'Mon';
            case  3; wd = 'Tue';
            case  4; wd = 'Wed';
            case  5; wd = 'Thu';
            case  6; wd = 'Fri';
            case  7; wd = 'Sat';
        end
        str = [mm,dd,wd];
    end

end
