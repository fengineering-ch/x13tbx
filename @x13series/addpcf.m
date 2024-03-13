% ADDPCF computes the partial autocorrelation function of a variable using the
% Econometrics Toolbox and adds the result to an x13series.
%
% NOTE: This method requires that Matlab's Econometric Toolbox is
% installed.
%
% Usage:
%   obj.addpcf(v,d,vname,descr);
%   obj.addpcf(v,d,vname,descr,nlags);
%
% Inputs:
%   obj     An x13series object.
%   v       Variable contained in obj.
%   d       Number of differences. d=0 means that the PACF of the data
%           itself is computed. Setting d=1 computes the PACF of the first
%           difference of the variable.
%   vname   Name of the new variable that is created.
%   descr   Short text describing the new variable.
%   nlags   Number of lags to compute (default is 2*obj.period).
% 
% Example: We assume that dates and data contain the dates and the observations
% of a timeseries that will be seasonally adjusted.
%   spec = makespec('ADDITIVE','FIXEDSEAS');
%   obj = x13([dates,data],spec);
%   obj.addpcf('ir' ,1,'fpi','PACF of fixed irregular');
%   plot(obj,'fpi');
%
% NOTE: This program is part of the X-13 toolbox. It requires the Econometrics
% toolbox as well.
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
% 2017-01-30    Version 1.30    First release featuring camplet and addspectrum,
%                               addacf, and addpcf.

function obj = addpcf(obj,v,d,vname,descr,varargin)
    version = ver;
    ok = any(strcmp('Econometrics Toolbox',{version.Name}));
    if ok
        if isempty(varargin)
            nlags = 2*obj.period;
        else
            nlags = varargin{1};
        end
        if d ~= 0
            [pcf,lags,bounds] = parcorr(diff(obj.(v).(v),d),nlags,[],1);
        else
            [pcf,lags,bounds] = parcorr(obj.(v).(v),nlags,[],1);
        end
        
        pcf(1) = []; lags(1) = [];
        s = struct( ...
            'descr'       , descr,  ...
            'type'        , 2,      ...
            'Lag'         , lags,   ...
            'Sample_PACF' , pcf,    ...
            'S_E__of_PACF', repmat(bounds(1),nlags,1));
        obj = additem(obj,vname,s);
    else
        warning('X13TBX:miss_toolbox', ...
            'ADDPCF requires the Econometrics Toolbox.');
    end
end
