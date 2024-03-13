% SEAS is a simple program that demonstrates the use of the programs in the
% seas directory of the X-13 toolbox.
%
% *** COMPONENTS OF THE SEAS SUBFOLDER **********************************
% 
% This folder contains a selection of programs that can be used to easily
% create a seasonal adjustment, based on filters, yourself.
% 
% These programs are:
%
% trendfilter.m         Computes a trend (i.e. smoothed) version of the
%                       data. You can choose from many different methods to
%                       do that.
% seasfilter.m          Splits data using splitperiods, smoothes them with
%                       trendfilter, and joins them together again with
%                       joinperiods.
% normalize_seas.m      Computes the difference or the ratio of two series,
%                       depending on whether the decomposition is additive
%                       or multiplicative. 
% splitperiods.m        Splits the data into their periods. For instance,
%                       with monthly data, split periods makes twelve times
%                       series out of your data, one for each month of the
%                       year. 
% joinperiods.m         Reverse of splitperiods.
% fillholes.m           Linear interpolation of missing values.
% wmean.m               Computes the weighted mean. Similar to Matlab's
%                       conv command, but with smarter treatment of the
%                       edge of the data.
% kernelweights.m       Computes the weights for a wide range of kernels.
%                       Used by trendfilter.m and seasfilter.m in
%                       conjunction with wmean.m
% fixedseas.m           A rather elaborate program that produces a rather
%                       simple version of seasonal adjustment in which the
%                       seasonal factors are kept fixed over the years.
% x11.m                 An implementation of a much simplified version of
%                       the original X-11 method of the U.S. Census Bureau.
% method1.m             An implementation of a simplified version of
%                       "Methiod I", a predecessor of all the X-Algorithms,
%                       also developed at the US Census Bureau.
% camplet.m             A form of seasonal adjustment that was recently
%                       developed and that does not produce revisions when
%                       data are added to the time series. It does that
%                       because the smoothing is completely backward
%                       looking (so no centered filters at all). camplet is
%                       separately implemented and does not use the other
%                       tools provided here.
% seas.m                This file. You can experiment with the
%                       implementation in this file, and develop your own
%                       seasonal adjustment routine starting from seas.m.
%
% *** AN EXAMPLE: SEAS.M ************************************************
% 
% Usage of seas.m
%   s = seas(data,p)
%   s = seas([dates,data],p)
%   s = seas(...,[mode],[title])
%
% data is either a column vector or an array with two columns. In that
% case, the left column is a date vactor and the right column is the data
% vector. 
%
% p is the period of the data that is to be filtered out. So, typically,
% with monthly data, for instance, p should be set to 12.
%
% mode is either 'add', 'logadd', or 'mult'. 'add' implies that the
% seasonal factor will be zero on average and is subtracted from the
% unadjusted data to get to the seasonally adjusted data. If type is
% 'logadd', an additive decomposition is performed on the logarithm of the
% data, which are then converted back to their non-log versions afterwards.
% With 'mult', the seasonal factor is one on average, and the data is
% divided by the seasonal factor to get the seasonally adjusted data.
% Quantitatively, 'mult' should be quite simkilar to 'logadd'.
%
% title is a string containing the name of the series (if one is provided).
%
% s contains the output neatly organized in a struct. To make an x13series
% out of this, say the following,
%   x = structtox13(s);
% Alternatively, you can use the custom implementation with x13 as follows,
%   x = x13(dates,data,spec,'prog','seas.m')
% If you use it like this, the settings passed on are set in the spec in
% the 'custom' section, for instance,
%   spec = makespec('custom','save','(sa sf)','custom','mode','add')
% This version has the advantage that you can also specify trading day and
% Easter corrections, which are extracted via a regression of the irregular
% component of a first pass of seas.m, correctingh the data from that, and
% then running seas.m a second time.
%
% *** MAKING YOUR OWN ***************************************************
%
% You can easily make your own implementation. It may be easiest to start
% from seas.m and modify a copy of this file. Any custom m-file that
% performs a seasonal adjustment has to return a struct, containing, at the
% minimum, the following fields:
%   'dates'     The column vector of dates.
%   'dat'       The column vector of unadjusted data.
% In addition, your output struct should contain the result of your
% seasonal decomposition. Note that these fields must have names with at
% most three letters (e.g., 'sa', 'rsd', etc). Fields with names longer
% than three letters (except the ones listed below) will not be imported
% into the x13series object.
%
% Optional fields are:
%   'keyv'      The content of this field is itself a struct with the
%               following components: 'dat','tr','sa','sf','ir','si','rsd'.
%               These fields contain the sames of key variables. This
%               setting is stored not in the x13spec, but directly in the
%               x13series object. If your output s does not contain a keyv
%               field, the default is used,
%               keyv = struct('dat','dat','tr','tr', 'sa','sa', ...
%                             'sf','sf','ir','ir','si','si','rsd','rsd')
%   'mode'      The mode of the adjustment (typically 'add', 'logadd',
%               'mult', but others are possible, depending on what you
%               implement). The setting is stored in custom-mode in the
%               x13spec.
%   'transform' A transformation of the data before processing (typically
%               'none' or 'log', but again, more is possible. The setting
%               is stored in transform-function in the x13spec.
%   'title'     The title of the variable (if one is provided).
%   'name'      The name of the series. There is a subtle difference
%               between title and name. title can be any string, name
%               should be a valid filename (this has to do with x13as.exe,
%               which is irrelevant in this context, but it is good
%               practice to observe this restriction anyway).
%   'options'   Some content, to be defined by you, that describes any
%               information or settings you wish to use in your seasonal
%               adjustment. The setting is stored in custom-options in the
%               x13spec.
%   'tbl'       This is itself a struct. The content of this struct will be
%               imported as tables into the x13series object.
%
% ***********************************************************************
%
% NOTE: This file is part of the X-13 toolbox, but it is completely
% independent of the Census X-13 program. It is part of the 'seas' addition
% to the toolbox which allows you to implement seasonal filters without
% using the Census Bureau programs.
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
% 2023-10-11    Version 1.54    Change of the trend filter specification
% 2020-05-03    Version 1.50    Much more extensive dosumentation (see
%                               above). Removed the second output (x),
%                               since this can easily be generated
%                               separately, x = structtox13(s).
% 2020-04-21    Version 1.42    Uses structtox13 to generate an x13series.
% 2020-07-01    Version 1.40    Changed normalize to normalize_seas to
%                               avoid conflict with one of the Mathworks
%                               toolboxes.
% 2018-09-19    Version 1.33    First version of the 'seas' part of the X-13
%                               toolbox.

function s = seas(data,p,adjmode,title)

    % PARSE ARGS
    
    % -- dates present?
    [nrow,ncol] = size(data);
    if nrow == 1 && ncol > 2
        data = data';
    end
    [nobs,ncol] = size(data); nyears = ceil(nobs/p);
    if ncol > 1
        dates = data(:,1);
        data  = data(:,2:end);
    else
        dates = (1:nobs)';
    end
    
    % -- name present?
    if nargin<4 || isempty(title)
        title = '';
    end
    
    % -- additive or multiplicative?
    if nargin<3 || isempty(adjmode) || all(isnan(adjmode))
        adjmode = 'logadd';
    end
    
    adjmode = validatestring(adjmode,{'add','logadd','mult'});
    ismult = strcmp(adjmode,'mult');
    islogadd = strcmp(adjmode,'logadd');
    
    if islogadd
        data = log(data);
    end
    
    % DO THE WORK
    % There are essentially two places where you need to make a choice, and
    % these choices will determine the shape of the seasonal decomposition.
    % The first is: How do you want to smooth the data to compute the trend.
    % Allowing for a lot of roughness in the trend produces smaller
    % seasonal factors over all. Enforcing a very smooth trend, on the
    % other hand, will produce a more important role for the seasonal
    % factor. The second decision is how you want to smooth the seasonal
    % deviations over consecutive years. If you allow for a lot of
    % roughness here, the seasonal factors will change quickly from year to
    % year, so that the seasonality might appear rather unstable. On the
    % other hand, you can also keep the seasonal factors completely fixed
    % from one year to the next, but that will come at the cost of
    % increasing the 'unexplained' irregular component and making it more
    % serially correlated.
    
    % -- TR (trend) -->  choice #1
    tr = trendfilter(data,'cma', [p,p/2,p/3], ...
        'mirror', ceil(p/2)+ceil(p/4)+ceil(p/6)+1);    % moving average
    % tr = trendfilter(data,'cma',p,'forward','mirror',ceil(p/2));    % forward-looking moving average
    % tr = trendfilter(data,'cma',p,'back','mirror',ceil(p/2));    % backward-looking moving average
    % tr = trendfilter(data,'spencer','mirror',8);    % Spencer's filter
    % tr = trendfilter(data,'henderson',2*p-1,'mirror',p);   % Henderson's filter
    % tr = trendfilter(data,'bongard',2*p-1,'mirror',p);     % Bongard's filter
    % % Rehomme & Ladiray: generalization of Henderson and Bongard
    % tr = trendfilter(data,'rehomme-ladiray',[2*p-1,3,0.5],'mirror',p);
    % lambda = exp(-7.10636 + 5.91863781313348 * log(p));    % Hodrick-Prescott
    % tr = trendfilter(data,'hp',lambda,'mirror',p);
    % % Some common Kernels (more are available) ...
    % tr = trendfilter(data,'triangle',2*p-1,'mirror',p);
    % tr = trendfilter(data,'epanech',2*p-1,'mirror',p);
    % tr = trendfilter(data,'epanech',[2*p-1,p],'mirror',p);
    % h = ((dates(end)-dates(1)) / (numel(dates)-1)) ./ p;   % cubic spline
    % roughness = 1 ./ (1 + h.^3 / 0.6);
    % tr = trendfilter(data,'spline',roughness,'mirror',p);
    
    % -- SI (deviation of data from trend)
    si = normalize_seas(data,tr,ismult);
    
    % -- SF (seasonal factors)  -->  choice #2
    %  sf = seasfilter(si,p,'spline',0.1,'mirror',nyears);
    % sf = seasfilter(si,p,'cma',5,4,4,'mirror',nyears);
    % sf = seasfilter(si,p,'hp',100,'mirror',nyears);
    % sf = seasfilter(si,p,'poly',4,'mirror',nyears);
    % sf = seasfilter(si,p,'henderson',13,'mirror',nyears);
    sf = seasfilter(si,p,'epanech',5,'mirror',nyears);
    %
    % To get seasonal factors that are fixed over the years, you need to
    % smooth this using a simple average over the whole sample. How you
    % take this average depends on whether you decompose additively or
    % multiplicatively.
    % if ismult
    %     sf = seasfilter(si,p,'reldeviation');   % relative deviation from mean
    % else
    %     sf = seasfilter(si,p,'deviation');      % simple deviation from mean
    % end
    
    % -- SA and IR (seasonally adjusted data and irregular component)
    sa = normalize_seas(data,sf,ismult);
    ir = normalize_seas(sa,tr,ismult);
    
    % In the end, tr should contain the low frequency components of the
    % data, sf should contain the medium frequencies, and ir the high
    % frequencies. sa, the seasonally adjusted data, is the data minus the
    % medium frequencies, or equivalently, the sum of tr and ir. (With
    % multiplicative decomposition, replace the word 'sum' with 'product',
    % and 'difference' with 'ratio').
    
    % unlog if transform is log
    if islogadd
        data = exp(data);
        tr   = exp(tr);
        sa   = exp(sa);
        sf   = exp(sf);
        si   = exp(si);
        ir   = exp(ir);
    end
        
    % COLLECT EVERYTHING
    
    s = struct(...
        'prog',     'seas.m',   ...
        'title',    title,      ...
        'period',   p,		    ...
        'mode',     adjmode,	...
        'dates',    dates,	    ...
        'dat',      data,	    ...
        'tr',       tr,		    ...
        'sa',       sa,		    ...
        'sf',       sf,		    ...
        'ir',       ir,		    ...
        'si',       si);
    
    % *** REMARKS *********************************************************
    %
    % seas.m can be used in connection with x13series. There is a
    % complicated and a comfortable way to do this.
    % 
    % Here's the complicated way: you can export the content of the s
    % struct created above into an x13series with x = struxttox13(s). x
    % will contain an x.spec that contains the settings you have chosen,
    % such as the adjustment mode.
    %
    % For your own algorithm, you can define custom settings. In order to
    % make sure that these settings will be transferred to the x.spec, just
    % add this field to your s.struct:
    %
    %  s = struct(...
    %      ...
    %      'options', [your custom options], ...
    %      ...);
    % 
    % Also, the s-struct is supposed to contain a keyv field with the names
    % of all the key variables, but if this is missing, the default will be
    % added to the x13series anyway, so
    %     'keyv', struct('dat','dat','tr','tr','sa','sa','sf','sf', ...
    %         'ir','ir','si','si','rsd','rsd'), ...
    % is superfluous.
    %
    % Here's the more comfortable way:
    %
    %  x = x13(dates,data, makespec(...), 'prog','seas.m')
    %
    % makespec(...) is the specs you can choose (see doc makespec and doc
    % x13spec). In makespec, you can use the 'custom' section to specify
    % any options that will be used with seas (or with your own seasonal
    % adjustment algorithm).

end
