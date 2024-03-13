% SPECMINUS removes all entries in the second x13spec object from the entries in
% the first x13spec object (provided the section-key-values of the second spec
% are present in the first spec). Consequently, if the first spec is a subset of
% the second spec, an empty x13spec object is returned.
%
% Usage:
%   spec1 = specminus(spec1,spec2)
%   spec1 = specminus(spec1,spec2,type)
%
% type is a number between 1 and 7, indicating the adjustment method that
% is supposed to be present. This method is first enforced on both
% arguments. For details, see the code of specminus. If type is anything
% illegal or omitted, spec1 and spec2 are not treated before performing the
% comparison.
%
% NOTE: This file is part of the X-13 toolbox.
%
% see also guix, x13, makespec, x13spec, x13series, x13composite, 
% x13series.plot,x13composite.plot, x13series.seasbreaks,
% x13composite.seasbreaks, fixedseas, spr, InstallMissingCensusProgram
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
% 2021-04-27    Version 1.50    Enlaged to cover more enforce specs, in
%                               line with the needs of guix (where
%                               specminus is heavily used).
% 2018-11-02    Version 1.34    Added type argument.
% 2016-09-94    Version 1.18    First version.

function specDiff = specminus(spec1,spec2,type)

    if nargin < 3
        type = 0;   % do not enforce a type if none is requested
    end
    
    specDiff = x13spec(spec1);
    specKeep = x13spec(spec2);
    
    % enforce a specific type
    switch type
        case 0
        case 1
            specDiff = specDiff.enforceX13;
            specKeep = specKeep.enforceX13;
        case 2
            specDiff = specDiff.enforceX12;
            specKeep = specKeep.enforceX12;
        case 3
            specDiff = specDiff.enforceX11;
            specKeep = specKeep.enforceX11;
        case 4
            specDiff = specDiff.enforceMETHOD1;
            specKeep = specKeep.enforceMETHOD1;
        case 5
            specDiff = specDiff.enforceCAMPLET;
            specKeep = specKeep.enforceCAMPLET;
        case 6
            specDiff = specDiff.enforceFIXEDSEAS;
            specKeep = specKeep.enforceFIXEDSEAS;
        otherwise
            specDiff = specDiff.enforceCUSTOM;
            specKeep = specKeep.enforceCUSTOM;
    end

    series1 = fieldnames(specDiff);
    series2 = fieldnames(specKeep);
    accumulKeys = x13spec.accKeys;
%    accumulKeys = {'save', 'savelog', 'print', 'variables', ...
%        'aictest', 'types', 'user', 'usertype'};

    ser = intersect(series1,series2);
    for s = 1:numel(ser)
        keys1 = {}; try keys1 = fieldnames(specDiff.(ser{s})); catch; end
        keys2 = {}; try keys2 = fieldnames(specKeep.(ser{s})); catch; end
        keys = intersect(keys1,keys2);
        for k = 1:numel(keys)
            if ismember(keys{k},accumulKeys)
                val1 = ExtractValues(specDiff,ser{s},keys{k});
                val2 = ExtractValues(specKeep,ser{s},keys{k});
                val  = intersect(val1,val2);
                specDiff = RemoveRequests(specDiff,ser{s},keys{k},val);
            else
                val1 = specDiff.(ser{s}).(keys{k});
                val2 = specKeep.(ser{s}).(keys{k});
                if isnumeric(val1); val1 = mat2str(val1); end
                if isnumeric(val2); val2 = mat2str(val2); end
                if isequal(val1,val2)
                    specDiff = x13spec(specDiff,(ser{s}),(keys{k}),[]);
                end
            end
        end
        try
            if isempty(fieldnames(specDiff.(ser{s})))   % nothing left in this section
                specDiff = specDiff.RemoveSections(ser{s});
            end
        catch
        end
    end
