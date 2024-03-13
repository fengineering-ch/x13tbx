% X13MINUS takes two x13series objects and returns a new x13series object
% that contains all time series both arguments have in common, but
% containing the difference of the values. This is useful to exactly
% compare the differences between two sets of specifications.
%
% Usage:
%   x3 = x13minus(x1,x2)
%
% x1, x2, x3 are x13series objects. x3 contains all time series objects
% that are common to x1 and x2, but with their differences as values. In
% addition, x3 will contain variables 'tr','sa','sf','ir','si','rsd' that
% contain the differences of the key variables, so that even if the key
% variables have different names in x1 and x2, you can still get a
% difference.
%
% Example1:
%   load BoxJenkinsG; dates = BoxJenkinsG.dates; data = BoxJenkinsG.data; 
%   spec1 = makespec('PICKFIRST','NOTRANS','EASTER','TD','X11', ...
%       'series','name','linear');
%   x1 = x13(dates,data,spec1);
%   spec2 = makespec(spec1,'LOG','series','name','log');
%   x2 = x13(dates,data,spec2);
%   x3 = x13minus(x1,x2);
%   ah = subplot(2,1,1); plot(ah,x1,x2,'e2','comb');
%   ah = subplot(2,1,2); plot(ah,x3,'e2');
%
% EXAMPLE 2:
%   spec1 = makespec('PICKFIRST','LOG','EASTER','TD','X11','DIAG', ...
%       'series','name','X-11');
%   x1 = x13(dates,data,spec1);
%   spec2 = makespec(spec1,'SEATS','series','name','SEATS','DIAG');
%   x2 = x13(dates,data,spec2);
%   x3 = x13minus(x1,x2);
%   ah = subplot(2,1,1); plot(ah,x1,x2,'d11','s11','comb','quiet');
%   ah = subplot(2,1,2); plot(ah,x3,'sa');
% Note that x3.sa is x1.e2 - x2.s11, because the seasonally adjusted
% variables have different names in in X11 and in SEATS.
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
% 2021-07-21    Version 1.52    Fixed a bug. In addition, function now also
%                               supports spectra and autocorr functions.
% 2021-04-27    Version 1.50    First version.

function z = x13minus(x,y)

    Lx = x.listofitems;
    Ly = y.listofitems;
    L  = intersect(Lx,Ly);
    
    D  = intersect(x.dat.dates,y.dat.dates);
    Dx = ismember(x.dat.dates,D);
    Dy = ismember(y.dat.dates,D);
    
    z = x13series;

    allkeyv = {'dat','tr','sa','sf','ir','si','rsd'};
    for v = 1:numel(allkeyv)
        try
            vx = x.(x.keyv.(allkeyv{v})).(x.keyv.(allkeyv{v}));
            vy = y.(y.keyv.(allkeyv{v})).(y.keyv.(allkeyv{v}));
            ts = vx(Dx) - vy(Dy);
            z.addvariable(allkeyv{v},D,ts,allkeyv{v},1);
        catch
        end
    end
    rem = ismember(L,allkeyv);
    L(rem) = [];
    
    for v = 1:numel(L)
        [~,xtype] = x.descrvariable(L{v});
        [~,ytype] = x.descrvariable(L{v});
        if (xtype == ytype)
            try
                % 1 : variable
                % 2 : ACF or PACF
                % 3 : spectrum
                switch xtype
                    case 1
                        D = intersect(x.(L{v}).dates,y.(L{v}).dates);
                        Dx = ismember(x.(L{v}).dates,D);
                        Dy = ismember(y.(L{v}).dates,D);
                        if ~isempty(D)
                            ts = x.(L{v}).(L{v})(Dx) - y.(L{v}).(L{v})(Dy);
                            z.addvariable(L{v},D,ts,L{v},1);
                        end
                    case 2
                        D = intersect(x.(L{v}).Lag,y.(L{v}).Lag);
                        Dx = ismember(x.(L{v}).Lag,D);
                        Dy = ismember(y.(L{v}).Lag,D);
                        s = struct( ...
                            'descr'     , '',             ...
                            'type'      , 2,              ...
                            'Lag'       , D);
                        if ~isempty(D)
                            fn = fieldnames(x.(L{v})); fn(1:3) = [];
                            for f = 1:numel(fn)
                                vals = x.(L{v}).(fn{f})(Dx) - y.(L{v}).(fn{f})(Dy);
                                s.((fn{f})) = vals;
                            end
                            z = additem(z,L{v},s);
                        end
                    case 3
                        D = intersect(x.(L{v}).frequency,y.(L{v}).frequency);
                        Dx = ismember(x.(L{v}).frequency,D);
                        Dy = ismember(y.(L{v}).frequency,D);
                        if ~isempty(D)
                            ampl = x.(L{v}).amplitude(Dx) - y.(L{v}).amplitude(Dy);
                            s = struct( ...
                                'descr'    , '',             ...
                                'type'     , 3,              ...
                                'frequency', D,              ...
                                'amplitude', ampl); % , ...
                            z = additem(z,L{v},s);
                        end
                end
            catch
            end
        end
    end
    
    [~,tx] = fileparts(x.prog);
    [~,ty] = fileparts(y.prog);
    if strcmp(tx,ty)
        tx = x.spec.title;
        ty = y.spec.title;
    end
    if strcmp(tx,ty)
        tx = x.spec.name;
        ty = y.spec.name;
    end
    if strcmp(tx,ty)
        tx = '#1';
        ty = '#2';
    end
    
    z.spec = x13spec('series','title',[tx, ' minus ', ty]);

end
