% INSTALLMISSINGCENSUSPROGRAM installs pieces of software from the US
% Census Bureau that are necessary to perform the seasonal filtering.
%
% *** NORMAL OPERATION
%
% Normally, x13.m will download and install any missing piece of software
% from the US Census Bureau as soon as it is required. You can, however,
% also install such software and documentation "manually" by invoking
% InstallMissingCensusProgam.
%
% Usage:
%   InstallMissingCensusProgram()
%   InstallMissingCensusProgram(arg, [arg2], [...])
%   success = InstallMissingCensusProgram([...])
%   InstallMissingCensusProgram('all')
%
% If called with no argument, the program tries to install all usable
% files. Alternatively, an argument or a list of arguments can be provided.
% Choices are:
%   'x13prog'       X-13 software, ascii and html versions
%   'x13doc'        documentation of X-13 program
%   'x12diag'       X-12 diagnostic utility
%   'x12prog'       X-12 software, 64 bit and 32 bit versions
%   'x12doc'        documentation of X-12 program
%   'campletdoc'    the original working paper presenting the CAMPLET
%                   algorithm
% The function returns a vector of booleans, indicating which installations
% were successful.
% 
% Using this function with no arguments
%    InstallMissingCensusProgram;
% should produce the following result:
%
% Downloading 'x13as_ascii-v1-1-b60.zip' from US Census Bureau website ... success.
% Downloading 'x13as_html-v1-1-b60.zip' from US Census Bureau website ... success.
% Downloading 'x13as_ascii-v1-1-b60.zip' from US Census Bureau website ... success.
% Downloading 'x13as_html-v1-1-b60.zip' from US Census Bureau website ... success.
% Downloading 'gettingstartedx13acc-winx13.pdf' from US Census Bureau website ... success.
% Downloading 'g18-1-v1-1-a-checklists.pdf' from US Census Bureau website ... success.
% Downloading 'dt9628e.pdf' from Banco d'Espagna website ... success.
% Downloading 'itoolsv03.zip' from fengineering.ch website ... success.
% Downloading 'omega64v03.zip' from fengineering.ch website ... success.
% Downloading 'omegav03.zip' from fengineering.ch website ... success.
% Downloading 'x12adocV03.pdf' from fengineering.ch website ... success.
% Downloading '25_2015_abeln_jacobs.pdf' from Australian National University website ... success.
% *** 12 of 12 requested packages installed. ***
%
% After that, all programs of the US Census Bureau website that are supported
% by the X-13 Toolbox are installed on your computer.
%
% *** IF IT DOES NOT WORK
%
% Normally, this program will download the specific pieces of software and
% documentation that are provided by the U.S. Census Bureau and copy them
% to the appropriate locations. This assumes, however, that your computer
% allows you to download and run software from the internet. This may not
% apply to a professional environment where IT security issues are managed
% centrally. If you cannot download and run externally-acquired software,
% you will need help from an IT administrator at your workplace.
%
% Also, this utility works only with Windows computers. If you use a
% different operating system, you will have to download and place the
% necessary files manually.
% 
% You find all the files you need at the the U.S.Census website
% (https://www.census.gov/data/software/x13as.X-13ARIMA-SEATS.html). Search
% in the different ZIP available there to locate the correct files. Also,
% it may be possible to obtain the source code of the X-13 program so that
% you may be able to compile this for so far unsupported operating systems.
% (If you do that, please let me know; I would be interested about this.)
% 
% If all usable files are present, the exe sub-direcory should contain the
% following files:
%  (**) x13_ascii.exe 
%       x13_html.exe
%       x12a64.exe
%       x12a.exe
% In addition, the doc sub-directory should contain
%   (*) docX13as.pdf                     Documentation for X-13 program
%       docX13ashtml.pdf
%       gettingstartedx13acc-winx13.pdf 
%       g18-1-v1-1-a-checklists.pdf      Checklist for Quality of Seasonal Adjustment
%       dt9628e.pdf                      Documentation TRAMO & SEATS
%       x12adocV03.pdf                   Documentation for X-12 program
%       25_2015_abeln_jacobs.pdf         Documentation for CAMPLET
%
% Only the double-starred file is essential. The single-starred file is
% the documentation. The unstarred files give you access to the HTML version
% of X-13 (called the 'accessible version by the Census Bureau) and the
% vintage X-12 version, with documentation as well as original working
% paper that introduced CAMPLET.
%
% *** OTHER THINGS YOU CAN DOWNLOAD WITH THIS UTILITY
%     (these are of only marginal interest) 
%
% In addition, eight other sets of programs that are related to X-13ARIMA-SEATS
% can be downloaded:
%
%   'x13graph'      The JAVA version of the X-13 graph program.
%   'x11prog'       An early version of the Census program.
%   'x11doc'        Some documentation of the early X-11 version.
%   'winx13'        Windows version of the X-13ARIMA-SEATS program.
%   'x13data'       A utility to transform data in an Excel sheet into
%                   files usable by x13as.exe, as well as for collecting
%                   x13as.exe output and storing it in an Excel file.
%   'genhol'        A program that allows the user to create variable files
%                   for holidays.
%   'cnv'           A utility to convert X-12 specification files to the
%                   X-13 format.
%   'sam'           A utility to change several spec files at once.
%
% These programs are not directly supported by the Matlab-Toolbox. The
% x13graph java program can be used if you add the 'graphicsmode' switch
% when calling x13, but you need to start the graph program outside of
% Matlab. Likewise, genhol, or the version with a GUI called wingenhol, is
% not used by the toolbox directly. You can create holiday variable files
% with it, and then use these files with the toolbox. But the interaction
% with genhol does not happen from within the toolbox. X-11 is not
% supported because its syntax is completely different from X-13ARIMA-SEATS
% and it is potentially prone to Y2K problems. The remaining programs
% winx13, x13data, cnv, and sam have no clear use for users of the toolbox.
% The download option provided here is only for completeness and may be
% useful for users who interact with the Census program also outside of
% Matlab.
%
% Calling InstallMissingPrograms('all') installs everything, including
% these additional sets of programs and files. This should produce the
% following result:
% Downloading 'x13as_ascii-v1-1-b60.zip' from US Census Bureau website ... success.
% Downloading 'x13as_html-v1-1-b60.zip' from US Census Bureau website ... success.
% Downloading 'x13as_ascii-v1-1-b60.zip' from US Census Bureau website ... success.
% Downloading 'x13as_html-v1-1-b60.zip' from US Census Bureau website ... success.
% Downloading 'gettingstartedx13acc-winx13.pdf' from US Census Bureau website ... success.
% Downloading 'g18-1-v1-1-a-checklists.pdf' from US Census Bureau website ... success.
% Downloading 'dt9628e.pdf' from Banco d'Espagna website ... success.
% Downloading 'itoolsv03.zip' from fengineering.ch website ... success.
% Downloading 'omega64v03.zip' from fengineering.ch website ... success.
% Downloading 'omegav03.zip' from fengineering.ch website ... success.
% Downloading 'x12adocV03.pdf' from fengineering.ch website ... success.
% Downloading 'x11.zip' from EViews(R) website ... success.
% Downloading 'Emanual.pdf' from fengineering.ch website ... success.
% Downloading '1980x11arimamanual.pdf' from Census Bureau website ... success.
% Downloading 'shiskinyoungmusgrave1967.pdf' from Census Bureau website ... success.
% Downloading 'x11_french.pdf' from Sebastien Ducos' website ... success.
% Downloading '25_2015_abeln_jacobs.pdf' from Australian National University website ... success.
% Downloading 'winx13-v3.0.zip' from US Census Bureau website ... success.
% Downloading 'x13graphjava_v3-1.zip' from US Census Bureau website ... success.
% Downloading 'x13data-v2-0.zip' from US Census Bureau website ... success.
% Downloading 'X13sam-v1.1.zip' from US Census Bureau website ... success.
% Downloading 'genhol_V1.0_B9.zip' from US Census Bureau website ... success.
% Downloading 'wingenhol-v1.0-B3.zip' from US Census Bureau website ... success.
% Downloading 'toolsx13.zip' from US Census Bureau website ... success.
% *** 24 of 24 requested packages installed. ***
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
% 2024-02-01    Version 1.55    Added sources at fengineering.ch
% 2022-02-07    Version 1.52    Adapting to several files that are no
%                               longer available online.
% 2021-08-09    Version 1.51    Adapted to V 1.1 Build 58
% 2021-04-28    Version 1.50    Removed two X-11 documentation files that
%                               are no longer available online. Added a
%                               book as PDF (in French and Spanish) on
%                               X-11.
% 2020-02-05                    Expanded header with more help on what to
%                               do if download fails.
% 2019-09-19    Version 1.34    Added winx13.
% 2018-08-12    Version 1.33    Impoved error message when download fails.
%                               Changed structure a bit and added a file to X-11
%                               documentation.
% 2017-03-24    Version 1.32    Added x13sam.
% 2017-03-10    Version 1.31    Adaptation to X13ARIMA-SEATE V1.1 B39.
% 2017-01-09    Version 1.30    First release featuring camplet.
% 2016-11-28    Version 1.20.3  Added original X-11 documentation file.
% 2016-11-24    Version 1.20.1  Documentation of X-11 is no longer
%                               available from EViews. An alternative
%                               source is no being used. Also, the additional
%                               downloads (from 'x11' to 'cnv') have been
%                               extended.
% 2016-08-22    Version 1.18.2  Added 'all' option.
% 2016-08-20    Version 1.18    Support for downloading x13graphjava.
% 2016-07-22    Version 1.17.4  Improved warning message.
% 2016-07-10    Version 1.17.1  Improved guix. Bug fix in x13series relating to
%                               fixedseas.
% 2016-07-06    Version 1.17    First release featuring guix.
% 2016-03-29    Version 1.16.1  Added X-11 download from EViews website.
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
% 2015-05-21    Version 1.12    Several improvements: Ensuring backward
%                               compatibility back to 2012b (possibly
%                               farther); Added 'seasma' option to x13;
%                               Added RunsSeasma to x13series; other
%                               improvements throughout. Changed numbering
%                               of versions to be in synch with FEX's
%                               numbering.
% 2015-04-28    Version 1.6     x13as V 1.1 B 19, inclusion of accessible
%                               version
% 2015-04-02    Version 1.1     Adaptation to X-13 Version V 1.1 B19
% 2015-01-21    Version 1.0

function success = InstallMissingCensusProgram(varargin)

    % location of the various files on the US Census website and elsewhere

    % *** X-13 *************************************************************

    x13prog = struct( ...
        'source',   {'US Census Bureau', 'US Census Bureau'}, ...
        'url',      {CensusBureau('x13as/windows/program-archives/x13as_ascii-v1-1-b60.zip'), ...
                     CensusBureau('x13as/windows/program-archives/x13as_html-v1-1-b60.zip')}, ...
        'dir',      {'x13as', 'x13as'}, ...
        'files',    {'x13as_ascii.exe', 'x13as_html.exe'}, ...
        'loc',      {'exe', 'exe'});

    x13doc = struct( ...
        'source',   {'US Census Bureau', 'US Census Bureau', 'US Census Bureau', ...
                     'US Census Bureau', 'Banco d''Espagna'}, ...
        'url',      {CensusBureau('x13as/windows/program-archives/x13as_ascii-v1-1-b60.zip'), ...
                     CensusBureau('x13as/windows/program-archives/x13as_html-v1-1-b60.zip'), ...
                     'https://www.census.gov/content/dam/Census/library/working-papers/2016/adrm/gettingstartedx13acc-winx13.pdf', ...
                     'https://www.census.gov/content/dam/Census/library/working-papers/2010/adrm/g18-1-v1-1-a-checklists.pdf', ...
                     ['https://www.bde.es/f/webbde/SES/Secciones/Publicaciones/', ...
                      'PublicacionesSeriadas/DocumentosTrabajo/96/Fich/', ...
                      'dt9628e.pdf']}, ...
        'dir',      {'x13as/docs', 'x13as/docs', [], [], []}, ...
        'files',    {'docx13as.pdf qrefx13aspc.pdf', ...
                     'docx13ashtml.pdf qrefx13ashtmlpc.pdf', ...
                     'gettingstartedx13acc-winx13.pdf', ...
                     'g18-1-v1-1-a-checklists.pdf', 'dt9628e.pdf'}, ...
        'loc',      {'doc', 'doc', 'doc', 'doc', 'doc'});

    % *** x12diag **********************************************************
    
    % As of Dec 2021, this file is no longer available at this place.

%     x12diag = struct( ...
%         'source',   'US Census Bureau', ...
%         'url',      'https://www.census.gov/ts/x12a/v03/pc/itoolsv03.zip', ...
%         'dir',      'tools', ...
%         'files',    'x12diag03.exe libjpeg.6.dll libpng3.dll zlib1.dll', ...
%         'loc',      'exe');

    x12diag = struct( ...
        'source',   'fengineering.ch', ...
        'url',      'https://fengineering.ch/X/itoolsv03.zip', ...
        'dir',      [], ...
        'files',    'x12diag03.exe libjpeg.6.dll libpng3.dll zlib1.dll', ...
        'loc',      'exe');

    % *** X-12 ************************************************************* 
    
    % The X-12 version of the Census program is also no longer available
    % from the Census website.
    
%     x12prog = struct( ...
%         'source',   {'US Census Bureau', 'US Census Bureau'}, ...
%         'url',      {'https://www.census.gov/ts/x12a/v03/pc/omega64v03.zip', ...
%                      'https://www.census.gov/ts/x12a/v03/pc/omegav03.zip'}, ...
%         'dir',      {[], []}, ...
%         'files',    {'x12a64.exe', 'x12a.exe'}, ...
%         'loc',      {'exe', 'exe'});

    x12prog = struct( ...
        'source',   {'fengineering.ch'}, ...
        'url',      {'https://fengineering.ch/X/omega64v03.zip', ...
                     'https://fengineering.ch/X/omegav03.zip'}, ...
        'dir',      {[], []}, ...
        'files',    {'x12a64.exe', 'x12a.exe'}, ...
        'loc',      {'exe', 'exe'});

    % The documentation files are also no longer available...
%     x12doc = struct( ...
%         'source',   {'US Census Bureau', 'US Census Bureau', 'SAS Institute'}, ...
%         'url',      {'https://www.census.gov/ts/x12a/v03/pc/docsv03.zip', ...
%                      'https://www.census.gov/ts/papers/gettingstartedx12.pdf', ...
%                      'https://support.sas.com/rnd/app/ets/papers/ffc2000.pdf'}, ...
%         'dir',      {'docs',[],[]}, ...
%         'files',    {'x12adocV03.pdf qref03pc.pdf', 'gettingstartedx12.pdf', ...
%                      'ffc2000.pdf'}, ...
%         'loc',      {'doc','doc','doc'});
    % ...only SAS's "ffc2000.pdf" is still available.

    x12doc = struct( ...
        'source',   'fengineering.ch', ...
        'url',      'https://fengineering.ch/X/x12adocV03.pdf', ...
        'dir',      [], ...
        'files',    'x12adocV03.pdf', ...
        'loc',      'doc');
    
    % *** CAMPLET documentation ********************************************
    
    campletdoc = struct( ...
        'source',   'Australian National University', ...
        'url',      'https://cama.crawford.anu.edu.au/sites/default/files/publication/cama_crawford_anu_edu_au/2015-07/25_2015_abeln_jacobs.pdf', ...
        'dir',      [], ...
        'files',    '25_2015_abeln_jacobs.pdf', ...
        'loc',      'doc');

    % *** X-11 *************************************************************
    
    % The Census Bureau does not distribute X-11 anymore. EViews still does.
    % x11 = struct( ...
    %     'source',   'EViews(R)', ...
    %     'url',      {'http://www.eviews.com/download/older/x11.zip', ...
    %                  'ftp://ftp.rau.am/EViews%20Enterprise%20Edition%207.0.0.1/Docs/x11/X11V2.PDF', ...
    %                  'ftp://ftp.rau.am/EViews%20Enterprise%20Edition%207.0.0.1/Docs/x11/X11V2QRF.PDF'}, ...
    %     'dir',      {[], [], []}, ...
    %     'files',    {'X11Q2.exe X11SS.exe', 'X11V2.PDF', 'X11V2QRF.PDF'}, ...
    %     'loc',      {'exe', 'doc', 'doc'});

    x11prog = struct( ...
        'source',   'EViews(R)', ...
        'url',      'http://www.eviews.com/download/older/x11.zip', ...
        'dir',      [], ...
        'files',    'X11Q2.exe X11SS.exe', ...
        'loc',      'exe');

    % All documentation for X-11 has also disappeared.
    %     x11doc = struct( ...
    %         'source',   {'US Census Bureau', 'US Census Bureau', 'US Census Bureau', ...
    %                      'US Census Bureau', 'US Census Bureau'}, ...
    %         'url',      {'https://www.census.gov/ts/papers/ShiskinYoungMusgrave1967.pdf', ...
    %                      'https://www.census.gov/ts/papers/x11_french.pdf', ...
    %                      'https://www.census.gov/ts/papers/x11_spanish.pdf', ...
    %                      'https://www.census.gov/ts/papers/1980X11ARIMAManual.pdf', ...
    %                      'https://www.census.gov/ts/papers/Emanual.pdf'}, ...
    %         'dir',      {[], [], [], [], []}, ...
    %         'files',    {'ShiskinYoungMusgrave1967.pdf', 'x11_french.pdf', ...
    %                      'x11_spanish.pdf', '1980X11ARIMAManual.pdf', 'Emanual.pdf'}, ...
    %         'loc',      {'doc', 'doc', 'doc', 'doc', 'doc'});

    x11doc = struct( ...
        'source',   {'fengineering.ch', 'Census Bureau', 'Census Bureau', 'Sebastien Ducos'''}, ...
        'url',      {'http://fengineering.ch/X/Emanual.pdf', ...
                     'https://www.census.gov/content/dam/Census/library/working-papers/1980/adrm/1980x11arimamanual.pdf', ...
                     'https://www.census.gov/content/dam/Census/library/working-papers/1967/adrm/shiskinyoungmusgrave1967.pdf', ...
                     'http://sebastien.ducos.free.fr/x11_french.pdf'}, ...
        'dir',      {[]}, ...
        'files',    {'Emanual.pdf', '1980x11arimamanual.pdf', ...
                     'shiskinyoungmusgrave1967.pdf', 'x11_french.pdf'}, ...
        'loc',      {'doc','doc','doc','doc'});

    % *** FURTHER TOOLS ****************************************************
    
    winx13 = struct( ...
        'source',   'US Census Bureau', ...
        'url',      CensusBureau('win-x-13/download/winx13-v3.0.zip'), ...
        'dir',      'WinX13', ...
        'files',    '*.*', ...
        'loc',      'tools\winx13');

    % x13graph = struct( ...
    %     'source',   'US Census Bureau', ...
    %     'url',      {CensusBureau('x-13-graph/java/X13GraphJava_V3.0.zip'), ...
    %                  CensusBureau('x-13-graph/java/X13GraphJavaDoc.pdf')}, ...
    %     'dir',      {'X13GraphJava', []}, ...
    %     'files',    {'*.*', 'X13GraphJavaDoc.pdf'}, ...
    %     'loc',      {'tools\graphjava','tools\graphjava'});

    x13graph = struct( ...
        'source',   'US Census Bureau', ...
        'url',      CensusBureau('x-13-graph/java/x13graphjava_v3-1.zip'), ...
        'dir',      'X13GraphJava', ...
        'files',    '*.*', ...
        'loc',      'tools\graphjava');

    x13data = struct( ...
        'source',   'US Census Bureau', ...
        'url',      CensusBureau('x-13-data/download/x13data-v2-0.zip'), ...
        'dir',      'x13data', ...
        'files',    'X13Data.exe ExpTreeLib.dll X13DataDoc.pdf', ...
        'loc',      'tools\x13data');
    
    sam = struct( ...
        'source',   'US Census Bureau', ...
        'url',      CensusBureau('x-13-sam/download/X13sam-v1.1.zip'), ...
        'dir',      'x13sam', ...
        'files',    '*.*', ...
        'loc',      'tools\x13sam');

    cnv = struct( ...
        'source',   'US Census Bureau', ...
        'url',      CensusBureau('x13as/windows/program-archives/toolsx13.zip'), ...
        'dir',      'tools', ...
        'files',    'cnvx13as.exe cnvx13as.html', ...
        'loc',      'tools\cnv');

    genhol = struct( ...
        'source',   {'US Census Bureau','US Census Bureau'}, ...
        'url',      {CensusBureau('win-genhol/download/genhol_V1.0_B9.zip'), ...
                     CensusBureau('win-genhol/download/wingenhol-v1.0-B3.zip')}, ...
        'dir',      {'genhol','wingenhol'}, ...
        'files',    {'*.*','*.*'}, ...
        'loc',      {'tools\genhol','tools\wingenhol'});
    % A possibly newer version (?) of genhol (not wingenhol) seems to be
    % available in CensusBureau('x13as/windows/program-archives/toolsx13.zip')

    % *** LIST OF DOWNLOAD GROUPS ******************************************

    toc = struct( ...
        'x13prog'    , x13prog,     ...
        'x13doc'     , x13doc,      ...
        'x12diag'    , x12diag,     ...
        'x12prog'    , x12prog,     ...
        'x12doc'     , x12doc,      ...     
        'x11prog'    , x11prog,     ...
        'x11doc'     , x11doc,      ...
        'campletdoc' , campletdoc,  ...
        'winx13'     , winx13,      ...
        'x13graph'   , x13graph,    ...
        'x13data'    , x13data,     ...
        'sam'        , sam,         ...
        'genhol'     , genhol,      ...
        'cnv'        , cnv);

    % parse arguments
    legal = fieldnames(toc);
    if nargin == 0              % install everything in that case
        varargin = legal([1:5,8]);  % x13 and x12 incl doc and campletdoc
    elseif ismember('all',varargin)
        varargin = legal;       % all, incl x11 ... sam
    end
    
    % work through arguments
    success = [];
    while ~isempty(varargin)
        
        validstr = validatestring(varargin{1},legal);
        
        % do the work
        for f = 1:numel(toc.(validstr))
            source   = toc.(validstr)(f).source;
            url      = toc.(validstr)(f).url;
            folder   = toc.(validstr)(f).dir;
            files    = toc.(validstr)(f).files;
            loc      = toc.(validstr)(f).loc;
            thefiles = strsplit(files);
            success(end+1) = InstallMissingPiece( ...
                source,url,folder,thefiles,loc); %#ok<AGROW>
        end

        varargin(1) = [];
        
    end
    
    % Some folders cause trouble when installing a component more than once.
    p = {'\WinGenhol\images','\X13GraphJava\images','\X13SAM\img'};
    for c = 1:numel(p)
        if exist([tempdir,p{c}],'dir') == 7    % code 7 is a folder
            rmdir([tempdir,p{c}],'s');
        end
    end
    
    fprintf(' *** %i of %i requested packages installed. ***\n', ...
        sum(success), numel(success));
    
    if nargout == 0
        clear('success');
    end

end

function f = CensusBureau(f)
    % pre-append root directory of US Census Bureau program file archive
    f = ['https://www2.census.gov/software/x-13arima-seats/',f];
end

function ok = InstallMissingPiece(source,url,folder,files,loc)

    td = tempdir;                           % temporary file location
    p  = fileparts(mfilename('fullpath'));	% get direcory of this file
    p  = [p,filesep];
    
    % download
    [~,fname,fext] = fileparts(url);
    % tell user what we are doing
    fprintf(' Downloading ''%s'' from %s website ... ', ...
        [fname,fext], source);
    fname = fullfile(td,[fname,fext]);
    ok = true;
    try
        websave(fname,url);
    catch
        try
            if exist(fname,'file') == 2
                delete(fname);
            end
            [~, ok] = urlwrite(url,fname); %#ok<URLWR>
            if ~ok
                fprintf('\n');
                if isempty(folder)
                    dirinfo = '';
                else
                    dirinfo = sprintf('of the ''%s'' directory ',folder);
                end
                warning('X13TBX:InstallMissingCensusProgram:DownloadFailed', ...
                    ['Download from url ''%s'' failed.\n', ...
                    'Try downloading this file manually. Unpack it and ', ...
                    'copy the content %sto %s on your drive.'], ...
                    url, dirinfo, [p,loc]);
            end
        catch err
            fprintf('\n');
            warning('X13TBX:InstallMissingCensusProgram:FileAccessFailure', ...
                ['%s\n%s\nCannot access the file "%s". It is possible ', ...
                'that the download from the web was faulty. Or maybe the ', ...
                'file exists but is write protected, or it is already ', ...
                'opened by another program.'], ...
                err.identifier, err.message, fname);
            ok = false;
        end
    end

    % unzip
    if ok
        [~,~,fext] = fileparts(fname);
        if strcmp(fext,'.zip')
            try
                unzip(fname,td);
            catch err
                fprintf('\n');
                warning('X13TBX:InstallMissingCensusProgram:UnzipFailed', ...
                    'Downloaded archive ''%s'' could not be unzipped.\n%s', ...
                    fname, err.message);
                ok = false;
            end
        end
        if ~isempty(folder)
            folder = [td,folder,filesep];
        else
            folder = td;
        end
    end
    
    % copy to correct location
    if ok
        for f = 1:numel(files)
            source      = fullfile(folder,files{f});
            loc         = strrep(loc,'\',filesep);
            destination = [p,loc,filesep];
            % create destination directory if it does not yet exist
            if exist(destination,'file') ~= 7
                % ... code 7 refers to directory
                mkdir(destination);
            end
            % copy file from source to destination
            [thisfileok,msg] = copyfile(source,destination,'f');
            if ~thisfileok
                fprintf('\n');
                warning('X13TBX:InstallMissingCensusProgram:CopyFailed', ...
                    ['File ''%s'' could not be copied to correct ', ...
                    'location.\n%s'], files{f}, msg);
                ok = false;
            end
        end
    end

    % inform user that installation was successful
    if ok
        fprintf('success.\n');
    end
    
end
