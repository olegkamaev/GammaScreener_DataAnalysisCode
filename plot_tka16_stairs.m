function [enrrev, dh, ltsec, xst, ymaxst] =...
            plot_tka16_stairs(dt, md, rb, llim, ulim)

% Plot spectrum from 16K tka file
% Requires ReBin.m or should be used under CAP
% Input: dt - data, one column per one tka file
%        md - y-scale mode (1 - linear, 2 - log)
%        rb - 1 - don't rebin, n - rebin n to 1
%        llim - low limit in x in keV
%        ulim - upper limit in x in keV
%
% Oleg Kamaev - oleg.v.kamaev AT gmail.com

Lwidth = 1;
st = 200; % step for plotting in keV
kg = 2.075; % detector mass
en = 0.1687;
en_off = 0.2775;

if nargin == 5
    ll = round((llim-en_off)/en);
    ul = round((ulim-en_off)/en);
else
    ll = 1;
    ul = size(dt,1)-2;
end

shft = 2;
enr = en_off + en*((ll+shft):(ul+shft)); 

enrrev = enr';% energy vector for data below
dh = dt((ll+2):(ul+2),:); % data
ltsec = dt(1,:); % live-time in seconds

col=['b','r','k','g'];
fig(1); clf;
set(gca,'Fontsize',14); hold off;
d = zeros(1,4);

for i = 1:size(dt,2)
    % define what to plot here
    cntN = dt((ll+2):(ul+2),i);
    d(i) = dt(1,i)/(3600*24); % live-time in days

    if rb == 1
        ybkg = cntN'/(kg*d(i)*en);
        stairs(enr-0.5*(enr(2)-enr(1)),ybkg,col(i),'LineWidth',Lwidth)
        grid on; hold on;
    else
        [xbkg, ybkg] = ReBin(enr', cntN, rb, 1);
        ybkg = ybkg/(kg*d(i)*en);
        stairs(xbkg-0.5*(xbkg(2)-xbkg(1)),ybkg,col(i),'LineWidth',Lwidth)
        grid on; hold on;
    end;
    
    % need this for 
    % plotting spectra in 200-keV-wide range
    if i == 2 % it's sample spectrum
        xst = 0;
        ymaxst = [];
        imin = 1;
        for r = st:st:max(xbkg)
            xst = [xst r];
            imax = find(abs(xbkg-r)<5);
            ymaxst = [ymaxst max(ybkg(imin:imax))];
            imin = imax;
        end
        if r ~= max(xbkg)
            xst = [xst max(xbkg)];
            ymaxst = [ymaxst max(ybkg(imin:end))];
        end
    end
end;

xlabel('Energy (keV)','FontSize',14);
ylabel('Counts /keV /kg /day','FontSize',14);
legend(['background, ',num2str(round(d(1))),' days']...
    ,['with sample, ',num2str(round(d(2))),' days']...
    ,['data3, ',num2str(round(d(3))),' days']...
    ,['data4, ',num2str(round(d(4))),' days'])
if rb == 1
    titl = 'Gopher''s spectra';
else
    titl = ['Gopher''s spectra rebinned ',num2str(rb),' to 1'];
end
if nargin == 5
    titl = [titl,', ',num2str(0.5*(llim+ulim)),' keV line of interest'];
end
title(titl,'FontSize',14)
if md == 2
    set(gca,'YScale','log');
end
autax = axis;
axis([min(enr) max(enr) autax(3) autax(4)]);

end
