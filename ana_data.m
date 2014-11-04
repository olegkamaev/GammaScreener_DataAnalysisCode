% Fit gamma spectrum and produce tables and figs.
% Called from do_main.m
%
% Oleg Kamaev - oleg.v.kamaev AT gmail.com

res = '150';
Lwidth = 2;
pllog = true; % plot with y-scale log?

% look at spectra and get data in nice format
% plot spectra in 200-keV-wide range
% dh: first column background, second - sample
[enr, dh, ltsec] = look_at_spectra(files_dir, sname,...
                    bpath, bfile, pllog, savefigs, figdir);

% prepare dh for fitting:
if ltsec(1) > ltsec(2)
    dhf(:,1) = dh(:,1)*ltsec(2)/ltsec(1);
    dhf(:,2) = dh(:,2);
    aqt = ltsec(2); % aquisition time
else
    dhf(:,2) = dh(:,2)*ltsec(1)/ltsec(2);
    dhf(:,1) = dh(:,1);
    aqt = ltsec(1);
end

% now fit data with g+p1 for every loi
% return for under the peak: # of total events and background

for i = 1:length(loi)

    % data
    [t, ft, y, pgl, tbnum] = gausslinFixedSgmFit...
        (dhf(:,2), enr, loi(i), -rng*sgm(i), rng*sgm(i), rngs*sgm(i),...
        sgm(i));
    rdc(i,2).t = t;
    rdc(i,2).ft = ft;
    rdc(i,2).y = y;
    rdc(i,2).pgl = pgl;
    rdc(i,2).tbnum = tbnum;
    % background
    [t, ft, y, pgl, tbnum] = gausslinFixedSgmMnFit...
        (dhf(:,1), enr, loi(i), -rng*sgm(i), rng*sgm(i), rngs*sgm(i),...
        sgm(i), rdc(i,2).pgl(2));
    rdc(i,1).t = t;
    rdc(i,1).ft = ft;
    rdc(i,1).y = y;
    rdc(i,1).pgl = pgl;
    rdc(i,1).tbnum = tbnum;

    % make plots if needed
    if makeplots
        fig(2); clf;
        set(gca,'Fontsize',14); hold off;

        stairs((rdc(i,1).t-0.5*(enr(2)-enr(1))),rdc(i,1).ft,'b-','LineWidth',1)
        hold on; grid on;
        stairs((rdc(i,2).t-0.5*(enr(2)-enr(1))),rdc(i,2).ft,'r-','LineWidth',1)
        plot(rdc(i,1).t,rdc(i,1).y,'k-','LineWidth',Lwidth)
        plot(rdc(i,2).t,rdc(i,2).y,'g-','LineWidth',Lwidth)

        xlabel('Energy (keV)','FontSize',14);
        ylabel('Counts','FontSize',14);
        legend('bkg','sample','bkg fit','sample fit')%,'Location','Best')
        title([sname,': events in +/-',num2str(rngs),' sgm - p1Fitbkg: ',...
            num2str(0.1*round(10*(rdc(i,1).tbnum(1)-rdc(i,1).tbnum(2)))),' bkg, ',...
            num2str(0.1*round(10*(rdc(i,2).tbnum(1)-rdc(i,2).tbnum(2)))),' sample'])
        if savefigs
            print('-dpng',['-r' res],[figdir,...
                'data_loi',num2str(loi(i)),'_fit.png']);
        end
    end
end

if table
    clear smn2
    for i = 1:length(loi)
        smn2(i,1) = rdc(i,2).tbnum(1);
        smn2(i,2) = rdc(i,2).tbnum(2);
        smn2(i,3) = rdc(i,2).tbnum(3);
        smn2(i,4) = rdc(i,1).tbnum(1);
        smn2(i,5) = rdc(i,1).tbnum(2);
        smn2(i,6) = rdc(i,1).tbnum(3);
    end
    GTHTMLtable('Table_1',[loi' smn2],'%0.3g',{'Line (keV)'...
        'S_t' 'S_b' 'S_b (alt)'...
        'B_t' 'B_b' 'B_b (alt)'...
        },'save');
    eval(['!mv TABLE_Table_1.html ', note_dir]);
end

% now let's calculate RATE
clear r
for i = 1:length(loi)
    
    st = rdc(i,2).tbnum(1); % total
    bt = rdc(i,1).tbnum(1);
    
    sb = rdc(i,2).tbnum(2); % p1-fit background
    bb = rdc(i,1).tbnum(2);
    
    % decide which method to choose
    mthd = 0;
    if abs((sb-bb)/aqt) <=...
            sqrt(sb/(ltsec(2)*aqt)+bb/(ltsec(1)*aqt))
        % baselines are consistent
        s = st;
        b = bt;
        rt_err = sqrt(s/(ltsec(2)*aqt) + b/(ltsec(1)*aqt));
        mthd = 2;
    else
        if abs((bt-bb)/sqrt(bb)) >= 1
            % peak in the background is significant
            s = st - sb;
            b = bt - bb;
            rt_err = sqrt((st+sb)/(ltsec(2)*aqt)+...
               (bt+bb)/(ltsec(1)*aqt));
            mthd = 3;
        else
            s = st;
            b = sb;
            rt_err = sqrt((st+sb)/(ltsec(2)*aqt));
            mthd = 31;
        end
    end
    rt = (s-b)/aqt; % in cts/sec
    ul = calcUL(rt, rt_err, s, b);
    
    r(i).rt = rt;
    r(i).rt_err = rt_err;
    r(i).s = s;
    r(i).b = b;
    r(i).ul = ul;
    r(i).mthd = mthd;
    
    clear st sb bt bb rt rt_err ul mthd
end

if table
    clear smn1
    for i = 1:length(r)
        smn1(i,1) = r(i).s;
        smn1(i,2) = r(i).b;
        smn1(i,3) = r(i).rt;
        smn1(i,4) = r(i).rt_err;
        smn1(i,5) = r(i).ul;
        smn1(i,6) = r(i).mthd;
    end
    GTHTMLtable('Table_2',[loi' smn1],'%0.3g',{'Line (keV)' '# of signal events'...
        '# of background'...
        'Rate, cts/sec' 'Rate error'...
        'UL at 90%CL' 'Calc method'...
        },'save');
    eval(['!mv TABLE_Table_2.html ', note_dir]);
end
  
save([files_dir, sname,'_rdc.mat'],'rdc','enr','dh','ltsec','loi','r');
