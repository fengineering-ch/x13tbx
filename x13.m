% X13 calls the x13as program of the US Census Bureau / Bank of Spain to
% perform seasonal and extreme value adjustments.
%
% Usage (single time series):
%   x = x13([dates,data])
%   x = x13([dates,data],spec)
%   x = x13(dates,data)
%   x = x13(dates,data,spec)
%   x = x13(ts,spec)
%   x = x13(..., 'x-13')
%   x = x13(..., 'html')
%   x = x13(..., 'x-12')
%   x = x13(..., 'x-11')
%   x = x13(..., 'method1') or x = x13(..., 'method I')
%   x = x13(..., 'camplet')
%   x = x13(..., 'fixedseas')
%   x = x13(..., 'prog',filename)
%   x = x13(..., 'progloc',path)
%   x = x13(..., 'quiet')
%   x = x13(..., '-c', '-w', ... etc)
%   x = x13(..., 'noflags')
%   x = x13(..., 'graphicsmode')
%   x = x13(..., 'graphicsloc',path)
%   x = x13(..., 'fileloc',path)
%
% 'dates' and 'data' are single column or single row vectors with obvious
% meanings. 'dates' must contain dates as datenum codes. Alternatively, use
% a timeseries object ('ts') containing a single time series. In version 3
% and 4 above, dates can also be a datetime class variable (this is
% available in ML 2014b and later).
%
% 'spec' is a x13spec object containing the specifications used by the
% x13as.exe program. If no 'spec' is given, the program uses the
% specification that is produced by makespec('DEFAULT'), see help makespec.
%
% The output 'x' is a x13series object containing the requested numerical
% results, as well as the data and dates used as input.
%
% Four switches are available that determine the program that is used to
% perform the seasonal decomposition. The 'x-12' switch uses the x12a
% program instead of the x13as program. The 'x-13' switch enforces the use
% of the x13as program. This is the default.
%
% The 'html' switch uses the 'accessible version' of the Census program.
% The accessible version formats the tables and log files in html. Using
% this version has the advantage that you can view the output neatly
% formatted in your browser. The disadvantage is that the tables are not
% extracted and placed into the x13series (or x13collection) object. So,
% x.listoftables and x.table are empty. Instead, you can inspect the tables
% in the browser with web(x.out) and web(x.log). Note that 'html' has no
% effect if the 'x-12' or 'prog' options (or any other option selecting the
% method such as 'x-11', 'method1', 'camplet' etc) are used.
% 
% The 'x-11' switch uses an approximate version of the original Census X-11
% algorithm from 1965. The original Census X-11 program is available, but
% is not compatible with this toolbox because the format of its in- and
% output is very different from X-12 and X-13. Instead, an approximate
% version of X-11 is implemented in Matlab and this is used when you set
% the 'x-11' switch. This has many limitations. It has one important
% advantage, however: the simplified X-11 implementation can deal with
% arbitrary frequencies (not only monthly or quarterly data as the Census
% programs do). See help x11 for further information.
%
% Finally, 'method1' is similar to 'x-11', but uses an approximate version
% of the original Method I argorithm that was developed by 
%
% Normally, all warnings of the x13as/x12a program are shown on the console
% as Matlab warnings (for instance when a variable was requested but is not
% available). The switch 'quiet' suppresses warnings. The corresponding
% messages will still be contained in the resulting object, but they will
% not show up on the screen at runtime.
%
% Any string arguments starting with a hyphen are flags passed on to x13as.exe
% through the command line. Section 2.7 of the X-13ARIMA-SEATS Reference Manual
% explains the meanings of the different flags. Some flags are dealt with by the
% x13 Matlab program, so they should not be used by the user (in particular,
% using -g, -d, -i, -m, or -o is likely to mess up the functioning of the
% program).
%
% The most relevant flags are
% -n  (No tables) Only tables specifically requested in the input
%     specification file will be printed out 
% -r  Produce reduced X-13ARIMA-SEATS output (as in GiveWin version of
%     X-13ARIMA-SEATS)
% -w  Wide (132 character) format is used in main output file
% -c  Sum each of the components of a composite adjustment, but only
%     perform modeling or seasonal adjustment on the total
% -v  Only check input specification file(s) for errors; no other
%     processing
% -q  Run X-13ARIMA-SEATS in quiet-mode (warning messages are not sent to
%     the console). This is equivalent to the 'quiet' switch.
% -s  Store seasonal adjustment and regARIMA model diagnostics in a file
% -t  Same as -s
%
% The -q flag as defined by x13as.exe suppresses all messages. It is
% preferrable to use the 'quiet' switch instead, because then the messages
% are not shown on the console (as would be the case with '-q'), but they
% are still available as messages stored in the x13series object.
%
% To use flags, use one of the following syntaxes,
%    x = x13(..., '-n'), or
%    x = x13(..., '-n', '-w'), or
%    x = x13(..., '-n -w'),
% or x = x13(..., 'noflags')
% If no flag is set by the user, the default is to set the '-n' flag, so
% that only the requested tables (-n) are written to the .out property. The
% 'noflags' option removes all the flags, including the default. 
% 
% Please note that the '-s' flag also triggers a call to the x12diag.exe
% program, which produces some additional reporting. [It collects data from
% the .udg field and condenses it and makes it more human-readable and then
% stores this as a new .x2d field.] However, as of 2022, the x12dag.exe
% program is no longer available for download from the U.S. Census Bureau
% website. Thus, the .x2d field is no longer generated.
%
% Four optional arguments can be provided in name-value style: The argument
% following the 'fileloc' keyword is the location where all the files
% should be stored that are used and generated by the x13as program. If
% this optional argument is not used, these files will be located in a
% subdirectory 'X13' of the system's temporary files directory
% (%tempdir%\X13).
%
% The argument following the 'graphicsloc' keyword is the location where
% all the files should be stored that can be used with the separately
% available X-13-Graph program (see
% https://www.census.gov/srd/www/x13graph/). If this optional argument is
% used, x13as will run 'in graphics mode' and these files will be
% generated. If this argument is not used or set to [], the
% graphics-related files will not be generated. If 'graphicsloc' is set to
% '' (i.e. an empty string), then the graphics files will be created in a
% subdirectory called 'graphics' of the fileloc directory. The same is
% achieved with the switch 'graphicsmode'.
%
% The arguments following 'progloc' and 'prog', respectively, allow you to
% specify the location of the executables that do the computations. 'prog'
% is the name of the executable. By default, this is 'x13as_ascii' (or
% 'x13as_html' if the 'html' flag is set), or 'x12a' (or 'x12a64' on a
% 64-bit computer) if the 'x-12' option is set. But it is also possible to
% specify an m-file that performs the necessary seasonal adjustment
% computations.
%
% 'progloc' indicates the folder where the executables can be found. In the
% argument following 'progloc', the term '%tbx%' is replaced by the root
% directory of this toolbox.  By default, 'progloc' is '%tbx%\exe', i.e.
% the 'exe' subdirectity of the X-13 toolbox. If 'prog' is an m-file then
% the default 'progloc' is '%tbx%\seas'.
%
% So what is the 'prog' option really used for? You could, in principle,
% specify alternative executables, other than the ones provided by the US
% Census Bureau. The output of such an alternative program would have to be
% compatible with the output generated by the Census Bureau program. So, in
% practice, the only two conceivable options here are that either you have
% an older version of the Census Bureau software that you want to use, or
% you have a beta version which is in development. For instance, a previous
% version of x13as was version 1.1 build 9. If you have a copy of it, and
% you called it 'x13asv11b9.exe' on your harddisk (in the exe subdirectory
% of the toolbox), then
%   x = x13(..., 'prog','x13asv11b9');
% uses the previous version of the Census program.
%
% Another application is to use a seasonal adjustment algorithm in Matlab's
% language. seas.m is an example or this. By setting
%   x = x13(..., 'prog','seas.m'),
% you use this self-made seasonal adjustment algorithm in place of the
% Census programs. The advantage is that you have more freedom to
% experiment. Also, you are not constrained to monthly or quarterly
% frequencies.
%
% Usage (composite time series):
%   x = x13([dates1,data1],spec1, [dates2,data2],spec2, [...], compositespec)
%   x = x13( dates1,data1 ,spec1, dates2,data2  ,spec2, [...], compositespec)
%   x = x13([dates,data]  ,{spec1,spec2,...},compositespec)
%   x = x13( dates,data   ,{spec1,spec2,...},compositespec)
%   x = x13(ts,{spec1,spec2,...},compositespec)
%   x = x13(ts,spec1,[dates,data],spec2,dates,data,spec3,compositespec)
%   x = x13(..., 'x-12')
%   x = x13(..., 'x-13')
%   x = x13(..., 'html')
%   x = x13(..., '-n', '-w', '-c', ... etc)
%   x = x13(..., 'noflags')
%   x = x13(..., 'graphicsmode')
%   x = x13(..., 'graphicsloc',path)
%   x = x13(..., 'fileloc',path)
%   x = x13(..., 'progloc',path)
%   x = x13(..., 'prog',filename)
%
% In the first and second version you can set different specifications for
% the individual time series. Alternatively, in the third and fourth usage
% form, 'data' may be an array with m columns, where each column is
% interpreted as one timeseries. In the fifth usage form, all variables in
% the timeseries object 'ts' are interpreted as time series of the
% composite run. You can also combine the syntax as seen in the sixth usage
% form.
%
% For composite runs, the last argument (except possible optional
% arguments) is always the specification of the composite series
% ('compositespec' cannot contain the 'series' section, but must contain
% the 'composite' section).
%
% Example 1:
%   spec = makespec('DIAG','PICK','X11');
%   x = x13(dates,data,spec);
% Then, 'x' is a x13series object with several variables, such as x.dat
% (containing the original data), x.d10, x.d11, x.d12, x.d13 (containing
% the results of the X-11 filtering as produced by the x13as program), as
% well as different tables (essentially plain text). See the help of
% x13series for further explanation.
%
% Example 2:
% Let C, I, G, NX now be components of components of GDP of a country,
% measured at quarterly frequency (Y=C+I+G+NX), and D be the common dates
% vector when the components were measured.
%   spec = makespec('AUTO','TRAMO','SEATS','series','comptype','add');
%   x = x13( ...
%     [D,C], x13spec(spec,'series','name','C'), ...
%     [D,I], x13spec(spec,'series','name','I'), ...
%     [D,G], x13spec(spec,'series','name','G'), ...
%     [D,NX],x13spec(spec,makespec('ADDITIVE'),'series','name','NX'), ...
%     makespec('AUTO','TRAMO','SEATS','composite','name','Y'));
% Then, 'x' is a x13composite object containing x13series C, I, G, NX, and
% Y. Again, see the help of x13composite and x13series for further
% explanation.
%
% Alternatively, you can produce the same result as follows:
%   spec = makespec('AUTO','TRAMO','SEATS','series','comptype','add');
%   allspec = { ...
%       x13spec(spec,'series','name','C'), ...
%       x13spec(spec,'series','name','I'), ...
%       x13spec(spec,'series','name','G'), ...
%       makespec(spec,'ADDITIVE','series','name','NX')};
%   compspec = makespec('AUTO','TRAMO','SEATS','composite','name','Y');
%   x = x13(D,[C,I,G,NX],allspec,compspec);
%
% Requirements: The program requires the X-13 programs of the US Census
% Bureau to be in the directory of the toolbox. The toolbox attempts to
% download the required programs itself. Should that attempt fail, you can
% download this software yourself for free from the US Census Bureau
% website. Download http://www.census.gov/ts/x13as/pc/x13as_V1.1_B26.zip
% and unpack the x13as.exe file to the 'exe' subdirectory of this toolbox.
%
% To install all programs and tools from the US Census Bureau that are
% supported by the X-13 Toolbox, issue the command
% InstallMissingCensusProgram once. The program will then attempt to
% download and install all files in one go.
% 
% Acknowledgments: Detailed comments by Carlos Galindo helped me make the
% Toolbox backward compatible.
%
% NOTE: This file is part of the X-13 toolbox.
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
% 2023-10-11    Version 1.55    Reestablishment of '-s' flag as default
%                               selection.
% 2022-01-20    Version 1.54    Removal of '-s' flag from default
%                               selection.
% 2021-08-09    Version 1.51    Adapted to V 1.1 Build 58
% 2018-09-04    Version 1.33    Added progtype property.
% 2017-03-26    Version 1.32    Support for datetime class variable for the
%                               dates.
% 2017-01-09    Version 1.3     First release featuring camplet.
% 2016-11-24    Version 1.20.1  Fixed a bug discovered by Carlos (a FEX
%                               user). The error message that is generated
%                               when the program cannot automatically
%                               download x13as.exe was crippled.
% 2016-10-13    Version 1.19    If no spec is given, makespec('DEFAULT') is
%                               used.
% 2016-07-06    Version 1.17    First release featuring guix.
% 2016-03-03    Version 1.16    Adapted to X-13 Version 1.1 Build 26.
% 2015-08-20    Version 1.15    Significant speed improvement. The imported
%                               time series will now be mapped to the first
%                               day of month if this is the case for the
%                               original data as well. Otherwise, they will
%                               be mapped to the last day of the month. Two
%                               new options --- 'spline' and 'polynomial'
%                               --- for fixedseas. Improvement of .arima,
%                               bugfix in .isLog.
% 2015-07-25    Version 1.14    Improved backward compatibility. Overloaded
%                               version of seasbreaks for x13composite. New
%                               x13series.isLog property. Several smaller
%                               bugfixes and improvements.
% 2015-07-24    Version 1.13.3  Resolved some backward compatibility
%                               issues (thank you, Carlos).
% 2015-07-07    Version 1.13    seasma removed, replaced by fixedseas.
%                               Complete integration of fixedseas into
%                               x13spec, with fore-/backcast extension
%                               before computing trend for simple seasonal
%                               adjustment. Various improvemnts to
%                               x13series.plot (including 'separate' 
%                               option). seasbreaks program to identify
%                               seasonal breaks. Better support for PICKMDL
%                               model list files. Added '-n' to list of
%                               default flags in x13. Select print requests
%                               added as default in makespec.
% 2015-06-01    Version 1.12.3  Added 'quiet' switch.
% 2015-05-30    Version 1.12.2  Dealing with 'pickmdl.txt' file. Moreover,
%                               'fileloc' X13 subdirectory in temporary
%                               folder is created already by x13, not by
%                               x13series or x13composite, respectively.
% 2015-05-22    Version 1.12.1  Specification of flags without the 'flags'
%                               keyword. One can now say, for instance,
%                               x13(data,makespec(...),'-w'). Before, it
%                               was necessary to say x13(...,'flags','-w').
% 2015-05-21    Version 1.12    Several improvements: Ensuring backward
%                               compatibility back to 2012b (possibly
%                               farther); Added 'seasma' option to x13;
%                               Added RunsSeasma to x13series; other
%                               improvements throughout. Changed numbering
%                               of versions to be in synch with FEX's
%                               numbering.
% 2015-05-19    Version 1.6.1   Added 'seasma' option.
% 2015-04-28    Version 1.6     x13as V 1.1 B 19, some bug fixes, 'html'
%                               switch
% 2015-04-02    Version 1.5     Adaptation to X-13 Version V 1.1 B19
% 2015-01-26    Version 1.3     Small bugfix
% 2015-01-24    Version 1.2     Bugfix (copy .prog and .progloc before
%                               using .PrepareFiles method (lines 400ff))
% 2015-01-21    Version 1.1     Collaboration with
%                               InstallMissingCensusProgram
% 2015-01-18    Version 1.09    Support for x12a and x12diag
% 2015-01-04    Version 1.05    Adapting to changes in x13series and
%                               x13composite classes
% 2015-01-01    Version 1.01    Bug fix: 'precision' instead of 'decimal'
%                               in created .spc file. Also, automatic
%                               support for NaNs ('missingcode' and
%                               'missingval')
% 2014-12-31    Version 1.0     First Version

function x = x13(varargin)

    %#ok<*SPWRN>

    % --- PRELIMINARIES ---------------------------------------------------
        
    tic;
    starttime = datenum(clock);
    
    % --- PARSE ARGUMENTS -------------------------------------------------
    
    dates   = cell(0);
    series  = cell(0);
    spec    = cell(0);
    nSeries = 0;
    
    % defaultflags  = '-n';
    defaultflags  = '-n -s';
    progloc       = [];
    prog          = '';
    fileloc       = [];
    graphicsloc   = [];
    useX12        = false;
    useHTML       = false;
    quiet         = false;
    warnings      = cell(0);
    
    % trim leading and trailing spaces of all string arguments
    isString = cellfun(@(v) ischar(v),varargin);
    varargin(isString) = strtrim(varargin(isString));
    
    % check if some options start with '-' (such as '-n')
    fopts = cellfun(@(v) ~isempty(v) && strcmp(v(1),'-'),varargin);
%    flagsset = any(fopts);  % at least one flag arg was found
    noflagsset = false;
    flags = varargin(fopts);
    varargin(fopts) = [];
    
    for v = 2:nargin
        try  %#ok<TRYNC>
            validstr = validatestring(varargin{v}, ...
                {'progloc','prog','fileloc','graphicsloc','graphicsmode', ...
                'noflags','x-13','x-12','x-11','method1','Method I', ...
                'fixedseas','camplet','html','quiet'});
            switch validstr
                case 'progloc'
                    progloc = strtrim(varargin{v+1});
                    varargin{v+1} = [];
                case 'prog'
                    prog = strtrim(varargin{v+1});
                    varargin{v+1} = [];
                    [p1,p2,p3] = fileparts(prog);
                    if isempty(p3)
                        prog = fullfile(p1,[p2,'.exe']);
                    end
                case 'fileloc'
                    fileloc = strtrim(varargin{v+1});
                    varargin{v+1} = [];
                case 'graphicsloc'
                    if ischar(varargin{v+1})
                        graphicsloc = strtrim(varargin{v+1});
                        varargin{v+1} = [];
                    end
                case 'graphicsmode'
                    graphicsloc = '';
                case 'noflags'
                    flags = {};
                    noflagsset = true;
                case 'x-13'
                    useX12 = false;
                case 'x-12'
                    useX12 = true;
                case 'x-11'
                    useX12 = false;
                    prog = 'x11.m';
                case 'Method I'
                    useX12 = false;
                    prog = 'method1.m';
                case {'method1','fixedseas','camplet'}
                    useX12 = false;
                    prog = [validstr,'.m'];
                case 'html'
                    useHTML = true;
                case 'quiet'
                    quiet = true;
            end
            varargin{v}   = [];     % replace the argument we dealt with
                                    % with an empty set (it will be removed
                                    % alltogether after the loop)
        end
    end
    remove = cellfun(@(v) isempty(v),varargin); % remove empty args
    varargin(remove) = [];
    
    % using an M file instead of a Census progam?
    [~,~,ext] = fileparts(prog);
    useMfile = strcmp(ext,'.m');
    
%     % if no flag was set by user, set the default flag
%     if ~flagsset
%         flags = defaultflags;
%     end
    
    % graphisloc cannot contain spaces
    if ~isempty(strfind(graphicsloc,' ')) %#ok<STREMP>
        str = sprintf(['Your path to the graphics files ', ...
            '(''graphsicsloc'') is "%s", but it cannot contain spaces. ', ...
            '''graphicsmode'' will therefore be turned off.'], graphicsloc);
        warnings{end+1} = [' TOOLBOX WARNING: ',str];
        warning('X13TBX:x13:IllegalPath', str);
        graphicsloc = [];
    end
    
    % no 'accessible version' for x-12
    if (useX12 || useMfile) && useHTML
        str = ['''html'' can only be used with ''x-13''. ', ...
            '''html'' switch will be ignored.'];
        warnings{end+1} = [' TOOLBOX WARNING: ',str];
        warning('X13TBX:x13:IncompatibleSelection', str)
        useHTML = false;
    end
    
    % find entries like '-w -p', i.e. strings containing more than one flag
    tosplit = find(cellfun(@(v) length(v)>2,flags));
    moreflags = cell(0);
    for z = 1:numel(tosplit)
        moreflags = [moreflags, strsplit(flags{tosplit(z)})];
    end
    flags(tosplit) = [];
    flags = [flags, moreflags];
    
    % split flags into cells
    if isempty(flags)   % '' or {} or []
        flags = {};
    else
        if ~iscell(flags)
            flags = {flags};
        end
        for f = 1:numel(flags)
            if ~iscell(flags{f})
                thisflags = strsplit(flags{f});
            else
                thisflags = flags{f};
            end
            flags = [flags,thisflags];
        end
        flags = unique(flags);
        % remove unsupported flags
        legal = {'-c','-d','-g','-i','-m','-n','-o','-p','-q','-r', ...
            '-s','-t','-v','-w'};
        keep = ismember(flags,legal);
        if any(~keep)   % some flags are not supported
            if sum(~keep) > 1
                str = sprintf('Flags ''%s'' are not supported.', ...
                    strjoin(flags(~keep)));
            else
                str = sprintf('Flag ''%s'' is not supported.', flags{~keep});
            end
            warnings{end+1} = [' TOOLBOX WARNING: ',str];
            warning('X13TBX:x13:UnsupportedFlag',str);
        end
        flags = unique(flags(keep));    % keep only the legal ones
    end
    qflag = ismember('-q',flags);
    if any(qflag)
        quiet = true;
%        flags(qflag) = [];     % make 'quiet' equivalent to '-q' by not
                                % passing on the '-q' flag
    end
    flags = strjoin(flags);
    
    % if no flag was set by user (or none remains), set the default flags
    if isempty(flags) && ~noflagsset
        flags = defaultflags;
    end
    
    % make subdirectory in temporary folder, or in place requested
    % by the user
    if isempty(fileloc)
        fileloc = [tempdir,'X13',filesep];
    elseif ~strcmp(fileloc(end),filesep)
        fileloc = [fileloc,filesep];
    end
    if exist(fileloc,'file') ~= 7   % ... code 7 refers to directory
        mkdir(fileloc);
    end

    % get data and specs
    while ~isempty(varargin)
        
        isArrayOfSpecs = false;
        
        if numel(varargin) > 1
            
            if isa(varargin{1},'timeseries')

                ts         = varargin{1};
                thisDates  = ts.Time;
                thisSeries = ts.Data;
                ncol       = size(ts.Data,2);

            elseif isnumeric(varargin{1})

                [nrow,ncol] = size(varargin{1});
                doTranspose = (nrow <= 2 && ncol > 2);
                if doTranspose
                    varargin{1} = varargin{1}';
                    ncol = nrow;
                end
                if ncol == 1
                    if doTranspose
                        varargin{2} = varargin{2}';
                    end
                    thisDates   = varargin{1};
                    thisSeries  = varargin{2};
                    varargin(2) = [];
                else
                    thisDates = varargin{1}(:,1);
                    thisSeries = varargin{1}(:,2:end);
                end
                ncol = size(thisSeries,2);
                
            elseif isa(varargin{1},'datetime')
                
                thisDates   = datenum(varargin{1});
                thisSeries  = varargin{2};
                varargin(2) = [];
                [nrow,ncol] = size(thisDates);
                doTranspose = (nrow == 1 && ncol > 1);
                if doTranspose
                    thisDates  = thisDates';
                    thisSeries = thisSeries';
                end
                ncol = size(thisSeries,2);

            else

                err = MException('X13TBX:x13:IllegalArg', ...
                    ['Program expects numeric data on the odd ', ...
                    'numbered positions of the argument list.']);
                throw(err);

            end
            
            if numel(varargin) == 1
                varargin{2} = makespec('DEFAULT');
            end
            
            if iscell(varargin{2})
                isArrayOfSpecs = true;
                if ~all(cellfun(@(x) isa(x,'x13spec'), varargin{2}))
                    err = MException('X13TBX:x13:IllegalSpec', ...
                        ['Program expects x13spec objects ', ...
                        'or a cell array of such objects on the even ', ...
                        'numbered positions of the argument list.']);
                    thow(err);
                end
                ArrayOfSpecs = varargin{2};
            else
                thisSpec = varargin{2};
                if isempty(thisSpec)
                    thisSpec = makespec('DEFAULT');
                end
                if ~isa(thisSpec,'x13spec')
                    err = MException('X13TBX:x13:IllegalSpec', ...
                        ['Program expects x13spec objects ', ...
                        'on the even numbered positions of the ', ...
                        'argument list.']);
                    throw(err);
                end
            end

            if isArrayOfSpecs && numel(ArrayOfSpecs) ~= ncol
                err = MException('X13TBX:x13:IllegalNbArgs', ...
                    ['You''ve provided %i x13spec objects, but %i ', ...
                    'time series of data. The two numbers must be ', ...
                    'the same.'], numel(ArrayOfSpecs), ncol);
                throw(err);
            end

            nSeries = nSeries + ncol;
            for s = 1:ncol
                dates{end+1}    = thisDates; %#ok<*AGROW>
                series{end+1}   = thisSeries(:,s);
                if isArrayOfSpecs
                    spec{end+1} = ArrayOfSpecs{s};
                else
                    spec{end+1} = thisSpec;
                end
            end

            varargin(1:2) = [];

        else    % only one varargin remains
            
            if nSeries == 0     % must be data, with no specs specified
                
                thisSpec = makespec('DEFAULT');
                if isa(varargin{1},'timeseries')
                    [thisDates,thisSeries,ncol] = ts2arr(varargin{1});
                elseif isnumeric(varargin{1})
                    [nrow,ncol] = size(varargin{1});
                    doTranspose = (nrow == 2 && ncol > 2);
                    if doTranspose
                        varargin{1} = varargin{1}';
                    end
                    thisDates  = varargin{1}(:,1);
                    thisSeries = varargin{1}(:,2:end);
                    ncol = size(thisSeries,2);
                elseif isa(varargin{1},'datetime')
                    thisDates   = datenum(varargin{1});
                    thisSeries  = varargin{2};
                    varargin(2) = [];
                    [nrow,ncol] = size(thisDates);
                    doTranspose = (nrow == 1 && ncol > 1);
                    if doTranspose
                        thisDates  = thisDates';
                        thisSeries = thisSeries';
                    end
                    ncol = size(thisSeries,2);
                else
                    err = MException('X13TBX:x13:IllegalArg', ...
                        ['Program expects numeric data on the odd ', ...
                        'numbered positions of the argument list.']);
                    throw(err);
                end
                
                nSeries = nSeries + ncol;
                for s = 1:ncol
                    dates{end+1}  = thisDates;
                    series{end+1} = thisSeries(:,s);
                    spec{end+1}   = thisSpec;
                end
                
            else                % must be composite specs
                
                if ~isa(varargin{1},'x13spec')
                    err = MException('X13TBX:x13:IllegalSpec', ...
                        'Last argument must be an x13spec object.');
                    throw(err);
                end
                compositeSpec = x13spec( ...
                    'composite','name','composite', ...
                    varargin{1});
                
            end
            
            varargin(1) = [];
            
        end
        
    end

    isComposite = (nSeries > 1);

    if nSeries == 0
        err = MException('X13TBX:x13:NoData', ...
            'x13 expects some data to process.');
        throw(err);
    end

%     % no composites for my Mickey Mouse X-11 implementation
%     if useMfile && isComposite
%         err = MException('X13TBX:x13:NoCompositeWithX11', ...
%             'Composite runs are not supported by this implementation of X-11.');
%         throw(err);
%     end
    
    % --- LOCATE X13/X12 PROGRAM ------------------------------------------
    
    if isempty(progloc)
        progloc = fileparts(mfilename('fullpath')); % directory of this m-file
        [~,~,ext]= fileparts(prog);
        switch ext
            case {'.exe',''}
                progloc = [progloc,filesep,'exe']; % seas-subdirectory
            case '.m'
                progloc = [progloc,filesep,'seas']; % seas-subdirectory
        end
    else
        progloc = strrep(progloc,'%tbx%',fileparts(mfilename('fullpath')));
    end
    if strcmp(progloc(end),filesep)
        progloc = progloc(1:end-1);
    end
%     if strcmp(progloc,fileparts(mfilename('fullpath')))
%         [~,~,ext]= fileparts(prog);
%         switch ext
%             case {'.exe',''}
%                 progloc = [progloc,filesep,'exe']; % seas-subdirectory
%             case '.m'
%                 progloc = [progloc,filesep,'seas']; % seas-subdirectory
%         end
%     end
    
    if ~useMfile && isempty(prog)
%        progloc = fileparts(mfilename('fullpath')); % directory of this m-file
%    elseif isempty(prog)
        is64 = strcmp(mexext,'mexw64');             % running 64-bit version?
        % location and name of x13/x12 program
        if useX12
            prog32 = fullfile(progloc,'x12a.exe');
            prog64 = fullfile(progloc,'x12a64.exe');
        else
            if ~useHTML
                prog64 = fullfile(progloc,'x13as_ascii.exe');
                prog32 = prog64;
            else
                prog64 = fullfile(progloc,'x13as_html.exe');
                prog32 = prog64;
            end
        end
        % check if present
        existprog = [exist(prog32,'file'), exist(prog64,'file')];
        if is64 && existprog(2)
            prog = prog64;
        else    % use 32bit version also on 64bit machine if 64bit version
                % of program is not present
            prog = prog32;
        end
        % if program not present, try to download. If download fails, throw
        % an error.
        if exist(prog,'file')
            % extract filename
            [~,prog,ext] = fileparts(prog);
            prog = [prog,ext];
        else
            if useX12
                success = InstallMissingCensusProgram('x12prog');
                if success
                    if is64
                        prog = 'x12a64.exe';
                    else
                        prog = 'x12a.exe';
                    end
                else
                    err = MException('X13TBX:x13:ProgramMissing', ...
                        ['X-12 program is missing and automatic ', ...
                        'download failed. Try manual download from', ...
                        '''https://www.census.gov/ts/x12a/v03/pc/%s'' ', ...
                        'and unpack to ''exe'' subdirectory of the ', ...
                        'toolbox (''%s'').'], 'omegav03.zip', progloc);
                    throw(err);
                end
            else
                success = InstallMissingCensusProgram('x13prog');
                if success
                    if useHTML
                        prog  = 'x13as_html.exe';
                    else
                        prog  = 'x13as_ascii.exe';
                    end
                else
                    if useHTML
                        theZIP  = 'x13as_html-v1-1-b58.zip';
                    else
                        theZIP  = 'x13as_ascii-v1-1-b58.zip';
                    end
                    err = MException('X13TBX:x13:ProgramMissing', ...
                        ['X-13 program is missing and automatic ', ...
                        'download failed. Try manual download from ', ...
                        '''https://www2.census.gov/software/', ...
                        'x-13arima-seats/x13as/windows/program-archives/', ...
                        '%s'' and unpack to ''exe'' subdirectory of the ', ...
                        'toolbox (''%s'').'], theZIP, progloc);
                    throw(err);
                end
            end
        end
    end
    
    % --- PROCESS EVERYTHING ----------------------------------------------
    
%     isComposite = (nSeries > 1);
    if isComposite
        x = x13composite();
        x.ishtml      = useHTML;
        x.fileloc     = fileloc;
        x.graphicsloc = graphicsloc;
        x.flags       = flags;
        x.quiet       = quiet;
        x.warnings    = warnings;
        x.specgiven   = [spec,{compositeSpec}];
        x.prog        = prog;
        x.progloc     = progloc;
        [~,~,ext]     = fileparts(prog);
        useMfile      = strcmp(ext,'.m');
        if ~useMfile
            x.PrepareFiles(dates,series,spec,compositeSpec);
            x.Run;
            x.CollectFiles;
        else
            err = MException('X13TBX:X13COMPOSITE:composite_not_supported', ...
                ['Custom m-files for seasonal decomposition do not ', ...
                 'support composites.']);
             throw(err);
        end
    else
        x = x13series();
        x.ishtml      = useHTML;
        x.fileloc     = fileloc;
        x.graphicsloc = graphicsloc;
        x.flags       = flags;
        x.quiet       = quiet;
        x.warnings    = warnings;
        x.specgiven   = spec{1};
        x.prog        = prog;
        x.progloc     = progloc;
        if ~useMfile
            x.PrepareFiles(dates{1},series{1},spec{1});
            x.Run;
            x.CollectFiles;
        else
            x.RunMfile(dates{1},series{1},spec{1});
        end
    end
    
    x.timeofrun = {starttime,toc};
    
end
