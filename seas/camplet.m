% CAMPLET computes the Camplet seasonal adjustment.
%
% Source: Barend Abeln and Jan P.A.M. Jacobs, "Seasonal adjustment with and
% without revisions: A comparison of X-13ARIMA-SEATS and CAMPLET," CAMA Working
% Paper 25/2015, Australian National University, July 2015.
%
% Note: The initialization algorithm is different from the one proposed by the
% authors. As a result, the adjustment of the first few years of data is
% different then when using the authors' original algorithm. Moreover, on very
% volatile time series, these differences remain throughout the sample because
% the automatic parameter adjustments are not identical. In practice, the
% differences should be rather small.
%
% Usage:
%   s = camplet(data,period);
%   s = camplet([dates,data],period);
%   s = camplet(... ,'log');
%   s = camplet(... ,'verbose');
%   s = camplet(... , name,value, [name,value], ...);
%
% data must be a vector. camplet is NaN tolerant, meaning data can contain
% NaNs.
%
% period is a positive number which indicates the length of the seasonal
% cycle (i.e. period = 12 for monthly data, period = 7 for daily data
% having a weekly cycle, or period = 5 if the data is weekdaily).
%
% Some arguments are added as single keywords:
% 'add' or 'none'     Implies that the analysis is performed on the
%                     data as presented.
% 'mult' or 'log'     The log of the data is first taken. After the
%                     application of the algorithm, the exponential of
%                     the result is returned. This amounts to a
%                     multiplicative seasonal adjustment.
% 'verbose'           During execution the program outputs detailed
%                     information to the console whenever something
%                     unusual happens (detection of an outlier or
%                     pattern shift, for instance).
%
% Other optional arguments are entered as name-value pairs. Possible names and
% their meaning are:
% 'INITYEARS'   The number of years used to initialize the alorithm. Default
%               is 3. (initT = INITYEARS * period is the number of observattions
%               used for the initialization.)
% 'INITMETHOD'  The argument following this must be one of the following:
%  	 ...,'mean' Takes the average daviation of the data from its mean over the
%               interval 1:initT. The initial estimate of the seasonal factors
%               is then the average of these deviations for each month/quarter.
%      ...,'ma' Computes the deviation of the data (1:initT) from a centered
%               moving average over period observations, instead.
%      ...,'ls' ls stands for least squares. This option estimates a linear
%               regression of the data (1:initT) on a constant and a linear
%               trend. The average residuals per month/quarter are the starting
%               values for the seasonal factor. The slope of this regression is
%               the initial estimat of g. This method is the default.
% 'CA'          Initial CA parameter (Common Adjustment).
% 'M'           Initial M parameter (Multiplier).
% 'P'           Reset value for CA when pattern shift is detected.
% 'LE'          Initial LE parameter (Limit to Error).
% 'T'           Initial T parameter (Number of repetition before pattern shift
%               is detected).
% 'LEshare'     Limit of outliers that invokes the 'volatile series' adjustment.
% 'CAadd'       Increment to CA parameter for volatile series.
% 'LEadd'       Increment to LE parameter for volatile series.
% 'LEmax'       Maximum limit to error.
% 'TIadd'       Increment of T parameter for volatile series when LE exceed
%               LEmax.
% 'MUsub'       Reduction of MU parameter for volatile series when LE exceed
%               LEmax.
% 'SIM'         Strictly between 0 and 1. The parameter determines the required
%               similarity between consecutive errors to trigger a pattern
%               shift.
%
% s is a struct with the following fields:
%   .dat        The original data.
%   .dates      The original dates. If none were provided, this is just a vecor
%               counting from 1 to the number of data points.
%   .period     Period that has been filtered.
%   .transform  Either 'none' or 'log'.
%   .keyv       A struct containing the sames of some key variables.
%   .opt        Structure containing the selected parameters.
%   .sa         Seasonally adjusted series.
%   .sf         Seasonal factors.
%   .fcst       Running forecast.
%   .fer        Running forecast error.
%   .g          Running estimate of trend.
%   .nol        Number of consecutive outliers in a particular month/quarter.
%   .pshift     Boolean indicating detection of a pattern shift.
%   .currca     Changing value of CA.
%   .ca         Changing value of CA.
%   .m          Changing value of M.
%   .le         Changing value of LE.
%   .t          Changing value of T.
%
% s.opt is a struct with the the parameters chosen by the user (or the default
% parameters if nothing was selected): .INITMETHOD .INITYERAS .CA .M .P .LE .T
% .LEshare .CAadd .LEadd .LEmax .TIadd .MUsub .SIM
%
% Examples:
% We assume that data is a column vector of data (the original time series)
% with a quarterly frequency, and dates is an equally long vector containing
% Matlab date codes.
%   c = camplet(data,4);
%   figure('Position',[440 160 560 700]);
%   ah = subplot(2,1,1); plot(ah,[data,c.sa]); grid on;
%   ah = subplot(2,1,2); plot(ah,c.sf,'k');    grid on;
% If data is monthly, replace the 4 above by 12. Any other frequency is fine,
% too, actually (for instance, with weekdaily data, searching for a weekday
% pattern, use 5).
% You can choose to perform a multiplicative filtering instead, and add detailed
% feedback to the console on what is happening:
%   c = camplet([dates,data],4,'verb','mult');
%   figure('Position',[440 160 560 700]);
%   ah = subplot(2,1,1); plot(ah,dates,[data,c.sa]); dateaxis('x'); grid on;
%   ah = subplot(2,1,2); plot(ah,dates,c.sf,'k');    dateaxis('x'); grid on;
% You can tweak the parameters. Here, we change the initial period and the
% method of the initialization phase:
%   c  = camplet([dates,data],4);
%   c2 = camplet([dates,data],4,'INITMETHOD','ma','INITYEARS',5);
%   plot(dates,[c.sf,c2.sf]); dateaxis('x'); grid on;
%
% NOTE: This program is part of the X-13 toolbox, but it is completely
% independent of the Census X-13 program. It uses a simpler strategy to filter
% seasonal cycles than X-13ARIMA-SEATS. The main advantage of CAMPLET is that
% this argorithm does not produce revisions of older seasonal adjustements when
% new data comes in. Also, CAMPLET accomodates arbitrary frequencies, not only
% monthly and quarterly. Moreover, the residual seasonality is often much
% smaller than when using fixedseas.m, but unlike with this algorithm, the
% seasonal factors are not constant, but adapt over time. This program is just
% a small addition to the toolbox that makes it more complete.
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
% 2020-05-19    Version 1.50    Only compatibility cleanup with the new
%                               version of the toolbox; no change to the
%                               algorithm
% 2018-09-19    Version 1.33    Default changed to logadditive (similar to
%                               multiplicative, which is in accordance with x-11
% 2017-01-09    Version 1.30    First release featuring camplet.

function s = camplet(data,period,varargin)

    % store original shape
    [row,col] = size(data);
    if min(row,col) > 2
        err = MException('X13TBX:camplet:NoVector', ...
            'camplet expects a vector, but you have provided a %ix%i array.', ...
            row, col);
        throw(err);
    elseif min(row,col) == 2
        if row == 2
            dates = data(1,:);
            data  = data(2,:);
            row = 1;
        else
            dates = data(:,1);
            data  = data(:,2);
            col = 1;
        end
        hasDates = true;
    else
        dates = (1:numel(data))';
        hasDates = false;
    end
    assert(isnumeric(period) & fix(period) == period & period > 0, ...
        'X13TBX:camplet:IllegalPeriod', ...
        'The second argument of camplet must be a positive integer.');
    data = data(:);         % program works with column vector
    
    % check optional arguments
    
    % - defaults
    INITYEARS = 3;
    CA      = (9/8)*period + 3/2;       % common adjustment
    MU      = 50;                       % multiplier
    PA      = period;                   % CA after pattern shift
    LE      = 5 + period/4;             % limit to error
    TI      = 1;                        % times of repetition
    
    LEshare = 50;                       % share of outliers that triggers
                                        % volatile series adjustment
    LEadd   = 5;                        % increment of LE
    LEmax   = 30;                       % maximum value for LE
    CAadd   = period/4;                 % increment of CA
    TIadd   = 1;                        % increment of TI
    MUsub   = 25;                       % reduction of MU
    
    SIM     = 0.5;                      % similarity of errors that triggers
                                        % pattern shift detection
    
    method  = 'ls';                     % default method used in init phase
    
    % - remove blank entries
    remove = cellfun(@(c) isempty(c),varargin);
    varargin(remove)= [];
    
    % - work on non-empty parameters
    legal = {'verbose','none','add','logadd','mult', ...
        'INITMETHOD','INITYEARS','CA','M','P','LE','T', ...
        'LEshare','LEadd','LEmax','CAadd','TIadd','MUsub','SIM'};
    isLog = true; isVerb = false;
    while ~isempty(varargin)
        validstr = validatestring(varargin{1},legal);
        switch validstr
            case 'verbose'
                isVerb = true;
                varargin(1) = [];
            case {'none','add'}
                isLog = false;
                varargin(1) = [];
            case {'logadd','mult'}
                isLog = true;
                varargin(1) = [];
            case 'INITMETHOD'
                method = varargin{2};
                varargin(1:2) = [];
            case 'INITYEARS'
                INITYEARS = varargin{2};
                if ~isnumeric(INITYEARS)
                    INITYEARS = str2double(INITYEARS);
                end
                varargin(1:2) = [];
            case 'CA'
                CA = varargin{2};
                if ~isnumeric(CA); CA = str2double(CA); end
                varargin(1:2) = [];
            case 'M'
                MU = varargin{2};
                if ~isnumeric(MU); MU = str2double(MU); end
                varargin(1:2) = [];
            case 'P'
                PA = varargin{2};
                if ~isnumeric(PA); PA = str2double(PA); end
                varargin(1:2) = [];
            case 'LE'
                LE = varargin{2};
                if ~isnumeric(CA); CA = str2double(CA); end
                varargin(1:2) = [];
            case 'T'
                TI = varargin{2};
                if ~isnumeric(TI); TI = str2double(TI); end
                varargin(1:2) = [];
            case 'LEshare'
                LEshare = varargin{2};
                if ~isnumeric(LEshare); LEshare = str2double(LEshare); end
                varargin(1:2) = [];
            case 'LEadd'
                LEadd = varargin{2};
                if ~isnumeric(LEadd); LEadd = str2double(LEadd); end
                varargin(1:2) = [];
            case 'LEmax'
                LEmax = varargin{2};
                if ~isnumeric(LEmax); LEmax = str2double(LEmax); end
                varargin(1:2) = [];
            case 'CAadd'
                CAadd = varargin{2};
                if ~isnumeric(CAadd); CAadd = str2double(CAadd); end
                varargin(1:2) = [];
            case 'TIadd'
                TIadd = varargin{2};
                if ~isnumeric(TIadd); TIadd = str2double(TIadd); end
                varargin(1:2) = [];
            case 'MUsub'
                MUsub = varargin{2};
                if ~isnumeric(MUsub); MUsub = str2double(MUsub); end
                varargin(1:2) = [];
            case 'SIM'
                SIM = varargin{2};
                if ~isnumeric(SIM); SIM = str2double(SIM); end
                varargin(1:2) = [];
        end
    end
    
    % - assert sensibility of input
    numT  = numel(data);
    initT = INITYEARS * period;

    assert(isscalar(CA) && isscalar(MU) && isscalar(PA) && isscalar(LE) && ...
        isscalar(TI) && isscalar(LEshare) && isscalar(LEadd) && ...
        isscalar(LEmax) && isscalar(CAadd) && isscalar(TIadd) && ...
        isscalar(MUsub) && isscalar(SIM) && ...
        isnumeric(CA) && isnumeric(MU) && isnumeric(PA) && isnumeric(LE) && ...
        isnumeric(TI) && isnumeric(LEshare) && isnumeric(LEadd) && ...
        isnumeric(LEmax) && isnumeric(CAadd) && isnumeric(TIadd) && ...
        isnumeric(MUsub) && isnumeric(SIM), ...
        'X13TBX:camplet:ill_param', ['CA, M, P, LE, T, LEshare, LEadd, ', ...
        'LEmax, CAadd, TIadd, MUsub, and SIM parameters must be scalars.']);
    assert(CA>=0 && MU>=0 && PA>=0 && LE>=0 && TI>=0 && LEshare>=0 && ...
        LEadd>=0 && LEmax>=0 && CAadd>=0 && TIadd>=0 && MUsub>=0, ...
        'X13TBX:camplet:ill_param', ['CA, M, P, LE, T, LEshare, LEadd, ', ...
        'LEmax, CAadd, TIadd, and MUsub parameters must be non-negative.']);
    assert(INITYEARS>=1,'X13TBX:camplet:ill_param', ...
        'INITYEARS must me at least 1.');
    assert(numT>=initT,'X13TBX:camplet:ill_param', ...
        'INITYEARS = %g requires at least %i datapoints, but there are only %i.', ...
        INITYEARS,initT,numT);
    assert(SIM>0 && SIM<1, 'X13TBX:CAMPLET:ill_param', ...
        'SIM must be strictly between 0 and 1.');
    
    if isLog
        assert(all(data(~isnan(data)) > 0), ...
            'X13TBX:camplet:NegLog', ['Data must be strictly positive ', ...
            'for multiplicative transformation.']);
        data = log(data);
    end
    
    % linearly interpolate missing values
    if any(isnan(data))
        x = 1:numT;
        valid = ~isnan(data);
        fill = interp1(x(valid),data(valid),x(~valid));
        data(~valid) = fill;
    end
    
    % perform CAMPLET algorithm
    
    % - declare variables
    g       = zeros(numT,1);            % running trend estimate
    fcst    = nan(numT,1);              % running forecast
    err     = nan(numT,1);              % running forecast error
    relerr  = nan(numT,1);              % running relative forecast error
    bar     = nan(numT,1);              % moving average
    graduator = nan(numT,1);            % ...
    sf      = nan(numT,1);              % seasonal factor
    sa      = nan(numT,1);              % seasonally adjusted
    
    ca      = CA * ones(numT,1);        % common adjustment
    mu      = MU * ones(numT,1);        % multiplier
    le      = LE * ones(numT,1);        % limit to error
    ti      = TI * ones(numT,1);        % times of repetition
    
    currca  = ca;
    
    outlier = uint16(zeros(numT,1));
    pshift  = false(numT,1);            % pattern shift
    
    % initialize camplet
    
    % There are three methods for the initialization phase.
    % 
    % 'mean' takes the average daviation of the data from its mean over the
    % interval 1:initT. The initial estimate of the seasonal factors is then the
    % average of these deviations for each month/quarter.
    %
    % 'ma' computes the deviation of the data (1:initT) from a centered moving
    % average over period observations, instead.
    %
    % 'ls' (for least squares) estimates a linear regression of the data
    % (1:initT) on an absolute and a linear trend. The average residuals per
    % month/quarter are the starting values for the seasonal factor. The slope
    % of this regression is the initial estimat of g. This method is the
    % default.
    
    legal = {'mean','ma','ls'};
    method = validatestring(method,legal);

    switch method
        
        case 'mean'     % simple mean on 1:initT
            thissf = data(1:initT) - mean(data(1:initT));
            bar(1:period) = mean(abs(data(1:period)));
        
        case 'ma'       % centered moving average (taken from fixedseas.m)
            laglead = ceil((period-1)/2);
            mult = (period - (2*laglead-1)) / 2;
            w = [mult; ones(2*laglead-1,1); mult] / period;
            thissf = nan(initT,1);
            for z = laglead+1:initT
                d = data(z-laglead:z+laglead);
                thissf(z) = data(z) - nansum(d.*w);
            end
            t = ceil(double(initT)/period)*period-initT;
            thissf(end+1:end+t) = nan;
            thissf = reshape(thissf,period,[]);
            thissf = nanmean(thissf,2);
            bar(1:period) = abs(data(1:period)-thissf);
        
        case 'ls'      % linear regression on 1:initT
            X = [ones(initT,1),(0:initT-1)'];
            beta = X \ data(1:initT);   % estimate regression
            g(1:initT) = beta(2);       % estimated slope
            sa(1:initT) = X * beta;     % forecast of the linear regression
            err(1:initT) = data(1:initT)-sa(1:initT); % residuals
            thissf = err(1:initT);      % work from here to get first estimate
            bar(1:period) = cumsum(abs(sa(1:period))) ./ (1:period)';
            
        otherwise
            error('X13TBX:camplet:ill_param', ...
                '''INITMETHOD'',''%s'' is illegal.',method);
        
    end
    
    t = period - mod(numel(thissf)-1,period)-1; % add nans to make length a ...
    thissf(end+1:end+t) = nan;                  % ... multiple of full year
    thissf = reshape(thissf,period,[]);     % residuals by year (columnwise)
    thissf = nanmean(thissf,2);             % take inter-year average
    thissf = thissf - mean(thissf);         % normalize
    sf(1:period) = thissf;
    sa(1:period) = data(1:period) - thissf;
    
    % compute camplet
    for t = 2:numT
        makestep(t);
    end
    
    % un-log?
    if isLog
        data = exp(data);
        sa   = exp(sa);
        sf   = exp(sf);
        fcst = exp(fcst);
        err  = exp(err);
        bar  = exp(bar);
        transform = 'log';
    else
        transform = 'none';
    end
    
    % bring back into shape of input
    data      = reshape(data,row,col);
    sa        = reshape(sa,row,col);
    sf        = reshape(sf,row,col);
    g         = reshape(g,row,col);
    err       = reshape(err,row,col);
    relerr    = reshape(relerr,row,col);
    bar       = reshape(bar,row,col);
    graduator = reshape(graduator,row,col);
    outlier   = reshape(outlier,row,col);
    
    % collect everything, ready for output
    options = struct('INITMETHOD',method,'INITYEARS',INITYEARS, ...
        'CA',CA,'M',MU,'P',PA,'LE',LE,'T',TI, ...
        'LEshare',LEshare,'LEadd',LEadd,'LEmax',LEmax,'CAadd',CAadd, ...
        'TIadd',TIadd,'MUsub',MUsub,'SIM',SIM);
    if isVerb
        opt.verbose = [];
    end
    
    keyv = struct('dat','dat','tr','bar','sa','sa','sf','sf', ...
                'ir','***','si','***','rsd','***');
    tbl = struct('heading', ...
        sprintf(['CAMPLET\n\nThis is an implementation of an algorithm ', ...
        'for seasonal adjustment developed\nby B Ablen and J Jacobs. The ', ...
        'algorithm uses only backward-looking filters\nwhich implies that no ', ...
        'revisions happen when new data are added at the end\nof the sample. ', ...
        '\n\nThe algorithm is included in the X13TBX to make the toolbox ', ...
        'more useful.\n\nSincerely, Yvan Lengwiler\n\n', ...
        'Source: Barend Abeln and Jan P.A.M. Jacobs, "Seasonal adjustment ', ...
        'with and\nwithout revisions: A comparison of X-13ARIMA-SEATS and ', ...
        'CAMPLET," CAMA\nWorking Paper 25/2015, Australian National University, ', ...
        'July 2015.\n\n', ...
        '%s to %s, frequency = %i\n%i observations\ntransformation function: %s', ...
        '\n\nUse ''help camplet'' to know more.'], ...
            datestr(dates(1)),datestr(dates(end)),period,numel(data),transform));
    
    s = struct( ...
        'prog',     'camplet.m', ...
        'period',   period, ...
        'transform',transform, ...
        'keyv',     keyv, ...
        'options',  options, ...
        'tbl',      tbl, ...
        'dat',      data, ...
        'dates',    dates, ...
        'sa',       sa, ...
        'sf',       sf, ...
        'fcs',      fcst, ...
        'fer',      err, ...
        'rer',      relerr, ...
        'bar',      bar, ...
        'gra',      graduator, ...
        'g',        g, ...
        'nol',      outlier, ...
        'psh',      pshift, ...
        'cca',      currca, ...
        'ca',       ca, ...
        'm',        mu, ...
        'lle',      le, ...
        't',        ti);
    
    % === internal function ====================================================
    
    function makestep(t)
        % initialize variables for this step
        if isVerb
            if hasDates
                strt = datestr(dates(t));
            else
                strt = ['t = ',int2str(t)];
            end
        end
        c = mod(t-1,period)+1;      % index to component in period
        ca(t) = ca(t-1); mu(t) = mu(t-1); le(t) = le(t-1); ti(t) = ti(t-1);
        currca(t) = currca(t-1);
        graduator(t) = mu(t)*le(t)/100 - ca(t)/period;
        fcst(t) = sa(t-1) + g(t-1) + thissf(c);     % forecast
        err(t) = data(t) - fcst(t);                 % forecast error
        % detect outlier, volatile series, and pattern shift
        if t > period
            bar(t) = bar(t-1) + (abs(data(t))-abs(data(t-period)))/period;
            relerr(t) = abs(err(t)/bar(t))*100;
            isoutlier = (relerr(t) > le(t));
            if ~isoutlier
                outlier(t) = 0;
                currca(t) = CA;
            else
                outlier(t) = outlier(t-period) + 1;
                manyoutliers = (sum(outlier>0)/t > LEshare/100);
                if manyoutliers
                    if le(t) <= LEmax        % volatile series
                        if isVerb
                            fprintf(['%s : volatile series (adjusting ', ...
                                'le and ca)\n'],strt);
                        end
                        le(t) = le(t) + LEadd;
                        ca(t) = ca(t) + CAadd;
                    else
                        if isVerb
                            fprintf('%s : volatile series (adjusting ti)\n', ...
                                strt);
                        end
                        ti(t) = ti(t) + TIadd;
                    end
                end
                % check for pattern shift
                if abs(err(t-period)) <= SIM * abs(err(t)) || ...
                        SIM * abs(err(t-period)) > abs(err(t)) || ...
                        err(t-period)*err(t) < 0
                    % no, pattern has not shifted
                    outlier(t) = 1;
                end
                if outlier(t) > ti(t)   % pattern has shifted
                    if isVerb
                        fprintf('%s : pattern shift detected\n',strt);
                    end
                    pshift(t) = true;
                    currca(t) = PA;
                else                % no pattern shift, just an ordinary outlier
                    if isVerb
                        fprintf('%s : outlier (relative error = %4.1f%%)\n', ...
                            strt,relerr(t));
                    end
                    currca(t) = (mu(t)*relerr(t)/100 - graduator(t)) * period;
                    if outlier(t-period) == 1
                        currca(t) = CA;
                    end
                end
            end
            manyoutliers = (sum(outlier>0)/t > LEshare/100);
            if manyoutliers && le(t) > LEmax
                if isVerb
                    fprintf('%s : reducing mu\n',strt);
                end
                mu(t) = mu(t) - MUsub;
            end
            if ~manyoutliers && le(t) > LE
                if isVerb
                    fprintf('%s : few outliers, retracting le, ca, and ti\n', ...
                        strt);
                end
                le(t) = LE - LEadd;
                ca(t) = CA - CAadd;
                ti(t) = TI;
            end
        end
        % compute seasonal adjustment
        g(t) = g(t-1) + err(t) / currca(t);
        ord = mod(((c-1:c+period-2)),period) + 1;
        thissf(ord) = thissf(ord) - ...
            ((1:period)'-(period+1)/2) * err(t) / currca(t);
        sf(t) = thissf(c);
        sa(t) = data(t) - sf(t);
    end

end
