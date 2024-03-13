%% DEMO for X13 Toolbox: Composite Run

%#ok<*CHARTEN>
%#ok<*SAGROW>

% turn warnings temporarily off
orig_warning_state = warning('off','all');

%% PRELIMINARIES

% get correct path
p = fileparts(mfilename('fullpath'));   % directory of this m-file
% if the section is run with Shift-Ctrl-Enter ...
if isempty(p); p = [cd,'\']; end
% location of graphics files for use with X-13-Graph program
grloc = fullfile(p,'graphics\');

% size for figures with subplots
scSize = get(groot,'ScreenSize');
scWidth = scSize(3); scHeight = scSize(4);
sizeFig = @(h,v) round([0.04*scWidth, scHeight*(1-0.08-v/100)-50, ...
    h/100*scWidth, v/100*scHeight]);

size1 = sizeFig(40,80);
size2 = sizeFig(80,45);
size3 = sizeFig(95,45);
size4 = sizeFig(70,70);
size6 = sizeFig(75,68);
size8 = sizeFig(95,65);
size9 = sizeFig(95,90);

% line width
lwidth = 78;

% single and double line
sline = repmat('-',1,lwidth+1);
dline = repmat('=',1,lwidth+1);

% display with wrapped lines and leading space
report = @(s) disp(WrapLines(s,lwidth,' '));

% write heading
m = ver('matlab');
clc; disp(dline);
report(['DEMONSTRATION OF X-13 TOOLBOX FOR MATLAB : ', ...
    'composite run']);
report(sprintf(['This script was developed with MATLAB Version ', ...
    '8.3.0.532 (R2014a) and ran on MATLAB Version %s %s'], ...
    m.Version, m.Release));
disp(sline)

%% LOADING DATA

load(fullfile(p,'gdp'));
report(['Data from Eurostat: quarterly GDP for several countries ', ...
    'http://ec.europa.eu/eurostat/web/national-accounts/data/database']);
name = 'Nominal GDP European Countries';

ctry  = gdp{1};
dates = gdp{2};
data  = gdp{3};

remove = any(isnan(data),2);
data(remove,:) = [];
dates(remove)  = [];

disp(sline)

%% COMPOSITE RUN

report(['We do a composite run of the GDPs of some European ', ...
    'countries. We seasonally adjust the aggregate GDP (direct ', ...
    'seasonal adjustment) and we seasonally adjust the individual ', ...
    'components and aggregate them afterwards (indirect seasonal ', ...
    'adjustment).']);
n = numel(ctry);

% specifications for the individual series ...
spec = cell(1,n);
common = makespec('MULT','TRAMOPURE','X11','AO','LS','ACF', ...
        'series','comptype','add');
for c = 1:n
    spec{c} = x13spec(common, 'series','title',ctry{c});
end

% ... and for the composite series
compspec = makespec('MULT','TRAMOPURE','X11','AO','LS','ACF', ...
    'outlier','method','addone', ...
    'composite','save','(cms itn isa iir iaf)', ...
    'composite','title','Aggregate');

% run x13 and show result
xgdp = x13(dates,data,spec,compspec,'graphicsloc',grloc,'quiet');
disp(xgdp);

%% REPORT SOME RESULTS

allseries = xgdp.listofseries;

fprintf('\n --- KEY STATISTICS ----------------------------------------------------------\n');
for c = 1:numel(allseries)
    strD8A   = xgdp.(allseries{c}).table('d8a');
    linesD8A = strsplit(strD8A,char(10));
    fprintf('\n *** %s ***\n Model: %s\n', ...
        upper(xgdp.(allseries{c}).spec.name), ...
        xgdp.(allseries{c}).arima)
    fprintf('\n %s\n\n',strtrim(lower(linesD8A{end-1})));
    if contains('x2d',xgdp.(allseries{c}).listofitems)
       strOUT   = xgdp.(allseries{c}).x2d;
       strOUT   = strrep(strOUT,char(10),[char(32),char(10)]);
       linesOUT = strsplit(strOUT,char(10));
       if strcmp(xgdp.(allseries{c}).spec.name,xgdp.compositeseries)
           first = -17;
       else
           first = -5;
       end
       for l = first:1:0
           disp(linesOUT{end+l});
       end
    else
        fprintf(xgdp.(allseries{c}).table('f3'));
    end
end
fprintf('\n -----------------------------------------------------------------------------\n\n');

report(['Most M-statistics pass, with some exceptions. The M4 and M8 ', ...
    'statistic marginally fail (>1) for some countries countries, but ', ...
    ' these are not the most crucial quality control statistics, so we ', ...
    'ignore that. The M1-statistic  marginally fails for the United ', ...
    'Kingdom. We ignore this as well, but you are welcome to look for ', ...
    'improvements. Interestingly, TRAMO identifies an ARIMA model with ', ...
    'no seasonal component for UK (model (0 1 1)), yet stable seasonality ', ...
    'is present according to the tests reported in table d8a.']);
% report(['Furthermore, PICKMDL did not find a good model for Finland. ', ...
%     'You might want to experiment with that (you can do so by ', ...
%     'analyzing the Finnish data separately; you don''t need to embed ', ...
%     'it in a composite while searching for a good model for the ', ...
%     'Finnsh series). Maybe TRAMO finds a usable model? For this ', ...
%     'demo, we ignore this problem.']);
fprintf(' -----------------------------------------------------------------------------\n\n');

%% COMPARE DIRECT WITH INDIRECT ADJUSTMENTS

figure('Position',size4, ...
    'Name',[name,': comparing direct with indirect adjustment']);

aggr = xgdp.compositeseries;    % name of composite series

ax = subplot(2,2,2);
plot(ax,xgdp.(aggr),'iaf','d10','combined');
title('\bfseasonal factor (iaf and d10)');
%
ax = subplot(2,2,3);
plot(ax,xgdp.(aggr),'isa','d11','combined');
plot(ax,xgdp.(aggr),'cms','combined','options',{'Color',[0.6,0.6,0.6]});
title('\bfseasonally adjusted (isa and d11)');
%
ax = subplot(2,2,1);
plot(ax,xgdp.(aggr),'itn','d12','combined');
plot(ax,xgdp.(aggr),'cms','combined','options',{'Color',[0.6,0.6,0.6]});
legend(ax,'direct adjustment','indirect adjustment','unfiltered data');
legend(ax,'Location','SouthEast');
title('\bftrend (itn and d12)');
%
ax = subplot(2,2,4);
plot(ax,xgdp.(aggr),'iir','d13','combined');
title('\bfirregular (iir and d13)');

report(['CONCLUSION from FIGURE 1: The differences between direct and ', ...
    'indirect adjustments are small --- except for the spike in the ', ...
    'indirect irregular component. The directly and indirectly seasonally ', ...
    'adjusted series look quite similar, though, and it is not obvious ', ...
    'which one is better. The sum of the individual irregulars in the GFC ', ...
    'is much greater than the irregular identified in the aggregate.']);
fprintf('\n');

%% PLOT NORMALIZED LOG GDP FOR ALL COUNTRIES

% get list of countries
prop = xgdp.listofseries;
remove = ismember(prop,aggr);
prop(remove) = [];

% sort according to decline of trend growth rate before and after crisis
s = nan(1,numel(prop));
for c = 1:numel(prop)
    loggdp = log(xgdp.(prop{c}).d11.d11);
    y = loggdp(1:35);
    x = [1:numel(y); ones(1,numel(y))]';
    slopebefore = x\y;
    y = loggdp(37:end);
    x = [1:numel(y); ones(1,numel(y))]';
    slopeafter = x\y;
    s(c) = slopeafter(1) - slopebefore(1);
end
[~,ord] = sort(s);
prop = prop(ord);

% plot seasonally adjusted series
% use log scale and normalize means for better comparison
fh = figure('Position',size8);
nax = 8;
n = ceil(numel(prop)/nax);
yl = [0,0];
colorOrder = get(gcf,'DefaultAxesColorOrder');
nColors    = size(colorOrder,1);
for f = 1:nax
    ax(f) = subplot(2,4,f);
    leg = cell(0);
    colorRow   = 0;
    for c = (f-1)*n+1:min(numel(prop),f*n)
        col = colorOrder(colorRow + 1,:);
        colorRow = mod(colorRow + 1, nColors);
        plot(ax(f),xgdp.(prop{c}),'d11','logscale','meannorm','comb', ...
            'options',{'Color',col});
        hold(ax(f),'all');
        leg{end+1} = prop{c};
    end
    legend(ax(f),leg{:});
    legend(ax(f),'Location','SouthEast');
    legend(ax(f),'boxoff');
    title(ax(f),'');
    axis(ax(f),'tight');
    ylnew = ylim;
    yl(1) = min(yl(1),ylnew(1));
    yl(2) = max(yl(2),ylnew(2));
end
for f = 1:nax
    ylim(ax(f),[yl(1),yl(2)]);
end

report(['CONCLUSION from FIGURE 2: The normalized log seasonally adjusted ', ...
    'levels give a clear view of how the financial / govt debt crisis has ', ...
    'affected different countries. Some were hit brutally but have ', ...
    'recovered quickly (e.g. Sweden). Others are back on their ', ...
    'pre-crisis growth rates, but their levels seem to have shifted ', ...
    'down permanently (UK, Iceland). Still others have essentially ', ...
    'stalled since the crisis (e.g. Spain). Greece has even ', ...
    'developped a negative (!) trend.']);
fprintf('\n');

%% STUDY CORRELATIONS OF HIGH FREQUENCY COMPONENTS

% extract variables from x13series objects and place them into arrays
prop = xgdp.listofseries;
remove = ismember(prop,aggr);
prop(remove) = [];
d10 = nan(numel(dates),numel(prop));
d13 = nan(numel(dates),numel(prop));
for c = 1:numel(prop)
   d10(:,c) = log(xgdp.(prop{c}).d10.d10); 
   d13(:,c) = log(xgdp.(prop{c}).d13.d13);
end
% mean correlations
figure('Position',size2,'Name',[name,': mean correlations']);
ax = subplot(1,2,1);
meancorr = mean(corr(d10)-diag(ones(1,numel(prop))));
[~,ord] = sort(meancorr,'descend');
bar(ax,meancorr(ord));
title(ax,'\bfmean correlation of log(d10)');
ax = subplot(1,2,2);
meancorr = mean(corr(d13)-diag(ones(1,numel(prop))));
bar(ax,meancorr(ord));
title(ax,'\bfmean correlation of log(d13)');
% study correlations of seasonal and irregular components
figure('Position',size2, ...
    'Name',[name,': pairwise correlations']);
subplot(1,2,1);
imagesc(corr(d10(:,ord)) - diag(NaN(1,numel(prop))));
colorbar;
title('\bfcorrelations of d10');
xlabel({[prop{ord(32)},' (country #32) seems to be much less'], ...
    'synchronous than everyone else.'});
subplot(1,2,2);
imagesc(corr(d13(:,ord)) - diag(NaN(1,numel(prop))));
colorbar;
title('\bfcorrelations of d13');

report(['CONCLUSION from FIGURE 4: Some countries, the UK in particular, ', ...
    'have seasonal adjustments that are very different from those of ', ...
    'other countries in the sample. From the correlation plot we can ', ...
    'identify at least two groups of countries that behave similarly. ', ...
    'To find out more, we try to cluster them.']);

%% CLUSTER d10

% compute kmeans clusters
ncluster = 4;   % number of clusters; you can play around with this
rng default;    % reproducibility
[idx,sa] = kmeans(d10',ncluster,'Distance','sqeuclidean');

% make a plot
figure('Position',size6, ...
    'Name',[name,': clustering the seasonal factors (d10)']);
nrows = ceil(sqrt(ncluster));
ncols = ceil(ncluster/nrows);
yl = [0,0];
% plot seasonal factors in one axis per cluster
colorOrder = get(gcf,'DefaultAxesColorOrder');
nColors    = size(colorOrder,1);
for c = 1:ncluster
    ax(c) = subplot(nrows,ncols,c);
    fidx = find(idx == c);
    colorRow   = 0;
    for cc = 1:numel(fidx)
        col = colorOrder(colorRow + 1,:);
        colorRow = mod(colorRow + 1, nColors);
        plot(ax(c),xgdp.(prop{fidx(cc)}),'d10','combined','logscale', ...
            'options',{'color',col})
    end
    ntit = ceil(numel(fidx)/4); ti = cell(1,ntit);
    for t = 1:ntit-1
        ti{t} = strjoin(ctry(fidx(1:4))');
        fidx(1:4) = [];
    end
    ti{ntit} = strjoin(ctry(fidx)');
    title(ti);
    grid on;
    axis tight;
    ylnew = ylim;
    yl(1) = min(yl(1),ylnew(1));
    yl(2) = max(yl(2),ylnew(2));
end
% same ylim for all axes (to ease comparison)
for c = 1:ncluster
    ylim(ax(c),[yl(1),yl(2)]);
end

report(['CONCLUSION from FIGURE 5: This graph shows the clustering of the ', ...
    'seasonal factors. The Czeck Republic and Slovakia are a clear ', ...
    'cluster. So are Denmark, Austria, and Switzerland. The remaining ', ...
    'countries are divided into two equally large groups, and the UK''s ', ...
    'seasonal pattern appears --- surprisingly --- not that special.']);

%% finish up

disp(dline);

% turn warnings on again (or to whatever state they were)
warning(orig_warning_state);
