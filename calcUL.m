function ul = calcUL(rt, rt_err, s, b)
% Calculate Upper Limit at 90% CL for event rate. 
%
% Oleg Kamaev - oleg.v.kamaev AT gmail.com

if ((rt - rt_err) <= 0 && (rt + rt_err) >= 0)
    % calculate upper limit as well
    if min(s,b) >= 10
        % can approximate with gaussian
        v = rt + rt_err*randn(1,1E+6);
        ul = prctile(v(v>=0),90);
    else
        disp('GammaScreener code WARNING: no Poisson estimator yet')
        ul = -999;
        % use something like this for observed 5 counts:
        % x0=5;
        % UL at 90% CL is
        % ul=lsqnonlin(@(x)(poisscdf(5,x)-0.1),x0,[],[],optimset('Display','off','MaxIter',1e3))

    end
elseif (rt - rt_err) <= 0
    ul = 0;
else
    ul = NaN;
end

end
