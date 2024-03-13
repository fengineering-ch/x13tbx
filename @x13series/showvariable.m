% SHOWVARIABLE returns a table with the content of a variable. Each column
% is a period (month or quarter) and each row is one year.
%
% Usage:
%   showvariable(obj,name)
%   showvariable(obj,name1,name2,...)
%   tbl = showvariable(...)
%
% Inputs:
%   obj      A x13series or x13composite object.
%   name     The three-letter name of a variable in obj.
%
% Outputs:
%   tbl      A table. If multiple names are given, tbl is a cell array of
%            tables.
%
% Example:
%   load BoxJenkinsG;
%   x = x13(BoxJenkinsG.dates,BoxJenkinsG.data,makespec('FULLX11'));
%   x.showvariable('d9')
% produces
%            Jan        Feb        Mar        Apr        May       Jun       Jul       Aug      Sep      Oct        Nov        Dec  
%          _______    _______    _______    _______    _______    ______    ______    ______    ___    _______    _______    _______
% 
% y1949        NaN        NaN        NaN        NaN        NaN       NaN       NaN       NaN    NaN        NaN        NaN        NaN
% y1950        NaN        NaN        NaN        NaN    0.92568       NaN       NaN       NaN    NaN        NaN    0.81459        NaN
% y1951    0.91268        NaN     1.0544        NaN        NaN       NaN       NaN       NaN    NaN        NaN        NaN        NaN
% y1952    0.91579    0.94117        NaN        NaN        NaN    1.1089       NaN       NaN    NaN        NaN        NaN        NaN
% y1953        NaN        NaN        NaN    0.98245    0.99152       NaN    1.1989       NaN    NaN        NaN        NaN        NaN
% y1954        NaN    0.88632        NaN        NaN        NaN       NaN       NaN       NaN    NaN        NaN        NaN        NaN
% y1955        NaN        NaN        NaN        NaN        NaN       NaN       NaN       NaN    NaN        NaN        NaN        NaN
% y1956        NaN        NaN        NaN        NaN        NaN       NaN       NaN       NaN    NaN        NaN        NaN        NaN
% y1957        NaN        NaN        NaN        NaN        NaN       NaN       NaN       NaN    NaN        NaN        NaN        NaN
% y1958        NaN        NaN        NaN    0.94755        NaN       NaN       NaN    1.2583    NaN    0.94195        NaN    0.87375
% y1959        NaN        NaN        NaN        NaN        NaN       NaN       NaN       NaN    NaN    0.92134        NaN    0.88138
% y1960        NaN    0.83732    0.96048    0.95257    0.98866       NaN       NaN       NaN    NaN        NaN        NaN        NaN
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
% 2020-05-19    Version 1.50     Small improvements.
% 2020-04-11    Version 1.41     First Version

%#ok<*AGROW>

function t = showvariable(x,varargin)

    % first arg should be the x13composite object
    assert(isa(x,'x13series') || isa(x,'x13composite'), ...
        'X13TBX:showvariable:notX13', ...
            'First argument has to be a x13series or x13composite object')
        
    % get all series names ...
    vrbl = x.listofitems;
    variable = cell(0);
    description = cell(0);
    while ~isempty(varargin)
        if ~(length(varargin{1}) <= 3 && ischar(varargin{1}))
            warning('Item ''%s'' is not a three-letter variable name.', ...
                varargin{1});
        elseif ~ismember(varargin{1},vrbl)
            warning('Item ''%s'' is not present in the x13 object.',varargin{1});
        else
            [descr,type] = x.descrvariable(varargin{1});
            if ~(type==1)
                warning(['Only time series can be printed into a table. ', ...
                    'Item ''%s'' is not a time series.'],varargin{1});
            else
                variable{end+1} = varargin{1};
                description{end+1} = descr;
            end
        end
        varargin(1) = [];
    end
    
    % determine offset and column titles
    p = x.period;
    switch p
        case 12
            offset = yqmd(x.dat.dates(1),'m') - 1;
            coltitles = {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug', ...
                'Sep','Oct','Nov','Dec'};
        case 4
            offset = yqmd(x.dat.dates(1),'q') - 1;
            coltitles = {'Q1','Q2','Q3','Q4'};
        otherwise
            offset = 1;
            coltitles = arrayfun(@(c) ['S',int2str(c)], 1:p, 'UniformOutput',false);
    end

    % make table
    n = numel(variable);
    t = cell(1,n);
    for v = 1:n
        d = x.(variable{v}).(variable{v});
        d = [NaN(offset,1);d];
        data = splitperiods(d,p);
        t{v} = table;
        for s = 1:p
            t{v} = [t{v},table(data(:,s),'VariableName',coltitles(s))];
        end
        if p==12 || p==4
            rowtitles = yqmd(x.dat.dates(1),'y'):yqmd(x.dat.dates(end),'y');
            rowtitles = arrayfun(@(c) {['y',int2str(c)]}, rowtitles)';
            t{v}.Properties.RowNames = rowtitles;
        end
        if isempty(x.spec.name)
            t{v}.Properties.Description = variable{v};
        else
            t{v}.Properties.Description = [x.spec.name,': ',variable{v}];
        end
        t{v}.Properties.UserData = description{v};
        t{v}.Properties.DimensionNames = {'Year','Period'};
    end
    
    % un-cell if there is only one table
    if n==1
        t = t{1};
    end
    
    % display result if user does not assign it to a variable
    if nargout < 1
        disp(t);
        clear t;
    end
    
end
