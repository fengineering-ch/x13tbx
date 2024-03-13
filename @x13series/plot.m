% PLOT (overloaded) plots the content of an x13series object 
%
% TO DO: legends and 'nolegend'
% legends are not yet implemented, and 'nolegend' therefore has no effect yet.
%
% MORE IMPORTANTLY, this code is a mess. It works, but it is extremely
% difficult to maintain because it is not well structured. This requires a
% fundamental overhaul...
%
% Usage:
%   plot(obj)
%   plot(obj, 'variable1', 'variable2', ...)
%   plot(obj1, obj2, ..., 'variable1', 'variable2', ...)
%   plot(h, obj, ...)
%   plot(..., 'columnwise'|'rowwise'|'layout',[rows,cols]|'combined')
%   plot(..., 'dateticks',['all','d','w','m','q','y','auto','matlab'])
%   plot(..., 'dateticks','...', 'multdateticks', integer)
%   plot(..., 'selection', boolean vector)
%   plot(..., 'logscale')
%   plot(..., 'normalized'|'meannormalized')
%   plot(..., 'overlapperiods')
%   plot(..., 'overlapyears')
%   plot(..., 'span')
%   plot(..., 'boxplot')
%   plot(..., 'byperiod')
%   plot(..., 'byperiodnomean')
%   plot(..., 'separate')
%   plot(..., 'fromdate',date)
%   plot(..., 'todate',date)
%   plot(..., 'selectdates',boolean vector)
%   plot(..., 'nolegend')
%   plot(..., 'options',{...})
%   plot(..., 'quiet')
%   [fh,ax] = plot(...)
%
% The command can plot variables, ACF/PACF, and spectra contained in an
% x13series object. It plots these types of items differently, and some of
% the options apply only to some types of items.
%
% The options can be abbreviated. However, at least four characters of the
% option must be specified. Otherwise, the parameter is interpreted as the
% name of an item that is to be plotted. For instance, in
% plot(obj,'dat','log'), the program will try to plot the items 'dat' and
% 'log' (if available), but maybe you wanted to plot 'dat' on a log-scale.
% To achieve that, you need to say (at the minimum) plot(obj,'dat,'logs')
% [abbreviation of 'logscale'].
%
% Inputs:
%   obj         An x13series object.
%   variable    The name of variables stored in obj. Default is 'dat'.
%   h           Can be a figure handle or an axis handle. If it is an axes
%               handle, then only one x13series and one variable can be
%               specified, or the 'combined' keyword must also be used.
%               This single variable of this single x13series is then
%               plotted to the given axis.
%   'rowwise'   The variables of an x13series are plotted in one row; each
%               column contains the same variable of all x13sereies
%               objects. This is the default.
%   'columnwise'  This option swaps the location of the subaxes. With
%               'columnwise', the variables of an x13series are plotted in
%               one column; each row contains the same variable of all
%               x13series objects.
%   'layout',[rows,cols] sets the number of rows and columns of the
%               subaxes. If rows or cols is NaN, it will be computed from
%               the other one. It is not legal to set both to NaN.
%   'combined'  Plots all the requested information in one axis.
%   'dateticks' This is one of the following: 'all', 'd', 'w', 'm', 'q',
%               'y', 'matlab', 'auto', or 'default'. 'auto' makes a choice that
%               often works. 'all' means that each datapoint on the dates-axis
%               is labelled. 'matlab' means that Matlab's default is used.
%               The default is 'auto'.
%   'multdateticks'  Reduces the number of ticks. Example, if 'dateticks'
%               is set to 'y' and 'multdateticks' is set to 3, then there
%               is a tick at the beginning of every third year.
%   'selection' If a variable contains several time series (such as .fct,
%               which conains the forecast as well as the lower and upper
%               bounds of the confidence interval), then the vector
%               following the 'selection' option determines which time
%               series are plotted. For instance, plot(obj, 'fct',
%               'selection',[1 0 0]) plots only the forecast without the
%               limits of the confidence band. Default is to plot all
%               timeseries contained in an item. If the number of entries
%               in the selection-vector does not match the number of time
%               series contained in a variable, 'selection' is simply
%               ignored.
%   'logscale'  Applies only to variables (not ACF or spectra). Uses a
%               logarithmic scale for the values.
%   'normalized'    Applies only to variables. Normalizes data so that mean
%               is zero and standard deviation is one. If 'normalized' and
%               'logscale' are used, the log of the data is first taken
%               and the logarithmic data are then normalized.
%   'meannormalized'    Applies only to variables. Same a 'normalized' but
%               applies only to the mean.
%   'overlapperiods'    The x-axis is either 1:12 (for monthly data) or 1:4
%               (for quarterly data). Each year's values are drawn as a
%               separate line.
%   'overlapyears'      The x-axis is one observation for each year. Each
%               period (month or quarter) is drawn as a separate line.
%   'span'      The x-axis is either 1:12 (for monthly data) or 1:4
%               (for quarterly data). Three lines are drawn, one containing
%               the average for each month/quater over all years, and one
%               showing the respective minimum or maximum.
%   'boxplot'   Similar to 'overlapperiods', but instead of plotting each
%               year as a line, here a boxplot for each month (quarter) is
%               produced. You can use 'boxplot' and 'overlapperiods'
%               together. This option requires the 'Statistics Toolbox'. If this
%               Toolbox is not available, the option will be substituted by
%               'span'.
%   'byperiod'  As with 'overlapperiods', 'span', and 'boxplot', the abscissa
%               is either 1:12 or 1:4. For each period, the year-by-year
%               development is depicted as a line, so for instance,
%               plot(obj,'d10','byperiod') would show the development of
%               the Jan, Feb, Mar erc seasonal factor from year to year.
%               Also, for each month (quarter), the average factor is shown
%               as a horizontal red line. The graph is similar to one of
%               the more innovative plots provided by the Census Bureau
%               plot utility.
%   'byperiodnomean'   Same as 'byperiod', except that the average for each
%               period is not shown in the graph.
%   'separateperiods'  Same as 'byperiodnomean', but each month (quarter) gets
%               its  own axis. Also the same as 'overlapyears', but with each
%               line in its own subaxis.
%   'fromdate' or 'todate'  Boundaries of the dates that are represented on
%               the hozizontal date axis in the graph.
%   'selectdates'  This must be followed by a boolean vector that is as
%               long as the time series that is being graphed. Only thos
%               datapoints are represented in the graph who have a TRUE
%               entry.
%   'nolegend'  A legend is added when there is more than one variable that is
%               printed. This option suppresses the legend.
%   'options'   This overloaded plot method relies on Matlab?s ordinary
%               plot command to actually produce the figure. With
%               'options' the user can specify any additional arguments
%               that will be passed to the main plot function.
%   'quiet'     Suppress warnings.
%
% Outputs:
%   fh          A handle to the figure that is created.
%   ax          An array of handles to the individual axes that are
%               contained in the figure.
%
% Examples:
%
% Straigtforward examples:
%     plot(obj);
%     plot(obj,'d10','d13');
%     plot(obj,'dat','d11','combined');
%     plot(obj1, obj2, 'd12','combined');
%
% A more elaborate example:
%     figure;
%     ah = subplot(2,2,[1 3]);
%     plot(ah,x,'dat','options',{'LineWidth',1.0});
%     hold on;
%     plot(ah,x,'d12','options',{'Color',[1,0,0],'LineWidth',2.0});
%     title(ah,'\bfdata and trend');
%     
%     ah = subplot(2,2,2);
%     plot(ah,x,'d10');
% 
%     ah = subplot(2,2,4);
%     plot(ah,x,'d10','boxplot');
%     title(ah,'\bfdistribution of seasonal factors (d10)');
%
% To plot all variables in an x13series, try this:
%     plot(x,x.listofitems{:});
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
% 2020-07-01    Version 1.40    Datatip shows day of month and day of week.
%                               Several bug fixes.
% 2019-10-19    Version 1.34    Bug fix in 'overlapyears.' Added 'layout'
%                               option.
% 2018-09-30    Version 1.33    Support for spectrum with confidence bands.
%                               'overlapyears' renamed to 'overlapperiods.'
%                               'overlapyears' has a new meaning.
% 2017-03-26    Version 1.32    Support for datetime class variable for the
%                               dates.
% 2017-01-09    Version 1.30    First release featuring camplet.
% 2016-08-20    Version 1.18    Support for 'byperiod' and 'separate' for data
%                               that are neither quartely nor monthly.
% 2016-07-28    Version 1.17.5  Adjusted title of single object, single variable
% 2016-07-10    Version 1.17.1  Improved guix. Bug fix in x13series relating to
%                               fixedseas.
% 2016-07-06    Version 1.17    First release featuring guix. Added 'quiet'
%                               option to plot and small bug fixes.
% 2016-03-03    Version 1.16    Adapted to X-13 Version 1.1 Build 26.
% 2015-10-21    Version 1.15.1  Adaptations to new color scheme and new name of
%                               'Statistics Toolbox' (now called 'Statistics and
%                               Machine Learning Toolbox').
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
% 2015-07-20    Version 1.13.3  Resolved some backward compatibility
%                               issues (thank you, Carlos). Using new
%                               program yqmd to ensure compatibility before
%                               R2013a. Fixed bug in plots with 'separate'
%                               and multiple variables with different date
%                               vectors.
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
% 2015-06-02    Version 1.12.1  Added 'bymonth'/'byquarter' option
% 2015-05-21    Version 1.12    Several improvements: Ensuring backward
%                               compatibility back to 2012b (possibly
%                               farther); Added 'seasma' option to x13;
%                               Added RunsSeasma to x13series; other
%                               improvements throughout. Changed numbering
%                               of versions to be in synch with FEX's
%                               numbering.
% 2015-05-16    Version 1.6.1   Corrected bug that prevented destruction of
%                               x13series object after it was used in a
%                               plot (mistake was in custom data cursor)
% 2015-04-28    Version 1.6     x13as V 1.1 B 19
% 2015-04-14    Version 1.2     Added description line in single variable
%                               plots
% 2015-01-18    Version 1.1     Support for boxplot and overlapyears
% 2015-01-09    Version 1.05    Support for plotting ACF/PACF and spectra;
%                               support for different datatips for
%                               variables, ACF/PACF, and spectra
% 2014-12-31    Version 1.0     First Version

 %#ok<*AGROW>
 
 function [fh,ax] = plot(varargin)

    % separate first arg if it is a fig or ax handle
    if nargin > 0
        if ishghandle(varargin{1},'figure')
            fh = varargin{1};
            isFig = true;
            isAx  = false;
            varargin(1) = [];
        elseif ishghandle(varargin{1},'axes')
            axh = varargin{1};
            fh = get(axh,'Parent');
            isFig = true;
            isAx  = true;
            varargin(1) = [];
        else
            isFig = false;
            isAx = false;
        end
    else
        err = MException('X13TBX:x13series:plot:arg_missing', ...
            'x13series.plot expects some arguments.');
        throw(err);
    end
    
    % separate x13series objects from options
    if isempty(varargin)
        err = MException('X13TBX:x13series:plot:expecting_x13series', ...
        'First or second arg must be an x13series object. (This error should not occur!)');
        % If the TBX is correctly installed, this error should not occur,
        % because ML would not reach the x13series.plot function if no x13series
        % object is given as argument.
        throw(err);
    end
    obj = cell(0);
    while ~isempty(varargin) && isa(varargin{1},'x13series')
        obj{end+1} = varargin{1};
        varargin(1) = [];
    end
    nbSeries = numel(obj);
    if nbSeries == 0
        err = MException('X13TBX:x13series:plot:expecting_x13series', ...
            'First or second arg must be an x13series object. (This error should not occur!)');
        % If the TBX is correctly installed, this error should not occur,
        % because ML would not reach the x13series.plot function if no x13series
        % object is given as argument.
        throw(err);
    end
    
    variable = cell(0);
    legal = {'columnwise','rowwise','combined','layout','dateticks', ...
        'multdateticks','logscale','normalized','meannormalized', ...
        'options','selection','boxplot','overlapyears','overlapperiods', ...
        'span','bymonth','byquarter','byperiod', ...
        'bymonthnomean','byquarternomean','byperiodnomean', ...
        'areachart','barchart','linechart', ...
        'separateperiods','fromdate','todate','selectdates','quiet'};
    codeDateTick     = 'auto';
    multDateTick     = NaN;
    plotOptions      = cell(0);
    isColwise        = false;
    isRowwise        = false;
    isCombined       = false;
    fixedLayout      = false;
    layout           = [NaN,NaN];
    isLog            = false;
    isNormalized     = false;
    isNormalizedMean = false;
    sel              = NaN;
    doBoxplot        = false;
    doOverlapYears   = false;
    doOverlapPeriods = false;
    doSpan           = false;
    doByPeriod       = false;
    doByPeriodNoMean = false;
    doSeparatePeriod = false;
    doLineChart      = true;
    doAreaChart      = false;
    doBarChart       = false;
    fromDate         = NaN;
    toDate           = NaN;
    selectdates      = NaN;
%    domakelegend     = true;
    quiet            = false;
    while ~isempty(varargin)
        if length(varargin{1}) <= 3 && ischar(varargin{1})
            variable{end+1} = varargin{1};
        else
            validstring = validatestring(varargin{1},legal);
            switch validstring
                case 'columnwise'
                    isColwise = true;
                case 'rowwise'
                    isRowwise = true;
                case 'combined'
                    isCombined = true;
                case 'layout'
                    fixedLayout = true;
                    layout = varargin{2};
                    varargin(2) = [];
                case 'dateticks'
                    codeDateTick = varargin{2};
                    varargin(2) = [];
                case 'multdateticks'
                    multDateTick = varargin{2};
                    varargin(2) = [];
                case 'logscale'
                    isLog = true;
                case 'normalized'
                    isNormalized = true;
                case 'meannormalized'
                    isNormalizedMean = true;
                case 'options'
                    plotOptions = varargin{2};
                    varargin(2) = [];
                case 'selection'
                    sel = varargin{2};
                    varargin(2) = [];
                    sel = logical(sel);
                    sel = sel(:)';
                case 'boxplot'
                    doBoxplot = true;
                case 'overlapperiods'
                    doOverlapPeriods = true;
                case 'span'
                    doSpan = true;
                case {'byperiod','bymonth','byquarter'}
                    doByPeriod = true;
                    doByPeriodNoMean = false;
                case {'byperiodnomean','bymonthnomean','byquarternomean'}
                    doByPeriod = true;
                    doByPeriodNoMean = true;
                case 'linechart'
                    doLineChart = true;
                    doAreaChart = false;
                    doBarChart  = false;
                case 'areachart'
                    doLineChart = false;
                    doAreaChart = true;
                    doBarChart  = false;
                case 'barchart'
                    doLineChart = false;
                    doAreaChart = false;
                    doBarChart  = true;
                case 'separateperiods'
                    doByPeriod = true;
                    doSeparatePeriod = true;
%                case 'nolegend'
%                    domakelegend = false;
                case 'overlapyears'
                    doOverlapYears = true;
                case 'fromdate'
                    fromDate = varargin{2};
                    if isa(fromDate,'datetime')
                        fromDate = datenum(fromDate);
                    end
                    varargin(2) = [];
                case 'todate'
                    toDate = varargin{2};
                    varargin(2) = [];
                    if isa(toDate,'datetime')
                        toDate = datenum(toDate);
                    end
                case 'selectdates'
                    selectdates = varargin{2};
                    varargin(2) = [];
                case 'quiet'
                    quiet = true;
            end
        end
        varargin(1) = [];
    end
    if isCombined && (isColwise || isRowwise)
        if ~quiet
            warning('X13TBX:x13series:plot:incompatible_options', ...
                ['Option ''combined'' is incompatible with ''rowwise'' ', ...
                'and ''columnwise''. Ignoring the latter.']);
        end
        isColwise = false; isRowwise = false;
    end
    
    % deal with compatibilities
    % - boxplot
    if doBoxplot
        tbx = ver;
        [tbxNames{1:numel(tbx)}] = deal(tbx.Name);
        if ~ismember('Statistics Toolbox',tbxNames) && ...
               ~ismember('Statistics and Machine Learning Toolbox',tbxNames)
            if ~quiet
                warning('X13TBX:x13series:plot:unavailable_feature', ...
                    ['''boxplot'' requires the Statistics Toolbox, which ', ...
                    'is not installed. ''boxplot'' will be replaced ', ...
                    'by the ''span'' option.']);
            end
            doBoxplot = false;
            doSpan = true;
        end
    end
    % - turn linesmoothing on by default
    if verLessThan('matlab', '8.4')
        defaultOptions = {'LineSmoothing','on'};
    else
        defaultOptions = cell(0);
    end
    % make lines thicker than 0.5 if not already so by default
    if get(0,'DefaultLineLineWidth') < 1.0
        defaultOptions = [defaultOptions,{'LineWidth'},{1}];
    end
    
%     % sliding spans code NaN as -999
%     specialNaN = {'sfs','chs','ycs','cis','ais','sis','yis'};
    
    % default is to plot 'dat'
    if isempty(variable)
        variable = {'dat'};
    end
    
    % dimensions of matrix plot
    nbVARS = numel(variable);
    
    if doSeparatePeriod
        p = NaN(nbSeries,1);
        for s = 1:nbSeries
            p(s) = obj{s}.period;
        end
        if numel(unique(p)) > 1
            err = MExeption('X13TBX:x13series:plot:cannot_mix_periods', ...
                'Cannot plot series with different periods in same figure.');
            throw(err);
        else
            maxAx = p(1);
        end
        if fixedLayout
            if ~isnan(layout(1))
                nbrows = layout(1);
                if ~isnan(layout(2))
                    nbcols = layout(1);
                else
                    nbcols = ceil(maxAx/nbrows);
                end
            else
                nbcols = layout(2);
                nbrows = ceil(maxAx/nbcols);
            end
        elseif isColwise
            nbcols = 1;
            nbrows = maxAx;
        elseif isRowwise
            nbcols = maxAx;
            nbrows = 1;
        else
            nbrows  = ceil(sqrt(maxAx));
            nbcols  = ceil(maxAx/nbrows);
        end
        figName = 'separated periods';
    else
        if nbSeries == 1
            maxAx  = nbVARS;
            if ~strcmp(obj{1}.spec.title,'(no name)')
                figName = obj{1}.spec.title;
            elseif nbVARS == 1
                figName = variable{1};
            else
                figName = 'multiple variables';
            end
            if fixedLayout
                if ~isnan(layout(1))
                    nbrows = layout(1);
                    if ~isnan(layout(2))
                        nbcols = layout(1);
                    else
                        nbcols = ceil(maxAx/nbrows);
                    end
                else
                    nbcols = layout(2);
                    nbrows = ceil(maxAx/nbcols);
                end
            elseif isColwise
                nbrows = 1;
                nbcols = maxAx;
            elseif isRowwise
                nbrows = maxAx;
                nbcols = 1;
            else
                nbrows  = ceil(sqrt(maxAx));
                nbcols  = ceil(maxAx/nbrows);
            end
        elseif nbVARS == 1
            maxAx  = nbSeries;
            figName = variable{1};
            if fixedLayout
                if ~isnan(layout(1))
                    nbrows = layout(1);
                    if ~isnan(layout(2))
                        nbcols = layout(1);
                    else
                        nbcols = ceil(maxAx/nbrows);
                    end
                else
                    nbcols = layout(2);
                    nbrows = ceil(maxAx/nbcols);
                end
            elseif isColwise
                nbrows = 1;
                nbcols = maxAx;
            elseif isRowwise
                nbrows = maxAx;
                nbcols = 1;
            else
                nbrows  = ceil(sqrt(maxAx));
                nbcols  = ceil(maxAx/nbrows);
            end
        else
            maxAx = nbSeries * nbVARS;
            figName = 'multiple series and variables';
            if fixedLayout
                if ~isnan(layout(1))
                    nbrows = layout(1);
                    if ~isnan(layout(2))
                        nbcols = layout(1);
                    else
                        nbcols = ceil(maxAx/nbrows);
                    end
                else
                    nbcols = layout(2);
                    nbrows = ceil(maxAx/nbcols);
                end
            elseif isColwise
                nbrows  = nbVARS;
                nbcols  = nbSeries;
            else
                nbrows  = nbSeries;
                nbcols  = nbVARS;
            end
        end
        if isCombined
            nbrows = 1;
            nbcols = 1;
            maxAx  = 1;
        end
    end
    
    if isempty(figName)
        figName = 'no name';
    end
    
    allDates = cell(1,nbrows*nbcols);
    allTypes = NaN(1,maxAx);
    
    % get plot options for each variable
    nOptions = numel(plotOptions);
    if nOptions > 0
        if ~iscell(plotOptions{1})
            plotOptions = {plotOptions};
            nOptions = 1;
        end
        for o = 1:nbVARS-nOptions
            plotOptions = [plotOptions,plotOptions(end)];
        end
    else
        plotOptions = cell(1,nbVARS);
        for o = 1:nbVARS
            plotOptions{o} = cell(0);
        end
    end
    
    % if user has given an axis, then only one axis can be plotted
    if isAx
        ax(1) = axh;
        if nbSeries*nbVARS>1 && ~isCombined
            err = MException('X13TBX:x13series:plot:multiple_axes', ...
                ['If you select an axis to plot into, then only one ', ...
                'variable of one x13series can be plotted, ', ...
                'or you have to use the ''combined'' option.']);
            throw(err);
        end
    else
        ax = zeros(1,nbrows*nbcols);
    end
    
    % create new fig or raise existing one
    if ~isFig
        fh = figure('Name', figName);
    else
        try
            figure(fh);     % make requested figure the current figure
        catch
        end
    end
    
    % loop through x13series
    
    strTitle = cell(nbSeries,1);
    
    % get the color order
    % (this is needed for plotting multiple ACFs in a single axes)
    colorOrder = get(fh,'DefaultAxesColorOrder');
    nColors    = size(colorOrder,1);
    colorRow   = 0;
    
    % needed to properly print variables with multiple sub-variables
    % (e.g.fct)
    styleOrder = get(fh,'DefaultAxesLineStyleOrder');
    if numel(styleOrder) == 1
        styleOrder = {'-','--','-.',':'};
    end
    nStyles = numel(styleOrder);

    for s = 1:nbSeries
        
        % loop through variables

        if isempty(strTitle{s})
            strTitle{s} = '\bf';
        end
        strTitle{s} = [strTitle{s}, obj{s}.spec.title, ' : '];
        
        for v = 1:nbVARS
            
            if ~ismember(variable{v},obj{s}.listofitems)
                if ~quiet
                    warning('X13TBX:x13series:plot:miss_variable', ...
                        'Item ''%s'' in series ''%s'' is missing.', ...
                        variable{v}, obj{s}.spec.title);
                end
                continue;
            end
            
            % increment axes counter
            if isCombined || doSeparatePeriod
                cntAx = 1;
            else
                if isColwise
                    cntAx = (v-1)*nbSeries + s;
                else
                    cntAx = (s-1)*nbVARS + v;
                end
            end

            % titles
            if isCombined
                strTitle{s} = [strTitle{s}, variable{v}, ' '];
            else
                strTitle{s} = ['\bf', obj{s}.spec.title, ' : ', variable{v}];
            end
            
            [~,type] = obj{s}.descrvariable(variable{v});
            
            if ~isAx && type ~= 0 && ~(doSeparatePeriod && v*s>1)
                ax(cntAx) = subplot(nbrows,nbcols,cntAx);
            end
            
            % line colors
            if isCombined || doSeparatePeriod || doSpan || ...
                    abs(type) == 2 || abs(type) == 3
                colorRow = rem(colorRow,nColors)+1;
                colorOpt = {'Color',colorOrder(colorRow,:)};
            else
                colorOpt = {};
            end
            
            if isnan(allTypes(cntAx))
                allTypes(cntAx) = type;
            else
                if floor(abs(allTypes(cntAx))) ~= floor(abs(type))
                    err = MException('X13TBX:x13series:plot:CannoMixTypes', ...
                        ['Cannot mix types of data in the same axis. ', ...
                        'Remove ''combined'' option.']);
                    throw(err);
                end
            end
            
            switch abs(type)
                
                case {0,99}	% text or other
                    
                    if ~quiet
                        warning('X13TBX:x13series:plot:CannotPlot', ...
                            ['Item ''%s'' in series ''%s'' cannot be ', ...
                            'plotted.'], variable{v}, obj{s}.spec.title);
                    end
                
                case 1      % variable
                    
                    % dates
                    dates = obj{s}.(variable{v}).dates;
                    if isa(dates,'datetime')
                        dates = datenum(dates);
                    end
                    %  fromdates and todates
                    if numel(selectdates) == numel(dates)
                        keepdates = logical(selectdates);
                    else
                        keepdates = true(size(dates));
                    end
                    if ~isnan(fromDate)
                        keepdates(dates < fromDate) = false;
                    end
                    if ~isnan(toDate)
                        keepdates(dates > toDate) = false;
                    end
                    dates(~keepdates) = [];
                    % selection
                    fn = fieldnames(obj{s}.(variable{v}));
                    fn(1:3) = [];  % drop descr, type, and dates fields
                    thisSel = 1:numel(fn);
                    if ~isnan(sel)
                        if numel(sel) == numel(fn)
                            thisSel = find(sel);
                        end
                    end
                    % extract data to plot
                    styleRow = 0;
                    for thisVrbl = 1:numel(thisSel)
                        styleRow = rem(styleRow,nStyles)+1;
                        styleOpt = {'LineStyle',styleOrder{styleRow}};
                        toplot = obj{s}.(variable{v}).(fn{thisSel(thisVrbl)});
                        toplot(~keepdates,:) = [];
%                         % check for sliding spans variables
%                         if contains(variable{v},specialNaN)
%                             toplot(toplot==-999) = NaN;
%                         end
                        % ---
                        if isLog
                            toplot = log(toplot);
                        end
                        if isNormalized || isNormalizedMean
                            for k = 1:size(toplot,2)
                                kk = toplot(:,k);
                                available = ~isnan(kk);
                                kk(~available) = [];
                                if isNormalizedMean
                                    kk = kk-mean(kk);
                                else
                                    kk = (kk-mean(kk)) / std(kk);
                                end
                                toplot(available,k) = kk;
                            end
                        end
                    
                        hold(ax(cntAx),'on');

                        if doOverlapYears

                            allTypes(cntAx) = 1.1;   % x-axis is 1:4 or 1:12

                            p = obj{s}.period;
                            y = unique(year(dates)); ny = numel(y);
                            firstYear = sum(year(dates) == y(1));
                            lastYear  = sum(year(dates) == y(end));
                            meanYear  = (year(dates)>y(1) & year(dates)<y(end));
                            meanYear  = sum(meanYear) / (y(end-1)-y(2)+1);
                            data = [nan(meanYear-firstYear,1);toplot;nan(meanYear-lastYear,1)];
                            shuffle = NaN(ny,p);
                            for cc = 1:p
                                shuffle(:,cc) = cc+(0:ny-1)*p;
                            end
                            data = data(shuffle);
                            plot(ax(cntAx),y,data, ...
                                defaultOptions{:},plotOptions{v}{:});
                            xlim([y(1),y(end)]);

                            grid(ax(cntAx),'on');

                        end

                        if doOverlapPeriods || doSpan

                            allTypes(cntAx) = 1.1;   % x-axis is 1:4 or 1:12

                            p = obj{s}.period;
                            data = toplot;
                            cut = mod(numel(dates),p);
                            data = reshape(data(cut+1:end),p, ...
                                numel(dates(cut+1:end))/p)';
                            shuffle = find(yqmd(dates(cut+1:end),'q')==1, ...
                                1,'first');
                            shuffle = [shuffle:p,1:shuffle-1];
                            data = data(:,shuffle);

                            if doOverlapPeriods
                                plot(ax(cntAx),1:p,data);
                                xlim([1,p]);
                            end

                            if doSpan
                                plot(ax(cntAx),1:p,meannan(data), ...
                                    'LineWidth',1.0, ...
                                    colorOpt{:}, styleOpt{:}, ...
                                    defaultOptions{:}, plotOptions{v}{:})
                                plot(ax(cntAx),1:p,max(data), ...
                                    '--','LineWidth',0.6, colorOpt{:}, ...
                                    defaultOptions{:}, plotOptions{v}{:})
                                plot(ax(cntAx),1:p,min(data), ...
                                    '--','LineWidth',0.6, colorOpt{:}, ...
                                    defaultOptions{:}, plotOptions{v}{:})
                                xlim(ax(cntAx),[1,p]);
                            end
                            
                            grid(ax(cntAx),'on');

                        end

                        if doBoxplot

                            allTypes(cntAx) = 1.1;   % x-axis is 1:4 or 1:12

                            p = obj{s}.period;
                            data = toplot;
                            cut = mod(numel(dates),p);
                            data = reshape(data(cut+1:end), p, ...
                                numel(dates(cut+1:end))/p)';
                            if p == 12
                                shuffle = find(yqmd(dates(cut+1:end),'m')==1, ...
                                    1,'first');
                            else
                                shuffle = find(yqmd(dates(cut+1:end),'m')==3, ...
                                    1,'first');
                            end
                            shuffle = [shuffle:p,1:shuffle-1];
                            data = data(:,shuffle);
                            boxplot(ax(cntAx),data);

                        end

                        if doByPeriod
                            
                            mp = obj{s}.mperiod; p = max(mp);
%                             try
%                                 p = obj{s}.spec.fixedseas.period;
%                                 p = max(p);
%                             catch
%                                 p = obj{s}.period;
%                             end
                            
                            allTypes(cntAx) = 1.1;   % x-axis is 1:4 or 1:12

                            data = toplot;
                            if numel(mp) ~= 1
                                err = MException('X13TBX:x13series:plot:multiple_periods_not_allowed', ...
                                    ['The x13series contains more than ', ...
                                    'one period, but the requested plot-type ', ...
                                    '(''byperiod'') cannot handle that.']);
                                throw(err);
                            end
                            
                            f = 12/p;
                            DoAttemptAssignCorrectPeriod = (floor(f) == f);
                            if DoAttemptAssignCorrectPeriod
                                try
                                    m = yqmd(dates(1),'m')/f - 1;
                                    data = [nan(m,1);data];
                                    d = dates;
                                    for mm = 1:m
                                        d = [nan;d];
                                        d(1) = addtodate(d(2),-f,'month');
                                    end
                                    m = floor((12 - yqmd(dates(end),'m'))/f);
                                    data = [data;nan(m,1)];
                                    for mm = 1:m
                                        d(end+1) = addtodate(d(end),+f,'month');
                                    end
                                    cyc = size(data,1)/p;
                                    data = reshape(data,[],cyc)';
                                    m = repmat(meannan(data),cyc,1);
                                catch
                                    DoAttemptAssignCorrectPeriod = false;
                                end
                            end
                            if ~DoAttemptAssignCorrectPeriod
                                d = ceil(numel(data)/p) * p - numel(data);
                                data = [data;NaN(d,1)];
                                cyc = size(data,1)/p;
                                data = reshape(data,[],cyc)';
                                m = repmat(meannan(data),cyc,1);
                            end
                            
                            if ~doSeparatePeriod

                                % append a NaN to interrupt the line
                                data = [data;nan(1,p)];
                                m    = [m;nan(1,p)];
                                cyc  = cyc+1;
                                
                                x = (1+1/cyc:1/cyc:p+1);
                                plot(ax(cntAx),x,data(:), ...
                                    'LineWidth',1.0, ...
                                    colorOpt{:}, styleOpt{:}, ...
                                    defaultOptions{:}, plotOptions{v}{:})
                                if ~doByPeriodNoMean
                                    plot(ax(cntAx),x(:),m(:),'r', ...
                                        'LineWidth',1.0, ...
                                        defaultOptions{:}, plotOptions{v}{:});
                                end
                                xlim(ax(cntAx),[1,p+1-1/cyc]);
                                set(ax(cntAx),'YGrid','on');
                                set(ax(cntAx),'XTick',(1:p)+0.5);
                                set(ax(cntAx),'XTickLabel',1:p);
                                
                            else
                                
                                switch p
                                    case 12
                                        tit = {'January','February','March', ...
                                            'April','May','June','July', ...
                                            'August','September','October', ...
                                            'November','December'};
                                    case 6
                                        tit = {'Jan-Feb','Mar-Apr', ...
                                            'May-Jun','Jul-Aug', ...
                                            'Sep-Oct','Nov-Dec'};
                                    case 4
                                        tit = {'1st Quarter','2nd Quarter', ...
                                            '3rd Quarter','4th Quarter'};
                                    case 3
                                        tit = {'1st Trimester', ...
                                            '2nd Trimester','3rd Trimester'};
                                    case 2
                                        tit = {'1st Semester','2nd Semester'};
                                    otherwise
                                        tit = cellstr(num2str((1:p)'))';
                                end
                                for a = 1:p
                                    allTypes(a) = type;
                                    try
                                        allDates{a} = unique([allDates{a};d(a:p:end)]);
                                    catch
                                        allDates{a} = d(a:p:end);
                                    end
                                    ax(a) = subplot(nbrows,nbcols,a);
                                    plot(ax(a),d(a:p:end),data(:,a), ...
                                        'LineWidth',1.0, ...
                                        colorOpt{:}, styleOpt{:}, ...
                                        defaultOptions{:}, plotOptions{v}{:});
                                    title(ax(a),['\bf',tit{a}]);
                                    hold(ax(a),'on');
                                end
                                
                            end

                        end

                        if ~doBoxplot && ~doOverlapPeriods && ~doSpan && ~doByPeriod

                            allDates{cntAx} = unique([allDates{cntAx};dates]);
                            
                            if doLineChart
                                plot(ax(cntAx),dates,toplot, ...
                                    colorOpt{:}, styleOpt{:}, ...
                                    defaultOptions{:}, plotOptions{v}{:})
                            elseif doAreaChart
                                area(ax(cntAx),dates,toplot, ...
                                    styleOpt{:}, ...
                                    defaultOptions{:}, plotOptions{v}{:})
                            elseif doBarChart
                                bar(ax(cntAx),dates,toplot, ...
                                    styleOpt{:}, ...
                                    defaultOptions{:}, plotOptions{v}{:})
                            end
                            
                        end
                        
                    end

                case 2      % ACF or PACF
                    
                    vrb = obj{s}.(variable{v});
                    l  = vrb.Lag;           % lag
                    fn = fieldnames(vrb);
                    m  = vrb.(fn{4});       % mean
                    se = vrb.(fn{5});       % std error
                    plot(ax(cntAx),l,m, 'LineWidth',1.6, colorOpt{:}, ...
                        defaultOptions{:}, plotOptions{v}{:});
                    hold(ax(cntAx),'on');
                    plot(ax(cntAx),[l(1),l(end)],[0,0],'k');
                    plot(ax(cntAx),l,m-1.96*se, ...
                        '--','LineWidth',0.8, colorOpt{:}, ...
                        defaultOptions{:}, plotOptions{v}{:});
                    plot(ax(cntAx),l,m+1.96*se, ...
                        '--','LineWidth',0.8, colorOpt{:}, ...
                        defaultOptions{:}, plotOptions{v}{:});
                    xlim(ax(cntAx),[l(1),l(end)]);
                    mult = NaN;
                    p = l(end)-l(1);
                    if obj{s}.period == 12
                        if p <= 12
                            mult = 1;
                        elseif p <= 36
                            mult = 3;
                        elseif p <= 120
                            mult = 12;
                        end
                    elseif obj{s}.period == 4
                        if p <= 12
                            mult = 1;
                        elseif p <= 48
                            mult = 4;
                        elseif p <= 120
                            mult = 12;
                        end
                    else
                        mult = ceil(p/12);
                    end
                    ticks = (l(1)-1:mult:l(end));
                    ticks(1) = [];
                    set(ax(cntAx),'XTick',ticks);
                    set(ax(cntAx),'XTickLabel',ticks);
                    set(ax(cntAx),'XGrid','on');
                    
                case 3      % spectrum
                    fr = obj{s}.(variable{v}).frequency;
                    am = obj{s}.(variable{v}).amplitude;
                    plot(ax(cntAx),fr,am, 'LineWidth',1.6, colorOpt{:}, ...
                        defaultOptions{:}, plotOptions{v}{:});
                    hold(ax(cntAx),'on');
                    fn = fieldnames(obj{s}.(variable{v}));
                    if contains('conf',fn)
                        cf = obj{s}.(variable{v}).conf;
                        plot(ax(cntAx),fr,cf(:,1), ...
                            '--','LineWidth',0.8, colorOpt{:}, ...
                            defaultOptions{:}, plotOptions{v}{:});
                        plot(ax(cntAx),fr,cf(:,2), ...
                            '--','LineWidth',0.8, colorOpt{:}, ...
                            defaultOptions{:}, plotOptions{v}{:});
                    end
                    mp = max(obj{s}.mperiod);
                    mticks      = 1:(mp/2);
                    if mp == 12
                        tdticks     = [0.3482,0.4320];
                        [ticks,ord] = sort([mticks/mp,tdticks]);
                        tlabels     = [num2cell(mticks),'td','td'];
                        tlabels     = tlabels(ord);
                    else
                        ticks       = mticks/mp;
                        tlabels     = num2cell(mticks);
                    end
                    set(ax(cntAx),'XTick',ticks);
                    set(ax(cntAx),'XTickLabel',tlabels);
%                    xlabel(ax(cntAx),'months');
                    xlim(ax(cntAx),[obj{s}.(variable{v}).frequency(1), ...
                         obj{s}.(variable{v}).frequency(end)]);
                    set(ax(cntAx),'XGrid','on');
                    hold(ax(cntAx),'on');
                    
            end
            
            if ~isCombined && ~doSeparatePeriod && type ~= 0
% until version 1.17.1
%                temp = {strTitle{s}, ...
%                    ['\rm',obj{s}.descrvariable(variable{v})]};
% since version 1.17.5
                temp = sprintf('\\bf%s : \\rm%s', ...
                    obj{s}.spec.title, ...
                    obj{s}.descrvariable(variable{v}));
                title(ax(cntAx),temp);
            end
        
        end
        
    end
    
    if ~doSeparatePeriod && (isCombined && ishghandle(ax,'axes'))
        title(ax(1),strTitle);
    end
    
    % store type information of individual axes;
    % adjust x-axis for axes containing variables
    for cntAx = 1:maxAx
        if abs(allTypes(cntAx)) == 1
            try
                allDates{cntAx} = sort(allDates{cntAx});
                % make x-axis tight
                xlim(ax(cntAx),[allDates{cntAx}(1),allDates{cntAx}(end)]);
                % x-axis
                if strcmpi(codeDateTick,'matlab')
                    datetick(ax(cntAx),'x');
                else
                    if doSeparatePeriod
                        setXticks(ax(cntAx),allDates{cntAx},4);
                    else
                        setXticks(ax(cntAx),allDates{cntAx});
                    end
                end
            catch
            end
            % turn on grid
            grid(ax(cntAx),'on');
        end
        % store types drawn in the axes
        setappdata(ax(cntAx),'type',allTypes(cntAx));
        
    end
    
    % force immediate drawing
    drawnow();
    
    % customize cursor datatip
    try
        hDCM = datacursormode(fh);
        p = obj{1}.period;
        for s = 2:numel(obj)
            if p ~= obj{s}.period
                p = 1;
            end
        end
        % The strategy using UpdateFct (see below) leads to problems. The
        % x13series objects cannot properly be destroyed anymore if a plot was
        % used, even if the figures are deleted. Why this is so I don't
        % understand.
        %   set(hDCM,'UpdateFcn',{@customized_cursortext,p});
        % But passing the p parameter not as argument to the UpdateFct, but
        % instead through appdata resolves this issue.
        setappdata(fh,'period',p);
        set(hDCM,'UpdateFcn',{@customized_cursortext});
    catch
    end
    
    switch nargout
        case 0
            clear fh ax
        case 1
            clear ax
        otherwise
            if numel(ax) == 1
                ax = ax(1);
            else
                ax = reshape(ax,nbcols,nbrows)';
            end
    end
    
    % ---------------------------------------------------------------------
    
    function m = meannan(x)
        killrows = any(isnan(x),2);
        m = mean(x(~killrows,:));
    end
    
    function out_txt = customized_cursortext(~,event_obj)
    % Display the position of the data cursor
    % ~            currently not used (empty)
    % event_obj    handle to event object
    % out_txt      data cursor text string (string or cell array of strings).
    
        % retrieve period information stored in figure
        p = getappdata(get(event_obj.Target,'Parent'),'period');
        if isempty(p)
            p = getappdata(get(get(event_obj.Target,'Parent'), ...
                'Parent'),'period');
        end
        
        % retrieve type information stored in axes
        type = getappdata(get(event_obj.Target,'Parent'),'type');
        if isempty(type)
            type = getappdata(get(get(event_obj.Target,'Parent'), ...
                'Parent'),'type');
        end
        
        % retrieve position of mouse click
        pos = get(event_obj,'Position');
        
        % branch out to different formats
        try
            switch abs(type)
                case 1      % for variables
                    datelabel = datestr(pos(1),'dd mmm yyyy (ddd)');
                    out_txt = {[' Date: ', datelabel],...
                               ['Value: ', num2str(pos(2),6)]};
                case 1.1    % byperiod
                    if pos(1) == floor(pos(1))
                        pos(1) = floor(pos(1)-1);
                    else
                        pos(1) = floor(pos(1));
                    end
                    out_txt = {['Month/Quarter: ', int2str(pos(1))], ...
                               ['Value: ', num2str(pos(2),6)]};
                case 2      % for ACF/PACF
                    out_txt = {[' Lag: ', num2str(pos(1),6),' ', ...
                                                            periods], ...
                               ['Corr: ', num2str(pos(2),6)]};
                case 3      % for spectra
                    out_txt = {['Freq: ', num2str(pos(1)*p,6),' ', ...
                                                            periods], ...
                               ['Ampl: ', num2str(pos(2),6),' dB']};
                otherwise   % something's wrong
                    out_txt = {['X: ', num2str(pos(1),6)], ...
                               ['Y: ', num2str(pos(2),6)]};
            end
        catch
             out_txt = {['X: ', num2str(pos(1),6)], ...
                        ['Y: ', num2str(pos(2),6)]};
        end
        
    end

    % select date ticks for date axes
    function [labels,ticks] = setXticks(ax,thedates,varargin)
        if numel(varargin) > 0
            nbTicks = varargin{1};
        else
            nbTicks = 9;
        end
        legalcodes = {'all','d','wd','w','m','q','y','auto'};
        code = find(strcmpi(legalcodes,codeDateTick));
        switch code
            case 1
                ticks  = 1:numel(thedates);
                labels = datestr(thedates);
            case {2,3}
                [labels,ticks] = daycell(thedates);
            case 4
                [labels,ticks] = weekcell(thedates);
            case 5
                [labels,ticks] = monthcell(thedates);
            case 6
                [labels,ticks] = quartercell(thedates);
            case 7
                [labels,ticks] = yearcell(thedates);
            case 8
                if numel(thedates) < 10
                	ticks  = 1:numel(thedates); labels = datestr(thedates);
                else
                    dlength = thedates(end)-thedates(1);
                    if dlength/365 > 4
                        [labels,ticks] = yearcell(thedates);
                    elseif dlength/90  > 5
                        [labels,ticks] = quartercell(thedates);
                    elseif dlength/30  > 4
                        [labels,ticks] = monthcell(thedates);
                    elseif dlength/7   > 2
                        [labels,ticks] = weekcell(thedates);
                    else
                        [labels,ticks] = daycell(thedates);
                    end
                end
        end
        ticks = find(ticks);
        if isnan(multDateTick)
            mult = ceil(numel(ticks)/nbTicks);
        else
            mult = multDateTick;
        end
        if mult > 1
            ticks = ticks(1:mult:end);
            labels = labels(1:mult:end);
        end
        set(ax,'XTick',thedates(ticks));
        set(ax,'XTickLabel',labels);
    end

    % make cell arrays containing entries only when the year, quarter,
    % month, week, or day changes
    
    function [str,keep] = yearcell(d)
        d = d(:);
        c = datevec([d(1)-1;d]);
        num = c(:,1);
        keep = (diff(num) ~= 0);
        num = num(2:end);
        str = strtrim(cellstr(num2str(num(keep))));
    end
    
    function [str,keep] = quartercell(d)
        d = d(:);
        c = datevec([d(1)-1;d]);
        num = (c(:,2)-1)/3 + 1;
        keep = (floor(num) == num);
        keep = (keep(2:end) & ~keep(1:end-1));
        num = num(2:end);
        c = c(2:end,:);
        ystr = strtrim(cellstr(num2str(c(:,1))))';
        strvec = {'-1Q','-2Q','-3Q','-4Q'};
        str = strcat(ystr(keep),strvec(num(keep)));
    end
    
    function [str,keep] = monthcell(d)
        d = d(:);
        c = datevec([d(1)-1;d]);
        num = c(:,2);
        keep = (diff(num) ~= 0);
        num = num(2:end);
        ystr = strtrim(cellstr(num2str(c(:,1))))';
        strvec = {'Jan ','Feb ','Mar ','Apr ','May ','Jun ','Jul ', ...
            'Aug ','Sep ','Oct ','Nov ','Dec '};
        str = strcat(strvec(num(keep)),ystr(keep));
    end
    
    function [str,keep] = weekcell(d)
        d = d(:); d = [d(1)-1;d];
        num = weekday(d(:));
        num = mod(num-2,7);     % Monday = 0
        keep = (num(2:end) < num(1:end-1));
        d = d(2:end);
        % strvec = {'Mon','Tue','Wed','Thu','Fri','Sat','Sun'};
        str = strtrim(cellstr(datestr(d(keep),'dd-mmm')));
    end
    
    function [str,keep] = daycell(d)
        d = d(:);
        c = datevec([d(1)-1;d]);
        num = c(:,3);
        keep = (diff(num) ~= 0);
        num = num(2:end);
        str = strtrim(cellstr(num2str(num(keep))));
    end

end
