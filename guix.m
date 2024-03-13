% GUIX is a graphical user interface that allows you to easily create a
% specification for a seasonal adjustment, perform the computations, and
% view the results in the GUI. guix supports only single time series
% (x13series), not composites (x13composite).
%
% Usage:
%   guix
%   guix('style')
%   guix 'style' 
%   guix('variable')
%   guix('variable','style')
%   guix variable
%   guix variable 'style'
%   h = guix(['style'],['variable'])
%
% Inputs and Outputs:
%   'style'     Can be 'normal', 'modal', or 'docked' (or 'n', 'm', or
%               'd', for short), indicating the WindowStyle of the GUI.
%               Default is 'normal'.
%   variable    A x13series variable in the main workspace.
%   'variable'  The name of a x13series variable in the main workspace, as
%               string.
%   h           A struct containing handles to the GUI and to its
%               components.
%
% Usage of this GUI should be self-explanatory (if you are familiar with
% the outputs that X-13ARIMA-SEATS generates). X-13 requires a vector of
% observation dates and the corresponding data. Dates can be specified by
% entering the start date and the period (e.g., monthly). Alternatively, it
% is also possible to use a vector of datenums. The data that are to be
% worked on are given by a vector of floats. The data vector and, if used,
% dates vector, must be  present in the calling workspace. You can also
% import an x13series object existing in the calling workspace into guix
% with the 'Import' button.
% 
% The 'Run' button performs the computations. You can export the resulting
% x13series object to the calling workspace with the 'Export' button.
%
% With the 'Text/Chart' button you can switch between viewing tables and
% text items on the one hand, and plots on the other.
%
% The 'Copy' button copies the current output window (text or chart) to
% Windows' clipboard. You can then paste it into some other program.
%
% NOTE: This GUI was programmatically created, without GUIDE. Other than
% the code generated with GUIDE, it uses nested functions, which has the
% advantage that all variables that are defined in the main function are
% also in the scope of the nested functions. Moreover, the code is more
% transparent.
%
% NOTE: This file is part of the X-13 toolbox.
% The toolbox consists of the following base programs, guix, x13, makespec,
% x13spec, x13series, x13composite, x13series.plot,x13composite.plot,
% x13series.seasbreaks, x13composite.seasbreaks, fixedseas, camplet, spr,
% InstallMissingCensusProgram, makedates, yqmd, TakeDayOff, EasterDate.
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
% 2021-12-29    Version 1.53    Added 'x13as_ascii.exe' and
%                               'x13as_html.exe' as program names
%                               associated with the regular x13as
%                               adjustment program.
% 2021-07-14    Version 1.52    Bug fixed in plot definition for 'forecast'
%                               group.
% 2021-04-26    Version 1.50    Much better support for custom seasonal
%                               adjustment algorithms. Adaptation to the
%                               various changes in x13series that were
%                               implemented in Version 1.50 of the toolbox.
% 2021-04-14    Version 1.41    Some bug fixes. Some adaptation for the new
%                               version of x-11 (this isn't finished yet).
% 2020-03-17    Version 1.36    Support for makedates. Some bug fixes.
% 2019-10-24    Version 1.34    Better support for non-standard items in
%                               guix.
% 2018-09-29    Version 1.33    Support for 'x-11' and 'x-12' option. Some
%                               basic support for x13collections. Slightly
%                               increased initial size of GUI.
% 2017-03-26    Version 1.32    Support for datetime class variable for the
%                               dates.
% 2017-01-09    Version 1.30    First release featuring camplet.
% 2016-08-23    Version 1.18.2  Added ability to provide a variable that is to
%                               be loaded from the command line.
% 2016-08-22    Version 1.18.1  Using 'specminus' instead of 'specdiff' now.
%                               'specdiff' is not part of the toolbox.
% 2016-08-19    Version 1.18    Adaptations related to x13series support of
%                               user-defined variables.
% 2016-08-18    Version 1.17.7  Take care of incompatinility of -r with -w
%                               and -n.
% 2016-08-16    Version 1.17.6  Added flag support.
% 2016-07-30    Version 1.17.5  Better support for composite series (not
%                               for x13composite objects; they are still
%                               not supported). Bug fix in reading value of
%                               'x11-mode'. Added 'no model' option. Bug
%                               fix in working with 'additional
%                               specifications' field that ontains only
%                               spaces or empty lines. 
% 2016-07-27    Version 1.17.4  Added possibility to import an x13series
%                               object from the base workspace.
% 2016-07-17    Version 1.17.3  Added buttons to open documentation files.
%                               Fixed problem of sliders with non-monthly
%                               data.
% 2016-07-13    Version 1.17.2  Further improvements of guix. Separating
%                               lines in menu, plots of arbitrary
%                               variables, sliders to select the date-range
%                               that is plotted.
% 2016-07-10    Version 1.17.1  Improved guix. Bug fix in x13series
%                               relating to fixedseas.
% 2016-07-06    Version 1.17    First release featuring guix.

%#ok<*TRYNC>    % suppress 'try needs a catch' complaint in this file
%#ok<*AGROW>    % suppress 'argument grows' complaint in this file

function handles = guix(varargin)

% *** parse parameter **********************************************************
    style = [];
    loadvariable = [];
    while ~isempty(varargin)
        try
            test = isa(evalin('base',varargin{1}),'x13series') || ...
                   isa(evalin('base',varargin{1}),'x13composite');
        catch
            test = false;
        end
        if test
            if isempty(loadvariable)
                loadvariable = varargin(1);
            else
                warning(['I can only load one x13series object. Variable ''%s'' ', ...
                    'has already been requested. There is no space for also ', ...
                    'loading variable ''%s''.'], loadvariable{1}, varargin{1});
           end
        else
            if ~ischar(varargin{1})
                err = MException('X13TBX:guix:illarg','Arguments must be strings.');
                throw(err);
            else
                try
                    style = validatestring(varargin{1},{'normal','modal','docked'});
                catch e
                    err = MException('X13TBX:guix:illarg', ['Argument ''%s'' ', ...
                        'is neither an x13series object nor a style. Cannot ', ...
                        'proceed.'], varargin{1});
                    throw(err);
                end
            end
        end
        varargin(1) = [];
    end
    
% *** initialize some variables ************************************************
% (these variables are 'global' within this program)

    tbxfolder = mfilename('fullpath');              % get directory of the toolbox
    [tbxfolder,~,~] = fileparts(tbxfolder);         % remove the 'guix' name
    specfolder = fullfile(tbxfolder,'@x13spec');
%    exefolder  = fullfile(tbxfolder,'exe');         % not used
    docfolder  = fullfile(tbxfolder,'doc');
%    seasfolder = fullfile(tbxfolder,'seas');        % not used

    cmdspec   = '';                     % args of makespec command line
    cmdlinespec   = '';                 % makespec command line
    cmdx13    = '';                     % call x13 command line
    cmdafter  = '';                     % commands to be run after x13
    flagArgs  = cell(0);                % flags for x13 command line
    RunPossible = 'on';                 % Run button enabled
    x = x13series;                      % x13series object
    
    itemTextMenu = 'command line';      % item chosen in text menu
    itemPlotMenu = 'data';              % item chosen in plot menu
    % separator menu line
    % hline = {'--------------------------------------------'};
    hline = {'<html><hr width="700px">'};
    
    vecFirstDate = NaN; vecLastDate = NaN;  % date range of list of variables
    vecFromDate = NaN;  vecToDate = NaN;    % date range to plot
    
    doKeepPlotRange = false;            % If true, vecFromDate and vecToDate is
                                        % used to compute position of sliders.
                                        % If false, position of sliders is used
                                        % to compute vecFromDate and vecToDate.

% *** create but hide the GUI as it is being constructed ***********************

    % sizes of objects
    s = get(0,'ScreenSize');            % size of monitor
    vsizeGUI = max(750,min(0.8*s(4),900));	% initial size of GUI
    hsizeGUI = max(860,min(0.9*s(3),1255));
    % spaces between objects
    vmargin = 20;   hmargin = 20;       % vert and horiz margins
    headvspace = 8;                     % vert space between menu buttons and
                                        % rest
    vspace = 6;     hspace = 10;        % vert and horiz spacing
    xspace = 8;                         % extra vertical space
    sspace = 5;                         % small horizontal space
    % widths of columns
    width0 = 80; width = 87;            % first and regular columns
    % horizontal positions
    hpos0 = hmargin;                    % left-most column
    hpos1 = hpos0 + width0 + hspace;    % column 1
    hpos2 = hpos1 + width  + hspace;    % column 2
    hpos3 = hpos2 + width  + hspace;    % column 3
    widthdouble = hpos3 - hpos1 - hspace; 
    widthcol123 = 3*width + 2*hspace;   % width col 1 - col 3
    widthcol0123 = widthcol123 + width0 + hspace;
    hposOut = hpos3 + width  + 2*hspace;  % right part of GUI
    hposOut = hmargin;
    
    % size of particular objects
    vpb = 19;       hpb = 54;           % size of pushbuttons
    vpu = 18;                           % vert size of popup menu
    ved = 18;                           % vert size of editable text
    vtx = 18;                           % vert size of fixed text
    vti = 18;       hti = widthcol0123; % size of titles
    vsl = 18;                           % vert size of sliders
    bup = 3;    % move button row on top a little up
    hflag = 42;                         % width of flag check boxes
    % margins for axes
    axLmargin = 40; axRmargin = 5; axTmargin = 40; axBmargin = 25;

    hGUI = figure(...
        'Visible'         , 'off', ...
        'Units'           , 'pixels', ...
        'WindowStyle'     , 'normal', ...
        'Position'        , [0,0,hsizeGUI,vsizeGUI], ...
        'Name'            ,'GUIX : seasonal adjustment with a mouse click', ...
        'MenuBar'         , 'none', ...
        'NumberTitle'     , 'off', ...
        'Resize'          , 'on', ...
        'Color'           , get(0,'defaultUicontrolBackgroundColor'), ...
        'ResizeFcn'       , {@resizeGUI} ...
        );
    
    if ~isempty(style)
        try
            set(hGUI,'WindowStyle',style);
        catch e
            id = e.identifier;
            msg = ['clickspec: argument must be one of the following: ',...
                '''normal'', ''modal'', or ''docked''.\n', e.message];
            error(id,msg);
        end
    end
    
%% *** populate the GUI with objects **************************************
% Note that at this point the positions and sizes of the objects are not
% specified. They will be set later in 'resizeGUI'.

    hpbDocX13 = uicontrol(...
        'Style'          ,'pushbutton',...
        'String'         ,'Doc X-13',...
        'TooltipString'  ,'View X-13ARIMA-SEATS documentation.',...
        'Callback'       ,@pushOpenDoc);
    hpbDocTBX = uicontrol(...
        'Style'          ,'pushbutton',...
        'String'         ,'Doc TBX',...
        'TooltipString'  ,'View Documentation of Toolbox.',...
        'Callback'       ,@pushOpenDoc);
    
    htxtVARIABLE = uicontrol(...
        'Style'          ,'text',...
        'FontWeight'     ,'bold',...
        'HorizontalAlignment','left',...
        'String'         ,'VARIABLE');
    htxtX13 = uicontrol(...
        'Style'          ,'text',...
        'HorizontalAlignment','right',...
        'String'         ,'x13 object');
    hedX13Name = uicontrol(...
        'Style'          ,'edit',...
        'String'         ,'',...
        'TooltipString'  ,'Name of x13series variable',...
        'Callback'       ,@SpecChanged);
    hpbLoad = uicontrol(...
        'Style'          ,'pushbutton',...
        'String'         ,'Import',...
        'TooltipString'  ,'Load x13series from main workspace',...
        'Enable'         ,'off',...
        'Callback'       ,@pushLoadX13);
    hpbSave = uicontrol(...
        'Style'          ,'pushbutton',...
        'String'         ,'Export',...
        'TooltipString'  ,'Export x13series to main workspace',...
        'Enable'         ,'off',...
        'Callback'       ,@pushSaveX13);

    htxtDATES = uicontrol(...
        'Style'          ,'text',...
        'FontWeight'     ,'bold',...
        'HorizontalAlignment','left',...
        'String'         ,'DATES');
    hedDates = uicontrol(...
        'Style'          ,'edit',...
        'FontName'       ,'Courier',...
        'String'         ,'',...
        'TooltipString'  ,'Specify the variable that contains the dates.',...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);
    hchkDatesVector = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,' use vector',...
        'TooltipString'  ,'Use existing dates vector (checked) or make one on the spot (unchecked).',...
        'Callback'       ,@SpecChanged);
    htxtMakeDates = uicontrol(...
        'Style'          ,'text',...
        'HorizontalAlignment','right',...
        'String'         ,'Y M D mult');
    hedStartYear = uicontrol(...
        'Style'          ,'edit',...
        'FontName'       ,'Courier',...
        'String'         ,'',...
        'TooltipString'  ,'Year the data start.',...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);
    hedStartMonth = uicontrol(...
        'Style'          ,'edit',...
        'FontName'       ,'Courier',...
        'String'         ,'',...
        'TooltipString'  ,'Month the data start.',...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);
    hedStartDay = uicontrol(...
        'Style'          ,'edit',...
        'FontName'       ,'Courier',...
        'String'         ,'',...
        'TooltipString'  ,'Day the data start.',...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);
    hedDateMult = uicontrol(...
        'Style'          ,'edit',...
        'FontName'       ,'Courier',...
        'String'         ,'',...
        'TooltipString'  ,'Multiple of the frequency.',...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);
    hpuFreq = uicontrol(...
        'Style'          ,'popupmenu',...
        'String'         ,{'year','semester','trimester','quarter', ...
                           'month','week','weekday','day'},...
        'TooltipString'  ,'Select the type of the data.',...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);
    
    htxtDATA = uicontrol(...
        'Style'          ,'text',...
        'FontWeight'     ,'bold',...
        'HorizontalAlignment','left',...
        'String'         ,'DATA VECTOR');
    hedData = uicontrol(...
        'Style'          ,'edit',...
        'FontName'       ,'Courier',...
        'String'         ,'',...
        'TooltipString'  ,'Specify the variable that contains the data.',...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);
    hpuType = uicontrol(...
        'Style'          ,'popupmenu',...
        'String'         ,{'unspecified','stock','flow'},...
        'TooltipString'  ,'Select the type of the data.',...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);
    htxtTitle = uicontrol(...
        'Style'          ,'text',...
        'HorizontalAlignment','right',...
        'String'         ,'title');
    hedTitle = uicontrol(...
        'Style'          ,'edit',...
        'String'         ,'',...
        'FontName'       ,'Courier',...
        'HorizontalAlignment','left',...
        'TooltipString'  ,['Specify the name of the variable as ',...
                           'contained in the X-13 output.'],...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);
    
    htxtFCT = uicontrol(...
        'Style'          ,'text',...
        'FontWeight'     ,'bold',...
        'HorizontalAlignment','left',...
        'String'         ,'FORECAST / BACKCAST');
    htxtHorizon = uicontrol(...
        'Style'          ,'text',...
        'HorizontalAlignment','right',...
        'String'         ,'horizon');
    hedHorizon = uicontrol(...
        'Style'          ,'edit',...
        'FontName'       ,'Courier',...
        'String'         ,'0',...
        'TooltipString'  ,['Specify the horizon of the forecast. ', ...
                           '(0 means that no forecast is computed.)'],...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);
    htxtConfidence = uicontrol(...
        'Style'          ,'text',...
        'HorizontalAlignment','right',...
        'String'         ,'conf. band');
    hedConfidence = uicontrol(...
        'Style'          ,'edit',...
        'FontName'       ,'Courier',...
        'String'         ,'0.95',...
        'TooltipString'  ,['Specify the probability covered by the ', ...
            'confidence band around the the forecast (greater than ', ...
            '0.0, less than 1.0.'],...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);

    htxtREGR = uicontrol(...
        'Style'          ,'text',...
        'FontWeight'     ,'bold',...
        'HorizontalAlignment','left',...
        'String'         ,'REGRESSION and OUTLIERS');
    htxtRegressors = uicontrol(...
        'Style'          ,'text',...
        'HorizontalAlignment','right',...
        'String'         ,'regressors');
    hchkConst = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,' constant',...
        'TooltipString'  ,'Add a constant to the ARIMA model.',...
        'Callback'       ,@SpecChanged);
    hchkTD = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,' trading days',...
        'TooltipString'  ,'Automatic trading day/leap year regressors.',...
        'Callback'       ,@SpecChanged);
    hchkEaster = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,' Easter',...
        'TooltipString'  ,'Check for Easter regressor.',...
        'Callback'       ,@SpecChanged);
    htxtAutoOutliers = uicontrol(...
        'Style'          ,'text',...
        'HorizontalAlignment','right',...
        'String'         ,'auto outliers');
    hchkAO = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,' additive',...
        'TooltipString'  ,'Add auto-detected additive (''one-time'') outliers.',...
        'Callback'       ,@SpecChanged);
    hchkLS = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,' level shifts',...
        'TooltipString'  ,'Add auto-detected permanent level shifts.',...
        'Callback'       ,@SpecChanged);
    hchkTC = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,' trans. shifts',...
        'TooltipString'  ,'Add auto-detected transitory shifts.',...
        'Callback'       ,@SpecChanged);
    htxtMoreRegressors = uicontrol(...
        'Style'          ,'text',...
        'HorizontalAlignment','right',...
        'String'         ,'more regressors');
    hedMoreRegressors = uicontrol(...
        'Style'          ,'edit',...
        'String'         ,'',...
        'HorizontalAlignment','left',...
        'TooltipString'  ,'Specify further regressors.',...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);

    htxtSARIMA = uicontrol(...
        'Style'          ,'text',...
        'FontWeight'     ,'bold',...
        'HorizontalAlignment','left',...
        'String'         ,'SARIMA-Model');
    htxtTransform = uicontrol(...
        'Style'          ,'text',...
        'HorizontalAlignment','right',...
        'String'         ,'transformation');
    hpuTransform = uicontrol(...
        'Style'          ,'popupmenu',...
        'String'         ,{'none specified','auto','no transformation', ...
            'logarithm','square root','inverse','logistic','power'},...
        'TooltipString'  ,'Select how data are transformed before working on them.',...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);
    hedPower = uicontrol(...
        'Style'          ,'edit',...
        'FontName'       ,'Courier',...
        'String'         ,'1.0',...
        'TooltipString'  ,'Specify the exponent of the power transformation.',...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);
    htxtSelectModel = uicontrol(...
        'Style'          ,'text',...
        'HorizontalAlignment','right',...
        'String'         ,'select model');
    hgrSelectModel = uibuttongroup(...
        'BorderType'     ,'none',...
        'SelectionChangedFcn',@SpecChanged);
    hrbPickmdl = uicontrol(hgrSelectModel, ...
        'Style'          ,'radiobutton',...
        'String'         ,'X-11 PickMdl',...
        'TooltipString'  ,'Use X-11 procedure to pick a model.');
    modelfiles = dir(fullfile(specfolder,'*.pml'));
    modelfiles = {'(use default)',modelfiles.name};
    hpuPickmdlFile = uicontrol(...
        'Style'          ,'popupmenu',...
        'String'         ,modelfiles,...
        'TooltipString'  ,'Select the model definition file used by PICKMDL.',...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);
    hpuFirstBest = uicontrol(...
        'Style'          ,'popupmenu',...
        'String'         ,{'use best','use first'},...
        'TooltipString'  ,['Test all models and pick the best, or ', ...
                           'use the first acceptable model.'],...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);
    hrbTramo = uicontrol(hgrSelectModel, ...
        'Style'          ,'radiobutton',...
        'String'         ,'TRAMO',...
        'TooltipString'  ,'Use TRAMO procedure to select a model.');
    hchkCheckMu = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,' check mu',...
        'TooltipString'  ,'Check if constant is significant.',...
        'Callback'       ,@SpecChanged);
    hchkAllowMixed = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,' allow mixed',...
        'TooltipString'  ,'Allow TRAMO to select a mixed model.',...
        'Callback'       ,@SpecChanged);
    hrbManualModel = uicontrol(hgrSelectModel, ...
        'Style'          ,'radiobutton',...
        'String'         ,'manual',...
        'TooltipString'  ,'Specify model manually.');
    hedArima = uicontrol(...
        'Style'          ,'edit',...
        'String'         ,'',...
        'FontName'       ,'Courier',...
        'TooltipString'  ,'(S)ARIMA specification.',...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);
    hrbNoModel = uicontrol(hgrSelectModel, ...
        'Style'          ,'radiobutton',...
        'String'         ,'no model',...
        'TooltipString'  ,'Do not estimate a regARIMA model.');
    
    htxtPRINTTABLE = uicontrol(...
        'Style'          ,'text',...
        'HorizontalAlignment','left',...
        'String'         ,'print');
    htxtSEASADJ = uicontrol(...
        'Style'          ,'text',...
        'FontWeight'     ,'bold',...
        'HorizontalAlignment','left',...
        'String'         ,'SEASONAL ADJUSTMENT');
    htxtSeasType = uicontrol(...
        'Style'          ,'text',...
        'HorizontalAlignment','right',...
        'String'         ,'adjustment type');
    hpuSeasType = uicontrol(...
        'Style'          ,'popupmenu',...
        'String'         ,{'none','X-11','SEATS'},...
        'TooltipString'  ,'Type of seasonal adjustment.',...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);
    htxtMode = uicontrol(...
        'Style'          ,'text',...
        'HorizontalAlignment','right',...
        'String'         ,'adjustment mode');
    hpuMode = uicontrol(...
        'Style'          ,'popupmenu',...
        'String'         ,{'unspecified','additive','multiplicative', ...
                           'log-additive','pseudo-additive'},...
        'TooltipString'  ,'Mode of seasonal adjustment.',...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);
    
    htxtDIAG = uicontrol(...
        'Style'          ,'text',...
        'FontWeight'     ,'bold',...
        'HorizontalAlignment','left',...
        'String'         ,'DIAGNOSTICS');
    hchkACF = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,' ACF',...
        'TooltipString'  ,'Compute auto-correlation function.',...
        'Callback'       ,@SpecChanged);
    hchkSpectrum = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,' spectrum',...
        'TooltipString'  ,'Compute a few spectra.',...
        'Callback'       ,@SpecChanged);
    hchkMSpectrum = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,' Matlab spectrum',...
        'TooltipString'  ,'Compute spectra with SIgnal Extraction Toolbox.',...
        'Callback'       ,@SpecChanged);
    hchkHistory = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,' history',...
        'TooltipString'  ,'Compute revision history.',...
        'Callback'       ,@SpecChanged);
    hchkSlidingSpans = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,' sliding spans',...
        'TooltipString'  ,'Compute sliding span analysis.',...
        'Callback'       ,@SpecChanged);
    
    htxtMORESPECS = uicontrol(...
        'Style'          ,'text',...
        'FontWeight'     ,'bold',...
        'HorizontalAlignment','left',...
        'String'         ,'ADDITIONAL SPECIFICATIONS');
    hedMoreSpecs = uicontrol(...
        'Style'          ,'edit',...
        'Min'            ,0,...
        'Max'            ,2,...                     % multi-line
        'FontName'       ,'Courier',...
        'String'         ,'',...
        'HorizontalAlignment','left',...
        'TooltipString'  ,['Space for additional specifications ', ...
                           '(passed on to makespec).'],...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);

    hpbRun = uicontrol(...
        'Style'          ,'pushbutton',...
        'String'         ,'Run',...
        'Enable'         ,'off',...
        'TooltipString'  ,'Run the commands.',...
        'Callback'       ,@pushRun);
    hpuPrintTable = uicontrol(...
        'Style'          ,'popupmenu',...
        'String'         ,{'requested','none','brief','default', ...
                           'all tables','all'},...
        'Enable'         ,'on',...
        'TooltipString'  ,'Select list of tables that are generated.',...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);
    hchkW = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,'wide',...	% '-w'
        'TooltipString'  ,['Use wide format (132 chars) for tables ', ...
                           '(''-w'' flag).'],...
        'Value'          ,false,...
        'Callback'       ,@SpecChanged);    % @SetW);
    hchkS = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,'diag',...	% '-s'
        'TooltipString'  ,'Make diagnostics files (''-s'' flag).',...
        'Value'          ,false,...
        'Callback'       ,@SpecChanged);
    hchkQ = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,'quiet',...
        'TooltipString'  ,'Suppress warnings to console.',...
        'Value'          ,true,...
        'Callback'       ,@SpecChanged);
    hchkNF = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,'no flags',...
        'TooltipString'  ,'Remove all flags.',...
        'Value'          ,false,...
        'Callback'       ,@SpecChanged);
    hpuXtype = uicontrol(...
        'Style'          ,'popupmenu',...
        'String'         ,{'X-13','X-12','X-11','Method I','CAMPLET','FIXED','custom ...'},...
        'Enable'         ,'on',...
        'TooltipString'  ,'Select version of seasonal adjustment program.',...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);
    hedProg = uicontrol(...
        'Style'          ,'edit',...
        'String'         ,'',...
        'Enable'         ,'off',...              % content not selectable
        'FontName'       ,'Courier',...
        'BackgroundColor','white',...
        'HorizontalAlignment','left',...
        'String'         ,'x13as.exe', ...
        'Callback'       ,@SpecChanged);

    htglOut = uicontrol(...
        'Style'          ,'togglebutton',...
        'String'         ,'Text / Chart',...
        'Enable'         ,'off',...
        'TooltipString'  ,'Switch between text and graph items.',...
        'Callback'       ,@TogglePressed);
    hpuOut = uicontrol(...
        'Style'          ,'popupmenu',...
        'String'         ,{'command line'},...
        'Enable'         ,'off',...
        'TooltipString'  ,'Select type of output.',...
        'BackgroundColor','white',...
        'Callback'       ,@MenuItemChanged);
    hpbCopy = uicontrol(...
        'Style'          ,'pushbutton',...
        'String'         ,'Copy',...
        'TooltipString'  ,'Copy command line or output to clipboard.',...
        'Callback'       ,@pushCopy);
    htxtTimeOfRun = uicontrol(...
        'Style'          ,'text',...
        'FontName'       ,'Courier',...
        'HorizontalAlignment','right',...
        'String'         ,'');
    hedOut = uicontrol(...
        'Style'          ,'edit',...
        'Enable'         ,'inactive',...              % content not selectable
        'Min'            ,0,...
        'Max'            ,2,...                       % multi-line
        'FontName'       ,'Courier',...
        'BackgroundColor','white',...
        'HorizontalAlignment','left',...
        'String'         ,'');
    set(hedOut,'FontSize',get(hedOut,'FontSize')+1);  % make font a little larger
    haxOut = axes(...
        'Visible'        ,'off');
    hslFrom = uicontrol(...
        'Style'          ,'slider',...
        'Min'            ,0,...
        'Max'            ,240,...
        'SliderStep'     ,[1/36,12/36],...
        'Value'          ,0,...
        'Visible'        ,'off',...
        'TooltipString'  ,'Select lower boundary of date-range that is shown in the graph.',...
        'Callback'       ,@SliderMovement);
    hslTo = uicontrol(...
        'Style'          ,'slider',...
        'Min'            ,-240,...
        'Max'            ,0,...
        'SliderStep'     ,[1/36,12/36],...
        'Value'          ,0,...
        'Visible'        ,'off',...
        'TooltipString'  ,'Select upper boundary of date-range that is shown in the graph.',...
        'Callback'       ,@SliderMovement);
    
%% *** prepare output arg (if requested) **********************************

    if nargout > 0
        % collect all handles
        handles = struct( ...
            'GUI',              hGUI, ...
            'pbDocX13',         hpbDocX13, ...
            'pbDocTBX',         hpbDocTBX, ...
            'txtVARIABLE',      htxtVARIABLE, ...
            'txtX13',           htxtX13, ...
            'edX13Name',        hedX13Name, ...
            'pbLoad',           hpbLoad, ...
            'pbSave',           hpbSave, ...
            'txtDATES',         htxtDATES, ...
            'edDates',          hedDates, ...
            'chkDatesVector',   hchkDatesVector, ...
            'txtMakeDates',     htxtMakeDates, ...
            'edStartYear',      hedStartYear, ...
            'edStartMonth',     hedStartMonth, ...
            'edStartDay',       hedStartDay, ...
            'edDateMult',       hedDateMult, ...
            'puFreq',           hpuFreq, ...
            'txtDATA',          htxtDATA, ...
            'edData',           hedData, ...
            'puType',           hpuType, ...
            'txtTitle',         htxtTitle, ...
            'edTitle',          hedTitle, ...
            'txtFCT',           htxtFCT, ...
            'txtHorizon',       htxtHorizon, ...
            'edHorizon',        hedHorizon, ...
            'txtConfidence',    htxtConfidence, ...
            'edConfidence',     hedConfidence, ...
            'txtREGR',          htxtREGR, ...
            'txtRegressors',    htxtRegressors, ...
            'chkConst',         hchkConst, ...
            'chkTD',            hchkTD, ...
            'chkEaster',        hchkEaster, ...
            'txtAutoOutliers',  htxtAutoOutliers, ...
            'chkAO',            hchkAO, ...
            'chkLS',            hchkLS, ...
            'chkTC',            hchkTC, ...
            'txtMoreRegressors', htxtMoreRegressors, ...
            'edMoreRegressors', hedMoreRegressors, ...
            'txtSARIMA',        htxtSARIMA, ...
            'txtTransform',     htxtTransform, ...
            'puTransform',      hpuTransform, ...
            'edPower',          hedPower, ...
            'txtSelectModel',   htxtSelectModel, ...
            'grSelectModel',    hgrSelectModel, ...
            'rbPickmdl',        hrbPickmdl, ...
            'puPickmdlFile',    hpuPickmdlFile, ...
            'puFirstBest',      hpuFirstBest, ...
            'rbTramo',          hrbTramo, ...
            'chkCheckMu',       hchkCheckMu, ...
            'chkAllowMixed',    hchkAllowMixed, ...
            'rbManualModel',    hrbManualModel, ...
            'edArima',          hedArima, ...
            'rbNoModel',        hrbNoModel, ...
            'txtPRINTTABLE',    htxtPRINTTABLE, ...
            'txtSEASADJ',       htxtSEASADJ, ...
            'txtSeasType',      htxtSeasType, ...
            'puSeasType',       hpuSeasType, ...
            'txtMode',          htxtMode, ...
            'puMode',           hpuMode, ...
            'txtDIAG',          htxtDIAG, ...
            'chkACF',           hchkACF, ...
            'chkSpectrum',      hchkSpectrum, ...
            'chkMSpectrum',     hchkMSpectrum, ...
            'chkHistory',       hchkHistory, ...
            'chkSlidingSpans',  hchkSlidingSpans, ...
            'txtMORESPECS',     htxtMORESPECS, ...
            'edMoreSpecs',      hedMoreSpecs, ...
            'pbRun',            hpbRun, ...
            'puPrintTable',     hpuPrintTable, ...
            'chkW',             hchkW, ...
            'chkS',             hchkS, ...
            'chkQ',             hchkQ, ...
            'chkNF',            hchkNF, ...
            'puXtype',          hpuXtype, ...
            'tglOut',           htglOut, ...
            'puOut',            hpuOut, ...
            'pbCopy',           hpbCopy, ...
            'txtTimeOfRun',     htxtTimeOfRun, ...
            'edOut',            hedOut, ...
            'axOut',            haxOut, ...
            'slFrom',           hslFrom, ...
            'slTo',             hslTo);
    end

%% *** finalize appearance of GUI *****************************************

    % no element is adjusted automatically on resize ('units' are
    % not 'normalized')
    AllHandles = [hGUI, hpbDocX13, hpbDocTBX, htxtVARIABLE, htxtX13, ... 
        hedX13Name, hpbLoad, hpbSave, htxtDATES, hedDates, ...
        hchkDatesVector, htxtMakeDates, hedStartYear, hedStartMonth, ...
        hedStartDay, hedDateMult, hpuFreq, htxtDATA, hedData, hpuType, ...
        htxtTitle, hedTitle, htxtFCT, htxtHorizon, hedHorizon, ...
        htxtConfidence, hedConfidence, htxtREGR, htxtRegressors, ...
        hchkConst, hchkTD, hchkEaster, htxtAutoOutliers, hchkAO, ...
        hchkLS, hchkTC, htxtMoreRegressors, hedMoreRegressors, ...
        htxtSARIMA, htxtTransform, hpuTransform, hedPower, ...
        htxtSelectModel, hgrSelectModel, hrbPickmdl, hpuPickmdlFile, ...
        hpuFirstBest, hrbTramo, hchkCheckMu, hchkAllowMixed, ...
        hrbManualModel, hedArima, hrbNoModel, htxtPRINTTABLE, ...
        htxtSEASADJ, htxtSeasType, hpuSeasType, htxtMode, hpuMode, ...
        htxtDIAG, hchkACF, hchkSpectrum, hchkMSpectrum, hchkHistory, ...
        hchkSlidingSpans, htxtMORESPECS, hedMoreSpecs, hpbRun, ...
        hpuPrintTable, hchkW, hchkS, hchkQ, hchkNF, hpuXtype, htglOut, ...
        hpuOut, hpbCopy, htxtTimeOfRun, hedOut, haxOut, hslFrom, hslTo]; 
    set(AllHandles,'Units','pixels');
%    The following line makes ML crash when a radio button is operated:
%    set(AllHandles,'HitTest','off');    % items cannot take the focus
    resizeGUI();                        % size and position all elements
    if ~strcmp(get(hGUI,'WindowStyle'),'docked')
        movegui(hGUI,'center'); % move it to the center of the screen
        pos = get(hGUI,'Position');
        movegui(hGUI,[pos(1),pos(2)+10]);   % move slightly up
    end
    hpuXtype.Value = 1;         % initial type is X-13
    CleanDialog();              % standard settings
    SpecChanged();              % initial run of SpecChanged
    % the GUI should never become the 'current figure'
    set(hGUI,'HandleVisibility','off');
    set(hGUI,'Visible','on');   % now show the GUI
    % if requested, load a x13series object from the main workspace
    if ~isempty(loadvariable)
        if ~ischar(loadvariable{1})
            err = MException('X13TBX:guix:IllArg',['Argument is ', ...
                'illegal. If you want to load a x13series from ', ...
                'command line, use one of these two syntaxes:\n ', ...
                '(1) guix x\n (2) guix(''x'')\nwhere x is a ', ...
                'x13series variable.']);
            throw(err);
        end
        hedX13Name.String = loadvariable{1};
        pushLoadX13();
    end

%% *** function for adjusting the GUI *************************************

    % position all the objects of the GUI
    % all objects remain fixed, except htxtOut, haxOut, htxtTimeOfRun, and
    % hedMoreSpecs
    function resizeGUI(varargin)
        % get current position of GUI and avoid negative sizes
        p = get(hGUI,'Position'); hsizeGUI = p(3); vsizeGUI = p(4);
        
        hpos0 = hsizeGUI-widthcol0123 - 2*hspace;
        hpos1 = hpos0 + width0 + hspace;    % column 1
        hpos2 = hpos1 + width  + hspace;    % column 2
        hpos3 = hpos2 + width  + hspace;    % column 3
        vheight = max(1,vsizeGUI-2*(vmargin+vspace)-headvspace*0-vpb);
        hwidth = max(1,hsizeGUI-widthcol0123-2*(hspace+hmargin));

        % OUTPUT
        vpos = vsizeGUI - vmargin - vpb;
        hpos = hposOut;
        set(hpbDocX13, 'Position', [hpos,vpos+bup,hpb,vpb]);
        hpos = hpos + sspace + hpb;
        set(hpbDocTBX, 'Position', [hpos,vpos+bup,hpb,vpb]);
        hpos = hpos + 3*sspace + hpb;
        set(htglOut,       'Position', [hpos,vpos+bup,1.3*hpb,vpb]);
        hpos = hpos + 1.3*hpb + sspace;
        set(hpuOut,        'Position', [hpos,vpos+bup,160,vpb]);
        hpos = hpos + 160 + sspace;
        set(hpbCopy,       'Position', [hpos,vpos+bup,hpb,vpb]);
        hpos = hpos + hpb + sspace;
        set(htxtTimeOfRun, 'Position', [hpos,vpos, ...
            max(1,hwidth-(hpos-hposOut)),vtx]);
        % txtOut and axOut
        hpos = hposOut;
        vpos = vmargin;
        set(hedOut, 'Position', [hpos,vpos,hwidth,vheight]);
        set(haxOut, 'Position', [ ...
            hpos+axLmargin, ...
            vpos+axBmargin+(vsl+vspace), ...
            max(1,hwidth-(axLmargin+axRmargin)), ...
            max(1,vheight-(axBmargin+axTmargin)-(vsl+vspace)) ...
            ]);
        set(hslFrom,'Position', [hpos                  , vpos, ...
            max(1,(hwidth-hspace)/2), vsl]);
        set(hslTo  ,'Position', [hpos+(hwidth+hspace)/2, vpos, ...
            max(1,(hwidth-hspace)/2), vsl]);
        
        % VARIABLE NAMES
        vpos = vsizeGUI - (vpb + sspace) - vmargin - vti;
        vpos = vpos - headvspace;    % to make some vspace to the doc buttons
        set(htxtVARIABLE , 'Position' , [hpos0,vpos,hti,vti]);
        vpos = vpos - vspace - vtx;
        set(htxtX13      , 'Position' , [hpos0,vpos,width0,vtx]);
        set(hedX13Name   , 'Position' , [hpos1,vpos,width,ved]);
        set(hpbLoad      , 'Position' , [hpos2,vpos,width,vpb]);
        set(hpbSave      , 'Position' , [hpos3,vpos,width,vpb]);
        
        % DATES
        vpos = vpos - (vspace+xspace) - vti;
        set(htxtDATES    , 'Position' , [hpos0,vpos,hti,vti]);
        set(hedDates     , 'Position' , [hpos1,vpos,widthdouble,ved]);
        set(hchkDatesVector,'Position', [hpos3,vpos,width,vtx]);
        vpos = vpos - vspace - vtx;
        set(htxtMakeDates,'Position'  , [hpos0,vpos,width0,vtx]);
        set(hedStartYear,'Position'   , [hpos1,vpos,width/2-hspace/2,vtx]);
        set(hedStartMonth,'Position'  , [hpos1+width/2+hspace/2,vpos,width/2-hspace/2,vtx]);
        set(hedStartDay,'Position'    , [hpos2,vpos,width/2-hspace/2,vtx]);
        set(hedDateMult,'Position'    , [hpos2+width/2+hspace/2,vpos,width/2-hspace/2,vtx]);
        set(hpuFreq,'Position'        , [hpos3,vpos,width,vtx]);
        
        % DATA
        vpos = vpos - (vspace+xspace) - vti;
        set(htxtDATA     , 'Position' , [hpos0,vpos,hti,vti]);
        set(hedData      , 'Position' , [hpos1,vpos,widthdouble,ved]);
        set(hpuType      , 'Position' , [hpos3,vpos,width,vpu]);
        vpos = vpos - vspace - vtx;
        set(htxtTitle     , 'Position' , [hpos0,vpos,width0,vtx]);
        set(hedTitle      , 'Position' , [hpos1,vpos,widthcol123,ved]);
        
        % FCT
        vpos = vpos - (vspace+xspace) - vti;
        set(htxtFCT      , 'Position' , [hpos0,vpos,hti,vti]);
        vpos = vpos - vspace - vtx;
        set(htxtHorizon  , 'Position' , [hpos0,vpos-3,width0,vtx]);
        set(hedHorizon   , 'Position' , [hpos1,vpos,width,vtx]);
        set(htxtConfidence,'Position' , [hpos2,vpos-3,width0,vtx]);
        set(hedConfidence, 'Position' , [hpos3,vpos,width,vtx]);

        % REGRESSION and OUTLIERS
        vpos = vpos - (vspace+xspace) - vti;
        set(htxtREGR     , 'Position' , [hpos0,vpos,hti,vti]);
        vpos = vpos - vspace - vtx;
        set(htxtRegressors,'Position' , [hpos0,vpos-3,width0,vtx]);
        set(hchkConst    , 'Position' , [hpos1,vpos,width,vtx]);
        set(hchkTD       , 'Position' , [hpos2,vpos,width,vtx]);
        set(hchkEaster   , 'Position' , [hpos3,vpos,width,vtx]);
        vpos = vpos - vspace - vtx;
        set(htxtAutoOutliers, 'Position', [hpos0,vpos-3,width0,vtx]);
        set(hchkAO       , 'Position' , [hpos1,vpos,width,vtx]);
        set(hchkLS       , 'Position' , [hpos2,vpos,width,vtx]);
        set(hchkTC       , 'Position' , [hpos3,vpos,width,vtx]);
        vpos = vpos - vspace - vtx;
        set(htxtMoreRegressors,'Position', [hpos0-2,vpos-3,width0+2,vtx]);
        set(hedMoreRegressors, 'Position', [hpos1,vpos,widthcol123,ved]);
        
        % SARIMA
        vpos = vpos - (vspace+xspace) - vti;
        set(htxtSARIMA     , 'Position', [hpos0,vpos,hti,vti]);
        vpos = vpos - vspace - vtx;
        set(htxtTransform  , 'Position', [hpos0,vpos-3,width0,vtx]);
        set(hpuTransform   , 'Position', [hpos1,vpos,width,vtx]);
        set(hedPower       , 'Position', [hpos2,vpos,width,vtx]);
        vpos = vpos - (vspace+xspace) - vtx;
        set(htxtSelectModel, 'Position', [hpos0,vpos-3,width0,vtx]);
        set(hpuPickmdlFile , 'Position', [hpos2,vpos,width,vpu]);
        set(hpuFirstBest   , 'Position', [hpos3,vpos,width,vpu]);
        vpos = vpos - vspace - vtx;
        set(hchkCheckMu    , 'Position', [hpos2,vpos,width,vpu]);
        set(hchkAllowMixed , 'Position', [hpos3,vpos,width,vpu]);
        vpos = vpos - vspace - vtx;
        set(hedArima       , 'Position', [hpos2,vpos,2*width+hspace,ved]);
        vpos = vpos - vspace - vtx;
        set(hgrSelectModel , 'Position', [hpos1,vpos,width,4*vtx+3*vspace]);
        set(hrbPickmdl     , 'Position', [0,3*(vtx+vspace),width,vtx]);
        set(hrbTramo       , 'Position', [0,2*(vtx+vspace),width,vtx]);
        set(hrbManualModel , 'Position', [0,vtx+vspace    ,width,vtx]);
        set(hrbNoModel     , 'Position', [0,0             ,width,vtx]);
        
        % SEASONAL ADJUSTMENT
        vpos = vpos - (vspace+xspace) - vti;
        set(htxtSEASADJ    , 'Position', [hpos0,vpos,hti,vti]);
        vpos = vpos - vspace - vtx;
        set(htxtSeasType, 'Position', [hpos0,vpos-3,width0,vtx]);
        set(hpuSeasType , 'Position', [hpos1,vpos,width,vpu]);
        set(htxtMode    , 'Position', [hpos2,vpos-3,width,vpu]);
        set(hpuMode     , 'Position', [hpos3,vpos,width,vpu]);
        
        % DIAGNOSTICS
        vpos = vpos - (vspace+xspace) - vti;
        set(htxtDIAG    , 'Position', [hpos0,vpos,hti/2,vti]);
        vpos = vpos - vspace - vtx;
        set(hchkHistory     ,'Position', [hpos0,vpos,width ,vtx]);
        set(hchkSlidingSpans,'Position', [hpos1,vpos,width ,vtx]);
        set(hchkSpectrum    ,'Position', [hpos2,vpos,width ,vtx]);
        set(hchkMSpectrum   ,'Position', [hpos2,vpos + vspace + vti,2*width ,vtx]);
        set(hchkACF         ,'Position', [hpos3,vpos,width0,vtx]);
        
        % MORE SPECS
        vpos = vpos - (vspace+xspace) - vti;
        set(htxtMORESPECS   ,'Position' , [hpos0,vpos,hti,vti]);
        vheight = max(1,vpos - vspace - vmargin);
        vpos = vmargin;
        set(hedMoreSpecs    ,'Position' , [hpos0,vpos,widthcol0123,vheight]);
        
        % DOCUMENTATION, FLAGS, and RUN
        vpos = vsizeGUI -vmargin - vpb;
        hpos = hpos0;
        set(htxtPRINTTABLE,'Position',[hpos,vpos,0.55*hflag,vpb]);
        hpos = hpos + sspace + 0.55*hflag;
        set(hpuPrintTable,'Position',[hpos,vpos+bup,1.5*hpb,vpb]);
        hpos = hpos + 1.5*sspace + 1.5*hpb;
        set(hpuXtype,   'Position', [hpos,vpos+bup,1.6*hpb,vpb]);
        set(hedProg, 'Position', [hpos,vpos-20,1.6*hpb,vpb]);
        hpos = hpos + 2*sspace + 1.6*hpb;
        set(hchkW,     'Position', [hpos,vpos+bup,hflag,vpb]);
        set(hchkS,     'Position', [hpos,vpos-20,hflag,vpb]);
        hpos = hpos + sspace + hflag;
        set(hchkQ,     'Position', [hpos,vpos+bup,hflag,vpb]);
        set(hchkNF,    'Position', [hpos,vpos-20,2.0*hflag,vpb]);
        hpos = hpos + sspace + hflag;
        set(hpbRun,    'Position', [hpos,vpos+bup,hpb,vpb]);
        
    end
    
%% *** button callbacks **************************************************

    % load a PDF (documentation) into system-default Acrobat Reader
    function pushOpenDoc(hObject,~)
        progname = x.prog;
        if isempty(progname)
            progname = hedProg.String;
        end
        [~,progname,~] = fileparts(progname);
        customDocFile = fullfile(docfolder,[progname,'.pdf']);
        switch hObject.String
            case 'Doc X-13'; docfile = fullfile(docfolder,'docX13as.pdf');
            case 'Doc X-12'; docfile = fullfile(docfolder,'x12adocV03.pdf');
            case 'Doc X-11'; docfile = fullfile(docfolder,'1980x11arimamanual.pdf');
            case 'paper'   ; docfile = fullfile(docfolder,'25_2015_abeln_jacobs.pdf');
            case 'Doc TBX' ; docfile = fullfile(docfolder,'DocX13TBX.pdf');
            case 'file'    ; docfile = customDocFile;
            case '---'     ; docfile = '';
        end
        if ~strcmp(hObject.String,'Doc TBX') && ~exist(docfile,'file')
            switch hpuXtype.Value
                case 1
                    InstallMissingCensusProgram('x13doc');
                case 2
                    InstallMissingCensusProgram('x12doc');
                case 3
                    InstallMissingCensusProgram('x11doc');
                case 5
                    InstallMissingCensusProgram('campletdoc');
            end
        end
        try
            winopen(docfile);
        catch e
            str = sprintf(['Something went wrong. Make sure that the ', ...
                'documentation is installed ', ...
                '(use InstallMissingCensusProgram(...)).', ...
                'You also need Acrobat reader to view the ', ...
                'documentation. Moreover, this function works only ', ...
                'on the Windows operating system.']);
            errordlg(sprintf(['%s\n\nCannot open %s\n\n%s\n%s\n', ...
                '> In %s (line %i)\n'], str, docfile, e.identifier, ...
                e.message, e.stack(1).name, e.stack(1).line), ...
                'Cannot open documentation');
        end
    end

    % "Import" button was pushed
    function pushLoadX13(varargin)
        try
            x = evalin('base',hedX13Name.String);
            if ~isa(x,'x13series') && ~isa(x,'x13composite')
                x = x13series;
                set(htglOut,'Value' ,0);
                set(hpuOut ,'Value' ,1);
                set(htglOut,'Enable','off');
                set(hpuOut ,'Enable','off');
                PopulateMenu();
                MakeOutput();
                error('X13TBX:GUIX:WrongType', ['Variable ''%s'' is ', ...
                    'not an x13series object.'], hedX13Name.String);
            end
            if isa(x,'x13composite')
                x = x.(x.compositeseries);  % load only the aggregate series
                warning(['''%s'' is a x13composite. Only the aggregate series ', ...
                    'is loaded.'], hedX13Name.String);
            end
            LoadX13series(x);
        catch e
            m = sprintf('%s\n%s\n',e.identifier,e.message);
            for c = 1:numel(e.stack)
                m = sprintf('%s\n> In %s (line %i)',m, ...
                    e.stack(c).name, e.stack(c).line);
            end
            errordlg(m,'Error reading variable');
        end
    end

    % "Export" button was pushed
    function pushSaveX13(varargin)
        try
            assignin('base', hedX13Name.String, x);
            set(hpbSave,'Enable','off');
            fprintf('(variable ''%s'' assigned)\n', hedX13Name.String);
        catch e
            m = sprintf('%s\n%s\n',e.identifier,e.message);
            for c = 1:numel(e.stack)
                m = sprintf('%s\n> In %s (line %i)',m, ...
                    e.stack(c).name, e.stack(c).line);
            end
            errordlg(m,'Error exporting variable');
            errordlg(sprintf('%s\n%s\n> In %s (line %i)', ...
                e.identifier, e.message, e.stack(1).name, e.stack(1).line), ...
                'Error exporting variable');
        end
    end

    % "Run" button was pushed
    function pushRun(varargin)
        set(hpbRun,'String','working...');
        drawnow;
        try
            % import data
            if hchkDatesVector.Value
                d0 = evalin('base',hedDates.String);
            else
                d0 = evalin('base', ...
                    sprintf(['makedates([%s,%s,%s],numel(%s),', ...
                        '''%s'',%s)'], ...
                    hedStartYear.String, hedStartMonth.String, ...
                    hedStartDay.String, hedData.String, ...
                    hpuFreq.String{hpuFreq.Value}, hedDateMult.String));
            end
            d1 = evalin('base',hedData.String);
            % create spec and x by calling the two components of the
            % command line
            spec = evalin('base',cmdlinespec);
            x = x13(d0,d1,spec,flagArgs{:});
            % update filename of executable
            hedProg.String = x.prog;
            % if 'spectrum' is selected for non-monthly data, make sure
            % 'Matlab spectrum' is selected
            if ~all(x.period == 12); hchkMSpectrum.Value = hchkSpectrum.Value; end
            % run addMatlabSpectrum if selected
            if hchkMSpectrum.Value % && strcmp(hchkMSpectrum.Enable,'on')
                x = x.addMatlabSpectrum;
            end
            % do adjustments to GUI
            SpecChanged();
            % do additional stuff if requested
            % The following solution is maybe more flexible (it allows
            % various commands in cmdafter), but it does not work if the
            % x-variable in GUI has a name, because that name does not
            % exist in the base workspece ...
            %if ~isempty(cmdafter)
            %    x = evalin('base',cmdafter);
            %end
            % ... so we take the simple route and just hardcode
            % .addMatlabSpectrum if the checkbox is set because no other
            % commands can be there (at the moment).
            % enable htglOut and hpuOut
            set(htglOut,'Enable','on');
            set(hpuOut ,'Enable','on');
            % reset menu
            PopulateMenu;
            RestoreStoredMenuItem();
            % make new output
            doKeepPlotRange = true;
            MakeOutput();
            % make Run button unavailable
            set(hpbRun,'Enable','off');
            % make Export button available
            if ~isempty(hedX13Name.String)
                set(hpbSave,'Enable',RunPossible);
            end
        catch e
            m = sprintf('%s\n%s\n\n%s\n%s\n', ...
                cmdlinespec, cmdx13, e.identifier,e.message);
            for c = 1:numel(e.stack)
                m = sprintf('%s\n> In %s (line %i)',m, ...
                    e.stack(c).name, e.stack(c).line);
            end
            errordlg(m,'Error running x13');
            if hpuOut.Value > numel(hpuOut.String)
                hpuOut.Value = 1;
                doKeepPlotRange = true;
                MakeOutput();
            end
        end
        set(hpbRun,'String','Run');
    end

    % "Copy" button was pushed
    function pushCopy(varargin)
        if htglOut.Value                            % chart
            hTempFig = figure('Visible','off');             % create temp figure
            set(hTempFig,'Units','pixels');                 % size it
            set(hTempFig,'Position',get(hGUI,'Position'));
            copyobj(haxOut,hTempFig);                       % copy axes to temp fig
            set(gca,'Units','pixels');                      % move axes to bottom-left corner
            s = get(hedOut,'Position');
            set(gca,'Position', [ ...
                axLmargin ...
                axBmargin ...
                s(3)-axLmargin-axRmargin ...
                s(4)-axBmargin-axTmargin ...
                ]);
            set(hTempFig,'Position',[0 0 s(3) s(4)]);       % resize temp fig
%            print(hTempFig,'-dmeta');
            hgexport(hTempFig,'-clipboard');                % place in clipboard
            delete(hTempFig);                               % clean up
        else                                        % text
            str = hedOut.String;                            % get content
            if iscell(str)                                  % deal with multiple lines      
                nrows = size(str);                          % (if cells, i.e. cmdline)
                out = '';
                for r = 1:nrows
                    out = sprintf('%s%s\n',out,str{r});
                end
                str = out;
            elseif isa(str,'char')                          % (if multiline array,
                [r,c] = size(str);                          % i.e. all other cases)
                if r > 1
                    str = [str, repmat(newline,r,1)];       % append linefeed to each line
                    str = reshape(str',1,r*(c+1));          % make it a single line
                end
            end
            clipboard('copy',str);                          % place in clipboard
        end
    end

%% *** handling x13series/x13specs and setting components in the dialog ***

    % load x13spec into dialog
    function LoadX13series(x)
        try
            hchkW.Value = ~isempty(strfind(x.flags,'-w'));
            hchkS.Value = ~isempty(strfind(x.flags,'-s'));
            hchkQ.Value = x.quiet || ~isempty(strfind(x.flags,'-q'));
            hchkNF.Value = isempty(x.flags);
            hedProg.String = x.prog;
            switch x.prog
                case {'x13as_ascii.exe','x13as_html.exe','x13as.exe','x13html.exe'}
                    hpuXtype.Value = 1;
                case {'x12a.exe','x12a64.exe'}
                    hpuXtype.Value = 2;
                case 'x11.m'
                    hpuXtype.Value = 3;
                case 'method1.m'
                    hpuXtype.Value = 4;
                case 'camplet.m'
                    hpuXtype.Value = 5;
                case 'fixedseas.m'
                    hpuXtype.Value = 6;
                otherwise
                    hpuXtype.Value = 7;
            end
            SpecChanged();
            LoadX13spec(x.specgiven);
            % if 'spectrum' is selected for non-monthly data, make sure
            % 'Matlab spectrum' is selected
            if ~all(x.period == 12); hchkMSpectrum.Value = hchkSpectrum.Value; end
            SpecChanged();
            % get ready for user interaction
            set(htglOut,'Enable','on');
            set(hpuOut ,'Enable','on');
            PopulateMenu();
            doKeepPlotRange = true;
            MakeOutput();
        catch e
            m = sprintf('%s\n%s\n',e.identifier,e.message);
            for c = 1:numel(e.stack)
                m = sprintf('%s\n> In %s (line %i)',m, ...
                    e.stack(c).name, e.stack(c).line);
            end
            errordlg(m,'Error importing variable');
        end
    end

    % general callback when some settings were changed
    function SpecChanged(varargin)
        
        % edit field for custom m-file name
        if hpuXtype.Value == 7
            hedProg.Enable = 'on';
        else
            hedProg.Enable = 'off';
        end
        
        % addMatlabSepctrum enabled?
        hchkSpectrum.Enable = 'on';
        if hpuXtype.Value < 3     % X-13 or X-12
            if hchkSpectrum.Value
                hchkMSpectrum.Enable = 'on';
            else
                hchkMSpectrum.Enable = 'off';
            end
        else                % addMatlabSpectrum is anyways done in these cases
                            % and does not need to be added separately
                            % after the x13.m run
            hchkMSpectrum.Value = hchkSpectrum.Value;
            hchkMSpectrum.Enable = 'off';
        end
        
        % deal with dates
        if hchkDatesVector.Value
            hedDates.Enable = 'on';
            hedStartYear.Enable = 'off';
            hedStartMonth.Enable = 'off';
            hedStartDay.Enable = 'off';
            hedDateMult.Enable = 'off';
            hpuFreq.Enable = 'off';
        else
            hedDates.Enable = 'off';
            hedStartYear.Enable = 'on';
            hedStartMonth.Enable = 'on';
            hedStartDay.Enable = 'on';
            hedDateMult.Enable = 'on';
            hpuFreq.Enable = 'on';
        end
        
        % set according to the selected adjustment method
        
        switch hpuXtype.Value
            
            case 1              % x-13
                
                hpbDocX13.Enable = 'on';
                hpbDocX13.String = 'Doc X-13';
                hpbDocX13.TooltipString ='View X-13ARIMA-SEATS documentation.';
                
                legal = {'none specified','auto', ...
                    'no transformation','logarithm','square root','inverse', ...
                    'logistic','power'};
                adjustPU(htxtTransform,hpuTransform,legal,1);
                
                legal = {'unspecified','additive','multiplicative', ...
                       'log-additive','pseudo-additive'};
                adjustPU(htxtMode,hpuMode,legal,1);
                
                legal = {'none','X-11','SEATS'};
                adjustPU(htxtSeasType,hpuSeasType,legal,2);
                
                EnableDisableMost('on');
                
            case 2              % x-12
                
                hpbDocX13.Enable = 'on';
                hpbDocX13.String = 'Doc X-12';
                hpbDocX13.TooltipString ='View X-12-ARIMA documentation.';
                
                legal = {'none specified','auto', ...
                    'no transformation','logarithm','square root','inverse', ...
                    'logistic','power'};
                adjustPU(htxtTransform,hpuTransform,legal,1);
                
                legal = {'unspecified','additive','multiplicative', ...
                       'log-additive','pseudo-additive'};
                adjustPU(htxtMode,hpuMode,legal,1);
                
                legal = {'none','X-11'};
                adjustPU(htxtSeasType,hpuSeasType,legal,2);
                
                EnableDisableMost('on');
            
            case 3            % X-11
                
                hpbDocX13.Enable = 'on';
                hpbDocX13.String = 'Doc X-11';
                hpbDocX13.TooltipString =['View X11ARIMA ', ...
                    '(Version 2000) documentation.'];
                
                legal = {'none specified','no transformation','logarithm'};
                adjustPU(htxtTransform,hpuTransform,legal,1);
                
                legal = {'unspecified','additive','multiplicative', ...
                       'log-additive'};
                adjustPU(htxtMode,hpuMode,legal,1);
                
                legal = {'none','X-11'};
                adjustPU(htxtSeasType,hpuSeasType,legal,2);
                
                EnableDisableMost('off');
                  htxtREGR.Enable = 'on';
            htxtRegressors.Enable = 'on';
                    hchkTD.Enable = 'on';
                hchkEaster.Enable = 'on';
            
            case 4            % Method I
                
                hpbDocX13.Enable = 'off';
                hpbDocX13.String = '---';
                hpbDocX13.TooltipString ='(no documentation accessible)';
                
                legal = {'none specified','no transformation','logarithm'};
                adjustPU(htxtTransform,hpuTransform,legal,1);
                
                legal = {'unspecified','additive','multiplicative', ...
                       'log-additive'};
                adjustPU(htxtMode,hpuMode,legal,1);
                
                legal = {'none','X-11'};
                adjustPU(htxtSeasType,hpuSeasType,legal,2);
                
                EnableDisableMost('off');
                  htxtREGR.Enable = 'on';
            htxtRegressors.Enable = 'on';
                    hchkTD.Enable = 'on';
                hchkEaster.Enable = 'on';
            
            case 5              % camplet
                
                hpbDocX13.Enable = 'on';
                hpbDocX13.String = 'paper';
                hpbDocX13.TooltipString = ['View research paper by Abeln and ', ...
                    'and Jacobs, ANU, July 2015.'];
                
                legal = {'none specified','no transformation','logarithm'};
                adjustPU(htxtTransform,hpuTransform,legal,1);
                
                htxtMode.Enable = 'off';
                hpuMode.Enable = 'off';
                
                htxtSeasType.Enable = 'off';
                hpuSeasType.Enable = 'off';
                
                EnableDisableMost('off');
                
            case {6,7}          % (fixedseas.m or custom)
                
                progname = x.prog;
                if isempty(progname)
                    progname = hedProg.String;
                end
                [~,progname,~] = fileparts(progname);
                customDocFile = fullfile(docfolder,[progname,'.pdf']);
                if exist(customDocFile,'file')
                    hpbDocX13.Enable = 'on';
                    hpbDocX13.String = 'file';
                    hpbDocX13.TooltipString = ['documentation for ',x.prog];
                else
                    hpbDocX13.Enable = 'off';
                    hpbDocX13.String = '---';
                    hpbDocX13.TooltipString ='(no documentation accessible)';
                end
                
                legal = {'none specified','no transformation','logarithm'};
                adjustPU(htxtTransform,hpuTransform,legal,1);
                
                legal = {'unspecified','additive','multiplicative', ...
                       'log-additive'};
                adjustPU(htxtMode,hpuMode,legal,1);
                
                htxtSeasType.Enable = 'off';
                hpuSeasType.Enable = 'off';
                
                EnableDisableMost('off');
                  htxtREGR.Enable = 'on';
            htxtRegressors.Enable = 'on';
                    hchkTD.Enable = 'on';
                hchkEaster.Enable = 'on';
                
        end
        
        % now re-do the command lines
        CreateCmdLine();                        % fill in cmdspec and cmdx13
        if ~htglOut.Value && strcmp(itemTextMenu,'command line')
                                                % hedOut shows the command line,
            MakeOutput();                       % so this needs to be updated right
                                                % away
        end
        
        RunPossible = 'on';                     % make run button available
        set(hpbSave,'Enable','off');            % make save button unavailable
        % load button is available only if a name of the x13series has been provided
        if ~isempty(hedX13Name.String)
            set(hpbLoad,'Enable','on');
        else
            set(hpbLoad,'Enable','off');
        end
        
    end

    % enable or disable most components of the GUI (the ones that can only
    % be used with a genuine US Census Bureau executable)
    function EnableDisableMost(OnOff)
             hpuPrintTable.Enable = OnOff;
                   hpuType.Enable = OnOff;             
                   htxtFCT.Enable = OnOff;
               htxtHorizon.Enable = OnOff;
                hedHorizon.Enable = OnOff;
            htxtConfidence.Enable = OnOff;
             hedConfidence.Enable = OnOff;
                  htxtREGR.Enable = OnOff;
            htxtRegressors.Enable = OnOff;
                 hchkConst.Enable = OnOff;
                    hchkTD.Enable = OnOff;
                hchkEaster.Enable = OnOff;
          htxtAutoOutliers.Enable = OnOff;
                    hchkAO.Enable = OnOff;
                    hchkLS.Enable = OnOff;
                    hchkTC.Enable = OnOff;
        htxtMoreRegressors.Enable = OnOff;
         hedMoreRegressors.Enable = OnOff;
                htxtSARIMA.Enable = OnOff;
                  hedPower.Enable = OnOff;
           htxtSelectModel.Enable = OnOff;
                hrbPickmdl.Enable = OnOff;
            hpuPickmdlFile.Enable = OnOff;
              hpuFirstBest.Enable = OnOff;
                  hrbTramo.Enable = OnOff;
               hchkCheckMu.Enable = OnOff;
            hchkAllowMixed.Enable = OnOff;
            hrbManualModel.Enable = OnOff;
                  hedArima.Enable = OnOff;
                hrbNoModel.Enable = OnOff;
                   hchkACF.Enable = OnOff;
               hchkHistory.Enable = OnOff;
          hchkSlidingSpans.Enable = OnOff;
    end

    % assign the proper settings to the dialog to replicate the given
    % specification
    function LoadX13spec(spec)
        CleanDialog();
        % x-13, x-12, x-11, seas, method1 ?
        Xtype = hpuXtype.Value;
        % composite?
        isComposite = spec.isComposite; % ismember('composite',fieldnames(spec));
        % name
        hedTitle.String = ExtractValues(spec,spec.mainsec,'title');
        spec = x13spec(spec,spec.mainsec,'title',[]);
        % dates and data
        hchkDatesVector.Value = 1;
        if ~isComposite
            hedDates.String = [hedX13Name.String,'.dat.dates'];
            hedData.String  = [hedX13Name.String,'.dat.dat'];
        else
            hedDates.String = [hedX13Name.String,'.cms.dates'];
            hedData.String  = [hedX13Name.String,'.cms.cms'];
        end
        % print tables
        PRINTTYPE = 'PRINTREQUESTED';
        if strcmp(hpuPrintTable.Enable,'on')
            hpuPrintTable.Value = 1;
            done = false;
            M = {'','PRINTNONE','PRINTBRIEF','PRINTDEFAULT','PRINTALLTABLES'};
            m = 2;
            while ~done && m <= numel(M)
                s = specminus(makespec(spec,M{m}),spec,Xtype);
                if s.isempty
                    hpuPrintTable.Value = m;
                    PRINTTYPE = M{m};
                    done = true;
                end
                m = m+1;
            end
        end
        % stock, flow
        if ~isComposite
            s = specminus(makespec('STOCK',PRINTTYPE),spec,Xtype);
            if s.isempty
                hpuType.Value = 2;
            else
                s = specminus(makespec('FLOW',PRINTTYPE),spec,Xtype);
                if s.isempty
                    hpuType.Value = 3;
                else
                    hpuType.Value = 1;
                end
            end
        else
            try
                s = spec.composite.type;
                if isempty(s)
                    hpuType.Value = 1;
                elseif strcmpi(s,'stock')
                    hpuType.Value = 2;
                elseif strcmpi(s,'flow')
                    hpuType.Value = 3;
                end
            catch e
                hpuType.Value = 1;
            end                
        end
        % forecast
        s = specminus(makespec('FCT',PRINTTYPE),spec,Xtype);
        try strfwd = spec.forecast.maxlead; catch e; strfwd = ''; end
        try strp = spec.forecast.probability; catch; strp = '0.95'; end
        s = specminus(makespec('FCT', ...
                'forecast','maxlead',[], ...
                'forecast','maxback',[], ...
                'forecast','probability',[], ...
                PRINTTYPE), ...
            spec,Xtype);
        if s.isempty
            hedHorizon.String    = strfwd;
            hedConfidence.String = strp;
        else
            hedHorizon.String    = '0';
        end
        % regression
        s = specminus(makespec('CONST',PRINTTYPE),spec,Xtype);
        hchkConst.Value = s.isempty;
        s = specminus(makespec('TD',PRINTTYPE),spec,Xtype);
        hchkTD.Value = s.isempty;
        s = specminus(makespec('EASTER',PRINTTYPE),spec,Xtype);
        hchkEaster.Value = s.isempty;
        % outliers
        s = specminus(makespec('AO',PRINTTYPE),spec,Xtype);
        hchkAO.Value = s.isempty;
        s = specminus(makespec('LS',PRINTTYPE),spec,Xtype);
        hchkLS.Value = s.isempty;
        s = specminus(makespec('TC',PRINTTYPE),spec,Xtype);
        hchkTC.Value = s.isempty;
        % SARIMA-Model
        try
            v = spec.transform.power;
            idx = find(ismember('power',hpuTransform.String));
            hpuTransform.Value = idx;
            hedPower.String = v;
        catch
            hpuTransform.Value = 1;
        end
        if strcmp(hpuTransform.Enable,'on')
            s = specminus(makespec('AUTO',PRINTTYPE),spec,Xtype);
            done = setPU(hpuTransform,'auto',s.isempty);
            s = specminus(makespec('NOTRANSFORM',PRINTTYPE),spec,Xtype);
            done = setPU(hpuTransform,'no transformation',s.isempty && ~done);
            s = specminus(makespec('LOG',PRINTTYPE),spec,Xtype);
            done = setPU(hpuTransform,'logarithm',s.isempty && ~done);
            s = specminus(x13spec('transform','function','sqrt'),spec,Xtype);
            done = setPU(hpuTransform,'square root',s.isempty && ~done);
            s = specminus(x13spec('transform','function','inverse'),spec,Xtype);
            done = setPU(hpuTransform,'inverse',s.isempty && ~done);
            s = specminus(x13spec('transform','function','logistic'),spec,Xtype);
            setPU(hpuTransform,'logistic',s.isempty && ~done);
        end
        % manual model
        if strcmp(htxtSARIMA.Enable,'on')
            f = fieldnames(spec);
            if ismember('arima',f)
                try
                    hrbManualModel.Value = true;
                    m = spec.arima.model;
                    hedArima.String = m;
                end
            else
                % pickmdl
                found = false;
                s = specminus(makespec('PICKBEST',PRINTTYPE),spec,Xtype);
                if s.isempty
                    hrbPickmdl.Value = true;
                    hpuFirstBest.Value = 1;
                    found = true;
                end
                s = specminus(makespec('PICKFIRST',PRINTTYPE),spec,Xtype);
                if s.isempty && ~found
                    hrbPickmdl.Value = true;
                    hpuFirstBest.Value = 2;
                    found = true;
                end
                if found
                    f = ExtractValues(spec,'pickmdl','file');
                    if ~isempty(f)
                        idx = find(ismember(hpuPickmdlFile.String,f));
                        if ~isempty(idx)
                            hpuPickmdlFile.Value = idx;
                        end
                    else
                        hpuPickmdlFile.Value = 1;   % use default model file
                    end
                end
                % tramo
                s = specminus(makespec('TRAMO',PRINTTYPE),spec,Xtype);
                if s.isempty
                    found = true;
                    hrbTramo.Value = true;
                    m = ExtractValues(spec,'automdl','mixed');
                    if ismember(m,'no')
                        hchkAllowMixed.Value = false;
                    else
                        hchkAllowMixed.Value = true;
                    end
                    c = ExtractValues(spec,'automdl','checkmu');
                    if ismember(c,'no')
                        hchkCheckMu.Value = false;
                    else
                        hchkCheckMu.Value = true;
                    end
                end
                % no regARIMA
                if ~found
                    hrbNoModel.Value = true;
                end
            end
        end
        % seasonal adjustment method
        s = specminus(makespec('X11',PRINTTYPE),spec,Xtype);
        done = setPU(hpuSeasType,'X-11',s.isempty);
        if ~done
            s = specminus(makespec('SEATS',PRINTTYPE),spec,Xtype);
            done = setPU(hpuSeasType,'SEATS',s.isempty);
        end
        if ~done
            hpuSeasType.Value = 1;
        end
        % seasonal adjustment mode
        if strcmp(hpuMode.Enable,'on')
            m = ExtractValues(spec,spec.adjmethod,'mode');
            if ~isempty(m)
                m = find(ismember({'add','mult','logadd','pseudoadd'},m));
                hpuMode.Value = m+1;
            end
        end
        % diagnostics
        if strcmp(hchkSpectrum.Enable,'on')
            s = specminus(makespec('SPECTRUM',PRINTTYPE),spec,Xtype);
            hchkSpectrum.Value = s.isempty;
        end
        if strcmp(hchkACF.Enable,'on')
            s = specminus(makespec('ACF',PRINTTYPE),spec,Xtype);
            hchkACF.Value = s.isempty;
        end
        if strcmp(hchkHistory.Enable,'on')
            s = specminus(makespec('HISTORY',PRINTTYPE),spec,Xtype);
            hchkHistory.Value = s.isempty;
        end
        if strcmp(hchkSlidingSpans.Enable,'on')
            s = specminus(makespec('SLIDINGSPANS',PRINTTYPE),spec,Xtype);
            hchkSlidingSpans.Value = s.isempty;
        end
        % recreate cmdspec and see what is still missing
        CreateCmdLine();
        s = evalin('caller',cmdlinespec);
        s = specminus(spec,s,Xtype);
        % FORCETDAYS?
        more = {};
        if strcmp(hchkTD.Enable,'on') && ~s.isempty
            s0 = makespec('FORCETDAYS');
            s1 = specminus(s0,s,Xtype);
            if s1.isempty
                more = [more,{'''FORCETDAYS'''}];
                hedMoreSpecs.String = strjoin(more,',');
                CreateCmdLine();
                s = evalin('caller',cmdlinespec);
                s = specminus(spec,s,Xtype);
            end
        end
        % deal with additional explanatory variables in regression
        if strcmp(hedMoreRegressors.Enable,'on') && ~s.isempty
            regr = ExtractValues(s,'regression','variables');
            if ~isempty(regr)
                hedMoreRegressors.String = strjoin(regr,' ');
                CreateCmdLine();
                s = evalin('caller',cmdlinespec);
            end
        end
        % other makespec macros?
        if strcmp(hpuSeasType.Enable,'on') && ~s.isempty
            if ismember('X-11',hpuSeasType.String)
                s0 = makespec('TOTALX11');
                s1 = specminus(s0,s,Xtype);
                s1 = specminus(s1,makespec('FULLX11'),Xtype);
                if s1.isempty
                    more = [more,{'''TOTALX11'''}];
                    hedMoreSpecs.String = strjoin(more,',');
                    CreateCmdLine();
                    s = evalin('caller',cmdlinespec);
                    s = specminus(spec,s,Xtype);
                end
                s0 = makespec('FULLX11');
                s1 = specminus(s0,s,Xtype);
                s1 = specminus(s1,makespec('X11'),Xtype);
                if s1.isempty
                    more = [more,{'''FULLX11'''}];
                    hedMoreSpecs.String = strjoin(more,',');
                    CreateCmdLine();
                    s = evalin('caller',cmdlinespec);
                end
            end
            if ismember('SEATS',hpuSeasType.String)
                s0 = makespec('FULLSEATS');
                s1 = specminus(s0,s,Xtype);
                s1 = specminus(s1,makespec('SEATS'),Xtype);
                if s1.isempty
                    more = [more,{'''FULLSEATS'''}];
                    hedMoreSpecs.String = strjoin(more,',');
                    CreateCmdLine();
                    s = evalin('caller',cmdlinespec);
                end
            end
        end
        if strcmp(hchkHistory.Enable,'on') && ~s.isempty
            s0 = makespec('FULLHISTORY');
            s1 = specminus(s0,s,Xtype);
            s1 = specminus(s1,makespec('HISTORY'),Xtype);
            if s1.isempty
                more = [more,{'''FULLHISTORY'''}];
                hedMoreSpecs.String = strjoin(more,',');
                CreateCmdLine();
                s = evalin('caller',cmdlinespec);
            end
        end
        % list of stuff that remains
        CreateCmdLine();
        s = evalin('caller',cmdlinespec);
        s = specminus(spec,s,Xtype);
        series = fieldnames(s);
        for ser = 1:numel(series)
            if isstruct(s.(series{ser}))
                keys = fieldnames(s.(series{ser}));
                for key = 1:numel(keys)
                    value = s.(series{ser}).(keys{key});
                    if iscell(value)
                        valuestr = '{';
                        for c = 1:numel(value)
                            if ~ischar(value{c})
                                valuestr = [valuestr,mat2str(value{c}),', '];
                            else
                                valuestr = [valuestr,'''',value{c},''', '];
                            end
                        end
                        value = [valuestr(1:end-2),'}'];
                    else
                        if ~ischar(value)
                            value = mat2str(value);
                        end
                    end
                    more = [more, {sprintf('''%s'',''%s'',''%s''', ...
                        series{ser},keys{key},value)}];
                end
            end
        end
        hedMoreSpecs.String = more;
        CreateCmdLine();
    end

    % default state of the dialog
    function CleanDialog()
        % DATES
        hchkDatesVector.Value       = false;    % use makedates
        hedStartYear.String         = '';
        hedStartMonth.String        = '';
        hedStartDay.String          = '';
        hedDateMult.String          = '1';
        hpuFreq.Value               = 5;        % monthly frequency
        % TITLE
        hedTitle.String             = '';
        % STOCK/FLOW
        hpuType.Value               = 1;        % stock or flow not specified
        % FORECAST
        hedHorizon.String           = '0';      % no forecast by default
        hedConfidence.String        = '0.95';
        % REGRESSION and OUTLIERS
        hchkConst.Value             = false;
        hchkTD.Value                = false;
        hchkEaster.Value            = false;
        hchkAO.Value                = false;
        hchkLS.Value                = false;
        hchkTC.Value                = false;
        hedMoreRegressors.String    = '';
        % SARIMA-Model selection
        hpuTransform.Value          = 2;        % automatic transformation
        hedPower.String             = '1.0';
        hrbPickmdl.Value            = false;
        hpuPickmdlFile.Value        = 1;
        hpuFirstBest.Value          = 1;
        hrbTramo.Value              = true;     % TRAMO is default
        hchkCheckMu.Value           = true;
        hchkAllowMixed.Value        = false;
        hrbManualModel.Value        = false;
        hedArima.String             = '(0 1 1)(0 1 1)';
        hrbNoModel.Value            = false;
        % SEASONAL ADJUSTMENT
        hpuSeasType.Value           = min(numel(hpuSeasType.String),2);
                                        % seasonal adjustment with X-11
        hpuMode.Value               = 1;        % unspecified
        % DIAGNOSTICS
        hchkACF.Value               = true;     % yes
        hchkSpectrum.Value          = true;     % yes
        hchkMSpectrum.Value         = false;    % no
        hchkHistory.Value           = false;    % no
        hchkSlidingSpans.Value      = false;    % no
        hedMoreSpecs.String         = '';
    end

    % adjust the options in a pull-up menu, maintaining the current
    % selection if possible (and setting the default specified if not)
    function adjustPU(htxt,hpu,legal,default)
        htxt.Enable = 'on';
        hpu.Enable = 'on';
        remember = hpu.String{hpu.Value};
        hpu.Value = 1;
        hpu.String = legal;
        hpu.Value = default;
        setPU(hpu,remember,true);
    end

    % set pull-up menu to specific string value (if string exists in the
    % list)
    function success = setPU(hpu,strvalue,doit)
        success = false;
        if doit
            idx = find(ismember(hpu.String,strvalue));
            if ~isempty(idx)
                hpu.Value = idx;
                success = true;
            end
        end
    end

    % true if checkbox is enabled and set
    function on = check(hchk)
        on = strcmp(hchk.Enable,'on') && hchk.Value;
    end

%% *** create command line ************************************************

    % create the command lines making the spex and making the x13series
    % object (i.e. calling x13)
    function CreateCmdLine()
        
        cmdspec = ''; cmdlinespec = ''; cmdx13 = ''; cmdafter = ''; 
        
        % cmdx13
        
        if hchkDatesVector.Value
            strDates = hedDates.String;
        else
            if strcmp(strtrim(hedDateMult.String),'1')
                strDates = sprintf(['makedates([%s,%s,%s],numel(%s),', ...
                        '''%s'')'], ...
                    hedStartYear.String, hedStartMonth.String, ...
                    hedStartDay.String, hedData.String, ...
                    hpuFreq.String{hpuFreq.Value});
            else
                strDates = sprintf(['makedates([%s,%s,%s],numel(%s),', ...
                        '''%s'',%s)'], ...
                    hedStartYear.String, hedStartMonth.String, ...
                    hedStartDay.String, hedData.String, ...
                    hpuFreq.String{hpuFreq.Value}, hedDateMult.String);
            end
        end
        if ~isempty(strDates) && ~isempty(hedData.String)
            % flags
            strFlags = '-n ';
            if hchkW.Value; strFlags = [strFlags,'-w ']; end
%             if hchkN.Value; strFlags = [strFlags,'-n ']; end
%             if hchkR.Value; strFlags = [strFlags,'-r ']; end
            if hchkS.Value; strFlags = [strFlags,'-s ']; end
            if hchkNF.Value; strFlags = 'noflags'; end
            if strcmp(strFlags,'-n ')
                strFlags = '';
            elseif strcmp(strFlags,'')
                strFlags = 'noflags';
            end
            if ~isempty(strFlags)
                addFlags = strtrim(strFlags);
            else
                addFlags = [];
            end
            switch hpuXtype.Value
                case 1
                    addXtype = [];  % x-13
                case 2
                    addXtype = {'x-12'};
                case 3
                    addXtype = {'x-11'};
                case 4
                    addXtype = {'method1'};
                case 5
                    addXtype = {'camplet'};
                case 6
                    addXtype = {'fixed'};
                otherwise
                    addXtype = {'prog',hedProg.String};
            end
            if hchkQ.Value
                addQuiet = 'quiet';
            else
                addQuiet = [];
            end
            if isempty(addXtype)
                flagArgs = {addFlags,addQuiet};
            else
                flagArgs = [addXtype(:)',{addFlags},{addQuiet}];
            end
            % command line
            strFlags = sprintf(', ''%s'', ''%s'', ''%s''',flagArgs{:});
            strFlags = strrep(strFlags,''''', ','');
            strFlags = strrep(strFlags,'''''','');
            if strcmp(strFlags(end-1:end),', '); strFlags(end-1:end) = []; end
            if strcmp(strFlags(end-2:end),', '''); strFlags(end-2:end) = []; end
            cmdx13 = '';
            if ~isempty(hedX13Name.String)
                cmdx13 = sprintf('%s = ',hedX13Name.String);
            end
            cmdx13 = sprintf('%sx13(%s, %s, spec%s)', ...
                cmdx13, strDates, hedData.String, strFlags);
            set(hpbRun,'Enable',RunPossible);
        else
            set(hpbRun,'Enable','off');
        end
        
        % cmdspec
        if ~isempty(hedTitle.String)
            AddToSpec('series','title',hedTitle.String);
        end
        if strcmp(hpuType.Enable,'on')
            switch hpuType.Value
                case 2
                    AddToSpec('STOCK');
                case 3
                    AddToSpec('FLOW');
            end
        end
        fHorizon = str2double(hedHorizon.String);
        % FORE- and BACKCAST
        if isnan(fHorizon) || fHorizon <= 0
            hedHorizon.String = '0';
            set([htxtConfidence,hedConfidence],'Enable','off');
        else
            fHorizon = round(fHorizon);
            hedHorizon.String = int2str(fHorizon);
            set([htxtConfidence,hedConfidence],'Enable','on');
            fConfidence = str2double(hedConfidence.String);
            if fConfidence == 0.95
                AddToSpec('FCT');
            elseif fConfidence == 0.5
                AddToSpec('FCT50');
            else
                AddToSpec('FCT','forecast','probability',hedConfidence.String);
            end
            if fHorizon ~= 36
                AddToSpec('forecast','maxlead',hedHorizon.String);
                AddToSpec('forecast','maxback',hedHorizon.String);
            end
        end
        % OUTLIERS AND REGRESSORS
        if check(hchkConst);  AddToSpec('CONSTANT'); end
        if check(hchkTD);     AddToSpec('TD');       end
        if check(hchkEaster); AddToSpec('EASTER');   end
        if check(hchkAO);     AddToSpec('AO');       end
        if check(hchkLS);     AddToSpec('LS');       end
        if check(hchkTC);     AddToSpec('TC');       end
        if strcmp(hchkAO.Enable,'on') && strcmp(hchkLS.Enable,'on') && ...
                strcmp(hchkTC.Enable,'on') && ...
                ~hchkAO.Value && ~hchkLS.Value && ~hchkTC.Value
            AddToSpec('NO OUTLIERS');
        end
        if ~isempty(hedMoreRegressors.String)
            str = hedMoreRegressors.String;
            if contains(str,' ')
                if ~strcmp(str(1),'(')  ; str = ['(',str]; end
                if ~strcmp(str(end),')'); str = [str,')']; end
            end
            AddToSpec('regression','variables',str);
        end
        % SELECT ARIMA MODEL
        if check(hrbPickmdl)
            set(hpuFirstBest  ,'Enable','on' );
            set(hpuPickmdlFile,'Enable','on' );
            set(hchkAllowMixed,'Enable','off');
            set(hchkCheckMu   ,'Enable','off');
            set(hedArima      ,'Enable','off');
            switch hpuFirstBest.Value
                case 1
                    AddToSpec('PICKBEST');
                case 2
                    AddToSpec('PICKFIRST');
            end
            if hpuPickmdlFile.Value > 1
                AddToSpec('pickmdl','file', ...
                    hpuPickmdlFile.String{hpuPickmdlFile.Value});
            end
        end
        if check(hrbTramo)
            set(hpuFirstBest  ,'Enable','off');
            set(hpuPickmdlFile,'Enable','off');
            if hpuXtype.Value < 3
                set(hchkAllowMixed,'Enable','on' );
                set(hchkCheckMu   ,'Enable','on' );
            end
            set(hedArima      ,'Enable','off');
            if check(hchkAllowMixed)
                AddToSpec('TRAMO');
            else
                AddToSpec('TRAMOPURE');
            end
            if check(hchkConst)
                set(hchkCheckMu,'Enable','off');
            else
                set(hchkCheckMu,'Enable','on');
                if ~hchkCheckMu.Value
                    AddToSpec('automdl','checkmu','no');
                end
            end
        end
        if check(hrbManualModel)
            set(hpuFirstBest  ,'Enable','off');
            set(hpuPickmdlFile,'Enable','off');
            set(hchkAllowMixed,'Enable','off');
            set(hchkCheckMu   ,'Enable','off');
            if hpuXtype.Value < 3
                set(hedArima      ,'Enable','on' );
            end
            AddToSpec('arima','model',hedArima.String);
        end
        if check(hrbNoModel)
            set(hpuFirstBest  ,'Enable','off');
            set(hpuPickmdlFile,'Enable','off');
            set(hchkAllowMixed,'Enable','off');
            set(hchkCheckMu   ,'Enable','off');
            set(hedArima      ,'Enable','off');
        end
        % TRANSFORM
        set(hedPower,'Enable','off');
        switch hpuTransform.String{hpuTransform.Value}
            case 'auto'             ; AddToSpec('AUTO');
            case 'none specified'     % do nothing
            case 'no transformation'; AddToSpec('NOTRANS');
            case 'logarithm'        ; AddToSpec('LOG');
            case 'square root'      ; AddToSpec('transform','function','sqrt');
            case 'inverse'          ; AddToSpec('transform','function','inverse');
            case 'logistic'         ; AddToSpec('transform','function','logistic');
            case 'power'
                set(hedPower,'Enable','on');
                AddToSpec('transform','power',hedPower.String);
        end
        % TYPE of SEASONAL ADJUSTMENT
        switch hpuXtype.Value
            case {1,2,3,4}
                switch hpuSeasType.String{hpuSeasType.Value}
                    case 'none'
                        set(htxtMode,'Enable','off' );
                        set(hpuMode,'Enable','off');
                    case 'X-11'
                        AddToSpec('X11');
                        method = 'x11';
                        set(htxtMode,'Enable','on');
                        set(hpuMode,'Enable','on');
                    case 'SEATS'
                        AddToSpec('SEATS');
                        method = 'seats';
                        set(htxtMode,'Enable','off');
                        set(hpuMode,'Enable','off');
                end
            case 5
                AddToSpec('CAMPLET')
                method = "camplet";
                set(htxtMode,'Enable','off');
                set(hpuMode,'Enable','off');
            case 6
                AddToSpec('FIXED')
                method = 'fixedseas';
                set(htxtMode,'Enable','on');
                set(hpuMode,'Enable','on');
            case 7
                AddToSpec('CUSTOM')
                method = 'custom';
                set(htxtMode,'Enable','on');
                set(hpuMode,'Enable','on');
        end
        % ADJUSTMENT MODE
        if strcmp(hpuMode.Enable,'on')
            switch hpuMode.String{hpuMode.Value}
                case 'additive'
                    AddToSpec(method,'mode','add');
                case 'multiplicative'
                    AddToSpec(method,'mode','mult');
                case 'log-additive'
                    AddToSpec(method,'mode','logadd');
                case 'pseudo-additive'
                    AddToSpec(method,'mode','pseudoadd');
            end
        end
        % DIAGNOSTIC TOOLS
        if check(hchkACF); AddToSpec('ACF'); end
        if check(hchkSpectrum); AddToSpec('SPECTRUM'); end
        if check(hchkMSpectrum); cmdafter = '.addMatlabSpectrum';end
        if check(hchkHistory); AddToSpec('HISTORY'); end
        if check(hchkSlidingSpans); AddToSpec('SLIDINGSPANS'); end
        if ~isempty(strtrim(hedMoreSpecs.String))
            str = hedMoreSpecs.String;
            strkeep = str;
            str = strrep(str,'  ',' ');     % remove double spaces
            str = strrep(str,'''''','''');  % remove double quotes
            str = strrep(str,'''{','{');    % replace '{ with {
            str = strrep(str,'}''','}');    % replace }' with }
            while ~strcmp(str,strkeep)
                strkeep = str;
                str = strrep(str,'  ',' ');     % remove double spaces
                str = strrep(str,'''''','''');  % remove double quotes
                str = strrep(str,'''{','{');    % replace '{ with {
                str = strrep(str,'}''','}');    % replace }' with }
            end
            hedMoreSpecs.String = str;
            % deal with multiple lines
            [r,c] = size(str);
            if iscellstr(str) %#ok<ISCLSTR>
                str = strjoin(str,', ');
            else
                if r > 1
                    str = [str, repmat(sprintf(','),r,1)]; % append comma to each line
                    str = reshape(str',1,r*(c+1));         % make it a single line
                    str(end) = [];                         % remove last comma
                end
            end
            % add to spec string
            AddToSpec(str,'no_quotes');
        end
        % deal with print table setting
        if hpuXtype.Value < 3  % x-12 or x-13
            printtable = upper(hpuPrintTable.String{hpuPrintTable.Value});
            printtable = ['PRINT',printtable(~isspace(printtable))];
            if hpuPrintTable.Value > 1; AddToSpec(printtable); end
        end
        % final touch
        cmdspec = strrep(cmdspec,',  ',', ');   % remove double spaces after commas
        cmdspec = strrep(cmdspec,', ,',', ');   % remove empty entries in the middle
        compare = ['make different',cmdspec];
        while ~isequal(compare,cmdspec)
            compare = cmdspec;
            cmdspec = strrep(cmdspec,',  ',', ');   % remove double spaces after commas
            cmdspec = strrep(cmdspec,', ,',', ');   % remove empty entries in the middle
        end
        try
            while strcmp(cmdspec(end-1:end),', ')   % remove empty entries at the end
                cmdspec(end-1:end) = [];
            end
        end
        try
            if strcmp(cmdspec(end-2:end),',  ')
                cmdspec(end-2:end) = [];
            end
        end
        if isempty(cmdspec)
            cmdlinespec = 'x13spec()';
        else
            cmdlinespec = sprintf('makespec(%s);',cmdspec);
        end
        
    end

    % add entries to the spec in the command line
    function AddToSpec(varargin)
        % Normally, each entry is surrounded by quotes before being added to
        % the cmdspec variable. The option 'no_quotes' as last argument
        % makes that this is not done.
        if strcmp(varargin{end},'no_quotes')
            varargin(end) = [];
            fmt = repmat('%s, ',[1,numel(varargin)]);
        else
            fmt = repmat('''%s'', ',[1,numel(varargin)]);
        end
        fmt = ['%s',fmt];
        cmdspec = sprintf(fmt, cmdspec, varargin{:});
    end

%% *** menu ***************************************************************

    function MenuItemChanged(varargin)
        legit = GetMenuItem();
        if legit
            if htglOut.Value                % we're in plot menu ...
                doKeepPlotRange = true;     % ... so this is a new type of graph
            end
            MakeOutput();
        end
    end

    function TogglePressed(varargin)
        PopulateMenu;                       % fill menu
        RestoreStoredMenuItem;              % get to correct position in menu
        doKeepPlotRange = true;
        MakeOutput();                       % generate and show output
    end
    
    % extract lists of items in x13series object
    function [tbl,txt,ts,other,special] = GetAllItems()
        % tables
        tbl = fieldnames(x.tbl)';
        % text items and variables
        allprop = x.listofitems;
        types = NaN(numel(allprop),1);
        for t = 1:numel(types)
            [~,types(t)] = x.descrvariable(allprop{t});
        end
        keep = (types == 0); txt = allprop(keep);
        keep = (types == 1); ts = allprop(keep);
        keep = (types == 2 | types == 3); special = allprop(keep);
        keep = (types < 0);  other = allprop(keep);
        rem_vrbl = {'dat','d8','d10','d11','d12','d13','d16', ...
            's8','s10','s11','s12','s13','s16','e2','e3', ...
            'tr','sa','sf','ir','si','hol','td','ao','tc','ls', ...
            'fct','bct','rsd','sp0','sp1','sp2','spr','st0', ...
            'st1','st2','str','s1s','s2s','t1s','t2s','sfs', ...
            'acf','pcf','ac2','chs','ycs','sae','sar','csa','csf', ...
            'sir','ssa','ssf','ssi','stn','sxd','sxs','sxr','scd', ...
            'scs','ssd','sss','ssr'};
        remove = ismember(ts     ,rem_vrbl); ts(remove)      = [];
        remove = ismember(special,rem_vrbl); special(remove) = [];
        remove = ismember(other  ,rem_vrbl); other(remove)   = [];
    end

    % fill hpuOut popup menu
    function PopulateMenu()
        [tbl,txt,ts,other,special] = GetAllItems();
        if htglOut.Value                    % chart
            if ~isempty(ts);        ts    = [hline,ts];             end
            if ~isempty(special);   special    = [hline,special];   end
%            if ~isempty(other);     other = [hline,other];          end
            menu = ['data','seasonally adjusted','trend-cycle', ...
                'forecast','SF by period','seasonal breaks', ...
                'seasonal factors','combined adjustments', ...
                'holidays adjustments','trading day adjustments', ...
                'outliers','irregular','residuals', ...
                'ACF and PACF','ACF squared','spectrum of data', ...
                'spectrum of residuals','spectrum of adjusted series', ...
                'spectrum of mod. irregular','revisions','% revisions', ...
                'sliding spans of SF','sl sp of SF, max diff', ...
                'sliding spans of SA','sl sp of SA, max diff', ...
                'sliding spans % yoy of SA','sl sp % yoy of SA, max diff', ...
                ts, special];
        else                                % text
            if isempty(x.listofitems)
                menu = {'command line'};
            else
                menu = [{'command line'},{'messages'}, ...
                    {'x13series object'},{'x13spec object'}, ...
                    hline,tbl,hline,txt,hline,other];
            end
        end
        if hpuOut.Value > numel(menu); hpuOut.Value = 1; end
        hpuOut.String = menu;
    end

    % make sure menu entry is not a separator line; store itemTextMenu or
    % itemPlotMenu, respectively
    function legit = GetMenuItem()
        legit = ~strcmp(hpuOut.String{hpuOut.Value},hline);
        if ~legit                   % it's a separator line
            RestoreStoredMenuItem();
        else
            if htglOut.Value        % update itemTextMenu or itemPlotMenu
                itemPlotMenu = hpuOut.String{hpuOut.Value};
            else
                itemTextMenu = hpuOut.String{hpuOut.Value};
            end
        end
    end

    % set menu item to stored last entries of text or plot menu, respectively
    function RestoreStoredMenuItem()
        if htglOut.Value
            idx = find(ismember(hpuOut.String,itemPlotMenu));
        else
            idx = find(ismember(hpuOut.String,itemTextMenu));
        end
        if isempty(idx); idx = 1; end
        hpuOut.Value = idx;     % set position in menu to stored entry
    end

%% *** make output in hedOut or haxOut ************************************

    % fill in htxtOut or haxOut, respectively
    function MakeOutput()
        % report time of run of current x13series
        if isempty(x.timeofrun{2})
            htxtTimeOfRun.String = '';
        else
            str = sprintf('%s (%3.1f sec)\n', ...
            datestr(x.timeofrun{1}), x.timeofrun{2});
            htxtTimeOfRun.String = str;
        end
        % make output in edOut or axOut, respectively
        out = hpuOut.String{hpuOut.Value};      % selected position in menu item
        if length(out)>4 && strcmp(out(1:4),'----')
            hpuOut.Value = 1;
            out = hpuOut.String{1};
        end
        [tbl,~,ts,other,special] = GetAllItems;     % 2nd arg (txt) is not used
        %
        % --- axes --------------------------------------------------------
        if htglOut.Value
            set(hedOut ,'Visible','off');
            set(haxOut ,'Visible','on' );
            slidersOn = true;
            vrbl = {'NA'};
            args = {};
            switch out
                case 'data'
                    vrbl = {'dat','cms'};
                case 'seasonally adjusted'
                    vrbl = {'d11','e2','s11','isa','sa','csa','ssa'};
                case 'trend-cycle'
                    vrbl = {'d12','s12','itn','tr','crp','stn'};
                    args = {'selection',[0 0 0 1 0 0 0 0 0 0 0 0 0]};
                case 'forecast'
                        vrbl = {x.keyv.dat,x.keyv.sa,x.keyv.tr,'fct','bct'};
                case 'seasonal factors'
                    vrbl = {'d10','s10','sf','csf'};
                case 'SF by period'
                    slidersOn = false;
                    vrbl = {'d10','s10','sf'};
                    args = {'byperiod'};
                case 'seasonal breaks'
                    slidersOn = false;
                    if all(ismember({'d10','d8'},x.listofitems))      % X-11
                        vrbl = {'d10','d8'};
                    elseif all(ismember({'s10','s8'},x.listofitems))  % SEATS
                        vrbl = {'s10','s8'};
                    elseif all(ismember({'s10','s13'},x.listofitems)) % SEATS but s8 missing
                        if strcmp(x.spec.transfunc,'log')
                            s8 = x.s10.s10 .* x.s13.s13;
                            x.addvariable('s8',x.s10.dates,s8,'s8',1, ...
                                'SEATS s10 * s13 (= SI)');
                        else
                            s8 = x.s10.s10 + x.s13.s13;
                            x.addvariable('s8',x.s10.dates,s8,'s8',1, ...
                                'SEATS s10 + s13 (= SI)');
                        end
                        vrbl = {'s10','s8'};
                    else
                        if all(ismember({'sf','si'},x.listofitems))   % fixedseas
                            vrbl = {'sf','si'};
                        elseif all(ismember({'ssf','ssi'},x.listofitems))
                            vrbl = {'ssf','ssi'};
                        end
                    end
                    args = {'byperiodnomean'};
                case 'holidays adjustments'
                    vrbl = {'hol'};
                case 'trading day adjustments'
                    vrbl = {'td'};
                case 'outliers'
                    vrbl = {'ao','ls','tc'};
                case 'combined adjustments'
                    vrbl = {'d16','s16','iaf'};
                case 'irregular'
                    vrbl = {'d13','e3','s13','iir','ir','sir'};
                case 'residuals'
                    vrbl = {'rsd'};
                case 'ACF and PACF'
                    slidersOn = false;
                    vrbl = {'acf','pcf'};
                case 'ACF squared'
                    slidersOn = false;
                    vrbl = {'ac2'};
                case 'spectrum of data'
                    slidersOn = false;
                    vrbl = {'sp0','st0','is0','it0','sxd','scd','ssd'};
                case 'spectrum of residuals'
                    slidersOn = false;
                    vrbl = {'spr','str'};
                case 'spectrum of adjusted series'
                    slidersOn = false;
                    vrbl = {'sp1','st1','s1s','t1s','is1','it1','sxs', ...
                        'scs','sss'};
                case 'spectrum of mod. irregular'
                    slidersOn = false;
                    vrbl = {'sp2','st2','s2s','t2s','is2','it2','sxr','ssr'};
                case 'sliding spans of SF'
                    try
                        nsp = numel(fieldnames(x.sfs))-4;
                        vrbl = {'sfs'};
                        args = {'selection',[ones(1,nsp) 0]};
                    end
                case 'sl sp of SF, max diff'
                    try
                        nsp = numel(fieldnames(x.sfs))-4;
                        vrbl = {'sfs'};
                        args = {'selection',[zeros(1,nsp) 1]};
                    end
                case 'sliding spans of SA'
                    try
                        nsp = numel(fieldnames(x.chs))-4;
                        vrbl = {'chs'};
                        args = {'selection',[ones(1,nsp) 0]};
                    end
                case 'sl sp of SA, max diff'
                    try
                        nsp = numel(fieldnames(x.chs))-4;
                        vrbl = {'chs'};
                        args = {'selection',[zeros(1,nsp) 1]};
                    end
                case 'sliding spans % yoy of SA'                            
                    try
                        nsp = numel(fieldnames(x.ycs))-4;
                        vrbl = {'ycs'};
                        args = {'selection',[ones(1,nsp) 0]};
                    end
                case 'sl sp % yoy of SA, max diff'                            
                    try
                        nsp = numel(fieldnames(x.ycs))-4;
                        vrbl = {'ycs'};
                        args = {'selection',[zeros(1,nsp) 1]};
                    end
                case 'revisions'
                    vrbl = {'sae'};
                case '% revisions'
                    vrbl = {'sar'};
                case ts
                    vrbl = {out};
                case [other(:)',special(:)']
                    slidersOn = false;
                    vrbl = {out};
            end
            keep = ismember(vrbl,x.listofitems);
            vrbl(~keep) = [];   % like intersect, but keeping order
            if slidersOn
                set(hslFrom,'Visible','on' );
                set(hslTo  ,'Visible','on' );
                if isnan(vecFirstDate)     % very first plot request since start
                    SetSliderLimits(vrbl);
                    GetSliders();
                elseif doKeepPlotRange
                    SetSliderLimits(vrbl); 
                    SetSliders();
                else
                    GetSliders();
                end
                opt = {'fromdate',datenum(vecFromDate), ...
                    'todate',datenum(vecToDate), ...
                    'options',{'linewidth',1},'quiet'};
            else
                set(hslFrom,'Visible','off');
                set(hslTo  ,'Visible','off');
                opt = {'options',{'linewidth',1},'quiet'};
            end
            cla(haxOut,'reset');                % clear content from axis
%            keep = ismember(vrbl,x.listofitems);
%            vrbl(~keep) = [];
            if ~isempty(vrbl)
                if numel(vrbl) == 1 || ismember(vrbl{1},{'sfs','chs','ycs'})
                    plot(haxOut,x,vrbl{:},args{:},opt{:});
                else
                    plot(haxOut,x,vrbl{:},args{:},'combined',opt{:});
                end
                if numel(vrbl) == 1 && strcmp(vrbl{1},out)
                % this is not one of the  prepared standard charts
                    descr = x.descrvariable(out);
                    if strcmp(descr,'---')
                        strTitle = out;
                    else
                        strTitle = [descr,' (',out,')'];
                    end
                    title(haxOut,strTitle);
                elseif ~all(contains([ts,other],out))
                    str = repmat('%s ',1,numel(vrbl)); str(end) = [];
                    strTitle = sprintf(['%s (',str,')'], ...
                        out,vrbl{:});
                    title(haxOut,strTitle);
                end
                drawnow;
            else
                cla(haxOut);
                haxOut.Visible = 'off';
            end
        else
        %
        % --- text --------------------------------------------------------
            set(hedOut ,'Visible','on' );
            set(haxOut ,'Visible','off');
            set(hslFrom,'Visible','off');
            set(hslTo  ,'Visible','off');
            switch out
                case 'command line'
                    str = ['spec = ',cmdlinespec];
                    if ~isempty(cmdx13)
                        str = {str,[],[cmdx13,cmdafter,';']};
                    end
                case 'messages'
                    str = x.showmsg;
                case 'x13series object'
                    str = dispstring(x);
                case 'x13spec object'
                    str = dispstring(x.spec);
                case tbl
                    str = x.table(out);
                otherwise   % txt, special, or items with unknown format
                    try
                        str = evalc(['disp(x.',out,')']);
                    catch
                        str = '(cannot display this content)';
                    end
            end
            set(hedOut,'String',str);
        end
    end

    % set min, max, and step sizes of the two sliders
    function SetSliderLimits(vrbl)
        idx = ismember(vrbl,x.listofitems);
        if any(idx)
            vrbl = vrbl(idx);
            FirstDate  = x.(vrbl{1}).dates(1);
            LastDate   = x.(vrbl{1}).dates(end);
            for v = 2:numel(vrbl)
                temp = x.(vrbl{v}).dates(1);
                if temp < FirstDate;  FirstDate = temp;  end
                temp  = x.(vrbl{v}).dates(end);
                if temp > LastDate;   LastDate = temp;   end
            end
            vecFirstDate = datevec(FirstDate); vecFirstDate(4:end) = [];
            vecLastDate  = datevec(LastDate);  vecLastDate(4:end)  = [];
            lengthData = x.period*(vecLastDate(1)-vecFirstDate(1)) + ...
                (vecLastDate(2)-vecFirstDate(2)*(x.period/12));
            hslFrom.SliderStep = [1/lengthData,x.period/lengthData];
            hslFrom.Max        = lengthData;
            hslTo.SliderStep   = [1/lengthData,x.period/lengthData];
            hslTo.Min          = -lengthData;
        else
            hslFrom.Visible = 'off';
            hslTo.Visible   = 'off';
        end
    end

    % set value of the two sliders to correspond to current date range
    function SetSliders()
        if datenum(vecFromDate) > datenum(vecLastDate) || ...
                datenum(vecToDate) < datenum(vecFirstDate)
            % incompatible date range (the user has estimates using some
            % date range, and then estimates again using a new date range
            % that is incompatible with the first date range)
            hslFrom.Value = 0; vecFromDate = vecFirstDate;
            hslTo.Value   = 0; vecToDate   = vecLastDate;
        else
            % hslFrom
            diff = vecFromDate - vecFirstDate;
            value = x.period*diff(1) + diff(2)*(x.period/12);
            value = min(value, hslFrom.Max);
            value = max(value, hslFrom.Min);
            if value > hslFrom.Max
                hslFrom.Value = hslFrom.Max;
            else
                hslFrom.Value = value;
            end
            % hslTo
            diff = vecToDate - vecLastDate;
            value = x.period*diff(1) + diff(2)*(x.period/12);
            value = min(value, hslTo.Max);
            value = max(value, hslTo.Min);
            if value < hslTo.Min
                hslTo.Value = hslTo.Min;
            else
                hslTo.Value = value;
            end
        end
    end

    % compute current date range from position of sliders
    function GetSliders()
        vecFromDate = addMonth(vecFirstDate,hslFrom.Value*(12/x.period));
        vecToDate   = addMonth(vecLastDate ,hslTo.Value  *(12/x.period));
    end

    % slider was moved (callback)
    function SliderMovement(varargin)
        hslFrom.Value = round(hslFrom.Value);
        hslTo.Value   = round(hslTo.Value);
        doKeepPlotRange = false;            % we explicitly want to change the
        MakeOutput();                       % current date-range of the plot
    end

    % add (or subtract) a number of months from a date
    % (always returns first or last day of month)
    function thedate = addMonth(thedate,n)
        if numel(thedate) == 1
            thedate = datevec(thedate);
        end
        ym = 12*thedate(1) + (thedate(2)-1) + n;
        m = mod(ym,12)+1;
        y = (ym-(m-1))/12;
        if thedate(3) < 15
            d = 1;
        else
            d = eomday(y,m);
        end
        thedate = [y,m,d];
    end

end     % --- end function
