% JOINPERIODS is the opposite of splitperiods.
%
% Example:
%   data = [100 90 85 150 101 90 86 155 101 88 87 152 98 91 84 144 ...
%       99 88 86 153]';
%   q = splitperiods(data,4); nyears = size(q,1);
%   plot(q); title('data by quarter');
%   legend('First','Second','Third','Fourth Quarter');
%   qadj = q - repmat(mean(q),nyears,1) + mean(data);
%   dataadj = joinperiods(qadj);
%   figure; plot([data,dataadj],'linewidth',1); grid on;
%   title('unadjusted and adjusted data');
%
% NOTE: This program is part of the X-13 toolbox, but it is completely
% independent of the Census X-13 program. It is part of the 'seas' addition to
% the toolbox which allows to implement seasonal filters without using the
% Census Bureau programs.
%
% see also guix, x13, makespec, x13spec, x13series, x13composite, 
% x13series.plot,x13composite.plot, x13series.seasbreaks,
% x13composite.seasbreaks, fixedseas, camplet, spr, InstallMissingCensusProgram
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
% 2018-09-19    Version 1.33    First version of the 'seas' part of the X-13
%                               toolbox.

function x = joinperiods(x,varargin)
    x = x';
    x = x(:);
    if ~isempty(varargin)
        nobs = varargin{1};
        if numel(nobs) > 1
            nobs = numel(nobs);
        end
        if nobs < numel(x)
            x(nobs+1:end) = [];
        else
            x(end+1:nobs) = NaN;
        end
    else
        idx = find(~isnan(x),1,'last');
        x(idx+1:end) = [];
    end
end
