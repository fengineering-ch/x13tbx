% WRAPLINES wraps strings at spaces so that they have at most l characters
% per line. It preappends leadText and appends tailText to every line.
%
% Usage:
%   str = WrapLines(str,lenth,[leadText],[tailText]);
%
% Example:
%   str = 'George''s job is to chop wood.';
%   disp(WrapLines(str,22,'( ',' )'));
% produces
%   ( George's job is to )
%   ( chop wood.         )
%
% NOTE: This file is part of the X-13 toolbox.
%
% see also guix, x13, makespec, x13spec, x13series, x13composite, 
% x13series.plot,x13composite.plot, x13series.seasbreaks,
% x13composite.seasbreaks, fixedseas, camplet, spr, InstallMissingCensusProgram
%
% Author  : Yvan Lengwiler
% Version : 1.35
%
% If you use this software for your publications, please reference it as:
%
% Yvan Lengwiler, 'X-13 Toolbox for Matlab, Version 1.35', Mathworks File
% Exchange, 2014-2018.
% url: https://ch.mathworks.com/matlabcentral/fileexchange/49120-x-13-toolbox-for-seasonal-filtering

function str = WrapLines(str,l,leadText,tailText)

    if nargin < 4
        tailText = '';
    end
    assert(ischar(tailText), ...
        'Tailing text must be a string.');
    if nargin < 3
        leadText = '';
    end
    assert(ischar(leadText), ...
        'Leading text must be a string.');
    if nargin < 2
        l = 79;
    end
    l = l - numel(leadText) - numel(tailText);
    assert(l>0, ['Length of lines (second argument) must be strictly ', ...
        'positive after subtracting the length of the leading ', ...
        'and tailing texts (thirst and fourth arguments).']);
    
%    if not(exist('newline','builtin'))
%        newline = char(10);     %#ok<CHARTEN>
%    end
%    newline = char(10);     %#ok<CHARTEN>

    posLF    = [0,strfind(str,newline),length(str)];
    startpos = posLF(find(diff(posLF) > l)); %#ok<*FNDSB>
    while ~isempty(startpos)
        posSP = find(ismember(str(startpos(1)+1:startpos(1)+1+l),' '), ...
            1, 'last') + startpos(1);
        if isempty(posSP)
            % no space available; cut in the middle of a word
            str = [str(1:startpos(1)+l), newline, ...
                str(startpos(1)+l+1:end)];
        else
            % replace last available space with lf
            str = [str(1:posSP-1), newline, ...
                str(posSP+1:end)];
        end
        posLF    = [1,strfind(str,newline),length(str)];
        startpos = posLF(find(diff(posLF) > l+1));
    end

    lines = strsplit(str,newline);
    % make lines full length
    if ~isempty(tailText)
        lines = cellfun(@(c) [c,repmat(' ',1,l)],lines, ...
            'UniformOutput',false);
        lines = cellfun(@(c) c(1:l),lines, ...
            'UniformOutput',false);
    end
    % pre-append leadText and append tailText to all lines
    lines = cellfun(@(c) [leadText,c,tailText],lines, ...
        'UniformOutput',false);
    % append newline to all lines except the last one
    lines = [cellfun(@(c) [c,newline],lines(1:end-1), ...
        'UniformOutput',false) , lines{end}];
    % combine into one string
    str = [lines{:}];

end
