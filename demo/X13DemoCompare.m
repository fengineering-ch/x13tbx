%% COMPARING VARIOUS ALGORITHMS

%% Load Data and Specs

fprintf(['We are performing the seasonal decomposition with seven different ', ...
    'algorithms and compare the outcome.\n\n']);

% These are monthly data taken from the book by  D. Ladiray and
% B. Quenneville on the X-11 method.
load LadirayQuenneville

% This is a classic dataset used in ARIMA modelling and seasonal
% adjustment. It is known as Box-Jenkin's Series G and decribes the number
% of airline passengers from Jan 1949 and Dec 1960.
load BoxJenkinsG

% Unemployment quota in the USA.
load unemp;

% Vehicle miles travelled, USA.
load travel;

% choose the data set to use
data = BoxJenkinsG;
%data = LadirayQuenneville;
%data = unemp;
%data = travel;

% basic specs
basespec = makespec('LOG','TDAYS','EASTER','SPECTRUM');

%% Computations

n = {};

n{end+1} = 'X-13AS with X-11'; disp(n{end})
spec = makespec(basespec,'TRAMO','X11','series','title',n{end});
x3x = x13(data.dates,data.data,spec,'quiet');
x3x.addMatlabSpectrum;

n{end+1} = 'X-13AS with SEATS'; disp(n{end})
spec = makespec(basespec,'TRAMO','SEATS','series','title',n{end});
x3s = x13(data.dates,data.data,spec,'quiet');
x3s.addMatlabSpectrum;

% n{end+1} = 'X-12'; disp(n{end})
% spec = makespec(basespec,'TRAMO','X11','series','title',n{end});
% x2 = x13(data.dates,data.data,spec,'x-12','quiet');

n{end+1} = 'X-11'; disp(n{end})
spec = makespec(basespec,'X11','series','title',n{end});
x1 = x13(data.dates,data.data,spec,'x-11','quiet');

n{end+1} = 'Method I'; disp(n{end})
spec = makespec(basespec,'X11','series','title',n{end});
m = x13(data.dates,data.data,spec,'method1','quiet');

n{end+1} = 'FIXED'; disp(n{end})
spec = makespec(basespec,'series','title',n{end});
f = x13(data.dates,data.data,spec,'fixed','quiet');

n{end+1} = 'CAMPLET'; disp(n{end})
spec = makespec(basespec,'series','title',n{end});
c = x13(data.dates,data.data,spec,'camplet','quiet');

n{end+1} = 'seas.m'; disp(n{end})
spec = x13spec(basespec,'series','title',n{end});
s = x13(data.dates,data.data,spec,'prog','seas.m','quiet');

%% Correlation between seasonal factors

fprintf(['\n Correlations between different seasonal factors are extremely ', ...
    'high ...\n\n']);
all_sf = [x3x.d10.d10,x3s.s10.s10,x1.d10.d10, ...
    m.d10.d10,f.sf.sf,c.sf.sf,s.sf.sf];
corr_sf = corr(all_sf);
corr_sf_tbl = table(corr_sf(:,1),corr_sf(:,2),corr_sf(:,3),corr_sf(:,4), ...
    corr_sf(:,5),corr_sf(:,6),corr_sf(:,7), ...
    'VariableNames',n, 'RowNames',n);
disp(corr_sf_tbl);

n(6) = [];  % CAMPLET does not produce an irregulat component
fprintf([' Correlations between irregular components are smaller. CAMPLET ', ...
    'is missing in this\n table because it lacks an irregular ', ...
    'component.\n\n']);
all_ir = [x3x.d13.d13,x3s.s13.s13,x1.d13.d13, ...
    m.d13.d13,f.ir.ir,s.ir.ir];
corr_ir = corr(all_ir);
corr_ir_tbl = table(corr_ir(:,1),corr_ir(:,2),corr_ir(:,3),corr_ir(:,4), ...
    corr_ir(:,5),corr_ir(:,6), ...
    'VariableNames',n, 'RowNames',n);
disp(corr_ir_tbl);

%% Charts

fh = figure('Position',[74 69 854 693]); movegui(fh,'center');
ah = subplot(3,2,1); plot(ah,x3x,x3s,'d13','s13','comb','quiet')
ah = subplot(3,2,3); plot(ah,x3x,x1,'d13','comb');
ah = subplot(3,2,5); plot(ah,x3x,m,'d13','comb');
ah = subplot(3,2,2); plot(ah,x3x,s,'d13','ir','comb','quiet')
ah = subplot(3,2,6); plot(ah,x3x,f,'d13','ir','comb','quiet')

fh = figure('Position',[74 69 854 693]); movegui(fh,'center');
plot(fh,x3x,s,x1,c,m,f,'sp2','quiet')

fh = figure('Position',[74 69 854 693]); movegui(fh,'center');
ah = subplot(3,2,1); plot(ah,x3x,x3s,'e2','s11','comb','quiet')
ah = subplot(3,2,3); plot(ah,x3x,x1,'e2','comb');
ah = subplot(3,2,5); plot(ah,x3x,m,'d11','comb');
ah = subplot(3,2,2); plot(ah,x3x,s,'d11','sa','comb','quiet')
ah = subplot(3,2,4); plot(ah,x3x,c,'d11','sa','comb','quiet')
ah = subplot(3,2,6); plot(ah,x3x,f,'d11','sa','comb','quiet')

fh = figure('Position',[74 69 854 693]); movegui(fh,'center');
plot(fh,x3x,s,x1,c,m,f,'sp1')

fh = figure('Position',[74 69 854 693]); movegui(fh,'center');
ah = subplot(3,2,1); plot(ah,x3x,x3s,'d12','s12','comb','quiet')
ah = subplot(3,2,3); plot(ah,x3x,x1,'d12','comb');
ah = subplot(3,2,5); plot(ah,x3x,m,'d12','comb');
ah = subplot(3,2,2); plot(ah,x3x,s,'d12','tr','comb','quiet')
ah = subplot(3,2,4); plot(ah,x3x,c,'d12',c.keyv.tr,'comb','quiet')
ah = subplot(3,2,6); plot(ah,x3x,f,'d12','tr','comb','quiet')

fprintf(['\nCAMPLET is different because it is an only backward looking ', ...
    'filter. The advantage of a purely\nbackward-looking algorithm is that the ', ...
    'seasonal adjustment is not changed when new data\ncome along. But as can ', ...
    'be seen, the trend is markedly different and deviates from the\n', ...
    'effective development. To be fair, they are estimated ''on the go,'' ', ...
    'so without the benefit of\nknowing the future evolution, so we should ', ...
    'expect larger differences.\n']);
