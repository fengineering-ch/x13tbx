% SEASBREAKS (overloaded) produces a special plot showing potential seasonal breaks
%
% Usage:
%   seasbreaks(obj)
%   seasbreaks(..., plotoptions)
%   [fh,ax] = seasbreaks(...)
%
% The plot produces a chart with one axis for each month (quarter)
% displaying the seasonal factors as lines and the SI ratios as markers.
% Normally, the lines should be relatively close to the markers. If for one
% month (quarter), the markers are all below the line, and then suddenly
% above it (or vice versa), this indicates a break in the seasonal
% structure. The function returns a handle to the figure and a matrix of
% handles to the individual axes.
%
% The program works only if
%  - the X-11 seasonal factors have been computed and 'd10' as well as 'd8'
%    or 'd13' have been saved, or
%  - the SEATS seasonal factors have been computed and 's10' and 's13' have
%    been saved, or
%  - any CUSTOM seasonal factors have been computed and 'sf' as well as 'si'
%    or 'ir' have been saved.
% If SI (i.e. 'd8' or 's8') are missing, SI is recovered as SI = SF+IR (or
% (SI = SF*IR, depending on the type of adjustment defined in the spec).
%
% Inputs:
%   obj          An x13series object.
%   h            An optional figure handle.
%   plotoptions  Any options passed on to x13series.plot.
%
% Outputs:
%   fh           A handle to the figure that is created.
%   ax           Handles to the axes in the figure.
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
% 2021-04-28    Version 1.50    Using the new .keyv property of x13series
% 2017-01-09    Version 1.30    First release featuring camplet. Added the
%                               option to provide variables for sf and si
%                               manually.
% 2016-07-10    Version 1.17.1  Improved guix. Bug fix in x13series relating to
%                               fixedseas.
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
% 2015-07-21    Version 1.13.1  Common span of ordinates.
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

function [fh,ax] = seasbreaks(varargin)

    % first arg a figure handle?
    if ishghandle(varargin{1},'figure')
        fh = varargin{1};
        obj = varargin{2};
        varargin(1:2) = [];
        isFig = true;
    else
        obj = varargin{1};
        varargin(1) = [];
        isFig = false;
    end
    
    % error checking
    if ~isa(obj,'x13series')
        e = MException('X13TBX:x13series:seasbreaks:objectmissing', ...
            ['First or second argument must be a x13series object. ', ...
            '(This error should not occur! Something''s seriously messed up.)']);
        % If the TBX is correctly installed, this error should not occur,
        % because ML would not reach the seasbreaks function if no x13series
        % object is given as argument.
        throw(e);
    end

    % get names of variables
    si = obj.keyv.si;
    sf = obj.keyv.sf;
    ir = obj.keyv.ir;

    siNA = strcmp(si,'***');
    sfNA = strcmp(sf,'***');
    irNA = strcmp(ir,'***');
    
    % we do need SF
    if sfNA || ~ismember(sf,obj.listofitems)
        warning('X13TBX:x13series:seasbreaks:no_SA_found',['No seasonal ', ...
            'adjustment found. Cannot produce requested graph for ', ...
            'series ''%s''.'], obj.spec.title);
        return;
    end
    
    % STRANGELY, x13as.exe does NOT exponentiate SI if mode is logadd ??
    % I cannot figure out when x13as.exe is taking a log or not taking a
    % log of D8. 

    % make sure
    SF_is_0 = obj.isRoughly('sf',0); %(round(mean(obj.(sf).(sf)),0) == 0);

    % make SI if missing
    if siNA || ~ismember(si,obj.listofitems)
        if irNA || ~ismember(ir,obj.listofitems)
            warning('X13TBX:x13series:seasbreaks:no_IR_found',['No SI or ', ...
                'IR component found. Cannot produce requested graph for ', ...
                'series ''%s''.'], obj.spec.title);
            return;
        else
            if siNA
                si = 'si';
                obj.keyv.si = si;
            end
            if SF_is_0
                siValues = obj.(sf).(sf) + obj.(ir).(ir);
            else
                siValues = obj.(sf).(sf) .* obj.(ir).(ir);
            end
            obj.addvariable(si,obj.dat.dates,siValues,si,1, ...
                'SI (SF + IR or SF * IR)');
        end
    end
    
    SI_is_0 = obj.isRoughly('si',0); %(round(mean(obj.(si).(si)),0) == 0);
    isStrange1 = (SF_is_0 && ~SI_is_0);
    isStrange2 = (~SF_is_0 && SI_is_0);
    if isStrange1
        keepSI = obj.(si).(si);
        obj.(si).(si) = log(keepSI);
    end
    if isStrange2
        keepSI = obj.(si).(si);
        obj.(si).(si) = exp(keepSI);
    end
    
    % make the graph
%     if ~isnan(sf)
        if ~isFig
            fh = figure('Name',[obj.spec.title,' : seasonal breaks'], ...
                'Position',[206 305 869 515]);
            movegui(fh,'center')
        end
        [fh,ax] = plot(fh,obj,si,sf,'separate', ...
            'options',{{'Marker','o','LineStyle','none', ...
            'MarkerEdgeColor','r','MarkerSize',3}, ...
            {'Color','k','LineWidth',1}}, varargin{:});
%     else
%         warning('X13TBX:x13series:seasbreaks:no_SA_found',['No seasonal ', ...
%             'adjustment found. Cannot produce requested graph for ', ...
%             'series ''%s''.'], obj.spec.title)
%         return;
%     end
    
    % ensure that span of ordinate is identical across axes
    % - determine maximum span
    yspan = ylim(ax(1,1)); yspan = yspan(2)-yspan(1);
    for r = 1:size(ax,1)
        for c = 1:size(ax,2)
            candidate = ylim(ax(r,c));
            candidate = candidate(2)-candidate(1);
            if candidate > yspan; yspan = candidate; end
        end
    end
    % - set ylim of all axes
    yspan = yspan/2;
    for r = 1:size(ax,1)
        for c = 1:size(ax,2)
            yl = ylim(ax(r,c));
            yl = (yl(1)+yl(2))/2;
            ylim(ax(r,c),[yl-yspan,yl+yspan]);
        end
    end
    
    % deal with argout
    if nargout < 2
        clear ax
        if nargout < 1
            clear fh
        end
    end

    % go back to original SI
    if isStrange1 || isStrange2
        obj.(si).(si) = keepSI;
    end
    
end
