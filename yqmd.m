% YQMD retrievs the year, quarter, month, or day of a (vector of) serial dates.
% This is used for versions of Matlab prior to R2013a, before the 'year',
% 'quarter', 'month', and 'day' commands were introduced in Matlab.
%
% Usage: d = yqmd(d,type)
%
% type must be one of the following: 'year', 'semester', 'trimester',
% 'quarter', 'month' or 'm', 'day', 'weekday', 'hour', 'minute', 'second', or
% abbreviations thereof.
%
% NOTE: This file is part of the X-13 toolbox.
%
% Author : Yvan Lengwiler
% Date   : 2015-07-20
%
% If you use this software for your publications, please reference it as:
%
% Yvan Lengwiler, 'X-13 Toolbox for Matlab, Version 1.55', Mathworks File
% Exchange, 2014-2023.
% url: https://ch.mathworks.com/matlabcentral/fileexchange/49120-x-13-toolbox-for-seasonal-filtering

% History:
% 2019-08-19    Version 1.33    Change in the interpretation of type when
%                               given as a numerical input. type=2 is now
%                               semester, type=3 is trimester, type=4 is
%                               quarter.
% 2015-07-20    Version 1.0     First version of 'yqmd'.

function  [d,type] = yqmd(d,type)
    d = datevec(d);
    legal = {'year','month','day','hour','minute','second', ...
        'semester','trimester','quarter','weekday'};
    if ~ischar(type)
        if type == 2                % semester (used to be 6)
            type = 'semester';
        elseif type == 3            % trimester (used to be 4)
            type = 'trimester';
        elseif type == 4            % quarter (used to be 3)
            type = 'quarter';
        elseif type == 12           % month
            type = 'month';
        elseif type == 365          % day
            type = 'day';
        end
    else
        if strcmp(type,'m'); type = 'month'; end
        type = validatestring(type,legal);  % check for valid type
        typeNo = (ismember(legal,type));    % determine position
    end
    switch type
        case 'quarter'
            d = d(:,2);
            d = floor((d-1)/3) + 1;
        case 'trimester'
            d = d(:,2);
            d = floor((d-1)/4) + 1;
        case 'semester'
            d = d(:,2);
            d = floor((d-1)/6) + 1;
        case 'weekday'
            d = weekday(datenum(d));
        otherwise
            d = d(:,typeNo);
    end
end
