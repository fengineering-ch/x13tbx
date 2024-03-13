% X13COMPOSITE is the class definition for x13composite objects.
% Such an object is the home of the input to and the output of the US
% Bureau of the Census X13ARIMA-SEATS program as applied to a composite
% time series.
%
% Properties:
% - name             string             name of the series
% - filename         string             name of the files associated with
%                                       the series
% - fileloc          string             path to location of data files
% - graphicsloc      string             path to location of files for the
%                                       x13graph program; if this is an
%                                       empty string (''), the graphics
%                                       files are created in a subdirectory
%                                       of the temporary files directory;
%                                       if this property is empty ([]), no
%                                       graphics files are produced by the
%                                       .Run method.
% - flags            string             flags to be used in the x13as
%                                       run. Do not set the -g or the -m
%                                       flags here; they are taken care
%                                       of automatically. You could, for
%                                       instance, set the -r or the -n
%                                       flags to affect the .out
%                                       property, or set the -s switch to
%                                       generate the diagnostics summary
%                                       file.
% - spec             x13spec            specification structure for
%                                       estimation 
% - period           int                periodicity (4 or 12)
% - span             string             dates spanned by variable
% - prog             string             name of executable used for the
%                                       computation
% - progloc          string             path to the x13as/x12a program
% - ishtml           boolean            false if text version of executable
%                                       is used, true if html version is
%                                       used (in that case, obj.table is
%                                       empty)
% - progversion      string             version and build number of the
%                                       Census program used
% - timeofrun        1x2 array          time of running of program,
%                                       duration of run 
% - con              string             console output of x13as.exe
% - msg              string             errors, warnings, and notes during
%                                       run 
% - listofseries     array              names of x13series objects stored
%                                       in this object
% - isempty          boolean            true is listofseries is empty
% - compositeseries  string             name of x13series in the object
%                                       containing the composite
% - alldates         array              union of all .dat dates vectors
% - hseries          array              handles to series in object
%
% .spec, .prog, .progloc, .fileloc, .graphicsloc, and .timeofrun are freely
% accessible properties (they can be read and set from anywhere). The other
% properties are either protected or dependent, which means that you cannot
% easily set them (e.g., setting x.period = 12 throws an error).
%
% In addition, x13series objects are added as new properties during an x13
% run. These new properties contain the runs of the individual series that
% make up the composite, as well as the aggregated time series.
%
% Important methods:
% - disp and display    Show the content of the object. 
% - dispstring          Same as disp, but does not print to the console.
%                       Instead, the disp output is returned as a string
%                       variable.
% - plot                An overloaded method for this object class.
% - showmsg             Returns the content of the .msg property (which is
%                       a cell array) as a string.
%
% Rarely used methods: The following methods are normally not useful for
% regular users. They are used by x13.m to perform its work. Be careful if
% you employ these methods. It is possible to create unusable x13series
% objects if you don't know what you are doing.
% - PrepareFiles        Takes four arguments: dates, data, spec, and
%                       compSpec. data is the vecor for dates, data is the
%                       collection of series (the components), spec is the
%                       collection of x13spec specifications for the
%                       components, and compSpec is the specification for
%                       the composite series. The method calls the
%                       PrepareFiles method for the individual x13series
%                       objects.
% - Run                 Runs the x13 program using the files created by
%                       PrepareFiles.
% - CollectFiles        Imports the files produced by the x13 program into
%                       the Matlab object.
% - runX12diag          Runs the X-12 diagnostic utility on the files
%                       created with the -s flag.
% - updatemsg           Extracts all ERRORS, WARNINGS and NOTES from the
%                       .err property and places them in the .msg property.
%                       Also adds a list of variables that were requested
%                       in the specification (with some 'save' key) but
%                       that are not available (because the x13 program did
%                       not produce them, or because they were later
%                       deleted).
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
% 2022-02-07    Version 1.52    Adaptation to x12diag not being available
%                               online anymore.
% 2018-09-04    Version 1.33    Added progtype property.
% 2017-01-09    Version 1.30    First release featuring camplet.
% 2016-07-27    Version 1.17.4  Added .specgiven
% 2016-07-17    Version 1.17.3  Bug fix in x13series.
% 2016-07-12    Version 1.17.2  Bug fix.
% 2016-07-10    Version 1.17.1  Improved guix. Bug fix in x13series
%                               relating to fixedseas.
% 2016-07-06    Version 1.17    First release featuring guix.
% 2016-06-08    Version 1.16.2  Added span in disp of x13composite object.
% 2016-03-10    Version 1.16.1  Bug fix: 'quiet' option is now passed down
%                               to x13series.CollectFiles. Introduction of
%                               .alldates property.
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
%                               bugfixes and improvements.
% 2015-07-24    Version 1.13.3  Resolved some backward compatibility
%                               issues (thank you, Carlos). Fixed a bug in
%                               .rmseries
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
% 2015-06-01    Version 1.12.2  Added property 'quiet'
% 2015-05-21    Version 1.12    Several improvements: Ensuring backward
%                               compatibility back to 2012b (possibly
%                               farther); Added 'seasma' option to x13;
%                               Added RunsSeasma to x13series; other
%                               improvements throughout. Changed numbering
%                               of versions to be in synch with FEX's
%                               numbering.
% 2015-04-28    Version 1.6     x13as V 1.1 B 19, support for accessible
%                               version
% 2015-01-26    Version 1.3     Major bugfix
% 2015-01-24    Version 1.2     Enforces precedence over graphics class
%                               (thanks to Stephen Watson); bugfix (copy
%                               obj.progloc to ser.progloc)
% 2015-01-21    Version 1.1     Collaboration with
%                               InstallMissingCensusProgram
% 2015-01-18    Version 1.09    Support for x12a and x12diag
% 2015-01-04    Version 1.05    Removing .ListOfSeries property; relying of
%                               properties method of the class instead;
%                               listofseries is a dependent property now
% 2014-12-31    Version 1.0     First Version

%#ok<*AGROW>
%#ok<*TRYNC>
%#ok<*CHARTEN>
%#ok<*CPROP>
%#ok<*CPROPLC>

classdef ( InferiorClasses = { ...
                ?matlab.graphics.axis.Axes, ...
                ?matlab.ui.Figure}, ...
           Description = 'interaction with X-13 program, composite runs', ...
           DetailedDescription = ['Object for interaction with US ', ...
              'Census Bureau X-13 program for seasonal adjustment; ' ...
              'contains data and results of a composite run.'] ...
          ) ...
    x13composite < dynamicprops %#ok<MCADE,ATUNK>

    properties(Constant)
        version = '1.55';       % version number of toolbox
    end

    properties(Dependent)
        listofseries;           % list of series in object in defined order
        progtype;               % name of program used for seasonal adjustment
        alldates;               % union of all dates vectors in .dat and .cms
        isempty;                % returns true if the instance contains no variables
    end
    
    properties
        prog        = '';       % name of executable
        progversion = '';       % version of executable
        progloc     = [];       % location of executable
        ishtml      = false;    % boolean, true is 'accessible version' used
        fileloc     = [];       % location of generated files
        graphicsloc = [];       % location of generated graphics files
        flags       = '';       % list of flags passed to executable
        quiet       = false;    % boolean; do not show x13as relatid warnings
        filename;               %
        timeofrun   = cell(1,2);    % time and duration of run
        hseries     = cell(0);  % vector of handles to series in object
    end
    
    properties(SetAccess = protected, GetAccess = public)
        msg;                    % messages generated by Census program
        con             = '';   % console output of Census program run
        compositeseries = '';   % name of series holding the composite
    end
    
    properties(Hidden)
        warnings     = cell(0); % warnings issued by the toolbox (not by x13as)
        specgiven    = x13spec; % spec given by user, before internally adjusted by the program
    end
    
    properties(Hidden, GetAccess = protected)
        grmode;                 % boolean; true if run in graphics mode
    end
    
    methods
    
    % --- CONSTRUCTOR, DESTRUCTOR -----------------------------------------
    
%         function delete(obj)
%             % destructor function
%             fprintf('deleting x13composite object...\n');
%         end
    
    % --- GET OF DEPENDENTS -----------------------------------------------
    
        function list = get.listofseries(obj)
        % returns list of series in object in defined order
            % get all properties
            list = properties(obj);
            % drop the names of the hard-wired properties (except con)
            hardwired = {'unsortedlistofseries','listofseries', ...
                'prog','progtype','progloc','progversion','fileloc', ...
                'graphicsloc','grmode','flags','quiet','useX12', ...
                'timeofrun','con','msg','filename','version','hseries', ...
                'compositeseries','ishtml','alldates','isempty'};
            remove = ismember(list,hardwired);
            list(remove) = [];
            % defined order
            remove = ismember(list,obj.compositeseries);
            if any(remove)
                list(remove) = [];
                list = sort(list)';
                list = [{obj.compositeseries},list];
            else
                list = sort(list)';
            end
        end
        
        function b = get.isempty(obj)
        % returns true if the x13composite object contains no x13series
            b = (numel(obj.listofseries) == 0);
        end
        
        function d = get.alldates(obj)
        % returns union of the dates associates to the .dat properties of all
        % series and of the .cms property of the composite series
            d = [];
            for n = obj.listofseries
                try
                    d = [d; obj.(n{:}).dat.dates];
                catch
                    d = [d; obj.(n{:}).cms.dates];
                end
                d = unique(d);
            end
            d = sort(d);
        end
        
    % --- BASIC METHODS ---------------------------------------------------
    
        function obj = addseries(obj,ser,sname)
        % add a new x13series as a property
            assert(isa(ser,'x13series'), ...
                'X13TBX:x13composite:addseries:WrongType', ...
                'This must be a x13series object.');
            sname = obj.LegalVariableName(sname);
            if ~ismember(sname,properties(obj))
                h = obj.addprop(sname);
                obj.hseries{end+1} = h;
            end
            obj.(sname) = ser;
        end
        
        function obj = rmseries(obj,name)
        % remove an x13series object that was added earlier with addseries
            % if it's the composite, remove the name
            if strcmp(name,obj.compositeseries)
                obj.compositeseries = '';
            end
            % collect all names of removable series, in the ordering of
            % hseries
            nseries = numel(obj.hseries);
            names = cell(1,nseries);
            for n = 1:nseries
                names{n} = obj.hseries{n}.Name;
            end
            hit = find(ismember(names,name));
            if ~isempty(hit)
                delete(obj.hseries{hit});
                obj.hseries(hit) = [];
            else
                warning('X13TBX:x13composite:rmseries:PropUnknown', ...
                    'Series ''%s'' does not exist.', name);
            end
        end
        
        function obj = updatemsg(obj)
        % search through .con property and place relevant content into .msg property
            doNotStore = ['NOTE: The X-13ARIMA-SEATS diagnostic file ', ...
                '(.udg) has been stored'];
            S = obj.warnings;
            keyword = {'ERROR:','WARNING:','NOTE:'};
            for k = 1:3
                s = obj.ExtractParagraph('con',keyword{k});
                for p = 1:numel(s)
                    if ~strncmp(strtrim(s{p}),doNotStore,length(doNotStore))
                        S(end+1) = {obj.cleanString(s{p})};
                    end
                end
            end
            obj.msg = S;
        end
    
        function str = showmsg(obj)
        % show all messages as one string
        % msg is a list of cells; this function formats the content as one
        % string, ready to be displayed
            str = '';
            for m = 1:numel(obj.msg)
                str = [str, obj.msg{m}, char(10)];
            end
        end
        
        function sect = ExtractParagraph(obj,field,word)
        % extract all paragraphs from a string that contain a certain keyword
           str = obj.(field);
            % find occurrences of the word
            posWord = strfind(str,word);
            sect    = cell(numel(posWord),1);
            for s=1:numel(posWord)
                % find line feeds
                posLF   = [0,strfind(str,[char(10),char(10)]),length(str)];
                % find page feeds
                posPF   = strfind(str,char(12));
                % merge them
                posLF   = sort([posLF,posPF]);
                % now extract the paragraph
                fromPos = find(posLF<posWord(s),1,'last');
                toPos   = find(posLF>posWord(s),1,'first');
                sect{s} = obj.cleanString(str(posLF(fromPos)+1 : ...
                    posLF(toPos)-1));
            end
        end

        function disp(obj)
        % long form display of x13spec object
            if ~(numel(obj)==1) || obj.isempty
                display(obj);
            else
                display(dispstring(obj));
            end
        end
        
        function display(obj) %#ok<DISPLAY>
        % short form display of x13composite object
            [nrow,ncol] = size(obj);
            if nrow*ncol == 1
                str = sprintf(' Composite Seasonal Adjustment\n');
                count = numel(obj.listofseries);
                if count == 0
                    str = [str,' The object is empty.'];
                else
                    str = [str, sprintf(' Contains %i series', count)];
                    str = [str,' (use disp(obj) to see details).'];
                end
            else
                str = sprintf(['%ix%i <a href="matlab:helpPopup x13composite">', ...
                    'x13composite</a> array.\n'], nrow, ncol);
            end
            disp(str);
        end
        
        function str = dispstring(obj)
        % long form display of x13composite object, return as string
            allprop = obj.listofseries;
            dline = repmat('=',1,78);
            sline = repmat('.',1,78);
            str = dline;
            str = [str, sprintf(' Composite Seasonal Adjustment\n')];
            temp    = '';
            if ~isempty(obj.progversion)
                temp = [obj.progversion, ' '];
            end
            if ~isempty(obj.prog)
                temp = [temp,'(',obj.prog,')'];
            end
            if ~isempty(temp)
                str = [str, sprintf(' %s\n',temp)];
            end
            try
                txt = sprintf('%i.%i to %i.%i', ...
                    yqmd(obj.alldates(1),'y'), ...
                    yqmd(obj.alldates(1),'m'), ...
                    yqmd(obj.alldates(end),'y'), ...
                    yqmd(obj.alldates(end),'m'));
                str = [str, sprintf(' Data : %s\n', txt)];
            end
            str = [str, sline];
            str = [str, sprintf(' List of series:\n')];
            for f = 1:numel(allprop)
                if strcmp(obj.(allprop{f}).spec.title,obj.compositeseries)
                    dash = '->';
                else
                    dash = ' -';
                end
                if strcmp(obj.(allprop{f}).spec.title, allprop{f})
                    str = [str, sprintf('%s %s\n', dash, allprop{f})];
                else
                    str = [str, sprintf('%s %s   [.%s]\n', dash, ...
                        obj.(allprop{f}).spec.title, allprop{f})];
                end
            end
            % footline
            if ~isempty(obj.timeofrun{2}) || ~isempty(obj.msg)
                str = [str, sline];
            end
            if numel(obj.msg) > 7
                nstr = int2str(numel(obj.msg));
                str = [str, obj.msg{1:5}];
                str = [str, sprintf(['\n   .\n   .\n   .\n There are ', nstr, ...
                    ' messages in total. Use obj.showmsg to see them all.\n'])];
            else
                str = [str, obj.showmsg];
            end
            if ~isempty(obj.timeofrun{2})
                str = [str, sprintf(' Time of run: %s (%3.1f sec)\n', ...
                    datestr(obj.timeofrun{1}), obj.timeofrun{2})];
            end
            str = [str, dline];
            str = obj.wrapLines(str);
        end
        
    end     % --- end methods
    
    % --- HIDDEN STATIC METHODS -------------------------------------------

    methods (Static, Hidden, Access = private)
        
        % ensure that the variable name is legal
        function str = LegalVariableName(str)
            if isnumeric(str)
                str = mat2str(str);
            end
            if verLessThan('matlab','8.3')
                str = genvarname(str);
            else
                str = matlab.lang.makeValidName(str);
            end
        end

        % wrap string so that no line is longer than 78 character;
        % preappend a space
        function str = wrapLines(str,leadText)
            if nargin < 2
                leadText = ' ';
            end
            l = 78;
            if ~strcmp(str(end),char(10))
                str = [str,char(10)];
            end
            posLF    = [0,strfind(str,char(10)),length(str)];
            startpos = posLF(find(diff(posLF) > l)); %#ok<*FNDSB>
            while ~isempty(startpos)
                posSP = find(ismember(str(startpos(1)+1:startpos(1)+1+l),' '), ...
                    1, 'last') + startpos(1);
                if isempty(posSP)
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
       
        % remove empty double lines etc.
        function str = cleanString(str)
           space = char(32); eol = char(10);
            str_keep = [str,'make it longer'];
            while length(str_keep) > length(str)
                str_keep = str;
                % remove end of line spaces
                pos = strfind(str, [space,eol]);
                str(pos) = [];
                % remove double empty lines
                pos = strfind(str, [eol,eol,eol]);
                str(pos) = [];
                % remove end of string spaces
                if strcmp(str(end),space)
                    str(end) = [];
                end
            end
            % remove beginning and end of string empty line
            while length(str) >= 1 && strcmp(str(1),eol)
                str(1) = [];
            end
            while length(str) >= 2 && ...
                    strcmp(str(end-1:end),[eol,eol])
                str(end) = [];
            end
        end

    end     % -- end hidden static methods
    
    % --- METHODS FOR INTERACTING WITH X13AS.EXE --------------------------
    
    methods
        
        % --- PREPARE FILES

        function obj = PrepareFiles(obj,dates,data,spec,compSpec)
        % generate all files required by x13as.exe to run
            
            % check if it should be run in graphics mode
            obj.grmode = (ischar(obj.graphicsloc));
            if obj.grmode
                if ~strcmp(obj.graphicsloc(end),filesep)
                    obj.graphicsloc = [obj.graphicsloc,filesep];
                end
            end
            
            compDates = [];
            % PACK UP INDIVIDUAL SERIES
            % Prepare files for x13as.exe for each individuaL series; put
            % these half-baked series into the composite object (for
            % transportation, so to speak)
            for s = 1:numel(spec)
                compDates = unique([compDates;dates{s}]);
                ser = x13series();
                ser.specgiven = spec{s};
                ser.flags = obj.flags;
                ser.prog = obj.prog;
                ser.progloc = obj.progloc;
                ser.ishtml = obj.ishtml;
                ser.fileloc = obj.fileloc;
                ser.graphicsloc = obj.graphicsloc;
                sname = spec{s}.title;
                if isempty(sname)
                    sname = ['series',int2str(s)];
                end
                spec{s} = spec{s}.addtriplet(spec{s}.mainsec, ...
                    'title',sname);
                sname = spec{s}.name;
                spec{s} = spec{s}.addtriplet(spec{s}.mainsec, ...
                    'name',sname);
                ser = ser.PrepareFiles(dates{s},data{s},spec{s});
                obj = obj.addseries(ser,sname);
            end
            compDates = sort(compDates);

            % NOW, MAKE THE SERIES THAT WILL HOLD THE COMPOSITE SERIES
            % prepare files for this special series to be dealt with by the
            % x13as program ...
            ser = x13series();
            ser.keyv.dat = 'cms';
            ser.specgiven = compSpec;
            ser.flags = obj.flags;
            ser.prog = obj.prog;
            if ~isempty(obj.progloc)
                ser.progloc = obj.progloc;
            end
            if ~isempty(obj.fileloc)
                ser.fileloc = obj.fileloc;
            end
            if obj.grmode
                ser.graphicsloc = obj.graphicsloc;
            end
            ser = ser.PrepareFiles(compDates, [], compSpec, true);
            % ... place this half-baked composite series as an individual
            % series into the composite object
            obj = obj.addseries(ser,ser.spec.name);
            obj.compositeseries = ser.spec.name;
            
            % ADD FILE NAME AND LOCATION OF COMPOSITE SERIES SEPARATELY
            % ALSO INTO ROOT OF COMPOSITE OBJECT
% % % %             obj.spec.name   = ser.spec.name;
            obj.fileloc     = ser.fileloc;
            obj.graphicsloc = ser.graphicsloc;
            
            % MAKE .MTA
            fname = fullfile(ser.fileloc, [ser.spec.name,'.mta']);
            hFile = fopen(fname, 'w');
            if hFile == -1
                err = MException('X13TBX:x13composite:PrepareFiles:CannotCreateFile', ...
                    ['Cannot create .MTA file for some reason.\n', ...
                    'Attempted filename is %s'],fname);
                throw(err);
            end
            p = obj.listofseries;
            % make sure compositeseries is at the end
            cs = cellfun(@(s) strcmp(s,obj.compositeseries), p);
            cs = find(cs);
            ord = [1:cs-1,cs+1:numel(p),cs];
            for s = 1:numel(p)
                % In graphics mode or if the -s switch is used, the .udg file is
                % created. Ordinarily, we would add double quotes around the
                % path/name to deal with spaces in the path. However,
                % x12diag.exe does not work with the quotes.
                %
                % On the other hand, x13 does not work if there's a space in the
                % path somewhere and no double quotes to hold it together. So,
                % we will still add the double quotes if this is the case and
                % thus foregoe the creation of the x2d files. At least, x13 will
                % still work.
                %
                try
                    if (obj.grmode || ~isempty(strfind(obj.flags,'-s'))) && ...
                            isempty(strfind(obj.(p{ord(s)}).fileloc,' '))
                        fprintf(hFile,'%s%s\n', obj.(p{ord(s)}).fileloc, ...
                            obj.(p{ord(s)}).spec.name);
                    else
                        fprintf(hFile,'"%s%s"\n', obj.(p{ord(s)}).fileloc, ...
                            obj.(p{ord(s)}).spec.name);
                    end
                catch ME
                    fclose(hFile);
                    ME = MException('X13TBX:x13composite:PrepareFiles:CannotWriteToFile', ...
                        [ME.message, '\nCannot write to .MTA file for ', ...
                        'some reason.']);
                    throw(ME);
                end
            end
            fclose(hFile);
            
        end
        
        % --- RUN

        function obj = Run(obj)
        % execute the x13as.exe program on the files generated with .PrepareFiles
            
            prg = fullfile(obj.progloc, obj.prog);
            mta = fullfile(obj.fileloc, obj.(obj.compositeseries).spec.name);
            if ~isempty(obj.graphicsloc) && ~strcmp(obj.graphicsloc(end),filesep)
                obj.graphicsloc = [obj.graphicsloc,filesep];
            end
            
            if obj.grmode
                cmd = sprintf('"%s" -m "%s" -g %s %s', ...
                    prg, mta, obj.graphicsloc, obj.flags);
            else
                cmd = sprintf('"%s" -m "%s" %s', ...
                    prg, mta, obj.flags);
            end
            
            [~,consoleOut] = system(cmd);
            obj.con = consoleOut;
            
        end

        % --- RUN X12DIAG
        
        function console = runX12diag(obj)
        % run the X-12 diagnostic utility on the files generated by x13as.exe
            if obj.grmode
                fname = fullfile(obj.graphicsloc,obj.filename);
            else
                fname = fullfile(obj.fileloc,obj.filename);
            end
            % Version before 2022, when x12diag could still be downloaded
%             if exist([fname,'.mta'],'file') == 2   % code 2 refers to files
%                 if exist(fullfile(obj.progloc,'x12diag03.exe'),'file') ~= 2
%                     InstallMissingCensusProgram('x12diag');
%                 end
%                 [~,console] = system(sprintf('"%s%s" "%s" -m', ...
%                     obj.progloc, 'x12diag03.exe', fname));
%             else
%                 console = [];
%             end
            % New version since 2022
            if exist([fname,'.mta'],'file') == 2 ...  % code 2 refers to files
                && exist(fullfile(obj.progloc,'x12diag03.exe'),'file') == 2
                [~,console] = system(sprintf('"%s%s" "%s" -m', ...
                    obj.progloc, 'x12diag03.exe', fname));
            else
                console = [];
            end
        end
        
        % --- COLLECT FILES

        function obj = CollectFiles(obj)
        % collect all files generated by x13as.exe and place as items into x13series object
            
            % collect version and build number
            reg = 'Version Number \d+\.?\d+ Build \d+';
            temp = regexp(obj.con,reg,'match');
            if ~isempty(temp)
                obj.progversion = temp{1};
            end
            
            % create .x2d if possible
            console = runX12diag(obj);
            if ~isempty(console)
                obj.con = [obj.con,char(10),console];
            end
            
            % collect files for the individual components
            series = obj.listofseries;
            for s = 1:numel(series)
                if ~isempty(obj.prog)
                    obj.(series{s}).prog = obj.prog;
                end
                if ~isempty(obj.progversion)
                    obj.(series{s}).progversion = obj.progversion;
                end
                obj.(series{s}).quiet = obj.quiet;
                obj.(series{s}) = obj.(series{s}).CollectFiles();
            end

            % update msg property ...
            obj = obj.updatemsg();
            % ... and show them as warnings.
            if ~obj.quiet
                for m = numel(obj.warnings)+1:numel(obj.msg)
                    % preappend LF, remove LF at the end
                    str = [char(10),strrep(obj.msg{m}(1:end-1),'/','//')];
                    str = strrep(str,'\','/');
                    warning('X13TBX:x13composite:CollectFiles:x13message',str);
                end
            end
            
        end
            
    end     % --- end methods
    
end     % -- end classdef
