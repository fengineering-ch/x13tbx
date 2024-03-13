% X11 computes an approximate version of the original X-11 seasonal
% adjustment from 1965.
%
% Literature: Dominique Ladiray et Benoît Quenneville, DÉSAISONNALISER AVEC
%             LA MÉTHODE X-11, free version in French available for
%             download from researchgate.net
%             English version published as: Ladiray, Dominique, Quenneville,
%             Benoit, "Seasonal Adjustment with the X-11 Method," Lecture
%             Notes in Statistics, Springer, 2001.
%
% CAUTION: The program computes only an approximate version of the original
% X-11 algorithm. Most notably, data close to the edges of the sample are
% treated differently, and there are some differences in the detection of
% outliers.
%
% Later versions of X-11 used an estimated ARIMA model to produce fore- and
% backcasts in order to alleviate the edge of sample problem that occurs in any
% filtering using moving averages. This program does not use ARIMA, but instead
% 'mirrors' at the left and right and applies the filtering after that. This
% simple technique appears to get rid of the edge of sample problem rather
% well in most cases.
%
% An adjustment for calendar effects is not available using x11.m directly.
% This is, however, implemented when using x11.m through x13.m as follows:
%   x = x13(dates,data,spec,'x-11');
% If spec contains entries for 'regression','save','td' an adjustment for
% trading days will be computed. Likewise, if spec contains
% 'regression','save','hol', an adjustment for Easter will be computed.
% These corrections for calendar effects is different than the one
% implemented in the original X-11. It also offers much less options than
% the original, and also does not perform tests to determine whether
% calendar adjustments are useful.
%
% NOTE: This program does *not* use the original X-11 executable program from
% the US Census Bureau. It does not support many of the options of that program
% either. This program merely tries to replicate the key steps of the
% seasonal adjustment performed by the X-11 algorithm using Matlab directly. In
% other words, this is a Matlab implementation of an approximate version of the
% X-11 algorithm.
%
% This fact also implies that, unlike the U.S. Census software, this
% implementation accommodates arbitrary frequencies, not just monthly or
% quarterly. This program is just a small addition to the toolbox that makes it
% more complete. Because the adjustment using X-11 is often quite similar
% to the one offered by X-13, this program can be useful for users who are
% unable to download or install the Census programs (for instance because
% IT security regulation prevents installing executables).
%
% Usage:
%   s = x11(data,period);
%   s = x11([dates,data],period);
%   s = x11(... ,transform);
%   s = x11(... ,transform,name);
%   s = x11(... ,transform,name,dofull);
%
%   s   This is a structure containing the following components:
%       s.prog   = 'x11.m'
%       s.name   = name of series (if given)
%       s.period = period
%       s.type   = type of decomposition
%       s.tbl    = some calculations along the way
%       s.dates  = dates vector
%       s.dat    = data vector
%       s.d10    = seasonal factor (cycle)
%       s.d11    = seasonally adjusted data
%       s.d12    = trend
%       s.d13    = irregular component
%                .
%                .
%                .
%       The other components are from intermediate computation steps. Their
%       meaning is revealed in the documentation of x13as.exe.
%
% transform
%       must be one of the following: 'additive','none','multiplicative',
%       or 'logadditive'. It indicates the type of decomposition.
%       'additive' or 'none' : data = tr + sf + ir, sa = tr + ir.
%           'multiplicative' : data = tr * sf * ir, sa = tr * ir.
%              'logadditive' : log(data) = tr + sf + ir, sa = exp(tr + ir). 
%
% name  is a string containing a descriptive title of the variable that is
%       treated. This can be empty.
%
% dofull
%       is a boolean. If set to true, all the intermediate series are
%       stored in the struct. Default is false, which means that only the
%       most important final results are stored.
%
% REMARK: This program uses several smaller programs (trendfilter, seasfilter,
% normalize_seas) that can be used to create a custom seasonal adjustment
% algorithm relatively easily. To understand how, just study the source code of
% this program.
%
% NOTE: This file is part of the X-13 toolbox, but it is completely
% independent of the Census X-13 program. It is part of the 'seas' addition
% to the toolbox which allows to implement seasonal filters without using
% the Census Bureau programs.
%
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
% 2020-04-21    Version 1.42    Some bug fixes.
% 2020-04-18    Version 1.41	Much improved version, much closer to the
%                               original X-11 algorithm.
% 2017-09-19    Version 1.33	First version of X-11 implementation.

function s = x11(data,p,mode,title,dofull)

%%  preparations

    % parse args
    
    % -- dofull present?
    if nargin<5 || isempty(dofull) || all(isnan(dofull))
        dofull = false;
    end
    
    % -- name present?
    if nargin<4 || isempty(title) || all(isnan(title))
        title = [];
    end
    
    % -- mode of transformation ?
    if nargin<3 || isempty(mode) || all(isnan(mode))
        mode = 'logadd';
    end
    
    % validate parameters
    assert(isnumeric(p) && fix(p) == p && numel(p) == 1 && p > 0, ...
        'X13TBX:x11:IllegalPeriod', ...
        'The second argument of x11 must be a positive integer.');
    [nrow,ncol] = size(data);
    if nrow == 1 && ncol > 2
        data = data'; [nrow,ncol] = size(data);
    end
    assert(nrow>1 && (ncol == 1 || ncol == 2), ...
        'X13TBX:x11:NoVector', ['x11 expects a vector, but you have ', ...
            'provided a %ix%i array.'],nrow, ncol);
    
    % separate dates from data
    if ncol == 1
        dates = (1:numel(data))';
    else
        dates = data(:,1);
        data  = data(:,2);
    end
    
    % set parameters depending on mode
    legal = {'add','none','mult','logadd'};
    mode = validatestring(mode,legal);
    
    switch mode
        case {'add','none'}
            ismult   = false;
            islogadd = false;
            xbar = 0; xfactor = 1;
            mode = 'add';
        case 'mult'
            ismult   = true;
            islogadd = false;
            xbar = 1; xfactor = 100;
        case 'logadd'
            ismult   = false;
            islogadd = true;
            xbar = 0; xfactor = 1;
    end
    
    % take logs of data if mode is log-additive
    if islogadd
        assert(all(data(~isnan(data)) > 0), ...
            'X13TBX:x11:NegLog', ['Data must be strictly positive ', ...
            'for log-additive decomposition.']);
        data = log(data);
    end
    
%%  real work starts here

    tbl = struct;
    
    thetitle = title; if isempty(title); thetitle = 'no name'; end
    addtbl('heading', 'Approximate X-11\n', ...
        'An approximate version of the original X-11 procedure of 1965 has been', ...
        'performed using Matlab. The book by D. Ladiray and B. Quenneville was', ...
        'used as a guide (published by Springer, free French and Spanish ', ...
        'versions available for download from the US Census Bureau website).\n', ...
        'The original executable file from the U.S. Census Bureau was not used',...
        'to generate this seasonal adjustment because the interface of the vintage',...
        'program is very different than the one of the more modern versions (X-12', ...
        'and X-13).\n', ...
        'There are potentially important differences between the results of the', ...
        'original X-11 and the Matlab implementation:\n', ...
        '- No preadjustment stage (stage A in X-11)', ...
        '- If you use x11.m directly, no adjustment for trading days or Easter', ...
        '  is performed. If you use x11.m via x13.m (i.e. x13(...,''x-11''), see', ...
        '  documentation), then some form of calendar adjustment is possible.', ...
        '- The treatement at the edge of the sample differs from the original', ...
        '  algorithm.', ...
        '- In X-11, some of the filter length are endogenous. This is implemented', ...
        '  slightly differently here.', ...
        '- The identification and correction of extreme values differs a bit.', ...
        '- No statistical tests are performed, and hence no tables with such', ...
        '  information are available.', ...
        '- Unlike the original, this version works with arbitrary frequencies,', ...
        '  not just monthly or quarterly data.\n', ...
        'Yours truly, Yvan Lengwiler\n', ...
        sprintf('Name: %s \n%s to %s, frequency = %i\n%i observations\nadjustment mode: %s', ...
            thetitle,datestr(dates(1)),datestr(dates(end)),p,numel(data),mode), ...
        '\nUse ''help x11'' to know more.');

    % *** stage A is not implemented (no pre-adjustment) ***
    b1 = data;
    
    % *** stage B ***
    
    b2  = trendfilter(b1,'cma',p,'mirror',ceil(odd_up(p)/2));   % trend-cycle
    b3  = normalize_seas(b1,b2,ismult);                         % SI

    b4a = seasfilter(b3,p,'ma',[3,3],'mirror',5);               % raw SF
    b4b = trendfilter(b4a,'cma',p,'extend',p);                  % MA of raw SF
    b4c = normalize_seas(b4a,b4b,ismult);                       % smooth SF
    b4d = normalize_seas(b3,b4c,ismult);

    [b4e,b4f,idx] = adjust(b4d,5*p);                    % detect/adjust outliers
    b4 = seasfilter(b3,p,'ma',3,'mirror',2);
    b4(~idx) = NaN;
    meanweights = seasfilter(b4f,p,'ma',5,'mirror',2);
    b4(idx) = (b4(idx)-xbar)./meanweights(idx) + xbar;
    b4g = b3; b4g(idx) = b4(idx);

    b5a = seasfilter(b4g,p,'ma',[3,3],'mirror',3);      % raw SF
    b5b = trendfilter(b5a,'cma',p,'extend',p);          % smooth SF
    b5  = normalize_seas(b5a,b5b,ismult);
    b6  = normalize_seas(b1,b5,ismult);                 % SA

    b7a = trendfilter(b6,'henderson',odd_up(p),'mirror',ceil(odd_up(p)/2));
    b7b = xfactor*normalize_seas(b7a,b6,ismult);
    b7c = absgrowth(b7a,1);
    b7d = absgrowth(b7b,1);
%    b7c = xfactor*[NaN; normalize_seas(b7a(2:end),b7a(1:end-1),ismult) - xbar];
%    b7d = xfactor*[NaN; normalize_seas(b7b(2:end),b7b(1:end-1),ismult) - xbar];
%    b7c = abs(b7c); b7d = abs(b7d);
    Cbar = mean(b7c,'omitnan'); Ibar = mean(b7d(2*p+1:end-p),'omitnan');
    ICratio = Ibar/Cbar;
    if ICratio > 1
        Hmode = odd_up(p);
        b7 = b7a;
    else
        Hmode = odd_up(p*2/3);
        b7 = trendfilter(b6,'henderson',Hmode,'mirror',ceil(Hmode/2));
    end
    addtbl('B7','B7 IC ratio',sprintf(['Ibar     : %g \nCbar     : %g \n', ...
        'IC ratio : %g --> Henderson(%i)'], Ibar,Cbar,ICratio,Hmode));
    b8  = normalize_seas(b1,b7,ismult);                 % SI

    b9a = seasfilter(b8,p,'ma',[3,5],'mirror',5);       % raw SF
    b9b = trendfilter(b9a,'cma',p,'extend',p);          % MA of raw SF
    b9c = normalize_seas(b9a,b9b,ismult);               % smooth SF
    b9d = normalize_seas(b8,b9c,ismult);

    [b9e,b9f,idx] = adjust(b9d,5*p);                    % extect/adjust outliers
    b9 = seasfilter(b8,p,'ma',3,'mirror',2);
    b9(~idx) = NaN;
    meanweights = seasfilter(b9f,p,'ma',5,'mirror',2);
    b9(idx) = (b9(idx)-xbar)./meanweights(idx) + xbar;
    b9g = b8; b9g(idx) = b9(idx);

    b10a = seasfilter(b9g,p,'ma',[3,5],'mirror',3);     % raw SF
    b10b = trendfilter(b10a,'cma',p,'extend',p);        % smooth SF
    b10  = normalize_seas(b10a,b10b,ismult);
    b11  = normalize_seas(b1,b10,ismult);               % SA
    b13  = normalize_seas(b11,b7,ismult);               % IR

    % detection and removal of trading day effects is not implemented

    [b17a,b17] = adjust(b13-xbar,5*p);                  % extect/adjust outliers
    if ismult
        b20 = b13 ./ (1+b17.*(b13-1));
    else
        b20 = b13 .* (1-b17);
    end

    c1 = normalize_seas(b1,b20,ismult);
    
    % *** stage C ***

    c2  = trendfilter(c1,'cma',p,'mirror',ceil(odd_up(p)/2));   % trend-cycle
    c4  = normalize_seas(c1,c2,ismult);                         % SI

    c5a = seasfilter(c4,p,'ma',[3,3],'mirror',3);               % raw SF
    c5b = trendfilter(c5a,'cma',p,'extend',p);                  % smoothing
    c5  = normalize_seas(c5a,c5b,ismult);                       % SF
    c6  = normalize_seas(c1,c5,ismult);                         % SA

    c7a = trendfilter(c6,'henderson',odd_up(p),'mirror',ceil(odd_up(p)/2));
    c7b = xfactor*normalize_seas(c7a,c6,ismult);
    c7c = absgrowth(c7a,1);
    c7d = absgrowth(c7b,1);
%    c7c = xfactor*[NaN; normalize_seas(c7a(2:end),c7a(1:end-1),ismult) - xbar];
%    c7d = xfactor*[NaN; normalize_seas(c7b(2:end),c7b(1:end-1),ismult) - xbar];
%    c7c = abs(c7c); c7d = abs(c7d);
    Cbar = mean(c7c,'omitnan'); Ibar = mean(c7d(2*p+1:end-p),'omitnan');
    ICratio = Ibar/Cbar;
    if ICratio > 3.5
        Hmode = odd_dn(p*2);
        c7 = trendfilter(c6,'henderson',Hmode,'mirror',ceil(Hmode/2));
    elseif ICratio > 1
            Hmode = odd_up(p);
            c7 = c7a;
    else
        Hmode = odd_up(p*2/3);
        c7 = trendfilter(c6,'henderson',Hmode,'mirror',ceil(Hmode/2));
    end
    addtbl('C7','C7 IC ratio',sprintf(['Ibar     : %g \nCbar     : %g \n', ...
        'IC ratio : %g --> Henderson(%i)'], Ibar,Cbar,ICratio,Hmode));

    c9 = normalize_seas(c1,c7,ismult);                  % SI

    c10a = seasfilter(c9,p,'ma',[3,5],'mirror',3);      % raw SF
    c10b = trendfilter(c10a,'cma',p,'extend',p);        % smoothing
    c10  = normalize_seas(c10a,c10b,ismult);            % SF
    
    c11  = normalize_seas(b1,c10,ismult);               % SA
    c13  = normalize_seas(c11,c7,ismult);               % IR

    % detection and removal of trading day effects is not implemented

    [c17a,c17] = adjust(c13-xbar,5*p);                  % detect/adjust outliers
    if ismult
        c20 = c13 ./ (1+c17.*(c13-1));
    else
        c20 = c13 .* (1-c17);
    end

    d1 = normalize_seas(b1,c20,ismult);

    % *** stage D ***
    
    d2  = trendfilter(d1,'cma',p,'mirror',ceil(odd_up(p)/2));   % trend-cycle
    d4  = normalize_seas(d1,d2,ismult);                         % SI

    d5a = seasfilter(d4,p,'ma',[3,3],'mirror',3);               % raw SF
    d5b = trendfilter(d5a,'cma',p,'extend',p);                  % smoothing
    d5  = normalize_seas(d5a,d5b,ismult);                       % SF
    d6  = normalize_seas(d1,d5,ismult);                         % SA

    d7a = trendfilter(d6,'henderson',odd_up(p),'mirror',ceil(odd_up(p)/2));
    d7b = xfactor*normalize_seas(d7a,d6,ismult);
    d7c = absgrowth(d7a,1);
    d7d = absgrowth(d7b,1);
%    d7c = xfactor*[NaN; normalize_seas(d7a(2:end),d7a(1:end-1),ismult) - xbar];
%    d7d = xfactor*[NaN; normalize_seas(d7b(2:end),d7b(1:end-1),ismult) - xbar];
%    d7c = abs(d7c); d7d = abs(d7d);
    Cbar = mean(d7c,'omitnan'); Ibar = mean(d7d(2*p+1:end-p),'omitnan');
    ICratio = Ibar/Cbar;
    if ICratio > 3.5
        Hmode = odd_dn(p*2);
        d7 = trendfilter(d6,'henderson',Hmode,'mirror',ceil(Hmode/2));
    elseif ICratio > 1
            Hmode = odd_up(p);
            d7 = d7a;
    else
        Hmode = odd_up(p*2/3);
        d7 = trendfilter(d6,'henderson',Hmode,'mirror',ceil(Hmode/2));
    end
    addtbl('D7','D7 IC ratio',sprintf(['Ibar     : %g \nCbar     : %g \n', ...
        'IC ratio : %g --> Henderson(%i)'], Ibar,Cbar,ICratio,Hmode));
    
    d8 = normalize_seas(b1,d7,ismult);                  % SI
    d9bis = normalize_seas(d1,d7,ismult);               % alternative SI
    d9 = d9bis; d9(d8==d9bis) = NaN;
    
    d9a1 = seasfilter(d9bis,p,'ma',7,'mirror',3);
    d9a2 = xfactor*normalize_seas(d9bis,d9a1,ismult);
    d9a3 = absgrowth(d9a1,p);
    d9a4 = absgrowth(d9a2,p);
%    d9a3 = xfactor*[NaN(p,1); normalize_seas(d9a1(p+1:end),d9a1(1:end-p),ismult) - xbar];
%    d9a4 = xfactor*[NaN(p,1); normalize_seas(d9a2(p+1:end),d9a2(1:end-p),ismult) - xbar];
% %    d9a3 = xfactor*[NaN(p,1); d9a1(p+1:end) ./ d9a1(1:end-p) - 1];
% %    d9a4 = xfactor*[NaN(p,1); d9a2(p+1:end) ./ d9a2(1:end-p) - 1];
%    d9a3 = abs(d9a3); d9a4 = abs(d9a4);
    
    temp = splitperiods(d9a3,p);
    Sbar = mean(temp,1,'omitnan');
    Ibar = mean(splitperiods(d9a4,p),1,'omitnan');
    nb_years = sum(~isnan(temp),1);
    CS = sqrt(2)*nb_years./(6*sqrt(2)+(nb_years-6)*sqrt(3));
    idx = (nb_years == 6); CS(idx) = 5*sqrt(6)/(8+sqrt(2));
    idx = (nb_years == 5); CS(idx) = 2*sqrt(2)/(1+sqrt(3));
    idx = (nb_years == 4); CS(idx) = 3;
    FIS = 5*sqrt(6)*nb_years./(6*sqrt(149)+5*sqrt(6)*(nb_years-6));
    idx = (nb_years == 6); FIS(idx) = 25*sqrt(3)/(2*sqrt(298)+sqrt(67));
    idx = (nb_years == 5); FIS(idx) = 60/(sqrt(894)+2*sqrt(211));
    idx = (nb_years == 4); FIS(idx) = 90/(2*sqrt(842)+21*sqrt(2));
    Sbar = Sbar .* CS;
    Ibar = Ibar .* FIS;
    RSMi = Ibar./Sbar;
    RSM = (Ibar.*nb_years) / (Sbar.*nb_years);
    % Here's a simplification: X-11 uses an iterative procedure that
    % progressively reduces the sample if RSM is between 2.5 and 3.5 or
    % between 5.5 and 6.5. Here, we simply set hard limits at 3.0 and 6.0.
    if RSM < 3
        MAmode = [3,3];
    elseif RSM <= 6
        MAmode = [3,5];
    else
        MAmode = [3,9];
    end
    addtbl('D10bis','D10bis RSM ratio',sprintf(['I(i)     : %s\n', ...
        'S(i)     : %s\nRSM(i)   : %s\naverage RSM = %g --> MA[%ix%i]'], ...
        num2str(Ibar,'%12.4g'), num2str(Sbar,'%12.4g'), num2str(RSMi,'%12.4g'), ...
        RSM, MAmode));
    d10bis = seasfilter(d9bis,p,'ma',MAmode,'mirror',3);    % raw SF
    d10ter = trendfilter(d10bis,'cma',p,'extend',p);        % smoothing
    d10    = normalize_seas(d10bis,d10ter,ismult);          % SF
    d11    = normalize_seas(b1,d10,ismult);                 % SA
    d11bis = normalize_seas(d1,d10,ismult);                 % alternative SA
    
    d12a = trendfilter(d11bis,'henderson',odd_up(p),'mirror',ceil(odd_up(p)/2));
    d12b = xfactor*normalize_seas(d12a,d11bis,ismult);
    d12c = absgrowth(d12a,1);
    d12d = absgrowth(d12b,1);
%    d12c = xfactor*[NaN; normalize_seas(d12a(2:end),d12a(1:end-1),ismult) - xbar];
%    d12d = xfactor*[NaN; normalize_seas(d12b(2:end),d12b(1:end-1),ismult) - xbar];
%    d12c = abs(d12c); d12d = abs(d12d);
    Cbar = mean(d12c,'omitnan'); Ibar = mean(d12d,'omitnan');
    ICratio = Ibar/Cbar;
    if ICratio > 3.5
        Hmode = odd_dn(p*2);
        d12 = trendfilter(d11bis,'henderson',Hmode,'mirror',ceil(Hmode/2));
    elseif ICratio > 1
            Hmode = odd_up(p);
            d12 = d12a;
    else
        Hmode = odd_up(p*2/3);
        d12 = trendfilter(d11bis,'henderson',Hmode,'mirror',ceil(Hmode/2));
    end
    addtbl('D12','D12 IC ratio',sprintf(['Ibar     : %g \nCbar     : %g \n', ...
        'IC ratio : %g --> Henderson(%i)'], Ibar,Cbar,ICratio,Hmode));
    
    d13 = normalize_seas(d11,d12,ismult);
    
    % *** stage E ***
    
    if ismult
        e1 = d12 .* d10;
    else
        e1 = d12 + d10;
    end
    
    % Which one is correct?
    if false    %#ok<*UNRCH>
        % remove only outliers greater than 3sigma
        idx = (c17==0);        % extreme outliers that received zero weight (> 2.5 sigma)
        e2  = d11; e2(idx) = d12(idx);                          % replace sa with tr
        e3  = d13; e3(idx) = xbar;                              % replace ir with xbar
        e11 = e2; e11(idx) = d12(idx) + data(idx) - e1(idx);    % alternative ir
    else
        % reduce outliers greater 2sigma, remove greater 3sigma
        e2  = c17.*d11 + (1-c17).*d12;
        e3  = c17.*d13 + (1-c17)*xbar;
        e11 = c17.*e2 + (1-c17).*(d12+data-e1);
    end
    

%     % *** stage F ***
%     
%      % no pre-adjustment of trading day / easter adjustments
%     a1 = data; a2 = data; % c18 = 100*ones(p,1);
%     f1 = NaN(p,1);
% %    cols = {a1,d11,d13,d12,d10,a2,c18,f1,e1,e2,e3};
% %    f2a = NaN(p,numel(cols));
%     cols = {a1,d11,d13,d12,d10,a2,e1,e2,e3};
%     f2a = NaN(p,numel(cols));
%     
%     for col = 1:numel(cols)
%         for row = 1:p
%             f2a(row,col) = nanmean(absgrowth(cols{col},row));
%         end
%     end
%     
% %    f1 = trendfilter(d11,'cma',msd,'mirror',ceil(mcd/2));

%%  packing up everything

    % un-log if mode is log-additive
    
    if islogadd
        
        data = exp(data);
        
        b1   = exp(b1);
        b2   = exp(b2);
        b3   = exp(b3);
        b4   = exp(b4);
        b4a  = exp(b4a);
        b4b  = exp(b4b);
        b4c  = exp(b4c);
        b4d  = exp(b4d);
        b4e  = exp(b4e);
%        b4f  = exp(b4f);
        b4g  = exp(b4g);
        b5   = exp(b5);
        b5a  = exp(b5a);
        b5b  = exp(b5b);
        b6   = exp(b6);
        b7   = exp(b7);
        b7a  = exp(b7a);
        b7b  = exp(b7b);
%        b7c  = exp(b7c);
%        b7d  = exp(b7d);
        b8   = exp(b8);
        b9   = exp(b9);
        b9a  = exp(b9a);
        b9b  = exp(b9b);
        b9c  = exp(b9c);
        b9d  = exp(b9d);
        b9e  = exp(b9e);
%        b9f  = exp(b9f);
        b9g  = exp(b9g);
        b10  = exp(b10);
        b10a = exp(b10a);
        b10b = exp(b10b);
        b11  = exp(b11);
        b13  = exp(b13);
%        b17  = exp(b17);
        b17a = exp(b17a);
%        b20  = exp(b20);
        
        c1   = exp(c1);
        c2   = exp(c2);
        c4   = exp(c4);
        c5   = exp(c5);
        c5a  = exp(c5a);
        c5b  = exp(c5b);
        c6   = exp(c6);
        c7   = exp(c7);
        c7a  = exp(c7a);
        c7b  = exp(c7b);
%        c7c  = exp(c7c);
%        c7d  = exp(c7d);
        c9   = exp(c9);
        c10  = exp(c10);
        c10a = exp(c10a);
        c10b = exp(c10b);
        c11  = exp(c11);
        c13  = exp(c13);
%        c17  = exp(c17);
        c17a = exp(c17a);
%        c20  = exp(c20);
        
        d1   = exp(d1);
        d2   = exp(d2);
        d4   = exp(d4);
        d5   = exp(d5);
        d5a  = exp(d5a);
        d5b  = exp(d5b);
        d6   = exp(d6);
        d7   = exp(d7);
        d7a  = exp(d7a);
        d7b  = exp(d7b);
%        d7c  = exp(d7c);
%        d7d  = exp(d7d);
        d8   = exp(d8);   % STRANGELY, x13as.exe does NOT exponentiate SI
%                          % if mode is logadd  ???
        d9a1 = exp(d9a1);
        d9a2 = exp(d9a2);
%        d9a3 = exp(d9a3);
%        d9a4 = exp(d9a4);
        d9   = exp(d9);
        d10  = exp(d10);
        d10bis = exp(d10bis);
        d10ter = exp(d10ter);
        d11  = exp(d11);
        d11bis = exp(d11bis);
        d12  = exp(d12);
        d12a = exp(d12a);
        d12b = exp(d12b);
%        d12c = exp(d12c);
%        d12d = exp(d12d);
        d13  = exp(d13);
        
        e1   = exp(e1);
        e2   = exp(e2);
        e3   = exp(e3);
        e11  = exp(e11);

    end
    
%     % remove final crlf in out-string
%     out(end-1:end) = [];
    
    % pack output into a struct
    if dofull
        s = struct(...
            'prog',     'x11.m', ...
            'title',    title,   ...
            'period',   p,      ...
            'mode',     mode,   ...
            'keyv',     struct('dat','dat','tr','d12','sa','d11','sf','d10', ...
                'ir','d13','si','d8','rsd','***'), ...
            'tbl',      tbl, ...
            'dates',    dates,	...
            'dat',      data,   ...
            'b1',       b1, ...
            'b2',       b2, ...
            'b3',       b3, ...
            'b4',       b4, ...
            'b4a',      b4a, ...
            'b4b',      b4b, ...
            'b4c',      b4c, ...
            'b4d',      b4d, ...
            'b4e',      b4e, ...
            'b4f',      b4f, ...
            'b4g',      b4g, ...
            'b5',       b5, ...
            'b5a',      b5a, ...
            'b5b',      b5b, ...
            'b6',       b6, ...
            'b7',       b7, ...
            'b7a',      b7a, ...
            'b7b',      b7b, ...
            'b7c',      b7c, ...
            'b7d',      b7d, ...
            'b8',       b8, ...
            'b9',       b9, ...
            'b9a',      b9a, ...
            'b9b',      b9b, ...
            'b9c',      b9c, ...
            'b9d',      b9d, ...
            'b9e',      b9e, ...
            'b9f',      b9f, ...
            'b9g',      b9g, ...
            'b10',      b10, ...
            'b10a',     b10a, ...
            'b10b',     b10b, ...
            'b11',      b11, ...
            'b13',      b13, ...
            'b17',      b17, ...
            'b17a',     b17a, ...
            'b20',      b20, ...
            'c1',       c1, ...
            'c2',       c2, ...
            'c4',       c4, ...
            'c5',       c5, ...
            'c5a',      c5a, ...
            'c5b',      c5b, ...
            'c6',       c6, ...
            'c7',       c7, ...
            'c7a',      c7a, ...
            'c7b',      c7b, ...
            'c7c',      c7c, ...
            'c7d',      c7d, ...
            'c9',       c9, ...
            'c10',      c10, ...
            'c10a',     c10a, ...
            'c10b',     c10b, ...
            'c11',      c11, ...
            'c13',      c13, ...
            'c17',      c17, ...
            'c17a',     c17a, ...
            'c20',      c20, ...
            'd1',       d1, ...
            'd2',       d2, ...
            'd4',       d4, ...
            'd5',       d5, ...
            'd5a',      d5a, ...
            'd5b',      d5b, ...
            'd6',       d6, ...
            'd7',       d7, ...
            'd7a',      d7a, ...
            'd7b',      d7b, ...
            'd7c',      d7c, ...
            'd7d',      d7d, ...
            'd8',       d8, ...
            'd9',       d9, ...
            'd9a1',     d9a1, ...
            'd9a2',     d9a2, ...
            'd9a3',     d9a3, ...
            'd9a4',     d9a4, ...
            'd10',      d10, ...
            'd10bis',   d10bis, ...
            'd10ter',   d10ter, ...
            'd11',      d11, ...
            'd11bis',   d11bis, ...
            'd12',      d12, ...
            'd12a',     d12a, ...
            'd12b',     d12b, ...
            'd12c',     d12c, ...
            'd12d',     d12d, ...
            'd13',      d13, ...
            'e1',       e1, ...
            'e2',       e2, ...
            'e3',       e3, ...
            'e11',      e11);  % , ...
%            'f2a',      f2a);

    else
        
        s = struct(...
            'prog',     'x11.m', ...
            'title',    title,   ...
            'period',   p,      ...
            'mode',     mode,   ...
            'keyv',     struct('dat','dat','tr','d12','sa','d11','sf','d10', ...
                'ir','d13','si','d8','rsd','***'), ...
            'tbl',      tbl, ...
            'dates',    dates,	...
            'dat',      data,   ...
            'c20',      c20, ...
            'd8',       d8, ...
            'd10',      d10, ...
            'd11',      d11, ...
            'd12',      d12, ...
            'd13',      d13, ...
            'e2',       e2, ...
            'e3',       e3);
    end
    
%%  sub-functions
    
    % identify outliers (absol dev > 1.5 sliding std from sliding mean)
    function [sigma,weight,idx] = adjust(z,bw)
        bwhalf = ceil(bw/2);
        zext = [z(bwhalf+1:-1:2);z;z(end-1:-1:end-bwhalf)]; % mirror
        sigma = NaN(size(z)); mu = sigma;
        for t = 1:numel(z)
            tt = t + bwhalf;
            sigma(t) = std(zext(tt-bwhalf:tt+bwhalf));
            mu(t)    = mean(zext(tt-bwhalf:tt+bwhalf));
        end
        dev = abs(z-mu)./sigma;
        weight = max(0, min(1, 2.5 - dev));
        idx = (dev > 1.5);
    end

    % absolute difference or growth rates
    function g = absgrowth(z,lag)
        g = [NaN(lag,1); 
            normalize_seas(z(lag+1:end),z(1:end-lag),ismult) - xbar];
        g = xfactor * abs(g);
    end
    
    % smallest odd number weakly greater than input
    function z = odd_up(z)
        z = z + mod(z+1,2);
    end

    % greatest odd number weakly less than input
    function z = odd_dn(z)
        z = z - mod(z-1,2);
    end

%     % add content to out
%     function add2out(head,varargin)
%         out = [out, '>>> ', head, newline, sprintf(varargin{:}), ...
%             newline, newline]; %, char(12)];
%         % char(12) is form feed (new page)
%     end

    function addtbl(head,varargin)
        lines = cellfun(@(c) [c,newline], varargin, 'UniformOutput',false);
        tbl.(head) = sprintf([lines{:}]);
    end
end
