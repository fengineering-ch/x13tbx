% METHOD1 computes an approximate version of "Method I", developed by
% Julius Shishkin in the 1950 at the US Census Bureau.
%
% Note: I have not found a completely clear description of the algorithm,
% so it is unlikely that the algorithm is exactly the same as the original.
% My implementation is based on Allen H. Young's preface to the book by
% Ladiray and Quenneville:
%     "Dans la Méthode I, les coefficients saisonniers étaient estimés par
%     l’intermédiaire de moyennes mobiles appliquées aux valeurs de la
%     composante saisonnier-irrégulier de chaque mois. Cette composante
%     saisonnier-irrégulier était elle-même calculée comme rapport de la
%     série originale et du résultat du lissage de cette série originale
%     par une moyenne mobile centrée sur 12 termes, lissage sensé
%     représenter la composante tendance-cycle. Une seconde série ajustée
%     était calculée, en remplaçant cette estimation de la tendance-cycle
%     par le lissage de la première estimation de la série corrigée des
%     variations saisonnières par une moyenne mobile simple d’ordre 5."
% Also, the treatment at the edge of the sample is certainly different than
% the original.
%
% Usage:
%   s = method1(data,period);
%   s = method1([dates,data],period);
%   s = method1(... ,adjmode);
%   s = method1(... ,adjmode,title);
%
%   s   This is a structure containing the following components:
%         'prog',     'method1.m', ...
%         'tbl',      an explanatory text,  ... 
%         'title',    title,    ...
%         'period',   period,	...
%         'mode',     adjmode,  ...
%         'keyv',     struct('dat','dat','tr','d12','sa','d11','sf','d10', ...
%             'ir','d13','si','d8','rsd','rsd'), ...
%         'dates',    dates,	...
%         'dat',      data,     ...
%         'd12',      tr,		...
%         'd8',       si,       ...
%         'd10',      sf,		...
%         'd11',      sa,		...
%         'd13',      ir,		...
%         'b2',       tr1,      ...
%         'b3',       si1,      ...
%         'b4',       sf1,      ...
%         'b6',       sa1);
%
% adjmode
%       must be one of the following: 'additive','none','multiplicative',
%       or 'logadditive'. It indicates the type of decomposition.
%       'additive' or 'none' : data = tr + sf + ir, sa = tr + ir.
%           'multiplicative' : data = tr * sf * ir, sa = tr * ir.
%              'logadditive' : log(data) = tr + sf + ir, sa = exp(tr + ir). 
%
% title is a string containing a descriptive title of the variable that is
%       treated. This can be empty.
%
% REMARK: This program uses several smaller programs (trendfilter, seasfilter,
% normalize_seas) that can be used to create a custom seasonal adjustment algorithm
% relatively easily. To understand how, just study the source code of this
% program.
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
% 2020-05-16    Version 1.50    Cleaning up.
% 2020-04-21    Version 1.42	First version of Method I implementation.

function s = method1(data,p,adjmode,title)

    % PARSE ARGS

    % -- name present?
    if nargin<4 || isempty(title) || all(isnan(title))
        title = [];
    end
    
    % -- type of decomposition ?
    if nargin<3 || isempty(adjmode) || all(isnan(adjmode))
        adjmode = 'logadd';
    end
    
    % validate parameters
    assert(isnumeric(p) && fix(p) == p && numel(p) == 1 && p > 0, ...
        'X13TBX:method1:IllegalPeriod', ...
        'The second argument of method1 must be a positive integer.');
    [nrow,ncol] = size(data);
    if nrow == 1 && ncol > 2
        data = data'; [nrow,ncol] = size(data);
    end
    assert(nrow>1 && (ncol == 1 || ncol == 2), ...
        'X13TBX:method1:NoVector', ['method1 expects a vector, but you have ', ...
            'provided a %ix%i array.'],nrow, ncol);
    
    % -- dates present?
    [nrow,ncol] = size(data);
    if nrow == 1 && ncol > 2
        data = data';
    end
    [nobs,ncol] = size(data);
    if ncol > 1
        dates = data(:,1);
        data  = data(:,2:end);
    else
        dates = (1:nobs)';
    end
    
    % set parameters depending on adjustment mode
    legal = {'add','none','mult','logadd'};
    adjmode = validatestring(adjmode,legal);
    
    switch adjmode
        case {'add','none'}
            ismult   = false;
            islogadd = false;
            adjmode = 'add';
        case 'mult'
            ismult   = true;
            islogadd = false;
        case 'logadd'
            ismult   = false;
            islogadd = true;
    end
    
    % PRE-TREAT DATA
    % take logs of data if type is log-additive
    
    if islogadd
        assert(all(data(~isnan(data)) > 0), ...
            'X13TBX:x11:NegLog', ['Data must be strictly positive ', ...
            'for log-additive decomposition.']);
        data = log(data);
    end
    
    % DO THE WORK

    tr1 = trendfilter(data,'cma',p,'mirror',ceil(p/2));
    si1 = normalize_seas(data,tr1,ismult);
    sf1 = seasfilter(si1,p,'ma',[3,3],'mirror',3);
    sa1 = normalize_seas(data,sf1,ismult);
    tr  = trendfilter(sa1,'ma',5,'mirror',3);
    si  = normalize_seas(data,tr,ismult);
    sf  = seasfilter(si,p,'ma',[3,3],'mirror',3);
    sa  = normalize_seas(data,sf,ismult);
    ir  = normalize_seas(sa,tr,ismult);
    
    % PREPARE OUTPUT
    
    % un-log if type is log-additive
    if islogadd
        data = exp(data);
        tr   = exp(tr);
        si   = exp(si);
        sf   = exp(sf);
        sa   = exp(sa);
        ir   = exp(ir);
        tr1  = exp(tr1);
        si1  = exp(si1);
        sf1  = exp(sf1);
        sa1  = exp(sa1);
    end
    
    % collect everything
    
    thetitle = title; if isempty(title); thetitle = 'no name'; end
    tbl = struct('heading', ...
        sprintf(['Approximate implementation of US Census Bureau METHOD I\n\n', ...
        'This is an approximate implementation of an algorithm that was ', ...
        'developed\nin 1954 by Shiskin for the US Census Bureau. It is the ', ...
        'predecessor of\nMethod II (duh!), which is the predecessor of all ', ...
        'experimental X-Variants.\nOne of those, X-11, turned out to be very ',...
        'successful.\n\nMethod I is extremely simple and transparent, but ', ...
        'quite often yields\nvery good results.\n\nThe advantage of having this ', ...
        'in the toolbox is that the user is not\nconstrained to quartely or ', ...
        'monthly frequencies. The approximate X-11\nimplementation, which is ', ...
        'much more complicated, can also be used for this\npurpose.\n\n', ...
        'Sincerely, Yvan Lengwiler\n\n', ...
        'Name: %s \n%s to %s, frequency = %i\n%i observations\nadjustment mode: %s', ...
        '\n\nUse ''help method1'' to know more.'], ...
            thetitle,datestr(dates(1)),datestr(dates(end)),p,numel(data),adjmode));
    
    s = struct(...
        'prog',     'method1.m', ...
        'tbl',      tbl,        ... 
        'title',    title,      ...
        'period',   p,          ...
        'mode',     adjmode,	...
        'keyv',     struct('dat','dat','tr','d12','sa','d11','sf','d10', ...
            'ir','d13','si','d8','rsd','rsd'), ...
        'dates',    dates,      ...
        'dat',      data,       ...
        'd12',      tr,         ...
        'd8',       si,         ...
        'd10',      sf,         ...
        'd11',      sa,         ...
        'd13',      ir,         ...
        'b2',       tr1,        ...
        'b3',       si1,        ...
        'b4',       sf1,        ...
        'b6',       sa1);
    
end
