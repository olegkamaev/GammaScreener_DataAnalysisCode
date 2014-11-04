function [t, ft, y, pgl, tbnum] =...
            gausslinFixedSgmMnFit(dt, enr, loi, lli, uli, hreg, sgm, mn)

% Input: dt - data, column-vector
%        loi - center value for the line of interest in keV
%        lli - low limit in x in keV in respect to loi
%        uli - upper limit in x in keV in respect to loi
%        hreg - half-region for counts calculation
% Output: pgl - 1-by-5 vector of fit parameters, where
%         pgl(1) is number of signal events, pgl(2) is background
%         y(t) - fit function, t in keV
%
% Oleg Kamaev - oleg.v.kamaev AT gmail.com

en = enr(2) - enr(1); % bin size
%en=0.1687; % bin size in keV
%en_off=0.2775;
%shft=2;
tol = 1; % tolerance in keV

tl = round(tol/en); % how many bins

opt = optimset('Display','off','TolFun',1e-16,'TolX',1e-16);
%optexp = optimset('Display','final','TolFun',1e-16,'TolX',1e-16,...
%    'MaxFunEvals',1E+4);

% data to fit
llim = loi + lli;
ulim = loi + uli;
x1 = round((llim-enr(1))/en) + 1;
x2 = round((ulim-enr(1))/en) + 1;
xc = round((loi-enr(1))/en) + 1;
t = enr(x1:x2);  % in keV, column-vector
ft = dt(x1:x2);

% gauss+constant fit
gsfit_init = @(p,t,llim,ulim) en*(p(1)*...
    exp(-0.5*((t-mn)/sgm).^2)/(sgm*sqrt(2*pi))+...
    p(2)/(ulim-llim));
gsfit = @(p,t) gsfit_init(p,t,llim,ulim);

xb1 = round((loi-4*hreg-enr(1))/en) + 1;
xb2 = round((loi-2*hreg-enr(1))/en) + 1;
xb3 = round((loi+2*hreg-enr(1))/en) + 1;
xb4 = round((loi+4*hreg-enr(1))/en) + 1;
pgs_i(2) = 0.5*(sum(dt(xb1:xb2)) + sum(dt(xb3:xb4)));
pgs_i(1) = sum(ft) - pgs_i(2);

%pgs_i(1)=max(dt((xc-tl):(xc+tl)))*sgm*sqrt(2*pi);
%pgs_i(2)=sum(ft)-pgs_i(1);

lb(1) = 1E-10; ub(1) = +Inf;
lb(2) = 1E-10; ub(2) = +Inf;

pgs = lsqcurvefit(gsfit, pgs_i, t, ft, lb, ub, opt);

% gauss+linear fit
glfit_init = @(p,t,llim,ulim) en*(p(1)*...
    exp(-0.5*((t-mn)/sgm).^2)/(sgm*sqrt(2*pi))+...
    p(3)+2*t*(p(2)-p(3)*(ulim-llim))/...
    (ulim^2-llim^2));
glfit = @(p,t) glfit_init(p,t,llim,ulim);

pgl_i(1) = pgs(1);
pgl_i(2) = pgs(2);
pgl_i(3) = 1E-9;

lb(1) = 1E-10; ub(1) = +Inf;
lb(2) = 1E-10; ub(2) = +Inf;
lb(3) = 1E-10; ub(3) = +Inf;

pgl = lsqcurvefit(glfit, pgl_i, t, ft, lb, ub, opt);

% output
y = glfit(pgl,t);

% calculate number of events under +/- hreg
xh1 = floor((mn-hreg-enr(1))/en) + 1;
xh2 = ceil((mn+hreg-enr(1))/en) + 1;

% total
tbnum(1,1) = sum(dt(xh1:xh2));
% background
tbnum(2,1) = pgl(3)*(enr(xh2)-enr(xh1))+...
    (enr(xh2)^2-enr(xh1)^2)*(pgl(2)-pgl(3)*(ulim-llim))...
    /(ulim^2-llim^2);

% calculate number of events under (-4 -2), (2 4) in hreg units
xb1 = round((mn-4*hreg-enr(1))/en) + 1;
xb2 = round((mn-2*hreg-enr(1))/en) + 1;
xb3 = round((mn+2*hreg-enr(1))/en) + 1;
xb4 = round((mn+4*hreg-enr(1))/en) + 1;

tbnum(3,1) = 0.5*(sum(dt(xb1:xb2)) + sum(dt(xb3:xb4)));

end