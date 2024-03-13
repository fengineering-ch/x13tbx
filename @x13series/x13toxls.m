% X13TOXLS writes the content of an x13series variable into an Excel file.
%
% Usage:
%   x13toxls(x,filename,['overwrite'])
%
% x is a x13series object. filename is the name of the Excel workbook that will
% be created. If you add the switch 'overwrite', an existing Excel file with the
% same name will be overwritten.
%
% There is no function for exporting x13composite objects to Excel, but you can
% use x13toxls to export individual series contained in an x13composite. For
% instance, if x is a x13composite with three series, x.country, x.north,
% x.south, then x13toxls(x.country,'country.xlsx') will write the content of
% x.country into an Excel file.
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
% 2017-03-26    Version 1.32    Support for datetime class variable for the
%                               dates.
% 2017-01-09    Version 1.3     First release featuring camplet.
% 2016-12-23    Version 1.21    First version.

%#ok<*CHARTEN>
%#ok<*AGROW>

function x13toxls(x,filename,overwrite)

    % --- CHECK INPUTS ---------------------------------------------------------
    
    if nargin < 1 || ~isa(x,'x13series')
        err = MException('X13TBX:X13TOXLS:WrongType', ...
            'First argument must be a x13series type variable. (This error should never occur!)');
        throw(err);
        % If the toolbox is correctly installed, this error should not occur,
        % because Matlab would not reach the x13toxls function if no x13series
        % object is given as argument.
    end
    if isempty(x.listofitems)
        warning('X13TBX:x13toxls:EmptyObject', ...
            'x13series object is empty. There is nothing to export to the Excel file.');
        return;
    end
    
    if nargin < 2
        err = MException('X13TBX:x13toxls:NoFilename', ...
            'Second argument must be name of target file.');
        throw(err)
    end
    if ~ischar(filename) || isempty(filename) || any(ismember(filename,'?*<>"|'))
        err = MException('X13TBX:x13toxls:IllegalFilename', ...
            'Target filename is illegal.');
        throw(err)
    end
    [path,~,ext] = fileparts(filename);
    if isempty(ext)
        ext = '.xlsx';
        filename = [filename,ext];
    end
    if isempty(path)
        filename = [pwd,filesep,filename];
    end
    
    if nargin < 3 || isempty(overwrite)
        overwrite = false;
    else
        overwrite = strcmpi(overwrite,'overwrite');
    end
    
    % --- COLLECT ITEMS IN X13SERIES OBJECT ------------------------------------
    
    allprop = x.listofitems; n = numel(allprop);
    types = NaN(n,1); descr = cell(n,1);
    for t = 1:n
        [descr{t},types(t)] = x.descrvariable(allprop{t});
    end
    keep = (types == 0); txt = allprop(keep);   descrtxt = descr(keep);
    keep = (types == 1); ts = allprop(keep);    descrts = descr(keep);
    keep = (types >  1); other = allprop(keep);
    
    % --- CONNECT TO EXCEL AND CREATE FILE -------------------------------------
    
    % create instance of Excel
    try
        hExcel = actxserver('Excel.Application');
    catch ME
        msg = '\nCannot start Excel server.';
        ME  = MException(ME.identifier,[ME.message,msg]);
        throw(ME);
    end
    
    % create an Excel workbook
    try
        hBook = hExcel.Workbooks.Add;
    catch ME
        msg = ['\nCannot create file. Maybe it is protected or in use by ', ...
            'another program?'];
        ME  = MException(ME.identifier,[ME.message,msg]);
        throw(ME);
    end
    
    % delete all sheets except the first
    for s = 2:hBook.Sheets.Count
        hNextSheet = get(hExcel.Sheets,'item',s);
        hNextSheet.Delete(False);
    end
    hSheet = get(hBook.Sheets,'item',1);    % handle to the remaining worksheet
    
    % --- CONTENT --------------------------------------------------------------
    
    ExportText(sprintf('%s \n \n \n%s%s', ...
        x.dispstring, x.spec.dispstring, repmat('=',1,78)), 'Content');
    
    % --- TIME SERIES ----------------------------------------------------------
    
    % get union of date vectors
    alldates = [];
    for t = 1:numel(ts)
        thisdates = x.(ts{t}).dates;
        if isa(thisdates,'datetime')
            thisdates = datenum(thisdates);
        end
        alldates = unique([alldates;thisdates]);
    end
    
    % collect all the time series
    data = nan(numel(alldates),0);
    header1 = cell(0);
    header2 = cell(0);
    description = cell(0);
    for t = 1:numel(ts)
        fn = fieldnames(x.(ts{t}));
        header1(end+1) = ts(t);
        description(end+1) = descrts(t);
        if numel(fn)>4
            header1(end+1:end+numel(fn)-4) = cell(1,numel(fn)-4);
            description(end+1:end+numel(fn)-4) = cell(1,numel(fn)-4);
        end
        header2(end+1:end+numel(fn)-3) = fn(4:end);
        try
            loc = ismember(alldates,x.(ts{t}).dates);
        catch
            
        end
        for f = 4:numel(fn)
            data(loc,end+1) = x.(ts{t}).(fn{f});
            data(~loc,end)  = NaN;
        end
    end
    
    % write data into Excel sheet
    hSheet = hBook.Sheets.Add([],hSheet);
    hSheet.Name = 'timeseries';
    addr = RangeAddr(alldates,[4,1]);
    set(hSheet.Range(addr),'Value',num2cell(datenum(alldates)-693960));
    datefmt = XDateFmt(hSheet.Parent.Parent);
    hSheet.Range(addr).NumberFormat = datefmt;
    
    content = [description;header1;header2];
    addr = RangeAddr(content,[1,2]);
    set(hSheet.Range(addr),'Value',content);
    
    addr = RangeAddr(data,[4,2]);
    set(hSheet.Range(addr),'Value',num2cell(data));
    
    MakeSplits(3,1);                % split columns and rows
    GridVisible(false);
    
    % --- OTHER TYPES OF VARIABLES (NOT TIMESERIES OR TEXT) --------------------
    
    for t = 1:numel(other)
        ExportOther(other{t});
    end
    
    % --- TEXT ITEMS -----------------------------------------------------------
    
    for t = 1:numel(txt)
        ExportText([' *** ',upper(descrtxt{t}),char(10),x.(txt{t})], ...
            txt{t}, hSheet);
    end
    
    % --- SAVE FILE AND CLEANUP ------------------------------------------------

    % activate first sheet ('Content')
    hSheet = get(hBook.Sheets,'item',1);
    hSheet.Activate;

    % determine format of Excel sheet
    switch ext
        case '.xls' %xlExcel8 or xlWorkbookNormal
           xlFormat = -4143;
        case '.xlsb' %xlExcel12
           xlFormat = 50;
        case '.xlsx' %xlOpenXMLWorkbook
           xlFormat = 51;
        case '.xlsm' %xlOpenXMLWorkbookMacroEnabled
           xlFormat = 52;
        otherwise
           xlFormat = -4143;
    end
    
    % if overwrite, delete existing file first
    if exist(filename,'file')
        if overwrite
            try
                % allowed to overwrite, so just delete existing file
                % from disk
                delete(filename);
            catch ME
                % throw an error if deleting fails
                msg = ['\nFile is protected or used by other ', ...
                    'application; cannot be overwritten.'];
                hExcel.Quit;                    % delete Excel object
                hExcel.release;                 % stop process
                ME  = MException(ME.identifier,[ME.message,msg]);
                throw(ME);
            end
        else
            % not allowed to overwrite, so don't delete
            % just throw an error
            hExcel.Quit;                    % delete Excel object
            hExcel.release;                 % stop process
            msg = ['File already exists. Choose a different name ', ...
                'or set the ''overwrite'' option.'];
            ME = MException('X13TBX:x13toxls:FailToWrite',msg);
            throw(ME);
        end
    end
    
    % save Excel file to disk
    try
        hBook.SaveAs(filename, xlFormat);
    catch ME
        msg = sprintf(['\nFile ''%s'' cannot be saved. It is ', ...
            'either protected or in use by another application, ', ...
            'or the drive is full.'],strrep(filename,'\','\\'));
        ME  = MException(ME.identifier,[ME.message,msg]);
        hExcel.Quit;                    % delete Excel object
        hExcel.release;                 % stop process
        throw(ME);
    end
    
    % release Excel server
    hExcel.Quit;                    % delete Excel object
    hExcel.release;                 % stop process
    
    % === INTERNAL FUNCTIONS ===================================================
    
    % compute cell range in Excel notation
    function addr = RangeAddr(matrix, topleft)
        sizeofarray = size(matrix);
        % compute addr
        if sizeofarray(1) == 1 && sizeofarray(2) == 1
            % sizeofarray is 1x1 --> output only a single cell address (no ':') 
            addr = [to26(topleft(2)),int2str(topleft(1))];
        else
            % bottom right cell
            topcol = to26(topleft(2));
            toprow = int2str(topleft(1));
            botrow = int2str(topleft(1) + sizeofarray(1) - 1);
            botcol = to26(topleft(2) + sizeofarray(2) - 1);
            % result
            addr = [topcol,toprow,':',botcol,botrow];
        end
        % convert to 26imal code
        function code = to26(number)
            code = '';
            while number>0
                m = mod(number-1,26);
                code = [char(65+m),code];
                number = (number - m - 1) / 26;
            end
        end
    end

    % make fixed splits in Excel sheet
    function MakeSplits(rows,cols)
        hWin = get(hBook.Windows,'item',1);
        hWin.SplitRow = rows;
        hWin.SplitColumn = cols;
        hWin.FreezePanes = true;
    end

    % make grid visible / not visible in Excel sheet
    function GridVisible(bVisible)
        hWin = get(hBook.Windows,'item',1);
        hWin.DisplayGridlines = bVisible;
    end

    % Export non-timeseries numerical variable to Excel sheet
    function ExportOther(strVrbl)
        hSheet = hBook.Sheets.Add([],hSheet);
        hSheet.Name = strVrbl;
        vrbl = x.(strVrbl);
        set(hSheet.Range('A1'),'Value',upper(vrbl.descr));
        fn = fieldnames(vrbl); fn(1:2) = [];   % remove descr and type fields
        for ff = 1:numel(fn)
            data = vrbl.(fn{ff});
            addr = RangeAddr(fn(ff),[2,ff]);
            set(hSheet.Range(addr),'Value',fn(ff));
            addr = RangeAddr(data,[3,ff]);
            set(hSheet.Range(addr),'Value',num2cell(data));
        end
        GridVisible(false);
    end
    
    % Export string cells to Excel sheet  
    function ExportText(strContent,strSheetname,afterSheet)
        if nargin == 3
            hSheet = hBook.Sheets.Add([],afterSheet);
        end
        hSheet.Name = strSheetname;
        strContent = strrep(strContent,char(9),'   '); % replace tab with triplle space
        strContent = strsplit(strContent,char(10)); strContent = strContent';
        strContent = strcat('''',strContent);          % pre-append each line with a single quote
        addr = RangeAddr(strContent,[1,1]);            % range in Excel notation
        set(hSheet.Range(addr),'Value',strContent);
        hSheet.Range('A1').EntireColumn.Font.Name = 'Consolas';
        hSheet.Range('A1').EntireColumn.AutoFit;
        GridVisible(false);
    end

    % Return a cell format for calendar dates
    % (taken from X Toolbox)
    function fmt = XDateFmt(hExcel,fmt)
        if nargin < 2
            fmt = 'YYYY-MM-DD';
        end
        try
            codes = hExcel.International;
        catch ME
            msg = '\nFirst argument is not a valid handle to an Excel server.';
            ME  = MException('X13TBX:X13TOXLS:InvalidExcelServer', ...
                [ME.message,msg]);
            throw(ME);
        end
        fmt = strrep(fmt, 'Y', codes{19});
        fmt = strrep(fmt, 'M', codes{20});
        fmt = strrep(fmt, 'D', codes{21});
        fmt = strrep(fmt, 'h', codes{22});
        fmt = strrep(fmt, 'm', codes{23});
        fmt = strrep(fmt, 's', codes{24});
    end

    
end
