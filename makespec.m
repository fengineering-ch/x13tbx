% MAKESPEC produces x13 specification structures. It makes the use of
% x13spec easier by providing quick access to meaningful specification
% combinations.
%
% Usage:
%   spec = makespec(shortcut, [shortcut2, ...])
%   spec = makespec([shortcut], [section, key, value], ...)
%   spec = makespec([shortcut], [section, key, value], [spec1], ...)
%
% Available shortcuts are:
%   'DIAGNOSTIC'    produce ACF and spectra of the data; this is useful to
%                   determine if the data is seasonal at all
%   'ACF'           subset of 'DIAGNOSTIC' without spectra (for quarterly
%                   data); saves (partial) auto-correlation functions 
%   'SPECTRUM'      save some spectra
%   'STOCK'         Data is a stock variable. (This is relevant for the types of
%                   calendar dummies.)
%   'FLOW'          Data is a flow variable.
%   'AUTO'          let program select additive vs multiplicative filtering
%   'MULTIPLICATIVE'    force multiplicative filtering
%   'ADDITIVE'      force additive filtering
%   'ESTIMATE'      estimate ARIMA, even if no seasonal adjustment is
%                   computed
%   'TRAMO'         use TRAMO to select model
%   'TRAMOPURE'     use TRAMO, but do not consider mixed models
%   'PICKFIRST'     use Census X-11 procedure to select model; pick the first
%    or 'PICK'      that meets the criteria
%   'PICKBEST'      use Census X-11 procedure to select model; check all
%                   models and pick the best
%   'CONSTANT'      adds a constant to the regARIMA model
%   'AO'            allow additive outliers
%   'LS'            allow level shifts
%   'TC'            allow temporary changes
%   'NO OUTLIERS'   do not detect outliers
%   'TDAYS'         add trading day dummies to the regression and keep them
%                   if they are significant
%   'FORCETDAYS'    force seven trading day dummies on the regression
%                   (even if not significant)
%   'EASTER'        add an Easter dummy and keep it if significant
%   'FCT'           compute forecast with default confidence bands
%   'FCT50'         compute forecast with 50% confidence bands
%   'X11'           compute Trend-Cycle and Seasonality using X-11
%   'FULLX11'       same as X11, but save all available variables, except
%                   intermediary iteration results
%   'TOTALX11'      same as X11, but save all available variables,
%                   including intermediary iteration results
%   'SEATS'         compute Trend-Cycle and Seasonality using SEATS
%   'FULLSEATS'     same as SEATS, but save all available variables
%   'FIXEDSEASONAL' compute simple seasonal filtering with fixedseas
%   'CAMPLET'       compute filtering with camplet algorithm
%   'SLIDINGSPANS'  produces sliding span analysis to gauge the stability
%                   of the estimation and filtered series
%   'FULLSLIDINGSPANS'  same as SLIDINGSPANS, but save all available variables
%   'HISTORY'       another stability analysis that computes the amount of
%                   revisions that would have occurred in the past
%   'FULLHISTORY'   same as HISTORY, but save all available variables
%
% Moreover, makespec also accepts shortcuts that affect the tables that are
% printed throughout. The default is to print only those tables that are
% explicity requested ('PRINTREQUESTED'). Alternatives are
%   'PRINTNONE'     Do not print any tables (except some basic ones in series
%                   or composite, respectively).
%   'PRINTBRIEF'    Print a restricted set of tables.
%   'PRINTDEFAULT'  Use the default as defined by the X-13 program.
%   'PRINTALLTABLES' Print all tables, but no graphs.
%   'PRINTALL'      Print all tables and graphs.
%
% There are also meta-shortcuts:
%   'DEFAULT' is equal to {'AUTO','TRAMOPURE','X11'  ,'AO','TDAYS','DIAG'}
%   'X'       is equal to {'AUTO','PICKBEST' ,'X11'  ,'AO','TDAYS','DIAG'}
%   'S'       is equal to {'AUTO','TRAMOPURE','SEATS','AO','TDAYS','DIAG'}
% If no argument is used (spec = makespec()), 'DEFAULT' is used.
% You are free to add further meta-shortcuts according to your needs; see
% the program text right at the beginning after the 'function' statement.
%
% Note that shortcuts can be abbreviated but they are case sensitive; they
% must be given in upper case letter. (This is so in order to distinguish
% the shortcut 'X11' from the spec section 'x11', and shortcut 'SEATS' from
% the spec section 'seats').
%
% Multiple shortcuts can be combined, though some combinations are
% non-sensical (such as X11 and SEATS, or TRAMO and PICK together).
%
% No selection of shortcuts will ever accommodate all needs, unless the
% shortcuts are as detailed as the original specification possibilities,
% which would defy their purpose. Therefore, one can also add normal
% section-key-value triples as in x13spec (the second usage form above).
% These settings are simply merged, working from left to right. This means
% that later arguments overwrite earlier arguments.
%
% So, makespec('NO OUTLIERS','AO') is the same as makespec('AO'), and in
% makespec('AUTO','transform','function','none') the 'AUTO' shortcut is
% overruled. Likewise, makespec('X','MULT') is the same as the 'X' 
% meta-shortcut, but forcing the logarithmic transformation of the data
% ('X' sets this to 'auto' and therefore lets x13as choose between no
% transformation and the log).
%
% You can also use an existing spec (created with makespec or with x13spec) as
% an argument in makespec (thirtd usage form above). The contents of this
% spec-variable will again be merged.
%
% Example:
%   spec = makespec('DIAG','AUTO','TRAMOPURE','AO');
%   x1 = x13(dates,data,makespec(spec, 'X11', ...
%       'series','name','Using X11'));
%   x2 = x13(dates,data,makespec(spec, 'SEATS', ...
%       'series','name','Using SEATS'));
%   plot(x1,x2,'d11','s11','comb')
%
% Most users will never use x13spec directly, but will always create their
% specs with makespec, because everything you can do with x13spec you can
% also do with makespec, plus you have the added convenience of the
% shortcuts (and even meta-shortcuts).
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
% 2023-10-24    Version 1.55    Fix of bug in V1.1 B60 of x13.exe in the
%                               HISTORY section; expanded FULLHISTORY to
%                               include the complete range of entries in
%                               'estimates'
% 2018-09-06    Version 1.33    Changed definition of 'DEFAULT' meta-shortcut.
% 2017-03-27    Version 1.32    Added 'x11','save','d4' to X11 shortcut
%                               (later apparently removed again)
% 2017-01-09    Version 1.30    First release featuring camplet.
% 2016-09-94    Version 1.18.1  Simpler syntax for defining meta-shortcuts.
% 2016-08-18    Version 1.17.8  Added backcast to FCT shortcut.
% 2016-07-13    Version 1.17.2  Removed 'x11-appendfcst-yes' from 'X11'
%                               definition in makespec.
% 2016-07-04    Version 1.16.1  Added 'STOCK' and 'FLOW'.
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
% 2015-06-13    Version 1.12.1  Added 'CONST' and 'ESTIMATE' shortcut.
% 2015-04-15    Version 1.2     Adaptation of (meta-)shortcuts to version
%                               1.1 Build 19 of x13as.exe
% 2015-01-04    Version 1.1     Better selection of meta-shortcuts
% 2015-01-01    Version 1.01    Better support for meta-shortcuts
% 2014-12-31    Version 1.0     First Version

function spec = makespec(varargin)
    
    % definition of meta-shortcuts
    meta = struct;
    meta.DEFAULT = {'AUTO','TRAMOPURE','X11'  ,'AO','TDAYS','DIAG'};
    meta.X       = {'AUTO','PICKBEST' ,'X11'  ,'AO','TDAYS','DIAG'};
    meta.S       = {'AUTO','TRAMOPURE','SEATS','AO','TDAYS','DIAG'};
    % You are free to add your own here using the same syntax or change the
    % definitions above, but you must keep a meta.DEFAULT line.
    
    METANAMES = fieldnames(meta)';
    
    % list of available shortcuts
    SHORTCUTS = {'AUTO','LOG','MULTIPLICATIVE','NOTRANSFORM','ADDITIVE', ...
        'ESTIMATE','TRAMO','TRAMOPURE','PICK','PICKFIRST','PICKBEST', ...
        'STOCK','FLOW','CONSTANT','AO','LS','TC','NO OUTLIERS', ...
        'TDAYS','FORCETDAYS','EASTER','FCT','FCT50', ...
        'X11','FULLX11','TOTALX11','SEATS','FULLSEATS','CUSTOM', ...
        'SPECTRUM','ACF','DIAGNOSTIC', ...
        'SLIDINGSPANS','FULLSLIDINGSPANS', ...
        'HISTORY','FULLHISTORY','FIXEDSEASONAL','CAMPLET','FULLCAMPLET'};
    
    % list of PRINT SPECIFICATIONS
    PRINTSPECS = {'PRINTREQUESTED','PRINTNONE','PRINTBRIEF','PRINTDEFAULT', ...
        'PRINTALLTABLES','PRINTALL'};
    printcode = 0;
    
    % if no arg is given, 'DEFAULT' is executed
    if nargin < 1
        varargin{1} = 'DEFAULT';
    end
    
    % the work starts here
    
    spec = x13spec();
    
    while ~isempty(varargin)    % loop through all args
        
        try %#ok<TRYNC> % don't want to abort if no match is found
            % deal with abbreviated shortcuts ...
            validStr = validatestring(varargin{1}, ...
                [METANAMES,SHORTCUTS,PRINTSPECS]);
            % ... but accept only if they are upper case
            if strncmp(validStr,varargin{1},length(varargin{1}))
                varargin{1} = validStr;
            end
        end
        
        if isa(varargin{1},'x13spec')
            
            spec = x13spec(spec,varargin{1});
            varargin(1) = [];
            
        elseif ismember(varargin{1},[METANAMES,SHORTCUTS])
            
            spec = applyshortcut(spec,varargin{1});
            varargin(1) = [];
            
        elseif ismember(varargin{1},PRINTSPECS)
            
            printcode = find(ismember(PRINTSPECS,varargin{1})) - 1;
            varargin(1) = [];
            
        else    % it's not a shortcut or printspec, so it ought to be a
                % section-key-value triple
        
            if numel(varargin) < 3
                str = strjoin([SHORTCUTS,METANAMES,PRINTSPECS],''', ''');
                err = MException('X13TBX:MAKESPEC:IllArg', ...
                    ['Arguments must be specified as triplets ', ...
                    '(section-key-value), or be valid shortcuts.\n\n', ...
                    'Valid shortcuts are: ''%s''.\n\nTo see valid ', ...
                    'section-key-value triplets, use help x13spec.'], str);
                throw(err);
            else
                spec = x13spec(spec,varargin{1:3});
                varargin(1:3) = [];
            end
            
        end
        
    end
        
    % apply printcode
    if printcode > 0
        switch printcode
            case 1; code = 'none';
            case 2; code = 'brief';
            case 3; code = 'default';
            case 4; code = 'alltables';
            case 5; code = 'all';
        end
        sections = fieldnames(spec);
        % 'arima', 'fixedseas', 'camplet', and 'metadata' have no 'print' key
        sections(ismember(sections,{'arima','fixedseas','camplet','metadata'})) = [];
        for s = 1:numel(sections)
            spec = x13spec(spec, sections{s},'print',[], ...
                sections{s},'print',code);
        end
    end

%             sections(contains(sections,{'fixedseas','camplet','metadata'})) = [];
%             if ~isempty(spec.(sections{s}))
%                 keys = fieldnames(spec.(sections{s}));
%                 if ismember('print',keys)
%                     values = spec.(sections{s}).print;
%                     spec.RemoveRequests(sections{s},'print',values);
%                 end
%             end
%             spec = spec.SaveRequests(sections{s},'print',code);
    
    % --- sub-function ----------------------------------------------------
    
    function spec = applyshortcut(spec,arg)

        switch arg
            
            case METANAMES      % it's a meta-shortcut
                spec = x13spec(spec, ...
                    makespec(meta.(arg){:}));           % recursive call
                
            case 'STOCK'
                spec = x13spec(spec, ...
                    'series'   ,    'type',         'stock');

            case 'FLOW'
                spec = x13spec(spec, ...
                    'series'   ,    'type',         'flow');

            case 'AUTO'         % let progam select additive vs multiplicative
                spec = x13spec(spec, ...
                    'transform',    'power',        [],     ...
                    'transform',    'function',     'auto', ...
                    'transform',    'print',        'tac');
    
            % 'MULTIPLICATIVE' is here only for backward compatibility;
            % it's an inaccurate term
            case {'LOG','MULTIPLICATIVE'}	% force logarithmic transformation
                spec = x13spec(spec, ...
                    'transform',    'power',        [],     ...
                    'transform',    'function',     'log');
                spec = spec.RemoveRequests('transform','print','tac');

            % 'ADDITIVE' is here only for backward compatibility;
            % it's an inaccurate term
            case {'NOTRANSFORM','ADDITIVE'} 	% force no transformation
                spec = x13spec(spec, ...
                    'transform',    'power',        [],     ...
                    'transform',    'function',     'none');
                spec = spec.RemoveRequests('transform','print','tac');
               
            case 'ESTIMATE'     % estimate ARIMA,
                                % even without seasonal adjustment
                spec = x13spec(spec, ...
                    'estimate',     'save',         '(mdl ref rsd rts est lks)', ...
                    'estimate',     'print',        '(est lks rts)');
                if ~ismember('regression',fieldnames(spec))
                    spec = spec.AddSections('regression');
                end

            case 'TRAMO'        % use TRAMO to select model
                                % do allow mixed models
                spec = makespec(spec, 'ESTIMATE', ...
                    'arima'  , [], [], ...    % remove arima
                    'pickmdl', [], [], ...    % remove PICKMDL
                    'automdl',      'maxorder',     '(4,2)',    ...
                    'automdl',      'acceptdefault','no',       ...
                    'automdl',      'print',        '(hdr urt ach b5m)');
                if isempty(ExtractValues(spec,'automdl','checkmu'))
                    if ismember('const', ExtractValues(spec, ...
                            'regression','variables'))
                        spec = x13spec(spec,'automdl','checkmu','no');
                    end
                end
            
            case 'TRAMOPURE'   % use TRAMO to select model, 
                               % do not allow mixed models
                spec = makespec(spec,'TRAMO','automdl','mixed','no');

            case {'PICKFIRST','PICK'} % use Census X-11 procedure to select model
                spec = makespec(spec, 'ESTIMATE', ...
                    'arima'  ,      [],             [], ...    % remove arima
                    'automdl',      [],             [], ...    % remove TRAMO
                    'pickmdl',      'method',       'first',    ...
                    'pickmdl',      'print',        '(hdr pch -umd)', ...
                    'pickmdl',      'mode',         'fcst',     ...
                    'pickmdl',      'outofsample',  'yes');
                
            case 'PICKBEST'
                spec = makespec(spec,'PICKFIRST', ...
                    'pickmdl',      'method',       'best');
            
            case 'CONSTANT'     % add a constant to the ARIMA model
                spec = AddRequests(spec, ...
                    'regression',   'variables',    'const');
                if ismember('automdl',fieldnames(spec))
                    spec = x13spec(spec,'automdl','checkmu','no');
                end
                
            case 'AO'           % allow additive outliers
                spec = spec.RemoveRequests('outlier','types','none');
                spec = x13spec(spec, ...
                    'regression',   'save',         'ao',       ...
                    'outlier',      'types',        'ao',       ...
                    'outlier',      'savelog',      'id');
%                    'outlier',      'print',        'none',     ...
            
            case 'LS'           % allow level shifts
                spec = spec.RemoveRequests('outlier','types','none');
                spec = x13spec(spec, ...
                    'regression',   'save',         'ls',       ...
                    'outlier',      'types',        'ls',       ...
                    'outlier',      'print',        'hdr', ...
                    'outlier',      'savelog',      'id');
                
            case 'TC'           % allow temporary changes
                spec = spec.RemoveRequests('outlier','types','none');
                spec = x13spec(spec, ...
                    'regression',   'save',         'tc',       ...
                    'outlier',      'types',        'tc',       ...
                    'outlier',      'print',        'hdr', ...
                    'outlier',      'savelog',      'id');
               
            case 'NO OUTLIERS'  % do not detect outliers
                spec = RemoveRequests(spec, ...
                    'outlier',      'types',        {'ao','ls','tc'});
                spec = RemoveRequests(spec, ...
                    'regression',   'save',         {'ao','ls','tc'});
                spec = RemoveRequests(spec, ...
                    'outlier',      'savelog',      'id');
                spec = x13spec(spec, ...
                    'outlier',      'method',       [],         ...
                    'outlier',      'types',        'none',     ...
                    'outlier',      'savelog',      []);
                
            case 'TDAYS'
                spec = x13spec(spec, ...
                    'regression',   'aictest',      'td',       ...
                    'regression',   'save',         'td',       ...
                    'regression',   'print',        'ats');
                
            case 'FORCETDAYS'
                spec = x13spec(spec, ...
                    'regression',   'variables',    'td',       ...
                    'regression',   'save',         'td');
                spec = spec.RemoveRequests('regression','aictest','td');
                
            case 'EASTER'
                spec = x13spec(spec, ...
                    'regression',   'aictest',      'easter',   ...
                    'regression',   'save',         'hol',      ...
                    'regression',   'print',        'ats');
                
            case 'FCT'      % compute forecast
                spec = x13spec(spec, ...
                    'forecast',     'maxlead',      36,     ...
                    'forecast',     'maxback',      36,     ...
                    'forecast',     'save',         '(bct fct)');

            case 'FCT50'    % compute forecast with 50% confidence bands
                spec = makespec(spec, 'FCT', ...
                    'forecast',     'probability',  0.5);

            case 'X11'      % compute trend-cycle and seasonality using X11
                spec = x13spec(spec, ...
                    'seats', [], [], ...    % remove SEATS
                    'x11',   'print',       '(d8f d9a f2 f3 rsf)', ...
                    'x11',   'save',        [], ...    % remove existing x11-save
                    'x11',   'save',        '(b1 d8 d10 d11 d12 d13 d16 e2 e3)');
%                    'x11',   'appendfcst',  'yes', ...

            case 'FULLX11'  % more complete selection of saved variables
                spec = makespec(spec, 'X11', ...
                    'x11',   'save',   ...
                        ['(ars bcf chl c20 d4 d8 d10 d11 d12 d13 d16 d18 ', ...
                         'd8b d9 e1 e2 e3 e4 e5 e6 e7 e8 e11 e18 f1 ', ...
                         'fad fsd ira sac tac tad tal paf pe8 pir pe5 ', ...
                         'pe6 psf pe7)']);

            case 'TOTALX11' % all available variables of X11 are saved
                all_x13as_exe = ['ars b10 b11 b13 b17 b19 b2 b20 b3 b5 b6 ', ...
                         'b7 b8 bcf c1 c10 c11 c13 c17 c19 c2 c20 c4 ', ...
                         'c5 c6 c7 c9 chl d1 d10 d11 d12 d13 d16 d18 ', ...
                         'd2 d4 d5 d6 d7 d8 d8b d9 e1 e2 e3 e4 e5 e6 ', ...
                         'e7 e8 e11 e18 f1 fad fsd ira sac tac tad ', ...
                         'tal paf pe8 pir pe5 pe6 psf pe7'];
                all_x11_m = ['b1 b4 b4a b4b b4c b4d b4e b4f ', ...
                         'b4g b5a b5b b7a b7b b7c b7d b9 ', ...
                         'b9a b9b b9c b9d b9e b9f b9g c5a ', ...
                         'c5b c7a c7b c7c c7d d5a d5b d7a ', ...
                         'd7b d7c d7d'];
                spec = makespec(spec, 'X11', ...
                    'x11', 'save', ['(',all_x13as_exe,all_x11_m,')']);

            case 'SEATS'    % compute trend-cycle and seasonality using SEATS
                spec = x13spec(spec, ...
                    'x11',   [],      [], ...   % remove X11
                    'seats', 'out',   2, ...
                    'seats', 'save',  [], ...   % remove existing seats-save
                    'seats', 'save',  '(s10 s16 s11 s12 s13)');
%                    'seats', 'print', 'smd xmd ssg', ...

            case 'FULLSEATS'    % all available variables of SEATS are saved
                spec = makespec(spec, 'SEATS', ...
                    'seats', 'out',   0, ...
                    'seats', 'save',  ...
                        ['(afd cyc dsa dtr ltt ofd s10 s11 s12 s13 ', ...
                        's14 s16 s18 sec sfd ssm sta stc tfd yfd ' ...
                        'mdc fac faf ftc ftf pic pis pit pia gac gaf ', ...
                        'gtc gtf tac ttc wkf psa psi psc pss)']);
                    
            case 'CUSTOM'
                spec = makespec(spec, 'custom','save','(tr sa sf si ir)');
                    
            case 'SLIDINGSPANS'
                spec = x13spec(spec, ...
                    'slidingspans','save','(chs sfs ycs)', ...
                    'slidingspans','print','hdr');
                    
            case 'FULLSLIDINGSPANS'
                spec = makespec(spec, 'SLIDINGSPANS', ...
                    'slidingspans','save','(cis ais sis yis tds)');
                    
            case 'HISTORY'
                spec = x13spec(spec, ...
                    'history','save' ,'(iae iar rot sae sar smh)', ...
                    'history','estimates','sadj', ...  % fix of bug in Build 60
                    'history','print','hdr');
                    
            case 'FULLHISTORY'
                spec = makespec(spec, 'HISTORY', ...
                    'history','estimates',['(sadj sadjchng trend ', ...
                        'trendchng seasonal aic fcst arma)'], ...
                    'history','save',['(che chr fce fch lkh sfe sfh sfr ', ...
                        'tce tcr tre trr)']);
            
            case 'ACF'              % subset of DIAGNOSTIC
                spec = makespec(spec, 'ESTIMATE', ...
                    'check',    'save',     '(acf ac2 pcf)',    ...
                    'check',    'print',    '(hst nrm)');
                
            case 'SPECTRUM'         % subset of DIAGNOSTIC
                spec = x13spec(spec, ...
                    'spectrum', 'save' , ['(sp0 sp1 sp2 s1s s2s ', ...
                        'spr is0 is1 is2 ', ...
                        'st0 st1 st2 t1s t2s str it0 it1 it2)'], ...
                    'spectrum', 'print',   'tpk');
                % ser ter
                    
            case 'DIAGNOSTIC'       % ACF and SPECTRUM
                spec = makespec(spec,'ACF','SPECTRUM');
                
            case 'FIXEDSEASONAL'    % compute fixed seasonal pattern
                                    % with simple method
                spec = x13spec(spec,'fixedseas','save','(tr sa sf ir si)');

            case 'CAMPLET'          % compute seasonal pattern using CAMPLET
                                    % algorithm
                spec = x13spec(spec,'camplet','save', ...
                    '(sa sf fcs fer rer bar)');
                

            case 'FULLCAMPLET'      % compute seasonal pattern using CAMPLET
                                    % algorithm, save all variables
                spec = x13spec(spec,'camplet','save', ...
                    '(sa sf fcs fer rer bar gra g nol cca ca m lle t)');

        end
        
    end

end
