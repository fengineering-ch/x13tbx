% TRENDFILTER produces a smoothed version of the data.
%
% Usage:
%   tr = trendfilter(data)
%   tr = trendfilter(data,[method])
%   tr = trendfilter(data,[method,parameters])
%   tr = trendfilter(data,['mirror'|'extend', number])
%
% data      An array. Each column is a time series and is smoothed separately.
%
% method    Method used to smooth, possibly followed by one r several
%           parameters. Possibilities are:
%   'mean'                      Artithmetic mean over whole column.
%   'deviation'                 Deviation of column means from row means.
%   'reldeviation'              Relative deviation of column means from row
%                               means.
%   'detrend'                   A linear trend is fitted to the data.
%   'detrend',bp                A continuous, piecewise linear trend is
%                               fitted to the data. 'bp' is the (row) vector of
%                               breakpoints.
%   'hp',lambda                 For the Hodrick-Prescott filter, an
%                               additional argument must be given. lambda
%                               is a smoothing parameter lambda. The
%                               greater lambda, the smoother the trend.
%   'spline',roughness          Fits a smoothing cubic spline to the data.
%                               'roughness' is a number between 0.0
%                               (straight line) and 1.0 (no smoothing), see
%                               doc csaps.
%   'polynomial',degree         Fit a polynomial of specified degree to the
%                               data, see doc polyfit.
% In addition, all the kernels supported by kernelweights.m can also be
% specified here:
%   'ma' or 'ma',p1,p2,...      A simple moving average, or a convolution
%                               of simple movong averages.
%   'cma'                       A centered moving average over a range of
%   'cma',p1,p2,...             minus p1/2 lags to plus p1/2, or a
%                               convolution of such moving averages.
%   'spencer' or 'spencer15'    A special 15-term moving average.
%   'henderson',t               The Henderson filter with t terms.
%   'bongard',t                 The Bongard filter with t terms.
%   'rehomme-ladiray',t,p,h     The Rehomme-Ladiray filter with t terms,
%                               which perfectly reproduces polynome of
%                               order p, and minimizes a weighted average
%                               of the Henderson and the Bongard criteria
%                               (with h being the weight of the Henderson
%                               criterion).
% One of the following: 
%   'uniform','triangle','biweight' or 'quartic','triweight','tricube',
%   'epanechnikov','cosine','optcosine','cauchy', followed by a single
%    parameter indicating the bandwidth.
% Some kernels have infinite support: 'logistic','sigmoid','gaussian' or
%   'normal','exponential','silverman'. If you choose one of these, you can use
%   two parameters, the first indicating the bandwidth, the second indicating
%   the length of the vector that is returned. (If the second parameter is not
%   given, a vector is returned where all elements are at least 1e-15.
%
% 'mirror',p    The p first and the p last observations are mirrored and
%               pre-appended and appended to the data, respectively. This
%               reduces edge of sample problems. The mirrored part of the trend
%               is removed and not returned in tr.
% 'extend',p    Same as 'mirror', but without switching the order. This method
%               works well only with stationary data. If in doubt, use 'mirror'
%               rather than 'extend'.
%
% NOTE: This program is part of the X-13 toolbox, but it is completely
% independent of the Census X-13 program. It is part of the 'seas' addition to
% the toolbox which allows to implement seasonal filters without using the
% Census Bureau programs.
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
% 2018-09-19    Version 1.33    First version of the 'seas' part of the X-13
%                               toolbox.

function tr = trendfilter(data,type,varargin)

    [nobs,nseries]  = size(data);
%     data = [flipud(data);data;flipud(data)];
    
    if nobs == 1 && nseries > 1
        data = data(:);
        [nobs,nseries]  = size(data);
        isTransp = true;
    else
        isTransp = false;
    end

    args = varargin; args(~cellfun(@ischar, args)) = {''};
    extend = find(ismember(args,'extend'));
    if ~isempty(extend)
        e = varargin{extend+1};
        doExtend = true;
        varargin(extend:extend+1) = [];
    else
        doExtend = false;
    end
    mirror = find(ismember(args,'mirror'));
    if ~isempty(mirror)
        e = varargin{mirror+1};
        doExtend = false;
        doMirror = true;
        varargin(mirror:mirror+1) = [];
    else
        doMirror = false;
    end
    
    if doExtend
        data = [data(1:e,:);data;data(end-e+1:end,:)];
    end
    if doMirror
        data = [data(e:-1:1,:);data;data(end:-1:end-e+1,:)];
    end
    
    xnobs = size(data,1);
%     data = fillholes(data);

    kerneltypes = {'rehomme-ladiray','bongard', 'henderson', ...
        'spencer','spencer15','cma','centered moving average', 'ma', ...
        'moving average','uniform','rectangular','rectangle','box', ...
        'epanechnikov','triangle','triangular','biweight','quartic', ...
        'triweight','tricube','cosine','optcosine','logistic','sigmoid', ...
        'silverman','gaussian','normal','exponential','cauchy'};
    legalmethods = {'mean','deviation','reldeviation', 'detrend','spline',...
        'polynomial','hp'};
    legalmethods = [legalmethods,kerneltypes];
    
    type = validatestring(type,legalmethods);
    
    tr = nan(xnobs,nseries);
    
    switch type

        case 'mean'                 % artithmetic mean over whole column
            tr = repmat(nanmean(data,1),xnobs,1);
            
        case 'deviation'            % deviation of column means from row means
            tr = repmat(nanmean(data,1),size(data,1),1);
            tr = tr - repmat(nanmean(tr,2),1,size(data,2));
        
        case 'reldeviation'         % relative deviation of column means from row means
            tr = repmat(nanmean(data,1),size(data,1),1);
            tr = tr ./ repmat(nanmean(tr,2),1,size(data,2));
        
        case 'detrend'              % fit trend regression
            if isempty(varargin)
                cycle = detrend(data,'linear');
            else
                cycle = detrend(data,'linear',varargin{1});
            end
            tr = data - cycle;
            
        case 'spline'               % spline through the data points
            a = extractparameter(varargin,1);
            for c = 1:nseries
                keep = find(~isnan(data(:,c)));
                pp = csaps(keep,data(keep,c),a{:});
                tr(keep,c) = fnval(pp,keep);
            end
            
        case 'polynomial'           % fit polinomial to the data
            a = extractparameter(varargin,1);
            for c = 1:nseries
                keep = find(~isnan(data(:,c)));
                [p,~,mu] = polyfit(keep,data(keep,c),a{1});
                tr(keep,c) = polyval(p,keep,[],mu);
            end

        case 'hp'                   % Hodrick-Prescott filter
            a = extractparameter(varargin,1);
            lambda = a{1};
            A = (1 + 6*lambda) * eye(xnobs);
            A = A - 4*lambda*diag(ones(xnobs-1,1),1);
            A = A - 4*lambda*diag(ones(xnobs-1,1),-1);
            A = A + lambda*diag(ones(xnobs-2,1),2);
            A = A + lambda*diag(ones(xnobs-2,1),-2);
            A(1, 1) = 1 + lambda;
            A(1, 2) = -2 * lambda;
            A(1, 3) = lambda;
            A(xnobs,:) = fliplr(A(1,:));
            A(2, 1) = -2 * lambda;
            A(2, 2) = 1 + 5 * lambda;
            A(2, 3) = -4 * lambda;
            A(2, 4) = lambda;
            A(xnobs-1,:) = fliplr(A(2,:));
            filldata = fillholes(data);
            tr = nan(xnobs,nseries);
            fullseries = ~any(isnan(filldata));
            tr(:,fullseries) = A \ filldata(:,fullseries);
            incompleteseries = find(~fullseries);
            if ~isempty(incompleteseries)
                keepA = A;
                for c = 1:numel(incompleteseries)
                    valid = ~isnan(filldata(:,incompleteseries(c)));
                    nmiss = sum(~valid);
                    A = keepA;
                    midIdx = ceil(size(A,1)/2);
                    fromIdx = midIdx - ceil(nmiss/2)+1;
                    toIdx = midIdx + floor(nmiss/2);
                    A(fromIdx:toIdx,:) = [];    % remove columns
                    A(:,fromIdx:toIdx) = [];    % remove rows
                    tr(valid,incompleteseries(c)) = ...
                        A \ filldata(valid,incompleteseries(c));
                end
            end
            
        case kerneltypes            % (nonparametric) kernel regression
            w  = kernelweights(type,varargin{:});
            charargs = varargin(cellfun(@ischar,varargin));
            tr = wmean(data,w,charargs{:});
            
    end
    
    if doExtend || doMirror; tr = tr(e+1:end-e,:); end
    
    if isTransp; tr = tr'; end
    
    % --------------------------------------------------------------------------
    
    function a = extractparameter(in,n)
        if iscell(in); in = in{1}; end
        if ischar(in); in = str2num(in); end %#ok<ST2NM>
        if isfinite(n)
            a = [in,(NaN(1,n))];
            a = a(1:n);
        else
            if iscell(in)
                a = cell2mat(in);
            else
                a = in;
            end
        end
        if all(isnan(a))
            if n == 1
                e = MException('X13TBX:trendfilter:miss_arg', ...
                    'Expecting one argument, but got no valid one.');
            else
                e = MException('X13TBX:trendfilter:miss_arg', ...
                    'Expecting up to %i arguments, but got zero valid ones.',n);
            end
            throw(e);
        end
        a = num2cell(a);
    end

end
