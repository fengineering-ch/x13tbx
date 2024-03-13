% EASTERDATE computes date of Easter for the western and the orthodox churches
%
% Usage:
%   [d,g,j] = EasterDate(y,['western' or 'eastern' or 'orthodox']);
%
% y     A year or a vector of years.
% d     The date of Easter as a datenum.
% g     A [year,month,day] vector containing the date in the Gregorian
%       calendar.
% j     The same as g but using the Julian calendar. This is only returned
%       if the orthodox version of the Easter date is computed.
% 'w','e','o'   Indicates if the western or the orthodox (eastern) Easter
%       date is to be computed. 'eastern' is synonymous to 'orthodox'.
%
% Example:
% w = EasterDate(2020:2030);
% o = EasterDate(2020:2030,'orth');
% [datestr(w),repmat('; ',11,1),datestr(o)]
%     '12-Apr-2020; 19-Apr-2020'
%     '04-Apr-2021; 02-May-2021'
%     '17-Apr-2022; 24-Apr-2022'
%     '09-Apr-2023; 16-Apr-2023'
%     '31-Mar-2024; 05-May-2024'
%     '20-Apr-2025; 20-Apr-2025'
%     '05-Apr-2026; 12-Apr-2026'
%     '28-Mar-2027; 02-May-2027'
%     '16-Apr-2028; 16-Apr-2028'
%     '01-Apr-2029; 08-Apr-2029'
%     '21-Apr-2030; 28-Apr-2030'
%
% The program implements the Meeus/Jones/Butcher algorithm for the Western
% Easter date and the Meeus algorithm for the Orthodox Easter date, see
% https://en.wikipedia.org/wiki/Computus
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
% 2020-06-29    Version 1.40    First version

function [datecode,greg_vector,jul_vector] = EasterDate(y,type)

    if nargin < 2 || isempty(type)
        type = 'western';
    end
    type = validatestring(type,{'western','eastern','orthodox'});
    
    y = int16(fix(y(:)));

    switch type
        
        case 'western'
            % Meeus/Jones/Butcher algorithm
            a = mod(y,19);
            b = idivide(y,100);
            c = mod(y,100);
            d = idivide(b,4);
            e = mod(b,4);
            f = idivide(b+8,25);
            g = idivide(b-f+1,3);
            h = mod(19*a+b-d-g+15,30);
            i = idivide(c,4);
            k = mod(c,4);
            l = mod(32+2*e+2*i-h-k,7);
            m = idivide(a+11*h+22*l,451);
            n = h+l-7*m+114;
            greg_month = idivide(n,31);
            greg_day = mod(n,31)+1;
            jul_vector = [];
            
        case {'eastern','orthodox'}
            % Meeus algorithm
            a = mod(y,4);
            b = mod(y,7);
            c = mod(y,19);
            d = mod((19*c+15),30);
            e = mod((2*a+4*b-d+34),7);
            jul_month = idivide((d+e+114),31);
            jul_day = mod((d + e + 114),31)+1;
            jul_vector = [y,jul_month,jul_day];
            
            % from Julian to Gregorian dates
            div100 = idivide(y,100)-2;
            div400 = idivide(y,400);
            greg_day = jul_day + div100 - div400;
            greg_month = jul_month;
            ldom = repmat(int16(31),numel(y),1);    % last day of month: March ...
            ldom(greg_month==4) = int16(30);        % ... April
            idx = (greg_day > ldom);                % spilling into next month
            greg_day(idx) = greg_day(idx)-ldom(idx);
            greg_month(idx) = greg_month(idx)+1;
            
    end

    greg_vector = [y,greg_month,greg_day];
    datecode = datenum(double(greg_vector));
            
end
