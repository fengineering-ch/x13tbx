% PLOT (overloaded) plots the content of an x13composite object
%
% Usage:
%   plot(obj)
%   plot(obj, 'variable1', 'variable2', ...)
%   plot(obj, 'variable1', 'variable2', ..., 'dropcomposite')
%   plot(obj1, 'variable1', 'variable2', ..., option1, option2, ...)
%   plot(h, obj, ...)
%   [fh,ax] = plot(...)
%
% Inputs:
%   obj            A x13composite object.
%   variable       The name of variables stored in the x13series contained in
%                  obj.
%   h              Can be a figure handle or an axes handle. If it is an axes
%                  handle, then only one variable can be specified. If the
%                  x13composite object contains multiple series (which
%                  normally it would), then one must also set the 'combined'
%                  option. The single variable of all x13series in obj are
%                  then plotted to the given axes.
%   dropcomposite  Do not plot the composite series.
%   options        See help on x13series.plot for explanation.
%
% Outputs:
%   fh             A handle to the figure that is created.
%   ax             An array of handles to the individual axes that are
%                  contained in the figure.
%
% x13composite.plot really functions like x13series.plot, where all series
% contained in the composite object are passed as individual series to the
% x13series.plot routine. For instance, if obj is a x13composite with five
% series,
% 
% =========================================================================
%  X13-ARIMA-SEATS composite object
% .........................................................................
%  List of series:
% -> Y
%  - C
%  - I
%  - G
%  - NX
% .........................................................................
%  Time of run: 24-Jul-2015 09:18:02 (4.0 sec)
% =========================================================================
% 
% then plot(obj, [...]) --- which calls x13composite.plot --- is exactly
% the same as plot(objC,obj.I,obj.G,obj.NX,obj.Y, [...]) --- which calls
% x13series.plot.
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
% 2017-01-09    Version 1.30    First release featuring camplet.
% 2016-07-10    Version 1.17.1  Improved guix. Bug fix in x13series relating to
%                               fixedseas.
% 2016-07-06    Version 1.17    First release featuring guix.
% 2016-03-10    Version 1.16.1  Added 'dropcomposite' option.
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
% 2015-07-20    Version 1.13.3  Resolved some backward compatibility
%                               issues (thank you, Carlos). Using new
%                               program yqmd to ensure compatibility before
%                               R2013a.
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
% 2015-05-21    Version 1.12    Several improvements: Ensuring backward
%                               compatibility back to 2012b (possibly
%                               farther); Added 'seasma' option to x13;
%                               Added RunsSeasma to x13series; other
%                               improvements throughout. Changed numbering
%                               of versions to be in synch with FEX's
%                               numbering.
% 2015-04-28    Version 1.6     x13as V 1.1 B 19
% 2015-01-04    Version 1.1     Adapting to some changes in the
%                               x13composite class
% 2014-12-31    Version 1.0     First Version

function [fh,ax] = plot(varargin)

    % separate first arg if it is a fig or ax handle
    if nargin > 0
        if ishghandle(varargin{1},'figure') || ...
                ishghandle(varargin{1},'axes');
            h = varargin{1};
            isHandle = true;
            varargin(1) = [];
        else
            isHandle = false;
        end
    else
        err = MException('X13TBX:x13composite:plot:arg_missing', ...
            'Plot expects some arguments. (This error should not occur!)');
        % If the TBX is correctly installed, this error should not occur,
        % because ML would not reach the x13composite.plot function if no
        % x13series object is given as argument.
        thorw(err);
    end
    
    % next arg should be the x13composite object
    if nargin > 0
        if isa(varargin{1},'x13composite');
            x = varargin{1};
            varargin(1) = [];
        else
            err = MException('X13TBX:x13composite:plot:NoX13composite', ...
                'No x13composite found.  (This error should not occur!)');
            % If the TBX is correctly installed, this error should not occur,
            % because ML would not reach the x13composite.plot function if no
            % x13series object is given as argument.
            throw(err)
        end
    else
        err = MException('X13TBX:x13composite:plot:NoX13composite', ...
            ['No argument after handle found, in particular no ', ...
            'x13composite. (This error should not occur!)']);
        % If the TBX is correctly installed, this error should not occur,
        % because ML would not reach the x13composite.plot function if no
        % x13series object is given as argument.
        throw(err);
    end
    
    % check for 'dropcomposite' option
    dropComposite = false;
    for n = 1:numel(varargin)
        try
            validatestring(varargin{n},{'dropcomposite'});
            dropComposite = true;
            varargin(n) = [];
            continue;
        end
    end
    
    % get all series names ...
    strNames = x.listofseries;
    if dropComposite
        idx = strcmp(x.compositeseries,strNames);
        strNames(idx) = [];
    end
    cellNames = cell(1,numel(strNames));
    for s = 1:numel(cellNames)
        cellNames{s} = x.(strNames{s});
    end
    
    % ... and send it off to x13series.plot 
    if isHandle
        [fh,ax] = plot(h,cellNames{:},varargin{:});
    else
        [fh,ax] = plot(cellNames{:},varargin{:});
    end
    
    % remove unused argout
    switch nargout
        case 0
            clear fh ax
        case 1
            clear ax
    end

    
end
