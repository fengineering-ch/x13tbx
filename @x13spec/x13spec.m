% X13SPEC is the class definition for x13spec objects. Such an object is
% used to set all specifications of a run of the X-13ARIMA-SEATS program.
%
% Usage:
%   Specifications are entered as triples: section-key-value.
%   spec  = x13spec(section,key,value, section,key,value, ...);
%   spec2 = x13spec(spec1, section,key,value, section,key,value, ...);
%   spec3 = x13spec(spec1, section,key,value, spec2, section,key,value, ...);
%
% Remark 1: section-key-value syntax --------------------------------------
% spec = x13spec('series','title','rainfall','transform','function','auto')
% would set title = rainfall in the series section, and function = auto in the
% transform section. When using this with x13.m, this creates the following
% .spc file on the harddrive:
%   series{
%       title = rainfall
%   }
%   transform{
%       function = auto
%   }
% which is then used by the x13as.exe program.
%
% Remark 2: merging existing specs ----------------------------------------
% If existing x13spec objects are entered as arguments (second and third
% usage form above), the specifications are merged, from left to right,
% i.e. later section-key-value triplets or settings in later specs
% overwrite earlier ones.
% Example:
%   spec1 = x13spec('series','title','rainfall','x11','save','d10');
%   spec2 = x13spec(spec1,'series','title','snowfall');
% then spec2 contains save = d10 in the x11-section (inherited from spec1),
% but title = snowfall in the series-section (the title rainfall was
% overwritten).
%
% Remark 3: accumulating keys ---------------------------------------------
% The keys 'save','savelog','print','variables','aictest','types','user',
% 'usertype','keys','values','smoothmethod','methodarg' behave differently.
% These keys are accumulated,
%   spec = x13spec('x11','save','d10');
%   spec = x13spec(spec,'x11','save','d11');
% This does not overwrite the 'd10' value. Instead, 'd11' is added to the
% list of variables that ought to be saved, and spec contains
% save = (d10 d11) in the x11-section. To remove an item from one of these
% special keys, use the RemoveRequests function. There are also
% AddRequests and SaveRequests (to overwrite keys) methods.
%
% Multiple entries can be added to an accumulating key using different,
% equivalent syntaxes,
%   x13spec('x11','save','d10 d11 d13');
%   x13spec('x11','save','(d10 d11 d13)');
%   x13spec('x11','save',{'d10','d11','d13'});
%
% Remark 4: creating empty sections ---------------------------------------
% An empty section can be added by specifying an empty cell for the key,
% e.g. spec = x13spec('x11',{},{}) produces the entry
%   x11{ }
% in the .spc file.
%
% Remark 5: removing sections or keys from a spec -------------------------
% To remove a section completely, use an [] in place of the key, i.e. if
% spec has an 'x11' section, then spec = x13spec(spec,'x11',[],[]) removes
% the 'x11' section completely from this spec.
%
% To remove a key from a section, use an [] as value, as follows:
% spec = x13spec('x11','save','d10','x11','savelog','q') produces
%   x11{
%       save = d10
%       savelog = q
%   }
% Then spec = x13spec(spec,'x11','save',[]) removes the 'save' key and
% produces
%   x11{
%       savelog = q
%   }
% spec = x13spec(spec,'x11','save',{}), on the other hand, leaves the value
% of x11-save unchanged.
%
% Remark 6: user-defined variable -----------------------------------------
% The 'regression' and 'x11regression' sections allow the user to specify
% exogenous variables in the regressions that are not built in (like Easter
% or TD or AO2003.Jan). The names of such variables are added with the
% 'user' key, the type of the variables is specified with the 'usertype'
% key, and the exogenous variables themeselves are provided either with the
% 'data' key (in which case the data are part of the spec), or they are
% defined in an extra file and then the name of the file is specified with
% the 'file' key. You can use 'user', 'usertype', and 'data' in this
% fashion with x13spec. You could also use the 'file' key, but in that case
% you would have to make sure that your variables are stored as a table in
% plain ascii text in a file and then provide the path to this file in the
% spec. All of this is rather cumbersome.
%
% For this reason, x13spec provides a more convenient way. Suppose your
% exogenous variable is called 'strike' and is in your Matlab workspace.
% You can then simply say
% spec = x13spec(..., 'regression','user','strike', ...);
% The program will then create a file filename.udv containing the strike
% data in a form that is readable by the x13as program, and also adds the
% correct entries to the spec-file.
%
% If you have more than one user-definied exogenous variable, use this
% syntax,
% spec = x13spec(..., 'regression','user','(strike oilprice)', ...);
%
% Remark 7: error checking ------------------------------------------------
% x13spec allows you to set only sections that are known to the x13as
% program, and keys fitting to the respective sections. It does not check,
% however, if the values you assign are legal. If you assign illegal
% values you are likely to throw a runtime error by x13as.exe.
%
% For an explanation of all available options and settings, consult the
% documentation of the x13as program provided by the US Census Bureau.
%
% There is also a method spec.enforce(prog), where prog is the name of one
% of the US Census Bureau seasonal adjustment executable files, or a custom
% m-file that performs a seasonal adjustment. The procedure removes items
% from the spec that are not compatible with the program that is specified.
% Normally the user does not have to deal with this, as the .enforce method
% is automatically applied by x13.m whenever needed.
% 
% Remark 8: short vs long names of saveable variables ---------------------
% CAUTION: USE ONLY THE THREE-LETTER CODES FOR THE 'SAVE' KEY.
% The x13as program uses a long name and a short three-letter name for
% variables or tables (e.g. 'save = levelshift' in the .spc file is
% equivalent to 'save = ls'). For the 'save' key, the Matlab X-13 toolbox
% recognizes ONLY the short two-or-three-letter versions of these variable
% names,
%   x13spec('regression','save','ls')
% Using the long name,
%   x13spec('regression','save','levelshift')
% will cause problems, so avoid it.
%
% Remark 9: pickmdl file lists --------------------------------------------
% If the X-11 'pickmdl' method is used to select the regARIMA model, a list
% of models to choose from should be supplied. You can create such a model
% list file yourself, or use one of the files provided for you by the
% toolbox. The selection of these ready-to-use model files includes:
% - StatisticsCanada.pml    The default of Statistics Canada, contains
%                           5 models.
% - Hussain-McLaren-Stuttard.pml   5 models proposed by these authors.
% - ONS.pml                 Default of the Office of National Statistics,
%                           United Kingdom. 8 models. It's the union of
%                           Hussain-McLaren-Stuttard and StatisticsCanada.
% - pure2.pml               All ARIMA models (p d q)(P D Q) with p and q
%                           between 0 and 2, P and Q also between 0 and 2,
%                           d either 0 or 1, and D always equal to 1. Does
%                           not include mixed models (50 models).
% - pure3.pml               Same as pure2 but with p and q varying from 0
%                           to 3 (70 models).
% - pure4.pml and pure5.pml    Analogue (90 and 110 models, respectively).
% - st-pure2.pml and st-pure3.pml	Same as pure2 and pure3, respectively,
%                           but containing only stationary models (d = 0).
% - int-pure2.pml and int-pure3.pml	Same as pure2 and pure3, respectively,
%                           but containing only integrated models (d = 1).
% - mixed2.pml and mixed3.pml  Same as pure2 and pure3, respectively, but
%                           including mixed models (162 models and
%                           288 models, respectively).
% - ARIMA.pml               ARIMA models with no seasonal ARIMA part; all
%                           models from (0 0 0) to (3 1 3).
% To use one of these files, include the section-key-value triple
% 'pickmdl','file','ONS.pml' (as an example) in your x13spec command.
%
% You can also use your own model definition files. Your file must have
% the .pml extension and must be in the current directory, or you must
% provide the full path.
%
% If the pickmdl section is set but no file name is provided by the user,
% the toolbox will use pure3.pml.
%
% Remark 10: the fixedseas and camplet and custom sections ----------------
% x13spec also accommodates three sections that have no meaning for the
% x13as program. These sections are 'fixedseas', 'camplet', and 'custom'.
% The contents of these sections are not transmitted to x13as. Instead,
% they are passed to separate Matlab programs (fixedseas.m or camplet.m or
% a custom program specified in the x13 call by 'prog','name.m').
% 
% fixedseas computes a trend and seasonal adjustment using a much simpler
% method than X-13ARIMA-SEATS. The results are embedded into the x13series
% object as variables 'tr' (for trend), 'sf' (for seasonal factor), 'sa'
% (for seasonally adjusted), and 'ir' (for irregular). fixedseas is much
% less successful in removing seasonality that X-13ARIMA-SEATS is, but it
% has the advantage of producing seasonal factors that do not change over
% time. It is also computationally much cheaper, and works with arbitrary
% frequencies.
%
% The 'fixedseas' section supports the following keys:
% - 'period'    This is a single positive integer or a vector of
%               positive integers. It determines the frequencies that are
%               filtered out. If this key is not given, it is set equal to
%               obj.period (i.e. typically 4 or 12).
% - 'mode'      fixedseas does an additive or a multiplicative
%               (log-additive) decomposition of the data. You can specify
%               here which one to use. If this argument is omitted, the
%               decomposition is log-additive if obj.isLog is true and
%               additive otherwise.
% - 'save'      This is the list of variables that should be saved.
%               Possible values are ''tr', sa', 'sf', 'ir', and 'si'.
% - 'smothmethod'  Determines how the trend is computed. Default is 'ma' for
%               moving averages. Alternatives are 'hp' (for Hodrick-Prescott),
%               'detrend' (using Matlab's detrend function), 'spline', and
%               'polynomial'.
% - 'methodarg' Additional arguments for 'type' can be specified here. For
%               'hp', 'spline', and 'polynomial', see help fixedseas for
%               an explanation. With 'detrend', the additional argument
%               must be a date or datevector, indicating where breaks in
%               the trend should be allowed.
%
% camplet computes a seasonal adjustment proposed by Abeln and Jacobs, 2015.
% The results are embedded into the x13series object as variables 'sf'
% (seasonal factor), 'sa' (seasonally adjusted), as well as a couple of
% series unique to this algorithm (seee 'help camplet'). camplet is less
% successful in removing seasonality than X-13ARIMA-SEATS is, but it has
% the advantage that it is computationally much cheaper and works with
% arbitrary frequencies. Also, unlike fixedseas, it does allow for
% seasonality that is changing over time.
%
% The 'camplet' section supports the following keys:
% - 'period'    This is a single positive integer that determines the
%               frequency that is filtered out. If this key is not given,
%               it is set equal to obj.period (i.e. typically 4 or 12).
%               Unlike fixedseas, camplet does not support a vector for
%               'period', To perform multiple camplet filterings, run them
%               sequentially, using the original data first, and then the
%               output of the first filtering round (for the first frequency)
%               as the input for filtering out the second frequency, and so
%               on.
% - 'save'      This is the list of variables that should be saved.
%               Possible values are 'sa', 'sf', 'bar', 'fcs', 'fer', 'rer',
%               'gra', 'g', 'nol', 'psh', 'cca', 'ca', 'm', 'lle', 't'.
%
% - 'options'
% The following parameters are the ones defining the CAMPLET algorithm, see
% the working paper for explanations:
% - 'CA'        CA parameter (Common Adjustment).
% - 'M'         M parameter (Multiplier).
% - 'P'         P parameter (Pattern).
% - 'LE'        LE parameter (Limit to Error).
% - 'T'         T parameter (Times).
% - 'INITYEARS' The number of years used to initialize the algorithm. The
%               CAMPLET algorithms sets this to 3, but you can override this
%               choice.
% If set by the user, these are stored in the 'options' key of the struct.
%
% Note that camplet.m does an additive or a log-additive decomposition of
% the data. This choice is not stored in the camplet-transform or
% camplet-mode keys (which both do not exist), but rather in the
% transform-function key (outside of the camplet section).
%
% You can also define your own, custom m-file that performs a seasonal
% adjustment. You have to observe a few restrictions on the form of your
% output, so that it is readable for the toolbox. seas.m in the seas
% subfolder is an example of such a custom algorithm.
%
% The 'custom' section supports the following keys: 'period', 'mode',
% 'save', 'options'. What these mean and which values are legit depends on
% the custom m-file you use, and whose name is stored on the .prog property
% of the x13series object. The seas.m file is an example of such a custom
% file. It accepts in the 'mode' section either 'none', 'add', 'logadd',
% or 'mult'. In the 'save' section it accepts the same as fixedseas. seas.m
% does not use for the 'options' sections (but your own m-file could use
% this section).
%
% -------------------------------------------------------------------------
% PROPERTIES and METHODS
% 
% The resulting spec-object contains one property for each section entered.
% In addition, it also has the following properties:
% - isempty         boolean     spec.isempty returns true if the spec
%                               contains no sections.
% - isComposite     boolean     True if 'composite' is one of the series.
% - adjmethod       char        The name of the method used for seasonal
%                               adjustment, e.g. 'x11', 'seats',
%                               'fixedseas', ...
% - transfunc       char        The function stored in
%                               spec.transform.function. If that is
%                               missing, the content of
%                               spec.transform.power is mapped to either
%                               'none' or 'log' (or noting, if no mapping 
%                               is sensible).
% - adjmode         char        Typically 'add' or 'logadd' or 'mult'.
% - requesteditems  cells       All the variables requested for saving
%                               anywhere in the spec (with the 'save' key).
% - mainsec         char        Either 'series' or 'composite', depending
%                               on whether the spec belongs to composite
%                               data or not.
%
% Here are some methods that can be useful sometimes:
% - copy                obj2 = obj.copy creates an exact, but intependent
%                       copy of obj. Note that simply assigning obj2 = obj
%                       does not create an independent copy of obj, but
%                       only creates a handle to the same object. If you
%                       change properties of obj, they will also show up in
%                       obj2, and vice versa. The copy methods allows you
%                       to create independent instances.
% - specminus           spec3 = spec1.specminus(spec2) removes all
%                       components in spec1 that are also present in spec2
%                       and places the remainder into spec3.
%
% The following methods are useful when working with accumulation keys:
% - AddRequests adds values to an accumulating key. The syntax is
%   spec.AddRequests(series,key,value1,[value2, ...]). This is equivalent
%   to spec = x13series(spec,series,key,value1,[value2, ...]). The
%   following methods have the same syntax.
% - SaveRequests sets values to an accumulating key, overwriting existing
%   values.
% - KeepRequests removes all values not in the list of arguments.
% - RemoveRequests removes all the values in the arguments list.
% - RemoveKeys removes a whole key (or multiple keys) from a series.
% - KeepKeys removes all keys except the ones in the arguments list.
% - RemoveSections removes a whole section (or multiple sections) from a spec.
% - KeepSections removes all sections not in the arguments list.
% - AddSections adds empty section(s).
%
% spec.RemoveInconsistentSpecs cleans up spec so that it does not contain
%   obvious inconsistencies. For instance, save-requests that only make
%   sense for composites or for multiplicative decomopitions are removed if
%   the conditions are not met. Many more cases are covered and cleaned
%   up, although it is still possible that some inconsistencies remain.
% spec.enforce(progname) changes a spec so that it is conformant with a
%   particular program. For instance, spec.enforce('x12a.exe') makes the
%   spec compatible with the X-12 version. spec.enforce('fixedseas.m')
%   makes it compatible with fixedseas.m, etc.
%
% spec.Set_TransformFunction_From_TransformPower uses transform-power to set
%   transform-function to either 'none' or 'log'.
% spec.ExtractModeFormTransform uses transform-function to guess x11-mode
%   (or custom-mode etc, depending on the adjustment method that is
%   chosen).
% ExtractValues extracts values from a spec and returns them in the correct
%   format (as char, numerical, or cell array).
% disp displays a nicely formated content of the spec.
% display is a short form of disp.
% dispstring is the same as disp but returns a string that can be assigned
%   to a variable.
% 
% Some static methods are also available:
% [section,key] = legalize(section,key)
%   This checks is a section is legal and is paired with a legal key
%   belonging to that section. The input arguments can be abbreviated. The
%   non-abbreviated versions are returned.
% .toNum, .toCell, .toParen
%   These methods transform any input (if possible) into a numeric, a cell
%   or cellarray, and a char surrounded by parenthesis if there are
%   multiple components, where the components are separated by spaces.
%   (This is the way multiple values are stored in an .spc file).
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
% 2022-10-10    Version 1.52    enforce(...) now recognizes X-12 and X-13
%                               if the first four characters of the arg are
%                               'x12a' and 'x13a', respectively. This makes
%                               sure that if the program specified with
%                               'prog' is, for instance,
%                               'x13as_ascii_B58.exe' (the version 1.1
%                               build 58 of the X-13 program).
% 2021-06-07    Version 1.51    Bugfixes in .merge and .SaveRequests;
%                               better handling of non-sortable
%                               accumulating keys
% 2021-05-03    Version 1.50    Refactored and some new methods
%                               (.addtriplet, .merge, .enforce,
%                               .Set_TransformFunction_From_TransformPower)
%                               and some new properties (.adjmethod,
%                               .transfunc, .adjmode, .mainsec, .isempty)
% 2018-10-16    Version 1.33.1  Some support for spectrum in X-12-ARIMA.
% 2018-09-02    Version 1.33    Added enforceX12spec. Also removed one bug in
%                               legalize (pickmdl-identify replaced by
%                               pickmdl-identity). Moreover, the default model
%                               list for pickmdl has been changed from
%                               pure2.pml to pure3.pml
% 2017-03-10    Version 1.31    Adaptation to X13ARIMA-SEATS V1.1 B39.
% 2017-01-09    Version 1.30    First release featuring camplet.
% 2017-01-03    Version 1.21.1  Further bug fix related to not sorting user
%                               field.
% 2016-12-31    Version 1.21    Bug fix: regression-user was being sorted
%                               before, which leads to problems with
%                               regression-file and regression-usertype. (Bug
%                               was discovered while working on a question of
%                               Young-Min Kim.)
% 2016-08-19    Version 1.18    Better support for user-definied variables in
%                               'regression' and 'x11regression'.
% 2016-07-18    Version 1.17.4  Bug fix in special treatment of 'metadata' key.
% 2016-07-10    Version 1.17.1  Improved guix. Bug fix in x13series relating to
%                               fixedseas.
% 2016-07-06    Version 1.17    First release featuring guix.
% 2016-03-03    Version 1.16    Adapted to X-13 Version 1.1 Build 26.
% 2015-09-20    Version 1.15.1  Improved display of numerical values (in
%                               disp method). Improved help.
% 2015-08-20    Version 1.15    Significant speed improvement. The imported
%                               time series will now be mapped to the first
%                               day of month if this is the case for the
%                               original data as well. Otherwise, they will
%                               be mapped to the last day of the month. Two
%                               new options --- 'spline' and 'polynomial'
%                               --- for fixedseas. Improvement of .arima,
%                               bugfix in .isLog.
% 2015-07-28    Version 1.14.1  Making sure that values are always strings
%                               (except for 'period' key, where they are
%                               always numeric).
% 2015-07-25    Version 1.14    Improved backward compatibility. Overloaded
%                               version of seasbreaks for x13composite. New
%                               x13series.isLog property. Several smaller
%                               bugfixes and improvements.
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
% 2015-06-15    Version 1.12.1  Change in disp: 'series' or 'composite' are
%                               shown on top.
% 2015-05-21    Version 1.12    Several improvements: Ensuring backward
%                               compatibility back to 2012b (possibly
%                               farther); Added 'seasma' option to x13;
%                               Added RunsSeasma to x13series; other
%                               improvements throughout. Changed numbering
%                               of versions to be in synch with FEX's
%                               numbering.
% 2015-04-28    Version 1.6     x13as V 1.1 B 19
% 2015-04-02    Version 1.2     Adaptation to X-13 Version V 1.1 B19
% 2015-01-11    Version 1.1     accumulating keys; bugfix for removing
%                               sections and keys
% 2015-01-01    Version 1.05    error checking (only legal sections and
%                               corresponding keys accepted); abbreviation
%                               of sections and keys with 'validatestring';
%                               special formatting of 'metadata'
% 2014-12-31    Version 1.0     first version

%#ok<*CHARTEN>
%#ok<*AGROW>
%#ok<*TRYNC>
%#ok<*SEPEXR>
%#ok<*CPROP>
%#ok<*CPROPLC>

classdef x13spec < dynamicprops   %  & matlab.mixin.Copyable

%     properties(Constant)
%         version = '1.55';       % version of the toolbox
%     end

    properties (Dependent, Hidden)
        isempty;
        adjmethod;
        transfunc;
        adjmode;
        requesteditems;
        isComposite;
        mainsec;
        title;
        name;
    end
    
    properties (Constant, Hidden)
        % keys that can be accumulated, save = (d10 d11 d12), for instance.
        accKeys = {'save','savelog','print','variables','aictest','types', ...
            'user','usertype','keys','values','smoothmethod','methodarg'};
            % 'keys' and 'values' is for 'metadata'
            % 'smoothmethod' and 'methodarg' are used by 'fixedseas'
        % accumulating key values are normally sorted, except for the
        % following...
        nosortKeys = {{'user','usertype'},{'keys','values'}, ...
            {'smoothmethod','methodarg'}};
        % keys whose values are numerics
        numKeys = {'period','precision','missingcode','missingval','power', ...
            'maxorder'};
        % keys that store strings with spaces
        strKeys = {'title','name'};
    end
    
    % --- CONSTRUCTOR -----------------------------------------------------
    
    methods

        function obj = x13spec(varargin)
        % constructor of x13spec object
            while ~isempty(varargin)
                if isa(varargin{1},'x13spec')       % merge existing spec
                    obj = obj.merge(varargin{1});
                    varargin(1) = [];
                else
                    if numel(varargin) < 3          % add section-key-value
                        err = MException('X13TBX:x13spec:IllegalSyntax', ...
                            ['X-13 specifications must be triples: ', ...
                            '''section'', ''key'', ''value''.']);
                        throw(err);
                    end
                    obj = obj.addtriplet(varargin{1:3});
                    varargin(1:3) = [];
                end
            end
        end
        
        function s = copy(obj)
        % copy all the contents of a x13spec onto a fresh instance
            s = x13spec(obj);
        end
        
    end     % --- end of construction methods
    
    methods (Hidden)
        
        function obj = addtriplet(obj,section,key,value)
        % add section-key-value to a x13spec object
            
            % remove a section?
            if isempty(key) && isnumeric(key)           % key is []
                if isempty(value) && isnumeric(value)   % value is []
                    obj = RemoveSections(obj,section);
                    return
                else
                    err = MException('X13TBX:x13spec:addtriplet:IllegalSyntax', ...
                        'To remove a section, set key and value equal to [].');
                    throw(err);
                end
            end
            
            % legal entries?
            [section,key] = obj.legalize(section,key);
            
            % make sure section exists
            obj.AddSections(section);

            % keep empty section? (key is empty (but not []), and value is also empty
            if isempty(key) && isempty(value)
                return      % we are done here
            end

            % add values to spec
            if ismember(key,x13spec.accKeys)            % accumulating key
                if (isempty(value) && isnumeric(value))
                    % remove accumul key only if value is []
                    obj.RemoveKeys(section,key);
                else
                    % add entries to accumul key
                    obj = obj.AddRequests(section,key,value);
                end
            else                                        % ordinary key
                if isempty(value)
                    % remove key; keys without values are not allowed
                    obj = RemoveKeys(obj,section,key);
                else
                    % write value into spec
                    if strcmp(key,'name')   % special treatment of 'name' key
                        % -------------------------------------------------------
                        % the following is taken from x13series.LegalVariableName
                        if isnumeric(value)
                            value = mat2str(value);
                        end
                        try
                            value = matlab.lang.makeValidName(value);
                        catch
                            value = genvarname(value);
                        end
                        % -------------------------------------------------------
                    else
                        if ismember(key,x13spec.strKeys)
                            if ~ischar(value)
                                err = MException('X13TBX:x13spec:IllArg', ...
                                    'Values for key ''%s'' must be characters.', ...
                                    key);
                                throw(err);
                            end
                        else
                            value = x13spec.toParen(value);
                        end
                    end
                    obj.(section).(key) = value;
                end
            end
            
        end
        
        function obj = merge(obj,varargin)
        % merge specs
            allSections = {};
            for v = 1:numel(varargin)
                newObj = varargin{v};
                newSections = fieldnames(newObj);
                allSections = [allSections(:);newSections(:)];
            end
            remove = contains(allSections,fieldnames(obj));
            newSections = allSections(~remove);
            obj.AddSections(newSections);
            for v = 1:numel(varargin)
                newObj = varargin{v};
                newSections = fieldnames(newObj);
                for sec = 1:numel(newSections)
                    keys = fieldnames(newObj.(newSections{sec}));
                    for k = 1:numel(keys)
                        obj = obj.addtriplet(newSections{sec}, keys{k}, ...
                            newObj.(newSections{sec}).(keys{k}));
                    end
                end
            end
        end
        
    end     % -- end of hidden construction methods
    
    % --- GET METHODS -----------------------------------------------------
    
    methods
    
        function b = get.isempty(obj)
        % spec.isempty evaluates to true if spec has no sections. This is
        % not the same as isempty(spec), which always evaluates to false.
            b = isempty(fieldnames(obj));
        end

        function b = get.isComposite(obj)
        % true if 'composite' section found in the spec
            b = (ismember('composite',fieldnames(obj)));
        end
        
        function str = get.mainsec(obj)
        % returns 'series' or 'composite', depending on whether 'composite'
        % section exists in the spec or not
            if obj.isComposite
                str = 'composite';
            else
                str = 'series';
            end
        end
        
        function str = get.title(obj)
        % extracts the title from either 'series' or 'composite'
            str = obj.ExtractValues(obj.mainsec,'title');
        end
        
        function str = get.name(obj)
        % returns the name stored in spec, or a valid variable name
        % constructed from the title
            str = obj.ExtractValues(obj.mainsec,'name');
            if isempty(str)
                str = obj.title;
                if isempty(str)
                    str = 'no_name';
                else
                    try
                        str = matlab.lang.makeValidName(str);
                    catch
                        str = genvarname(str);
                    end
                    str(31:end) = [];   % upper bound on length
                end
            end
        end
        
        function TF = get.transfunc(obj)
            TF = obj.ExtractValues('transform','function');
            if isempty(TF)
                TP = obj.ExtractValues('transform','power');
                if TP == 0; TF = 'log' ; end
                if TP == 1; TF = 'none'; end
            end
        end
        
        function M = get.adjmethod(obj)
        % returns the method used: X11, SEATS, FIXEDSEAS, CAMPLET, CUSTOM
            fn = fieldnames(obj);
            selection = {'x11','seats','fixedseas','camplet','custom'};
            hit = contains(selection,fn);
            switch sum(hit)
                case 0
                    M = '';
                case 1
                    M = selection{hit};
                otherwise
                    M = selection(hit);
                    warning('X13TBX:x13spec:adjmethod:MultipleMethods', ...
                        ['Multiple methods present %s. This is unlikely ', ...
                         'to be legal.'], ['(''',strjoin(M,''','''),''')']);
            end
        end
        
        function M = get.adjmode(obj)
        % returns the adjustment mode used (add, logadd, mult) if it is
        % set; if it is not set an attempt is made to guess from the
        % fransform setting
            method = obj.adjmethod;
            M = obj.ExtractValues(method,'mode');
            if isempty(M)
                TF = obj.transfunc;
                switch TF
                    case 'none'; M = 'add';
                    case 'log' ; M = 'logadd';
                end
            end
        end

        function V = get.requesteditems(obj)
        % returns list of items requested for saving
            V = '';
            sections = fieldnames(obj);
            for s = 1:numel(sections)
                newV = ExtractValues(obj,sections{s},'save');
                V = [V,newV];
            end
        end
        
    end     % --- end of get methods

    % --- DISPLAY METHODS -------------------------------------------------
    
    methods
        
        function disp(obj)
        % long form display of x13spec object
            if ~(numel(obj)==1) || obj.isempty
                display(obj);
            else
                display(dispstring(obj));
            end
        end

        function str = display(obj) %#ok<DISPLAY>
        % short form display of x13spec object
            [nrow,ncol] = size(obj);
            if nrow*ncol == 1
                str = sprintf(' Seasonal Adjustment Specification\n');
                method = obj.adjmethod;
                if ~iscell(method) && ~isempty(method)
                    str = [str, sprintf(' Uses adjustment method %s.\n', ...
                        upper(method))];
                end
                n = numel(properties(obj));
                if n == 0
                    str = [str, ' The object is empty.'];
                    disp(str);
                    return;
                elseif n == 1
                    str = [str, ' Contains 1 section.'];
                else
                    str = [str, sprintf(' Contains %i sections.', n)];
                end
                str = [str,newline,' (use disp(obj) to see details).'];
                disp(str);
            else
                fprintf(['%ix%i <a href="matlab:helpPopup x13spec">', ...
                    'x13spec</a> array.\n'], nrow, ncol);
            end
        end
        
        function str = dispstring(obj)
        % long form display of x13spec object, return as string
            dline = [repmat('=',1,78),char(10)];
            sline = [repmat('.',1,78),char(10)];
            str = dline;
            str = [str, sprintf(' Seasonal Adjustment Specification\n')];
            fn = fieldnames(obj);
            fn = sort(fn);
            loc = ismember(fn,{'series','composite'});
            fn = [fn(loc);fn(~loc)];
            str = [str, sline];
            for f = 1:numel(fn)
                str = [str, sprintf(' - %s\n',fn{f})];
                sect = obj.(fn{f});
                keys = fieldnames(sect);
                nk = numel(keys);
                for k = 1:nk
                    if k < nk
                        str = [str,'    ',char(9500),char(9472),' '];
                    else
                        str = [str,'    ',char(9492),char(9472),' '];
                    end
                    if ismember(keys{k},x13spec.strKeys)
                        value = ['''',sect.(keys{k}),''''];
                    else
                        toprint = testFixedseasBreakpoint();
                        value = x13spec.toParen(toprint);
                    end
                    str = [str, keys{k}, ' : ', value, char(10)];
                end
            end
            str = obj.wrapLinesSpecial(str);
            
            % fixedseas - smoothmethod - detrend with fixedseas - methodarg
            % requires special treatment
            function toprint = testFixedseasBreakpoint()
                toprint = sect.(keys{k});
                if ~strcmp(fn{f},'fixedseas'); return; end
                if ~ismember('smoothmethod',fieldnames(sect)); return; end
                if ~strcmp('detrend',sect.smoothmethod); return; end
                if ~strcmp(keys{k},'methodarg'); return; end
                toprint = datestr(x13spec.toNum(sect.(keys{k})));
                [r,c] = size(toprint);
                if r == 1; return; end
                toprint = toprint';
                C = cell(1,r);
                for rr = 0:r-1
                    C{rr+1} = toprint(c*rr+1:c*(rr+1));
                end
                toprint = C;
            end
            
        end
        
    end     % --- end of display methods
    
    % --- ADD and REMOVE SPECS --------------------------------------------
    
    methods
        
    % --- basic operations ------------------------------------------------
    
        function obj = AddSections(obj,newSections)
        % adds an empty section to a struct
            if ~iscell(newSections); newSections = {newSections}; end
            for s = 1:numel(newSections)
                if ~ismember(newSections{s},fieldnames(obj))
                    obj.addprop(newSections{s});
                    obj.(newSections{s}) = struct;
                end
            end
        end
        
        function obj = RemoveSections(obj,rem)
        % remove a section (or multiple sections) from a spec
            if ~iscell(rem); rem = {rem}; end
            rem = intersect(rem,fieldnames(obj));
            for f = 1:numel(rem)
                delete(findprop(obj,rem{f}));
            end
        end
    
        function obj = KeepSections(obj,legal)
        % keep only supported sections
            fn = fieldnames(obj);
            rem = ~ismember(fn,legal);
            obj = RemoveSections(obj,fn(rem));
        end
        
        function obj = RemoveKeys(obj,section,keys)
        % removes a key (or multiple keys) from a particular section in a spec
            if ismember(section,fieldnames(obj))
                if ~iscell(keys); keys = {keys}; end
                s = obj.(section);
                keys = intersect(keys,fieldnames(s));
                s = rmfield(s,keys);
%                 if numel(fieldnames(s)) > 0
%                     obj.(section) = s;
%                 else
%                     obj = obj.RemoveSections(section);
%                 end
                obj.(section) = s;
            end
        end
        
        function obj = KeepKeys(obj,section,legal)
        % keep only supported keys of a sections
            try
                fn = fieldnames(obj.(section));
                rem = ~ismember(fn,legal);
                obj = RemoveKeys(obj,section,fn(rem));
            catch
%                fprintf('KeepKeys: section ''%s'' failed\n',section); 
            end
        end
        
        function req = ExtractValues(obj,section,key,class)
        % get the value of a section-key, formatted correctly (paren, cell,
        % or numeric), depending on the type of key
        
            % determine class to be returned
            if nargin < 4 || isempty(class)
                if ismember(key,x13spec.numKeys)
                    class = 'num';
                elseif ismember(key,x13spec.accKeys)
                    class = 'cell';
                elseif ismember(key,x13spec.strKeys)
                    class = 'string';
                else
                    class = 'paren';
                end
            end
            
            % extract requests
            req = [];
            if ismember(section,fieldnames(obj))
                if isstruct(obj.(section)) && ismember(key,fieldnames(obj.(section)))
                    req = obj.(section).(key);
                end
            end
            
            % format output
            switch class
                case 'num'
                    req = x13spec.toNum(req);
                case 'cell'     
                    req = x13spec.toCell(req);
                case 'string'
                    req = x13spec.toParen(req);
                    if length(req)>1 && strcmp(req([1,end]),'()')
                        req = req(2:end-1);
                    end
                otherwise
                    req = x13spec.toParen(req);
            end
            
%             if ismember(key,x13spec.numKeys)
%                 req = x13spec.toNum(req);
%             elseif ismember(key,x13spec.accKeys)
%                 req = x13spec.toCell(req);
%             elseif ismember(key,x13spec.strKeys)
%                 req = x13spec.toParen(req);
%                 if length(req)>1 && strcmp(req([1,end]),'()')
%                     req = req(2:end-1);
%                 end
%             else
%                 req = x13spec.toParen(req);
%             end

        end
        
        function obj = SaveRequests(obj,section,key,items)
        % assigns requests to accumulating key, overwriting existing entries
            [section,key] = obj.legalize(section,key);
            obj = obj.AddSections(section);
            items = x13spec.toParen(items);
            % The key is not added if there are no values. Accumulating
            % keys with no values are not legal.
            if ~isempty(items)
                obj.(section).(key) = items;
            end
        end
        
        function obj = AddRequests(obj,section,key,items)
        % adds requests to an accumulating key
            items = x13spec.toCell(items);
            req = ExtractValues(obj,section,key);
            if ismember(key,[x13spec.nosortKeys{:}])
                if ~isempty(req)
                    items = [req, items];
                end
            else
                items = unique([req,items]);
            end
            obj = obj.SaveRequests(section,key,items);
        end
        
        function obj = RemoveRequests(obj,section,key,items)
        % removes items from an accumulating key
            items = x13spec.toCell(items);
            req = ExtractValues(obj,section,key,'cell');
            if isempty(req); return; end
            if ismember(key,[x13spec.nosortKeys{:}])
                keep = ~ismember(req,items);
                pos = find(ismember([x13spec.nosortKeys{:}],key));
                pos = ceil(pos/2);
                if any(keep)
                    for k=1:2
                        thekey  = x13spec.nosortKeys{pos}{k};
                        thevals = ExtractValues(obj,section,thekey,'cell');
                        obj = SaveRequests(obj,section,thekey,thevals(keep));
                    end
                else
                    obj = RemoveKeys(obj,section,x13spec.nosortKeys{pos});
                end
            else
                keep = ~ismember(req,items);
                if any(keep)
                    obj = SaveRequests(obj,section,key,req(keep));
                else
                    obj = RemoveKeys(obj,section,key);
                end
            end
        end
        
        function obj = KeepRequests(obj,section,key,legal)
        % keep only those requested variables that are in a list of legal variables
            req = ExtractValues(obj,section,key,'cell');
            if ~isempty(req)
                rem = ~ismember(req,legal);
                obj = RemoveRequests(obj,section,key,req(rem));
            end
        end
        
    % --- set transform-function from transform-power if possible ---------
    
        function obj = Set_TransformFunction_From_TransformPower(obj)
            TP = obj.ExtractValues('transform','power');
            TF = obj.ExtractValues('transform','function');
            if isempty(TP)      % power not specified, nothing to do
                return;
            elseif isempty(TF)  % power specified but function not
                                % -> infer function from power if possible and
                                % change spec accordingly 
                switch TP
                    case 0; TF = 'log' ;
                    case 1; TF = 'none';
                    otherwise; TF = [];
                end
                if ~isempty(TF)
                    obj = x13spec(obj, 'transform','function',TF, ...
                        'transform','power',[]);
                end
            else                % power AND function spcified
                if (TP == 0 && strcmp(TF,'log')) || (TP == 1 && strcmp(TF,'none'))
                    obj = obj.RemoveKeys('transform','power');
                else
                    warning(['''transform'' is set to ''%s'' and ''power'' ', ...
                        'is %s. This is inconsistent.'], TF, num2str(TP));
                end
            end
        end
        
        function obj = Set_Mode_From_Transform(obj)
            method = obj.adjmethod;
            mode   = obj.adjmode;
            if ~isempty(method)
                obj = x13spec(obj,method,'mode',mode);
            end
        end
        
    % --- remove inconsistencies and enforce compatibility ----------------
        
        function obj = RemoveInconsistentSpecs(obj)
        % removes some (not all) inconsistencies in specifications

            % only one of X11 or SEATS or FIXEDSEATS or CAMPLET or CUSTOM
            allTypes = {'x11','seats','fixedseas','camplet','custom'};
            requestedTypes = ismember(allTypes,fieldnames(obj));
            if sum(requestedTypes)>1
                keep = find(requestedTypes,1,'first');
                obj = obj.KeepSections(allTypes{keep});
            end
            
            % X11REGRESSION only with X11
            test = ismember({'x11','x11regression'},fieldnames(obj));
            if ~test(1) && test(2)
                obj = x13spec(obj,'x11regression',[],[]);
            end

            % TRAMO has an upper bound on the ARIMA, with SEATS the bound
            % is more binding
            if ismember({'automdl'},fieldnames(obj))
                if ismember('maxorder',fieldnames(obj.automdl))
                    v = obj.ExtractValues('automdl','maxorder');
                    if ismember({'seats'},fieldnames(obj))
                        if v(1) > 3; v(1) = 3; end
                    else
                        if v(1) > 4; v(1) = 4; end
                    end
                    if v(2) > 2; v(2) = 2; end
                    obj = x13spec(obj,'automdl','maxorder',v);
                end
            end

            % only for composites ...
            if ~ismember('composite',fieldnames(obj))
                obj = RemoveRequests(obj,'history','save',{'iae','iar'});
                obj = RemoveRequests(obj,'slidingspans','save', ...
                    {'cis','ais','sis','yis'});
                obj = RemoveRequests(obj,'spectrum','save', ...
                    {'is0','is1','is2','it0','it1','it2'});
            end

            % not X-11 or SEATS (likely some m-file)
            if ~ismember('x11',fieldnames(obj)) && ~ismember('seats',fieldnames(obj))
                obj = RemoveRequests(obj,'spectrum','save', ...
                    {'st0','st1','st2','str'});
            end
            
            % not SEATS (only for X11 or m-files) ...
            if ismember('seats',fieldnames(obj))
                obj = RemoveRequests(obj,'spectrum','save', ...
                    {'sp1','sp2','st1','st2'});
            end

            % only for SEATS ...
            if ~ismember('seats',fieldnames(obj))
                obj = RemoveRequests(obj,'spectrum','save', ...
                    {'s1s','s2s','t1s','t2s'});
                obj = RemoveRequests(obj,'history','save','smh');
            end
            
            % only for multiplicative
            % 1) Default of x11/mode is 'mult'. If 'mode' is 'add' or
            %    'pseudoadd', the decomposition is not multiplicative.
            req = ExtractValues(obj,'x11','mode');
            req = x13spec.toCell(req);
            isMultiplicative = ~any(ismember({'add','pseudoadd'},req));
            % 2) If transform/function is 'log' or 'auto', the
            %    transformation is multiplicative.
            if ~isMultiplicative
                req = ExtractValues(obj,'transform','function');
                isMultiplicative = any(ismember({'log','auto'},req));
            end
            % remove tables that give results as percentage points (these
            % are computed only if the transformation is multiplicative)
            if ~isMultiplicative
                obj = RemoveRequests(obj,'composite','save', ...
                    {'ipa','ip8','ipi','ipf','ipr','ip6','ips','ip7','ip5'});
                obj = RemoveRequests(obj,'force','save', ...
                    {'p6a','p6r'});
                obj = RemoveRequests(obj,'seats','save', ...
                    {'psa','psi','psc','pss'});
                obj = RemoveRequests(obj,'x11','save', ...
                    {'paf','pe8','pir','pe5','pe6','psf','pe7'});
            end

        end
        
        function obj = enforce(obj,prog)
        % Forces a x13spec to conform to settings understandable by a
        % particular seasonal adjustment program. 'prog' can be
        % 'x13as_ascii.exe' for example.
            switch prog
                case {'x13as_ascii.exe','x13as_html.exe'}
                    obj = obj.enforceX13;
                case {'x12a.exe','x12a64.exe'}
                    obj = obj.enforceX12;
                case 'x11.m'
                    obj = obj.enforceX11;
                case 'method1.m'
                    obj = obj.enforceMETHOD1;
                case 'fixedseas.m'
                    obj = obj.enforceFIXEDSEAS;
                case 'camplet.m'
                    obj = obj.enforceCAMPLET;
                otherwise
                    [~,~,ext] = fileparts(prog);
                    if strcmp(ext,'.m')
                        obj = obj.enforceCUSTOM;
                    elseif strcmp(ext,'.exe')
                        % This is to capture older versions like
                        % 'x13as_ascii_B58.exe':
                        switch prog(1:4)
                            case 'x13a'
                                obj = obj.enforceX13;
                            case 'x12a'
                                obj = obj.enforceX12;
                        end
                    end
            end
        end
        
    end     % end of 'add and remove specs' methods
    
    methods (Hidden)
        
        function obj = enforceX13(obj)
        % translates some of the options that have been repositioned (from
        % the 'series' into the 'spectrum' section) and renamed in X-13

            % translate spectrum entries from X-12 to X-13
            keys = { ...
                'spectrumstart'     'start'
                'diffspectrum'      'difference'
                'maxspecar'         'maxar'
                'spectrumseries'    'series'
                'spectrumtype'      'type'
                'peakwidth'         'peakwidth'
                };
                 
            section = obj.mainsec;
            for k = 1:size(keys,1)
                value = ExtractValues(obj,section,keys{k,1});
                if ~isempty(value)
                    obj = x13spec(obj,'spectrum',keys{k,2},value);
                end
            end
            obj = x13spec(obj, ...
                section,       'spectrumstart',    [], ...
                section,       'diffspectrum',     [], ...
                section,       'maxspecar',        [], ...
                section,       'peakwidth',        [], ...
                section,       'spectrumseries',   [], ...
                section,       'spectrumtype',     []);
            
            obj.RemoveRequests('composite','save','is0 is1 is2');
            obj.RemoveRequests('series','save','sp0');
            obj.RemoveRequests('check','save','spr');
            % obj.RemoveRequests('x11','save','sp1 sp2');   % dealt with
                                                            % below
            
            % deal with other sections
            
            obj = RemoveSections(obj,{'fixedseas','camplet','custom'});
            
            x11keep = {'e2','e3','d8','d10','d11','d12','d13','d16','c20ars', ...
                'bcf','chl','c20','d4','d8','d10','d11','d12','d13','d16', ...
                'd18','d8b','d9','e1','e11','e18','e2','e3','e4','e5','e6', ...
                'e7','e8','f1','fad','fsd','ira','sac','tac','tad','tal', ...
                'paf','pe8','pir','pe5','pe6','psf','pe7ars','b10','b11', ...
                'b13','b17','b19','b2','b20','b3','b5','b6','b7','b8','bcf', ...
                'c1','c10','c11','c13','c17','c19','c2','c20','c4','c5','c6', ...
                'c7','c9','chl','d1','d10','d11','d12','d13','d16','d18','d2', ...
                'd4','d5','d6','d7','d8','d8b','d9','e1','e11','e18','e2','e3', ...
                'e4','e5','e6','e7','e8','f1','fad','fsd','ira','sac','tac', ...
                'tad','tal','paf','pe8','pir','pe5','pe6','psf','pe7'};
            obj = obj.KeepRequests('x11','save',x11keep);
            
        end

        function obj = enforceX12(obj)
        % removes specifications not supported by X-12; translates the
        % 'spectrum' series from X-13 into X-12 nomenclature; removes some
        % new options not supported by X-12

            % translate spectrum options from X-13 to X-12
            
            if ismember('spectrum',fieldnames(obj))
                
                if obj.isComposite
                    obj = x13spec(obj, 'composite','save','is0 is1 is2', ...
                        'check','save','spr');
                else
                    obj = x13spec(obj, 'series','save','sp0', ...
                        'x11','save','sp1 sp2', 'check','save','spr');
                end
                
                section = obj.mainsec;
            
                obj = x13spec(obj, section,'spectrumseries','b1');
                keys = { ...
                    'start'         'spectrumstart'
                    'difference'    'diffspectrum'
                    'maxar'         'maxspecar'
                    'series'        'spectrumseries'
                    'type'          'spectrumtype'
                    'peakwidth'     'peakwidth'
                    };
                for k = 1:size(keys,1)
                    value = ExtractValues(obj,'spectrum',keys{k,1});
                    if ~isempty(value)
                        obj = x13spec(obj,section,keys{k,2},value);
                    end
                end
            end
            
            % remove options that are not supported by X-12
            obj = x13spec(obj, ...
                'seats',        [],                 [], ...
                'spectrum',     [],                 [], ...
                'check',        'acflimit',         [], ...
                'check',        'qlimit',           [], ...
                'forecast',     'lognormal',        [], ...
                'outlier',      'savelog',          [], ...
                'regression',   'chi2test',         [], ...
                'regression',   'chi2testcv',       [], ...
                'regression',   'pvaictest',        [], ...
                'regression',   'tlimit',           [], ...
                'regression',   'testalleaster',    []);
            if obj.isComposite
                obj = x13spec(obj, ...
                    'composite',    'indoutlier',       []);
            end
            
            % deal with other sections
            obj = RemoveSections(obj, ...
                {'seats','spectrum','fixedseas','camplet','custom'});
            x11keep = {'b1f','b2','b3','b4','b5','b6','b7','b8','b9','b10', ...
                'b11','b13','b17','b19','b20', ...
                'c1','c2','c4','c5','c6','c7','c9','c10','c11','c13','c17', ...
                'c19','c20', ...
            	'd1','d2','d4','d5','d6','d7','d8','d9','d10','d11','d12','d13', ...
                'd16','d18','d8b','d8f', ...
                'e1','e2','e3','e4','e5','e6','e7','e8','e11','e18','f1', ...
                'asf','iao','sac','tal','tac','fad','chl','rsf','fsd', ...
                'sp1','sp2','tdy','tad'};
            obj = obj.KeepRequests('x11','save',x11keep);
            
        end

        function obj = enforceX11(obj)
        % removes specifications not supported by x11.m

            obj = enforceBasic(obj,'x11');
            obj = obj.KeepKeys('transform',{'function'});
            obj = obj.KeepRequests('transform','function',{'none','log'});
            obj = obj.KeepRequests('x11','mode',{'add','logadd','mult'});
            
            obj = obj.KeepKeys('x11',{'save','mode'});
            x11keep = {'b1','b2','b3','b4','b4a','b4b','b4c','b4d','b4e','b4f', ...
                'b4g','b5','b5a','b5b','b6','b7','b7a','b7b','b7c','b7d','b8', ...
                'b9','b9a','b9b','b9c','b9d','b9e','b9f','b9g','b10','b11','b13', ...
                'b17','b20','c1','c2','c4','c5','c5a','c5b','c6','c7','c7a', ...
                'c7b','c7c','c7d','c9','c10','c11','c13','c17','c20','d1', ...
                'd2','d4','d5','d5a','d5b','d6','d7','d7a','d7b','d7c','d7d', ...
                'd8','d9','d10','d11','d12','d13','d18','e1','e2','e3', ...
                'e11'};  % ,'f1'};
            obj = obj.KeepRequests('x11','save',x11keep);
        
        end
        
        function obj = enforceMETHOD1(obj)
        % removes specifications not supported by method1.m

            obj = obj.KeepKeys('transform',{'function'});
            obj = obj.KeepRequests('transform','function',{'none','log'});
            obj = obj.KeepRequests('x11','mode',{'add','logadd','mult'});
            
            obj = obj.KeepKeys('x11',{'save','mode'});
            x11keep = {'d8','d10','d11','d12','d13', ...
                'b2','b3','b4','b6','b1'};
            obj = obj.KeepRequests('x11','save',x11keep);
            
        end
        
        function obj = enforceCAMPLET(obj)
        % removes specifications not supported by camplet.m
            obj = enforceBasic(obj,'camplet');
            obj = obj.KeepKeys('transform',{'function'});
            obj = obj.KeepRequests('transform','function',{'none','log'});
            obj = x13spec(obj,'regression',[],[]);  % no calendar adj, hence no regr
            obj = obj.KeepRequests('spectrum','save',{'sp0','sp1'});
        end
        
        function obj = enforceFIXEDSEAS(obj)
        % removes specifications not supported by fixedseas.m
            obj = enforceBasic(obj,'fixedseas');
            obj = obj.KeepKeys('x11',{'mode'});
            obj = obj.KeepRequests('x11','mode',{'add','logadd','mult'});
            obj = obj.KeepKeys('transform',{'function'});
            obj = obj.KeepRequests('transform','function',{'none','log'});
        end
        
        function obj = enforceCUSTOM(obj)
        % removes specifications not likely to be supported by custom
        % seasonal adjustment programs
            obj = enforceBasic(obj,'custom');
        end
        
        function obj = enforceBasic(obj,method)
        % a common enforce routine used by other enforce routines
            obj = KeepSections(obj, {'composite','series',method, ...
                'transform','spectrum','regression'});
            obj = obj.KeepKeys('series',{'period','title','name'});
            obj = Set_TransformFunction_From_TransformPower(obj);
            obj = obj.KeepKeys('transform',{'function','power'});
            obj = obj.KeepKeys('spectrum',{'save'});
            obj = obj.KeepRequests('spectrum','save',{'sp0','sp1','sp2','spr'});
            obj = obj.KeepKeys('regression',{'save'});
            obj = obj.KeepRequests('regression','save',{'hol','td'});
            ser = fieldnames(obj);
            for s = 1:numel(ser)
                obj.RemoveKeys(ser{s},'print');
            end
        end
        
    end     % --- end of hidden enforce methods
    
    % --- CHECK LEGALITY AND FORMAT DATA ----------------------------------

    methods (Static)
        
        function [section,key] = legalize(section,key)
        % return full name of legal section or of key given section
        
            legalsections = {'arima','automdl','check','composite', ...
                'estimate','force','forecast','history','identify', ...
                'metadata','outlier','pickmdl','regression','seats', ...
                'series','slidingspans','spectrum','transform','x11', ...
                'x11regression','fixedseas','camplet','custom'};
            
            legalkeys = { ...
                {'ar','ma','model','title'}, ...                    % arima
                {'acceptdefault','checkmu','diff','fcstlim', ...    % automdl
                 'ljungboxlimit','maxdiff', 'maxorder', 'mixed', ...
                 'print','rejectfcst','savelog','armalimit', ...
                 'balanced','exactdiff','hrinitial','reducecv', ...
                 'urfinal','seasonaloverdiff'}, ...
                {'maxlag','print','qtype','save','savelog', ...     % check
                 'acflimit','qlimit'}, ...
                {'appendbcst','appendfcst','decimals', ...          % composite
                 'modelspan','name','print','save','savelog', ...
                 'title','type','indoutlier','saveprecision', ...
                 'yr2000', ...
                 'spectrumstart','diffspectrum','maxspecar', ...    % (X-12 only)
                 'peakwidth','spectrumseries','spectrumtype'}, ...
                {'exact','maxiter','outofsample','print', ...       % estimate
                 'save','savelog','tol','file','fix'} ...,
                {'lambda','mode','print','rho','round','save', ...  % force
                 'start','target','type','usefcst','indforce'}, ...
                {'exclude','lognormal','maxback','maxlead', ...     % forecast
                 'print','probability','save'}, ...
                {'endtable','estimates','fixmdl','fixreg', ...      % history
                 'fstep','print','save','sadjlags','savelog', ...
                 'start','target','trendlags','fixx11reg', ...
                 'outlier','outlierwin','refresh','transformfcst', ...
                 'x11outlier'}, ...
                {'diff','maxlag','print','save','sdiff'}, ...       % identify
                {'keys','values'}, ...                              % metadata
                {'critical','lsrun','method','print','save', ...    % outlier
                 'savelog','span','types','almost','tcrate'}, ...
                {'bcstlim','fcstlim','file','identity', ...         % pickmdl
                 'method','mode','outofsample','overdiff', ...
                 'print','qlim','savelog'}, ...
                {'aicdiff','aictest','chi2test','chi2testcv', ...   % regression
                 'file','data','format','print','pvaictest', ...
                 'save','savelog','start','tlimit','user', ...
                 'usertype','variables','b','centeruser', ...
                 'eastermeans','noapply','tcrate', ...
                 'testalleaster'}, ...
                {'appendfcst','finite','hpcycle','hptarget','hprmls', ... % seats
                 'out','print','printphtrf','qmax','save','savelog', ...
                 'statseas','tabtables','bias','epsiv','epsphi', ...
                 'hplan','imean','maxbias','maxit','noadmiss', ...
                 'rmod','xl'}, ...
                {'appendbcst','appendfcst','comptype','compwt', ... % series
                 'decimals','file','data','format','modelspan','name', ...
                 'period','precision','print','save','span','start', ...
                 'title','type','divpower','missingcode','missingval', ...
                 'saveprecision','trimzero','yr2000', ...
                 'spectrumstart','diffspectrum','maxspecar', ...    % (X-12 only)
                 'peakwidth','spectrumseries','spectrumtype'}, ...
                {'cutchng','cutseas','cuttd','fixmdl','fixreg', ... % slidingspans
                 'length','numspans','outlier','print','save', ...
                 'savelog','start','additivesa','fixx11reg', ...
                 'x11outlier'}, ...
                {'logqs','print','save','savelog','start', ...      % spectrum
                 'tukey120','axis','decibel','difference','maxar', ...
                 'peakwidth','series','siglevel','type','qcheck','robustsa'}, ...
                {'adjust','aicdiff','file','data','format', ...     % transform
                 'function','mode','name','power','precision', ...
                 'print','save','savelog','start','title','type', ...
                 'constant','trimzero'}, ...
                {'appendbcst','appendfcst','final','mode', ...      % x11
                 'print','save','savelog','seasonalma','sigmalim', ...
                 'title','trendma','type','calendarsigma','keepholiday', ...
                 'centerseasonal','print1stpass','sfshort','sigmavec', ...
                 'trendi','true7term','excludefcst','spectrumaxis'}, ...
                {'aicdiff','aictest','critical','file','data', ...  % x11regression
                 'format','outliermethod','outlierspan','print', ...
                 'prior','save','savelog','sigma','span','start', ...
                 'tdprior','user','usertype','variables','almost', ...
                 'b','centeruser','eastermeans','forcecal','noapply', ...
                 'reweight','umfile','umdata','umformat','umname', ...
                 'umprecision','umstart','umtrimzero'}, ...
                {'period','mode','smoothmethod','methodarg','save'}, ...  % fixedseas
                {'period','options','save'}, ...                    % camplet
                {'period','mode','options','save'}};            % for custom m-files
             
             section = strtrim(section);
             section = validatestring(section,legalsections);
             
             if nargin < 2
                 key = [];
                 return;
             end

             if ~isempty(key)
                 hit = ismember(legalsections,section);
                 key = strtrim(key);
                 try
                     key = validatestring(key,legalkeys{hit});
                 catch ME
                     if ~iscell(key); key = {key}; end
                     msg = sprintf(['\nFor section ''%s'', the following ', ...
                         'keys are possible: ''%s''.\n\n=> ''%s'' is ', ...
                         'not a legal key for the ''%s'' section.'], ...
                         section, strjoin(legalkeys{hit},''', '''), key{1}, section);
                     msg = strrep(msg,char(10),'\n');
                     err = MException(ME.identifier,msg);
                     throw(err);
                 end
             else
                 key = [];
             end
             
        end
        
        function p = toParen(in)
        % any input -> '( ... ... )'
            if ischar(in)
                p = strtrim(in);
                if ismember(' ',in)
                    if ~strcmp(p(1),'('); p = ['(',p]; end
                    if ~strcmp(p(end),')'); p = [p,')']; end
                end
            elseif iscell(in)
                p = x13spec.cell2paren(in);
            elseif isstruct(in)
                c = x13spec.struct2cell(in);
                p = x13spec.cell2paren(c);
            elseif isnumeric(in)
                if numel(in) > 1
                    p = mat2str(in);
                    p = strrep(p,'[','(');
                    p = strrep(p,']',')');
                else
                    p = num2str(in);
                end
            end
        end
        
        function c = toCell(in)
        % any input -> { ... ... }
            if iscell(in)
                c = in;
            elseif isnumeric(in)
                c = num2cell(in);
            elseif ischar(in)
                c = x13spec.paren2cell(in);
            end
        end
        
        function n = toNum(in)
        % any input -> [ ... ... ]            
            if isnumeric(in)
                n = in;
            elseif iscell(in)
                n = x13spec.cell2num(in);
            elseif ischar(in)
                n = x13spec.paren2num(in);
            end
        end

    end     % --- end of check legality and format methods
    
    methods (Static, Hidden)
        
        function p = cell2paren(c)
        % {'a','b'} -> '(a b)'
            isnum = cellfun(@(z) isnumeric(z), c);
            c(isnum) = cellfun(@(z) {num2str(z)}, c(isnum));
            switch numel(c)
                case 0;    p = '';
                case 1;    p = c{1};
                otherwise; p = sprintf('(%s)',strjoin(c));
            end
        end
        
        function n = cell2num(c)
        % {'a' 10 '20'} -> [NaN 10 20];
            isnum = cellfun(@(z) isnumeric(z), c);
            n = cellfun(@(z) str2double(z), c);
            n(isnum) = cell2mat(c(isnum));
        end
        
        function c = paren2cell(p)
        % '(tr sa sf)' -> {'tr','sa','sf'}
            rem = ismember(p,'(){}''"');
            p(rem) = [];
            p = strtrim(strrep(p,',',' '));
            c = strsplit(p);
            c(isempty(c)) = [];
        end
        
        function c = struct2cell(s)
        % strcut('a',1,'b',2) -> {'a','b';1,2}
            k = fieldnames(s);
            c = cell(2,numel(k));
            c(1,:) = k';
            for z = 1:numel(k)
                c{2,z} = s.(k{z});
            end
        end
        
        function n = paren2num(p)
        % '(4 12) -> [4 12]
            c = x13spec.paren2cell(p);
            n = x13spec.cell2num(c);
        end
        
        function str = wrapLinesSpecial(str)
        % wrap string so that no line is longer than 79 characters;
        % preappend a space
            leadText = ['    ',char(9474),'  ']; l = 79;
            if ~strcmp(str(end),char(10))
                str = [str,char(10)];
            end
            posLF    = [0,strfind(str,char(10)),length(str)];
            startpos = posLF(find(diff(posLF) > l)); %#ok<*FNDSB>
            while ~isempty(startpos)
                posSP = find(ismember(str(startpos(1)+1:startpos(1)+1+l),' '), ...
                    1, 'last') + startpos(1);
                if isempty(posSP) || posSP-startpos(1) < ceil(l * 0.6)
                    % no space available; cut in the middle of a word
                    str = [str(1:startpos(1)+l), char(10), ...
                        leadText, str(startpos(1)+l+1:end)];
                else
                    % replace last available space with lf
                    str = [str(1:posSP-1), char(10), ...
                        leadText, str(posSP+1:end)];
                end
                posLF    = [1,strfind(str,char(10)),length(str)];
                startpos = posLF(find(diff(posLF) > l+1));
            end
        end
        
%         function str = addquotes(str)
%             if ~isempty(str) && ~strcmp(str([1,end]),'""')
%                 str = ['"',str,'"'];
%             end
%         end
        
    end     % -- end hidden format methods

end     % -- end classdef
