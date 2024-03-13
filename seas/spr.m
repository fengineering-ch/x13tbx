% SPR computes the standard deviation of the irregular from the seasonal
% filtering using different periodicities. This volatility should be
% smaller when the period used matches the true period of the data. This is
% therefore a simply way to identify an unknown period of the cycle(s). It
% is, essentially, a poor man's spectral analysis.
%
% Usage:
%   spr(data);
%   [s,p,r,x] = spr(data);
%   [s,p,r,x] = spr(data1, data2, ...);
%   [s,p,r,x] = spr(..., method);
%   [s,p,r,x] = spr(..., options);
%
% data or data1, data2, etc are individual vectors or data.
%
% method is one of the following: 'fixedseas',' seas', 'method1', 'x11'.
% Default is 'fixedseas' (because this often works best in practice).
%
% options are any options passed on to fixedseas/seas/method1/x11.
%
% If used with no output variables, spr produces a graph showing the
% standard deviation of the irregular of fixedseas with periods running
% from one to a third the length of data. The spikes in this graph indicate
% potential periods of cycles. One line is used for each data vecor given
% as argument.
%
% If used with output variables, s is the vector of standard deviations, p
% is the vector 1:p, where p is a third of the length of data (so plot(p,s)
% plots the spikes), and r is a matrix with all the residuals. x is a
% boolean vector identifying spikes (extreme negative curvatures).
%
% If multiple data are used, then s,p,r,x are cell vectors, containing the
% results for each data vector separately.
%
% Example:
%   trend  = 0.02*(1:200)' + 5;
%   cycle1 = 1.0 * sin((1:200)'*(2*pi)/14);
%   cycle2 = 0.7 * sin((1:200)'*(2*pi)/20);
%   resid  = 0.5 * randn(200,1);
%   data   = trend + cycle1 + cycle2 + resid;
%   % So we know that data has two periods, 14 and 20. We now try to find
%   % these periods.
%   figure; spr(data,'add');
%   % The graph reveals a clear spike at 14 (and an echo at 28 etc), which
%   % we filter out now ...
%   s = fixedseas(data,14,'add');
%   figure; spr(s.sa,s.ir,'add');
%   % The seasonally adjusted series and the residuals show no spike at 14
%   % anymore, but a clear spike at 20 (and 40 and 60). We now take out
%   % period 20 as well.
%   s = fixedseas(data,[14,20],'add');
%   figure; spr(s(end).sa,s(end).ir,'add');
%   % The seasonally adjusted series and the residuals show no spikes
%   % anymore.
%
% NOTE: This program is part of the X-13 toolbox, but it is completely
% independent of the Census X-13 program. It uses fixedseas to filter
% seasonal cycles and computes the volatility of the resulting residuals.
% This program is just a small addition to the toolbox that makes it more
% complete.
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

% History
% 2021-05-12    Version 1.50    Support for x11.m
% 2021-04-22    Version 1.42    Support for method1.m
% 2017-11-09    Version 1.31    Separates multi-dimensional variables
%                               (containing more than one column) into seperate
%                               variables and treates them individually.
% 2017-01-09    Version 1.30    First release featuring camplet.
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
%                               bugfixes and improvements. Multiple series
%                               plotted in same figure using spr.
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
% 2015-05-21    Version 1.12    Several improvements: Ensuring backward
%                               compatibility back to 2012b (possibly
%                               farther); Added 'seasma' option to x13;
%                               Added RunsSeasma to x13series; other
%                               improvements throughout. Changed numbering
%                               of versions to be in synch with FEX's
%                               numbering.
% 2015-05-18    Version 1.6.1   better calibation of extreme points; added
%                               x output variable (vector of spikes)
% 2015-04-28    Version 1.6     x13as V 1.1 B 19
% 2015-01-30    Version 1.1     adaption to change in seasma
% 2015-01-22    Version 1.0     first version

function [s,p,r,x] = spr(varargin)

    % separate first arg if it is a fig or ax handle
    if nargin > 0
        if ishghandle(varargin{1},'figure')
            figure(varargin{1});
            hType = 'fig';
            varargin(1) = [];
        elseif ishghandle(varargin{1},'axes')
            hType = 'ax';
            h = varargin{1};
            varargin(1) = [];
        else
            hType = 'none';
        end
    else
        err = MException('X13TBX:X13SERIES:SPR:arg_missing', ...
            'spr expects some arguments.');
        throw(err);
    end
    
    % extract algorithm
    method = [];
    v = false(1,numel(varargin));
    for m = 1:numel(varargin)
        try
            method = validatestring(varargin{m}, ...
                {'fixedseas','seas','method1','x11'});
            v(m) = true;
        catch
        end
    end
    varargin(v) = [];
    if isempty(method); method = 'fixedseas'; end

    % preparations
    isStr = cellfun(@(c) ischar(c), varargin);
    nvrbl = find(isStr,1,'first')-1;    % nvrbl = # of variables given
    if isempty(nvrbl); nvrbl = numel(varargin); end
    data = [varargin{1:nvrbl}];         % make one big array of the data
    varargin(1:nvrbl) = [];             % remove variable names from list, ...
                                        % ...keep only options
    nvrbl = size(data,2);               % count number of columns

    seasadj = cell(1,nvrbl);
    s       = cell(1,nvrbl);
    p       = cell(1,nvrbl);
    r       = cell(1,nvrbl);
    x       = cell(1,nvrbl);
    
    % loop through variables
    for v = 1:nvrbl
        n       = floor((numel(data(:,v)))/3);
%        n       = floor((numel(data(:,v))-1)/3);
        p{v}    = (1:n)';
        r{v}    = nan(numel(data(:,v)),n);
%        r{v}    = nan(numel(data(:,v))-1,n);
        s{v}    = nan(n,1);
        % compute seasonal adjustment for different periods
        for pp = 1:n
            try
                switch method
                    case 'fixedseas'
                        seasadj{v} = fixedseas(data(:,v),pp,varargin{:});
                        dIR = seasadj{v}.ir;
%                        dIR = diff(seasadj{v}.ir);
                        r{v}(:,pp) = dIR;
                        s{v}(pp)   = std(dIR(~isnan(dIR)));
                    case 'seas'
                        seasadj{v} = seas(data(:,v),pp,varargin{:});
                        dIR = seasadj{v}.ir;
%                        dIR = diff(seasadj{v}.ir);
                        r{v}(:,pp) = dIR;
                        s{v}(pp)   = std(dIR(~isnan(dIR)));
                    case 'method1'
                        seasadj{v} = method1(data(:,v),pp,varargin{:});
                        dIR = seasadj{v}.d13;
%                        dIR = diff(seasadj{v}.d13);
                        r{v}(:,pp) = dIR;
                        s{v}(pp)   = std(dIR(~isnan(dIR)));
                    case 'x11'
                        seasadj{v} = x11(data(:,v),pp,varargin{:});
                        dIR = seasadj{v}.d13;
%                        dIR = diff(seasadj{v}.d13);
                        r{v}(:,pp) = dIR;
                        s{v}(pp)   = std(dIR(~isnan(dIR)));
                end
            catch
            end
        end

        % identify spikes
        % - to the left of a spike, derivative must be <0, to the right >0
        deriv = diff(s{v});             % derivative
        signchange = (deriv(1:end-1)<0) & (deriv(2:end)>0);
        % curvature must be extremely negative
        curv = diff(deriv);             % curvature
        curv = curv/std(curv);          % normalize
        try
            limitvalue = -norminv(0.9/n);   % threshold for outliers
        catch                               % in case stats tbx not present
            limitvalue = -sqrt(2)*erfinv(2*0.9/n - 1);
        end
        % these are the spikes
        x{v} = [false; (curv > limitvalue) & signchange; false];
    end
    
    if nargout == 0
        switch hType
            case 'fig'
                h = axes;
            case 'none'
                h = gca;
        end
        % turn linesmoothing on up top 2014a
        if verLessThan('matlab','8.4')
            defaultOptions = {'LineSmoothing','on'};
        else
            defaultOptions = cell(0);
        end
        xl = p{1}(1); xr = p{1}(end);
        for v = 1:nvrbl
            if p{v}(1) < xl  ; xl = p{v}(1)  ; end
            if p{v}(end) > xr; xr = p{v}(end); end
            % plot std error
            plot(h,p{v}(2:end),s{v}(2:end),defaultOptions{:});
            xlabel(h,'period'); ylabel(h,'std(irregular)');
            set(gca,'YDir','reverse'); grid on;
            % highlight and label significant spikes
            hold(h,'all');
            findx = find(x{v});
            scatter(h,p{v}(findx),s{v}(findx),'r','filled');
            yl = ylim; vd = (yl(2)-yl(1))/40;    % vertical distance
            for z = 1:numel(findx)
                text('Position', [p{v}(findx(z)),s{v}(findx(z))-vd], ...
                    'String', p{v}(findx(z)), ...
                    'HorizontalAlignment','center', ...
                    'VerticalAlignment','bottom');
            end
        end
        xlim([xl,xr]);
        % no output required
        clear s p r x
    else
        if nvrbl == 1
            s = s{1};
            p = p{1};
            r = r{1};
            x = x{1};
        end
    end

end
