% KERNELWEIGHTS returns a vector that can be used with wmean or conv to smooth a
% time series.
%
% Usage:
%   w = kernelweights('ma',p1[,p2,p3,...])
%   w = kernelweights('cma',p1[,p2,p3,...])
%   w = kernelweights('spencer',[p])
%   w = kernelweights('henderson',p1[,p2,p3,...])
%   w = kernelweights('bongard',p1[,p2,p3,...])
%   w = kernelweights('rehomme-ladiray',t,p,h[,t2,p2,h2,....])
%   w = kernelweights(kernel of group 1,b[,b2,b3,...])
%   w = kernelweights(kernel of group 2,b,l[,b2,l2,...])
%
%   w is a vector of weights. If used on an array of data together with conv or
%   wmean, it returns a smoothed version of the data.
%
%   'ma' or 'ma',p1,p2,...      A simple moving average, or a convolution of
%                               simple moving averages.
%   'cma'                       A centered moving average over a range of minus
%   'cma',p1,p2,...             p1/2 lags to plus p1/2, or a convolution of
%                               such moving averages.
%   'spencer' or 'spencer15'    A special 15-term moving average.
%   'henderson',t               The Henderson filter with t terms.
%   'bongard',t                 The Bongard filter with t terms.
%   'rehomme-ladiray',t,p,h     The Rehomme-Ladiray filter with t terms, which
%                               does perfectly reproduce polynomial of order n,
%                               and minimizes a weighted average of the
%                               Henderson and the Bongard criteria (with h being
%                               the weight of the Henderson criterion).
%   Group 1 (kernels with finite support):
%       'uniform','triangle','biweight' or 'quartic','triweight','tricube',
%       'epanechnikov', 'cosine','optcosine','cauchy'.
%   Group 2 (kernels with infinite support):
%       'logistic','sigmoid','gaussian' or 'normal','exponential','silverman'.
%   Kernels from group 1 are followed by a single parameter indicating the
%   bandwidth. Kernels from group 2 have infinite support, and even Matlab
%   cannot return an infinite vector. The first parameter is the bandwith. If no
%   second parameter is given, kernelweigths will return a vector that is long
%   enough to contain all weights that are at least 1e-15. Otherwise, the second
%   argument is the length of the vector that is returned.
%
% Example 1:

% m = kernelweights('ma',5,5,4,4);
% h = kernelweights('henderson',15);
% b = kernelweights('bongard',15);
% s = kernelweights('spencer');
% e = [0;kernelweights('epanechnikov',15);0];
% n = kernelweights('normal',2,15);
% plot((-7:7),[m,s,h,b,e,n],'linewidth',1);
% legend('4-fold MA','Spencer','Henderson(15)','Bongard(15)', ...
%    'Epanechnikov(15)','Gaussian(2)');
% xlim([-7,7]);
% grid on;
%
% Example 2:
% Let data be an array of noisy data:
% data1 = (1:100)/100;
% data2 = sin(2*pi*(1:100)/100);
% data = [data1;data2]';
% r = randn(101,2); r = r(2:end,:)*0.2 + r(1:end-1,:)*0.05; % autocorr noise
% noisy = data + r;
% w = kernelweights('epanech',20);
% s = wmean(noisy,w);
% figure('Position',[440 96 560 761]);
% subplot(2,1,1); plot([noisy(:,1),s(:,1),data(:,1)],'linewidth',1); grid on;
% subplot(2,1,2); plot([noisy(:,2),s(:,2),data(:,2)],'linewidth',1); grid on;
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
% 2018-10-03    Version 1.33    First version of the 'seas' part of the X-13
%                               toolbox.

%#ok<*AGROW>
function w = kernelweights(method,varargin)

    % supported methods
    kerneltypes = {'rehomme-ladiray','bongard', 'henderson', ...
        'spencer15','cma','centered moving average', 'ma', ...
        'moving average','uniform','rectangular','rectangle','box', ...
        'epanechnikov','triangle','triangular','biweight','quartic', ...
        'triweight','tricube','cosine','optcosine','logistic','sigmoid', ...
        'silverman','gaussian','normal','exponential','cauchy'};
    method = validatestring(method,kerneltypes);
    
    % extract numerical arguments
    a = getnum(varargin{:});

    % 'spencer' is a special case
    if strcmp(method,'spencer') || strcmp(method,'spencer15')
%        a = num2cell(ones(1,max(1,numel(a))));
        switch numel(a)
            case 0
                a = {1};    % simple Spencer kernel
            case 1
                a = num2cell(ones(1,max(1,a{1})));  % convolution
            otherwise
                err = MException('X13TBX:kernelweights:illArg', ...
                            ['The ''spencer'' method can be followed ', ...
                            'by at most one numerical argument. For ', ...
                            'instance: ''spencer'',2 will produce a ', ...
                            'convolution of two Spencer kernels.']);
                throw(err);
        end
    end
    
    % convolute recursively
    w = 1;
    while ~isempty(a)
        [wnew,remove] = do_one(method,a{:});
        a(1:min(remove,numel(a))) = [];
        w = conv(w,wnew);
        w = w(:)/sum(w);        % normalize
    end
    
    % --- internal functions ---------------------------------------------------

    function [w,r] = do_one(method,varargin)
        
        % the following few lines are useful for most kernels
        % a kernel that deviates from this overwrites it below
        r = 1;      % remove one arg in each iteration
        b = varargin{1};
        laglead = ceil((b-1)/2);
        k = -laglead:laglead;
        k = k / ((b-1)/2);
    
        switch method

            case 'rehomme-ladiray'
                r = 3;      % remove three args in each iteration
                w = rehomme_ladiray(varargin{:});

            case 'bongard'
                w = rehomme_ladiray(varargin{1},3,0);

            case 'henderson'
                w = rehomme_ladiray(varargin{1},3,1);

            case 'spencer15'
                % 5x4x4 triple moving average followed by a weighted MA(5)
                % source: page 2 of https://www.stat.berkeley.edu/~aditya/Site/Statistics_153;_Spring_2012_files/Spring2012Statistics153LectureThree.pdf
                % w = conv([-3,3,4,3,-3]',ma(5,4,4));
                w = conv(conv([-3 3 4 3 -3],ones(1,5)), ...
                    conv(ones(1,4),ones(1,4)));

            case {'cma','centered moving average','uniform','rectangular', ...
                    'rectangle','box'}
                % next weakly larger odd number
                oddn = ceil((varargin{1}-1)/2)*2+1;
                % simple weights
                w = ones(oddn,1);
                % adjust weights on the edge
                w([1,end]) = 1 - (oddn-varargin{1})/2;

            case {'ma','moving average'}
                % simple uniform weigths
                w = ones(ceil(varargin{1}),1);

            case 'epanechnikov'
                w = 1 - k.^2;
                w(w<=0) = [];

            case {'triangle','triangular'}
                w = 1 - abs(k);
                w(w<=0) = [];

            case {'biweight','quartic'}
                w = (1 - k.^2).^2;
                w(w<=0) = [];

            case 'triweight'
                w = (1 - k.^2).^3;
                w(w<=0) = [];

            case 'tricube'
                w = (1 - abs(k).^3).^3;
                w(w<=0) = [];

            case 'cosine'
                w = 1 + cos(k*pi);
                w(w<=0) = [];

            case 'optcosine'
                w = cos(k*pi/2);
                w(w<=0) = [];

            case 'logistic'
                if numel(varargin) > 1
                    l = varargin{2};
                    r = 2;
                else
                    l = ceil(b * 71);
                end
                laglead = ceil((l-1)/2);
                k = -laglead:laglead;
                k = k / b;
                w = 1./(exp(k) + exp(-k) + 2);
                
            case 'sigmoid'
                if numel(varargin) > 1
                    l = varargin{2};
                    r = 2;
                else
                    l = ceil(b * 71);
                end
                laglead = ceil((l-1)/2);
                k = -laglead:laglead;
                k = k / b;
                w = 2./(exp(k) + exp(-k));
                
            case {'gaussian','normal'}
                if numel(varargin) > 1
                    l = varargin{2};
                    r = 2;
                else
                    l = ceil(b * 19);
                end
                laglead = ceil((l-1)/2);
                k = -laglead:laglead;
                k = k / b;
                w = exp(-abs(k).^2/2);

            case 'exponential'
                if numel(varargin) > 1
                    l = varargin{2};
                    r = 2;
                else
                    l = ceil(b * 135);
                end
                laglead = ceil((l-1)/2);
                k = -laglead:laglead;
                k = k / b;
                w = exp(-abs(k)/2);

            case 'cauchy'
                w = 1./(1+k.*k);

            case 'silverman'
                if numel(varargin) > 1
                    l = varargin{2};
                    r = 2;
                else
                    l = ceil(b * 98);
                end
                laglead = ceil((l-1)/2);
                k = -laglead:laglead;
                k = k / b;
                s2 = sqrt(2) / 2;
                w = exp(-abs(k)*s2) .* cos(-abs(k)*s2);

            otherwise
                e = MException('TBX13X:kernelweights:unknown_method', ...
                    'Kernel of type ''%s'' is not implemented.',method);
                throw(e);

        end
        
    end
    
    % extract or convert to numerical arguments
    function a = getnum(varargin)
        a = [];
        for c = 1:numel(varargin)
            v = varargin{c};
            if isnumeric(v)
                for d = 1:numel(v)
                    a{end+1} = v(d);
                end
            elseif ischar(v)
                temp = str2num(v); %#ok<ST2NM>
                for d = 1:numel(temp)
                    a{end+1} = temp(d);
                end
            elseif iscell(v)
                for d = 1:numel(v)
                    temp = getnum(v{d});
                    a{end+1:end+numel(temp)} = [temp{:}];
                end
            end
        end
    end
    
    % Rehomme-Ladiray kernel (generalisation of Henderson and of Bongard)
    function w = rehomme_ladiray(n,p,h)

        % validate args

        if nargin<3 || isempty(h) || isnan(h)
            h = 0.5;
        elseif h>1 || h<0
            warning(['You have chosen to set h = %f. The computations will be ', ...
                'performed, but you should be aware that values outside [0,1] ', ...
                'do not make much sense.'],h);
        end

        if nargin<2 || isempty(p) || isnan(p)
            p = 3;
        else
            if iscell(n); n = n{1}; end
            if ischar(n); n = str2num(n); end %#ok<ST2NM>
            assert(fix(p) == p && p >= 1 && n>=p, ['The Rehomme-Ladiray ', ...
                'moving average requires that the second argument must be a ', ...
                'positive integer not exceeding the first argument. Your ', ...
                'second argument is %g, your first argument is %g.'],p,n);
            p = p + mod(p+1,2);     % next odd number
        end

        if fix(n) ~= n || mod(n,2) ~= 1 || n < 3
            new_n = max(ceil(n),3);
            if mod(new_n,2) ~= 1; new_n=new_n+1; end
            warning(['Rehomme-Ladiray moving average is only defined for odd ', ...
                'integers greater than or equal to 3. You have chosen %g. The ', ...
                'argument is set to %i instead.'],n,new_n);
            n = new_n;
        end

        % set up computation

        % - prepare A
        H = diag(ones(1,n))*20 + ...
            (diag(ones(1,n-1),1)+diag(ones(1,n-1),-1))*(-15) + ...
            (diag(ones(1,n-2),2)+diag(ones(1,n-2),-2))*6 + ...
            (diag(ones(1,n-3),3)+diag(ones(1,n-3),-3))*(-1);
        % convex combination of Henderson and Bongard
        A = h*H + (1-h)*eye(n);
        A = A/(19*h+1);

        % - prepare C
        nn = (n-1)/2; l = (p+1)/2;
        C = NaN(n,l);
        for k = 0:2:p-1
            C(:,k/2+1) = (-nn:nn)'.^k;
        end

        % - prepare alpha
        alpha = [1;zeros(l-1,1)];

        % perform computation
        lambda = -2*(C'/A*C)\alpha;     % multiplier
        w = -0.5*A\C*lambda;            % first order condition

    end

end
