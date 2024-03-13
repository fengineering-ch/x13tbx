%% DEMO for X13 Toolbox: Single Series Run

%% Preliminaries

% get correct path
p = fileparts(mfilename('fullpath'));   % directory of this m-file
% if the section is run with Shift-Ctrl-Enter ...
if isempty(p); p = [cd,'\']; end
% location of graphics files for use with X-13-Graph program
grloc = fullfile(p,'graphics\');

% size for figures with subplots
scSize = get(groot,'ScreenSize');   % size of physical monitor in pixels
scWidth = scSize(3); scHeight = scSize(4);
sizeFig = @(h,v) round([0.04*scWidth, scHeight*(1-0.08-v/100)-50, ...
    h/100*scWidth, v/100*scHeight]);

size1  = sizeFig(40,80);
size2  = sizeFig(80,45);
size3  = sizeFig(95,45);
size4  = sizeFig(70,70);
size6  = sizeFig(75,68);
size8  = sizeFig(95,65);
size9  = sizeFig(95,90);
size10 = sizeFig(70,80);

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
    'run on a single timeseries']);
report(sprintf(['This script was developed with MATLAB Version ', ...
    '8.3.0.532 (R2014a) and ran on MATLAB Version %s %s'], ...
    m.Version, m.Release));
disp(sline)

%% Loading Data

% US. Federal Highway Administration, Vehicle Miles Traveled
% [TRFVOLUSM227NFWA], retrieved from FRED, Federal Reserve Bank of St.
% Louis https://research.stlouisfed.org/fred2/series/TRFVOLUSM227NFWA/,
% December 31, 2014.

load travel
report(['Source and discription of data: ',travel.source,newline]);
strTitle = 'miles traveled';

% travel   = fetchdata('TRFVOLUSM227NFWA', 'source','fred');
% travelSA = fetchdata('TRFVOLUSM227SFWA', 'source','fred');
% travel   = fetchdata('TRFVOLUSM227NFWA', 'source','fred', ...
%     'from',travelSA.dates(1));

%% Step 1: Quick and Dirty

disp(sline)
fprintf(' Step 1: ''Quick-and-Dirty''\n\n');

report(['We run a seasonal adjustment with the default parameters ', ...
    'and see what is coming out of it.',newline]);

spec1a = makespec('AUTO','TRAMOPURE','X11','DIAG','series','title',travel.descr);
travel1a = x13(travel.dates,travel.data,spec1a,'quiet');

disp(travel1a.table('transform'));
report(['CONCLUSION: The filtering will be additive.',newline]);

spec1 = makespec(spec1a, 'NOTRANS');
travel1 = x13(travel.dates,travel.data,spec1,'quiet');

disp(travel1.table('d8a'));
report(['CONCLUSION: The data are clearly seasonal.',newline]);

%% Step 2: Calendar Dummies

disp(sline)
fprintf(' Step 2: Optimizing the regression\n\n');

report(sprintf(['TRAMO has chosen an ARIMA %s, but the autocorrelation ', ...
    'function is problematic. We have significant autocorrelation of the ', ...
    'residuals.\n'], travel1.arima));

fh = figure('Position',size2);
plot(fh,travel1,'acf','spr');

report(sprintf(['The problem could be the lack of a dummy for Easter and ', ...
    'trading days. It is very likely that Easter as well as the distribution ', ...
    'of weekends plays a role in travel behavior. We therefore add ', ...
    'Easter and trading day dummies and check if that solves the problem.\n']));

spec2a = makespec(spec1,'EASTER','TD');
travel2a = x13(travel.dates,travel.data,spec2a,'quiet');

disp(travel2a.table('regression'));
disp(travel2a.table('tukey'));

fh = figure('Position',size2);
plot(fh,travel2a,'acf','spr');

report(sprintf(['\nThe trading days are significant, but Easter is not. The ', ...
    'algorithm kicks out this dummy when it is not significant enough. We will ', ...
    'therefore keep the Easter dummy in for the moment; maybe it will become ', ...
    'relevant later. Also, the trading day dummies have not yet resolved the ', ...
    'autocorrelation issue.\n'], ...
    travel2a.arima));

report([newline,'The Tukey report shows a problem at frequency 6 in the ', ...
    'but a visual inspection of the spectrum also indicates a problem at ', ...
    'trading day frequencies. We try to address this by also adding ', ...
    'dummies for labor day and thanksgiving. This does not fully solve ', ...
    'the problem, however.',newline]);

ti = '(labor[1] thank[1])';
s11 = makespec(spec2a, 'FORCETD', 'regression','variables',ti, 'series','title',ti);
ti = '(labor[1] thank[8])';
s18 = makespec(spec2a, 'FORCETD', 'regression','variables',ti, 'series','title',ti);
ti = '(labor[8] thank[1])';
s81 = makespec(spec2a, 'FORCETD', 'regression','variables',ti, 'series','title',ti);
ti = '(labor[8] thank[8])';
s88 = makespec(spec2a, 'FORCETD', 'regression','variables',ti, 'series','title',ti);

t11 =  x13(travel.dates,travel.data,s11,'quiet');
t18 =  x13(travel.dates,travel.data,s18,'quiet');
t81 =  x13(travel.dates,travel.data,s81,'quiet');
t88 =  x13(travel.dates,travel.data,s88,'quiet');

fh = figure('Position',size8);
plot(fh,t11,t18,t81,t88,'acf','spr');

report(['We have tried combinations of thank[1] and thank [8] on the one hand ', ...
    'and labor[1] and labor[8] on the other. All of these specifications are ', ...
    'very similar. The best likelihood is achieved with the labor[8] and ', ...
    'thank[1] combination, so we will include these dummies.',newline]);

spec2 = makespec(s81,'series','title',travel.descr);
travel2 = t81;

%% Step 3: Automatic detection of structural breaks and outliers

disp(sline)
fprintf(' Step 3: Finding structural breaks\n\n');

report(['Next we allow the algorithm to detect one-time outliers and ', ...
    'level shifts, ba adding the AO and LS options.',newline]);

spec3 = makespec(spec2,'AO','LS');
travel3 = x13(travel.dates,travel.data,spec3,'quiet');

fh = figure('Position',size2);
plot(fh,travel3,'acf','spr')

report(['Two ouliers have been detected, a level shift LS1979.May and a ', ...
    'one-time outlier AO1995.Jan.',newline,newline,'The spikes in the ', ...
    'spectrum are now under control, but the autocorrelation issue remains.', ...
    newline]);

%% Step 4: Tweaking the ARIMA

disp(sline)
fprintf(' Step 4: Tweaking the ARIMA\n\n');

report(['The Spectrum and autocorrelation problems have still not been ', ...
    'resolved. It seems that we have to tweak the ARIMA specification ', ...
    'manually. Inspecting the ACF, there is a significant problem at lag ', ...
    '4 and maybe at lag 18. Such a long lag (18) would normally not be an ', ...
    'issue, but it might indicate an inappropriate choice of the seasonal ', ...
    'part of the ARIMA, since 18 lags is 1.5 years.', newline,' ',newline, ...
    'But we address the problem at lag 4 first. We check (4 1 0) and (0 1 4) ', ...
    'and find that (0 1 4) works much better.', newline,' ',newline, ...
    'However, looking at the regression output, we notice that the 2nd and 3rd ', ...
    'MA coefficients are not significant, so we remove them, (0 1 [1 4]).', ...
    newline,' ',newline, 'We now look at lag 18 and try to address it by ', ...
    'increasing the seasonal ARIMA. We have tried several specifications. ', ...
    'An extensive one would be (2 1 2), but the ACF and PACF do not improve.', ...
    newline]);
    
% remove TRAMO and significance testing in regression, fix outliers
s = makespec(spec3,'automdl',[],[], 'regression','aictest',[], 'NO OUTLIERS', ...
    'regression','save','(ao ls)', ...
    'regression','variables','(LS1979.May AO1995.Jan easter[15] labor[8] thank[1])');

arima = travel3.arima;
s = x13spec(s,'arima','model',arima, 'series','title',arima);
t0 = x13(travel.dates,travel.data,s,'quiet');

arima = '(4 1 0)(0 1 1)';
s = x13spec(s,'arima','model',arima, 'series','title',arima);
t1 = x13(travel.dates,travel.data,s,'quiet');

arima = '(0 1 4)(0 1 1)';
s = x13spec(s,'arima','model',arima, 'series','title',arima);
t2 = x13(travel.dates,travel.data,s,'quiet');

arima = '(0 1 [1 4])(0 1 1)';
s = x13spec(s,'arima','model',arima, 'series','title',arima);
t3 = x13(travel.dates,travel.data,s,'quiet');

arima = '(0 1 [1 4])(2 1 2)';
s = x13spec(s,'arima','model',arima, 'series','title',arima);
t4 = x13(travel.dates,travel.data,s,'quiet');

fh = figure('Position',size10);
plot(fh,t0,t1,t2,t3,t4,'acf','pcf');

report(['Our final specification is therefore (0 1 [1 4])(0 1 1), which ', ...
    'gives us an almost perfectly clean ACF and PACF and an acceptable ', ...
    'spectrum of the residuals.', newline]);

arima = '(0 1 [1 4])(0 1 1)';
s = x13spec(s,'arima','model',arima, 'series','title',arima);
spec4 = x13spec(s,'arima','model',arima,'series','title',travel.descr);
travel4 = x13(travel.dates,travel.data,spec4,'quiet');

fh = figure('Position',sizeFig(50,80));
plot(fh,travel4,'acf','pcf','spr','rowwise')

%% Step 5: Do the Seasonal Filtering

disp(sline)
fprintf(' Step 5: Performing the seasonal filtering\n\n');

spec5 = makespec(spec4,'X11','x11','mode','add');
travel5 = x13(travel.dates,travel.data,spec5);

figure('Position',size4)
ax = subplot(2,2,1);
plot(ax,travel5,'dat','e2','d12','comb');
ax = subplot(2,2,2);
plot(ax,travel5,'d10','bymonth');
ax = subplot(2,2,3);
plot(ax,travel5,'spr','sp1','sp2','comb');
ax = subplot(2,2,4);
plot(ax,travel5,'d13','span','boxplot');

report(['The seasonal factors are rather stable (the graph on the ', ...
    'top right shows little variation). The decomposition (top left ', ...
    'graph) looks reasonable.']);

fh = figure('Position',size6);
seasbreaks(fh,travel5);

report(['A closer inspection into possible seasonal breaks reveals no ', ...
    'major problems either. This graph shows the seasonal factors and ', ...
    'the SI ratios separately for each month. We do see some quantitatively ', ...
    'important shifts, but they are all slow enough so that the X-11 ', ...
    'procedure can deal with it. We do not need to specify seasonal ', ...
    'breaks in the estimation.']);

%% Step 6: Check Stability

disp(sline)
fprintf(' Step 6: Checking stability (this takes a while...)\n\n');

spec6 = makespec(spec5,'SLIDING','HISTORY');
travel6 = x13(travel.dates,travel.data,spec6,'quiet');

% --- sliding span analysis

figure('Position',size4,'Name',[strTitle,': sliding span analysis']);

ax = subplot(2,2,1);
[~,ax] = plot(ax,travel6,'sfs','selection',[0 0 0 0 1]);
title(ax,'\bfmaximum change SA series (sfs)');
ax = subplot(2,2,2);
[~,ax] = plot(ax,travel6,'chs','selection',[0 0 0 0 1]);
title(ax,'\bfmax change seasonal factor (chs)');

ax = subplot(2,2,3);
[~,ax] = plot(ax,travel6,'sfs','selection',[0 0 0 0 1],'span','boxplot');
title(ax,'\bfmaximum change SA series (sfs)');
ax = subplot(2,2,4);
[~,ax] = plot(ax,travel6,'chs','selection',[0 0 0 0 1],'span','boxplot');
title(ax,'\bfmax change seasonal factor (chs)');

report(['CONCLUSION: The sliding span analysis reveals small changes ', ...
    'of the seasonally adjusted series or the seasonal factors. ', ...
    'The maximum revisions are about 2''000, and the level of ', ...
    'the data is between 100''000 and 250''000, so the revisions ', ...
    'amount to about 1%.',newline]);

% --- stability analysis

figure('Position',size4,'Name',[strTitle,': stability analysis']);

ax = subplot(2,2,1);
plot(ax,travel6,'sar')
title(ax,{'\bfmax % change of final vs','concurrent SA series (sar)'});
% % Note: sar = (final./concurrent-1)*100, where
% final = travel4.sae.Final_SA;
% concurrent = travel4.sae.Conc_SA;
% d = travel4.sar.SA_revision-(final./concurrent-1)*100;
% d is equal to zero, except for numerical noise.
ax = subplot(2,2,3);
plot(ax,travel6,'sar','span','boxplot')
title(ax,{'\bfmax % change of final vs','concurrent SA series (sar)'});

ax = subplot(2,2,2);
plot(ax,travel6,'sar','from',datenum(1985,1,1))
title(ax,{'\bf... since 1985'});
ax = subplot(2,2,4);
plot(ax,travel6,'sar','span','boxplot','from',datenum(1985,1,1))
title(ax,{'\bf... since 1985'});

report(['CONCLUSION: The historical analysis also reveals small ', ...
    'changes of the seasonally adjusted series, except in the ', ...
    'beginning of the sample in the late 70s, early 80s.']);

%% Step 7: Adjust Length Of Filter

disp(sline)
fprintf(' Step 7: Adjusting the length of the seasonal filter\n\n');

disp(travel6.table('d9a'));
report(['The X11 procedure selects the length of the filter ', ...
    'according to the global moving seasonality ratio, GMSR. ', ...
    'For a GMSR above 3.5, X11 selects a 3x5 filter, for GMSR below ', ...
    '2.5 it selects a 3x3 filter. Values between 2.5 and 3.5 are in ', ...
    'a grey area, and I don''t know how the filter is selected then.']);

report(['The GMSR for February indicates 3x3 filter for that month. ', ...
    'January, July, and August are in the grey area. However, we can ', ...
    'marginally increase the stability of the filtering by enforcing ', ...
    'a 3x5 filter for all months.']);

spec7 = makespec(spec6,'x11','seasonalma','s3x5');
travel7 = x13(travel.dates,travel.data,spec7,'quiet');

% --- sliding span and stability analysis

figure('Position',size6,'Name',[strTitle,': sliding span analysis']);

ax = subplot(2,3,1);
[~,ax] = plot(ax,travel6,travel7,'sfs','selection',[0 0 0 0 1],'comb');
title(ax,'\bfmaximum change SA series (sfs)');

% On my computer, the series I'm looking for is called 'Max___DIFF', but on
% others, strangely, it is called ''Max_0x25_DIFF''. To make this computer-
% independent, I look up the fieldnames.
fn5 = fieldnames(travel6.sfs);
fn6 = fieldnames(travel7.sfs);
ax = subplot(2,3,4);
scatter(ax,travel6.sfs.(fn5{end}),travel7.sfs.(fn6{end}),'.');
hold on; plot(xlim,xlim,'k'); grid on;
xlabel(ax,'sfs spec #5');
ylabel(ax,'sfs spec #6');

ax = subplot(2,3,2);
[~,ax] = plot(ax,travel6,travel7,'chs','selection',[0 0 0 0 1],'comb');
title(ax,'\bfmax change seasonal factor (chs)');

fn5 = fieldnames(travel6.chs);
fn6 = fieldnames(travel7.chs);
ax = subplot(2,3,5);
plot(ax,travel6.chs.(fn5{end}),travel7.chs.(fn6{end}),'.');
hold on; plot(xlim,xlim,'k'); grid on;
xlabel(ax,'chs spec #5');
ylabel(ax,'chs spec #6');

ax = subplot(2,3,3);
[~,ax] = plot(ax,travel6,travel7,'sar','comb');
title(ax,{'\bfmax % change of final vs','concurrent SA series (sar)'});

ax = subplot(2,3,6);
plot(ax,travel6.sar.SA_revision,travel7.sar.SA_revision,'.');
hold on; plot(xlim,xlim,'k'); grid on;
xlabel(ax,'sar spec #5');
ylabel(ax,'sar spec #6');
drawnow;

report(['The difference is small, but the largest deviations are ', ...
    'made a bit smaller with spec #7, so we keep this.']);

%% Final Step: specification for production

% remove history and sliding spans
spec8 = makespec(spec7, 'history',[],[], 'slidingspans',[],[]);
travel8 = x13(travel.dates,travel.data,spec8,'quiet');

% this is the final specification
specfinal = makespec('series','title',travel.descr, 'DIAG', ...
    'NO OUTLIERS', 'regression','variables', ...
        '(AO1995.Jan LS1979.May easter[15] labor[8] td thank[1])', ...
    'regression','save','(hol td ao ls)', ...
    'arima', 'model', '(0 1 [1 4])(0 1 1)', ...
    'transform','function','none', ...
    'X11', 'x11','mode','add', 'x11','seasonalma','s3x5');

% The next step just removes portions that do not make sense in this context.
% For instance, 'DIAG' has introduced requests to compute spectra that are
% only available in a composite setting. These requsts are now removed
% from the specification. They will be removed at runtime anyway, but the
% specification is just cleaner and easier to read if we do it now for the
% final report.
specfinal.RemoveInconsistentSpecs;

% compare the two
%disp(spec8);
disp(specfinal);

% perform the computations
travelsa = x13(travel.dates,travel.data,specfinal,'quiet');
travelhtml = x13(travel.dates,travel.data,specfinal,'html','quiet');
report('You can view results with web(travelhtml.out).')

% report final results

disp(travelsa);

%disp(travelsa.x2d);
disp(travelsa.table('tukey'));

figure('Position',size1,'Name','X11')
ax = subplot(3,2,1);
plot(ax,travelsa,'dat','e2','d12','comb');
ax = subplot(3,2,3);
plot(ax,travelsa,'acf','pcf','comb');
ax = subplot(3,2,5);
plot(ax,travelsa,'d13','boxplot','span');
ax = subplot(3,2,2);
plot(ax,travelsa,'spr','str','comb');
ax = subplot(3,2,4);
plot(ax,travelsa,'sp1','st1','comb');
ax = subplot(3,2,6);
plot(ax,travelsa,'sp2','st2','comb');

fh = figure('Position',size6,'Name','breaks');
seasbreaks(fh,travelsa);

fh = figure('Position',size4,'Name','final decomposition');
plot(fh,travelsa,'d12','e2','d10','e3');

disp(travelsa.table('f3'));

report('CONCLUSION: The decomposition appears acceptable.');

disp(dline);
