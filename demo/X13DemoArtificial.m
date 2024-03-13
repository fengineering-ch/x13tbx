%% DEMO for X13 Toolbox: compare methods using artificial data

%% STEP 1: make artificial data with trend, seasonality, and noise

fprintf('1. make artificial data\n')

nobs = 500;

trend  = 0.025*(1:nobs)' + 5 - 0.00004*(1:nobs)'.^2 + 1e-8*(1:nobs)'.^3;

season1 = 0.4 * sin((1:nobs)'*(2*pi)/12);
season1 = season1 .* linspace(2,1,nobs)';
season2 = 0.15 * sin(3*(1:nobs)'*(2*pi)/12 + 0.3*pi);
season2 = season2 .* linspace(1,2,nobs)';
season = season1 + season2;

resid  = 0.6 * randn(nobs,1);
data   = trend + season + resid;
% So we know that data has two periods, 14 and 20. We will try to find
% these periods.

t = clock;      % now
m = mod((t(2)-1:-1:t(2)-nobs),12)+1;
y = [0,-cumsum(diff(m)>0)] + t(1);
d = ones(size(y)) * 28;
dates = datenum(y,m,d);
dates = fliplr(dates)';

%% We take a look at the data first.

fprintf('2. view the data\n')


orig = x13series;
orig.addvariable('dat',dates,data,'dat',1);
orig.addvariable('ttr',dates,trend,'ttr',1,'true trend');
orig.addvariable('tsf',dates,season,'tsf',1,'true season');
orig.addvariable('tir',dates,resid,'tir',1,'true irregular');
plot(orig,orig.listofitems{:});
plot(orig,'tsf','bymonth')

%% Use spr to figure out periodicity (we know it is 12)

fprintf('3. determine periodicity\n')

n = {'fixedseas','seas','method1','x11'};
figure;
for z = 1:4
    ah = subplot(2,2,z);
    spr(ah,data,n{z},'add');
    title(ah,n{z});
end
drawnow;

%% STEP 2: perform seasonal adjustments using different algorithms

fprintf('4. perform seasonal adjustments\n')

% n = {'X-13 X11','X-13 SEATS','X-12','X-11','Method I','Fixed Seas','seas.m'};
n = {'X-13 X11','X-13 SEATS','X-11','Method I','Fixed Seas','seas.m'};

basespec = makespec('NOTRANSFORM');
name = x13spec('series','title',n{1});
x3x = x13(dates,data,makespec(basespec,name,'TRAMO','X11'  ),         'quiet');
name = x13spec('series','title',n{2});
x3s = x13(dates,data,makespec(basespec,name,'TRAMO','SEATS'),         'quiet');
% name = x13spec('series','title',n{3});
% x2  = x13(dates,data,makespec(basespec,name,'TRAMO','X11'  ), 'x-12' ,'quiet');
name = x13spec('series','title',n{3});
x1  = x13(dates,data,makespec(basespec,name,'X11'          ), 'x-11'         );
name = x13spec('series','title',n{4});
m   = x13(dates,data,makespec(basespec,name                ), 'method1'      );
name = x13spec('series','title',n{5});
f   = x13(dates,data,makespec(basespec,name                ), 'fixed'        );
name = x13spec('series','title',n{6});
s   = x13(dates,data,makespec(basespec,name                ), 'prog','seas.m');

%% STEP 3: compare results visually

fprintf('5. compare results\n')

n = {'x3x','x3s','x1','m','f','s'};

ir = [x3x.d13.d13,x3s.s13.s13,x1.d13.d13,m.d13.d13,f.ir.ir,s.ir.ir];
figure;
scatter(resid,ir,'.');
xlabel('residual'); ylabel('irregular')
grid on; legend(n{:}); legend('Location','Best');

disp('correlations (residual,irregular)')
disp(' X-13(X-11) X-13(SEATS)   X-11  Method 1     fixed      seas');
disp(resid\ir);

tr = [x3x.d12.d12,x3s.s12.s12,x1.d12.d12,m.d12.d12,f.tr.tr,s.tr.tr];
figure;
plot(dates,tr,'linewidth',0.75); hold on;
plot(dates,trend,'r','linewidth',2);
grid on; legend(n{:}); legend('Location','Best');
title('trend')
dateaxis('x');

c = {x3x,x3s,x1,m,f,s};
figure;
for z = 1:numel(c)
    ah = subplot(2,3,z);
    plot(ah,orig,c{z},'tsf',c{z}.keyv.sf,'byperiodnomean','combined');
    title(c{z}.spec.title);
end

fprintf('\n')
