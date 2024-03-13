% STRUCTTOX13 uses the content of a struct to create a x13object
%
% Usage:
%   x = structtox13(s)
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
% have at most three characters. (Variablenames in x13series objects are
% constrained to three-letter names).
%
% structtox13 sets up the x13series variable and adds the dates and data
% vector to it, and then defers to addstructtox13 to do the rest of the
% work.
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

function x = structtox13(s,saveREQ)

    % check parameters
    
    if numel(s) > 1
        err = MException('X13TBX:structtox13:MultStruct', ...
            ['Multiple struct detected. (Did you use fixedseas with ', ...
             'multiple periods?) Please select only one struct.']);
        throw(err);
    end        

    fn = fieldnames(s);

    importALL = (nargin < 2 || all(strcmp(saveREQ,'all')));
    if importALL
        saveREQ = fn;
    end

    required = {'dates','dat'};
    miss = not(ismember(required,fn));
    if any(miss)
        err = MException('X13TBX:x13:MissingFields', ...
            'struct misses some required fields: %s.', ...
            ['''', strjoin(required(miss),''', '''), '''']);
        throw(err);
    end
    
    % make x13series with basic entries
    x = x13series;
    x.addvariable('dat',s.dates,s.dat,'dat',1);

    % add everything else
    x = addstructtox13(x,s,saveREQ);

end
