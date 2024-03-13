% ADDSPECTRUM computes the spectrum of a variable using the Signal Processing
% Toolbox and adds the result to an x13series.
%
% NOTE: This method requires that Matlab's Signal Processing Toolbox is
% installed.
%
% Usage:
%   obj.addspectrum(v,d,vname,descr);
%
% Inputs:
%   obj     An x13series object.
%   v       Variable contained in obj.
%   d       Number of differences. d=0 means that the spectrum of the data
%           itself is computed. Setting d=1 computes the spectrum of the first
%           difference of the variable.
%   vname   Name of the new variable that is created.
%   descr   Short text describing the new variable.
% 
% Example: We assume that dates and data contain the dates and the observations
% of a timeseries that will be seasonally adjusted.
%   spec = makespec(...);
%   obj = x13([dates,data],spec,'fixed');
%   obj.addspectrum('sa' ,1,'sfa','Spectrum of fixed seasonal adjustment');
%   obj.addspectrum('csa',1,'sca','Spectrum of camplet seasonal adjustment');
%   plot(obj,'sfa','sca','combined');
%
% NOTE: This program is part of the X-13 toolbox. It requires the Signal
% Processing toolbox as well.
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
% 2021-04-24    Version 1.50    Number of points at which periodogram is
%                               evaluated now depends on the number of
%                               observations.
% 2018-10-06    Version 1.33b   Bug fix.
% 2017-01-30    Version 1.30    First release featuring camplet and addspectrum,
%                               addacf, and addpcf.

function obj = addspectrum(obj,v,d,vname,descr)

    version = ver;
    ok = any(strcmp('Signal Processing Toolbox',{version.Name}));
    
    if ok
        
        % determine frequencies to be computed
        mp = obj.mperiod;
        maxp = max(mp);
        npoints = (obj.nobs+1)*0.5;
        if npoints < 60 ; npoints = 60 ; end
        if npoints > 200; npoints = 200; end
        % base frequencies
        freq = linspace(0,0.5,npoints); freq(1) = [];
        % trading day frequencies
        if maxp == 12   % if ismember(mp,12)
            TDfreq = [0.3482,0.4320] * 12/maxp;
            % TDfreq = [0.41+1/150,0.3565+1/3e4,0.44+1/3e3]:
            freq = [freq,TDfreq];
        else
            TDfreq = [];
        end
        % integer frequencies
        INTfreq = 0.5*(2:2:maxp)/maxp;
            % INTfreq = [];
            % for p = 1:numel(mp)
            %     INTfreq = [INTfreq,(0.5*(2:2:mp(p))/mp(p))];  %#ok<AGROW>
            % end
            % INTfreq = sort(INTfreq); rem = (diff(INTfreq) < 1/1000);
            % INTfreq(rem) = [];
        % combine the three sets of points
        freq = [freq,INTfreq];
        freq = sort(freq)';
        rem = find(diff(freq) < 1/1000);                % remove doubles
        moverem = ismember(freq(rem),[TDfreq,INTfreq]); % but protect ...
        rem(moverem) = rem(moverem)+1;                  % ... TD and INT
        freq(rem) = [];
        
        % differencing if requested
        if d == 0
            data = obj.(v).(v);
        else
            data = diff(obj.(v).(v),d);
        end
        
        % compute periodogram
        [ampl,~,conf] = periodogram(data,[],freq*maxp,maxp,'ConfidenceLevel', 0.95); %#ok<ASGLU>
        
        % add to x13series object
        s = struct( ...
            'descr'    , descr,          ...
            'type'     , 3,              ...
            'frequency', freq,           ...
            'amplitude', 10*log10(ampl)); % , ...
%             'conf'     , 10*log10(conf));
        obj = additem(obj,vname,s);

    else
        
        warning('X13TBX:miss_toolbox', ...
            'ADDSPECTRUM requires the Signal Process Toolbox.');

    end
    
end
