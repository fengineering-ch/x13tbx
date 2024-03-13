% ADDSTRUCTTOX13 uses the content of a struct and adds it to a x13object
%
% Usage:
%   x = structtox13(x,s)
%
% s is a struct. It must at least contain the fields 'dates', 'dat',
% 'period', and either 'type' or 'transform'.
% 
%   .period   is the number of observations (positive integer) for the
%             cycle that is removed, 'type' or 'transform' is either
%             'additive', 'multiplicative', 'logadditive' or some other
%             transform function supported by the program you use,
%             indicating the type of decomposition.
%  .dates     These are column vectors containing the dates of observation
%  .dat       (datenum) and the observations (floats). Both must have the
%             equal length. x is a x13series object containing the same
%             information.
%
% Optional fields that are treaded in a special way are 'name' and 'prog'.
%  .name      is the name of the variable that is seasonally adjusted (if
%             this content is a string). 
%  .prog      is the name of the program that was used to perform the
%             seasonal adjustment. 
%
% All other fields are added to the x13series object if their fieldnames
% have at most three characters (variable names in x13series objects are
% constrained to three-letter names).
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
% 2020-05-02    Version 1.50    Streamlined.
% 2020-04-21    Version 1.42    Some bug fixes.
% 2020-04-03    Version 1.41    First version.

function x = addstructtox13(x,s,saveREQ)

    % valid args?

    if numel(s) > 1
        err = MException('X13TBX:addstructtox13:MultStruct', ...
            ['Multiple struct detected. (Did you use fixedseas with ', ...
             'multiple periods?) Please select only one struct.']);
        throw(err);
    end
    
    if nargin < 3 || isempty(saveREQ)
        saveREQ = 'saveKeyv';
    end
    
    % keyv and dates vector

    fn = fieldnames(s);
    if ismember('keyv',fn)
        x.keyv = s.keyv;
    end
    thedates = x.(x.keyv.dat).dates;
    
    % save all key variables?
    
    if any(ismember(saveREQ,'saveKeyv'))
        toSave = {x.keyv.tr, x.keyv.sa, x.keyv.sf, ...
                x.keyv.ir, x.keyv.si, x.keyv.rsd};
        rem = ismember(toSave,'***'); toSave(rem) = [];
        x.spec.AddRequests(x.spec.adjmethod,'save',toSave);
        saveREQ = unique([saveREQ,toSave]);
    end

    % transform, title, name
    
    if ismember('transform',fn)
        x.spec = x13spec(x.spec,'transform','function',s.transform);
    end
    
    if ismember('title',fn)
        if ~isempty(s.title)
            x.spec = x13spec(x.spec, 'series','title',s.title);
        end
    end
    
    if ismember('name',fn)
        str = s.name;
        str = x13series.LegalVariableName(str);
        if ~isempty(str)
            % -------------------------------------------------------
            % the following is taken from x13series.LegalVariableName
            if isnumeric(str)
                str = mat2str(str);
            end
            try
                str = matlab.lang.makeValidName(str);
            catch
                str = genvarname(str);
            end
            % -------------------------------------------------------
        end
        x.spec = x13spec(x.spec, 'series','name',str);
        x.name = str;
    end
    
    % prog, mode, and period
    
    if ~ismember('prog',fn) || isempty(s.prog)
        prog = '(none)';
    else
        x.prog = s.prog;
        prog = s.prog;
    end
    
    method = x.spec.adjmethod;
    if isempty(method)
        switch prog
            case {'x11.m','method1.m'}
                method = 'x11';
            case 'camplet.m'
                method = 'camplet';
            case 'fixedseas.m'
                method = 'fixedseas';
            otherwise
                method = 'custom';
        end
    end
    
    if ismember('mode',fn)
        x.spec = x13spec(x.spec,method,'mode',s.mode);
    end
    
    if ismember('period',fn)
        try
            x.spec = x13spec(x.spec, method,'period',s.period);
        catch
        end
        if numel(s.period) > 1
            if x.spec.isComposite
                x.spec = x13spec(x.spec, 'composite','period',max(s.period));
            else
                x.spec = x13spec(x.spec, 'series','period',max(s.period));
            end
        end
    end
    
    % tables
    
    if ismember('tbl',fn)
        if isstruct(s.tbl)
            existingtbl = fieldnames(x.tbl);
            fntbl = fieldnames(s.tbl);
            for t = 1:numel(fntbl)
                if ismember(fntbl{t},existingtbl)
                    cnt = [x.tbl.(fntbl{t}),newline,newline,s.tbl.(fntbl{t})];
                    x.rmtable(fntbl{t});
                else
                    cnt = s.tbl.(fntbl{t});
                end
                x.addtable(fntbl{t},cnt);
            end
        end
    end
    
    % remaining content
    
    rem = ismember(fn,{'title','name','prog','keyv','dates','dat','period', ...
        'tbl','mode','transform'});
    fn(rem) = [];
    
    longfields = cellfun(@(c) length(c)>3, fn);
    if any(longfields)
        args = fn(longfields);
        for v = 1:numel(args)
            if ~isempty(s.(args{v}))
                try     % try to put this into the 'method' section of the spec
                    x.spec = x13spec(x.spec, method, args{v}, s.(args{v}));
                catch   % ignore this material
                end
            end
        end
        fn(longfields) = [];
    end
    
    fn = intersect(fn,saveREQ);
    
    for v = 1:numel(fn)
        if ismember(fn{v},x.listofitems)
            x.rmitem(fn{v});
        end
        try     % try to add content as time series
            data = s.(fn{v});
            if ~isnumeric(data); data = double(data); end
            x.addvariable(fn{v},thedates,data,fn{v},1);
        catch   % if that fails, add content as general item
            x.additem(fn{v}, s.(fn{v}));
        end
    end
    
    x.updatemsg;
    
end
