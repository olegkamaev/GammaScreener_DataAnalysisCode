% Analyze Monte Carlo simulation results.
% Produce tables and figs.
% Called from do_main.m
%
% Oleg Kamaev - oleg.v.kamaev AT gmail.com

res = '150';
Lwidth = 2;
clr = {'b','g','r','c','m','y','k',...
    'b:','g:','r:','c:','m:','y:','k:'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%
if DoRaw
    g4_load_raw(mc_files_dir,...
        sname, mc_files_matdir,...
        rad_name, n_length, n);
end
% save([files_matdir,rad_name{j},'_',sname,'.mat']
%%%%%%%%%%%%%%%%%%%%%%%%%%%
if DoEvUniq
    g4_ev_uniq(sname, mc_files_matdir,...
        rad_name);
end
% save([files_matdir,rad_name{nm},'_',sname,'_evu.mat']
%%%%%%%%%%%%%%%%%%%%%%%%%%%
if DoDepEnergy
    g4_dep_energy(sname, mc_files_matdir,...
        rad_name);
end
load([mc_files_matdir,'edep_',sname,'.mat']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% need to convert E_tot to keV
for nm = 1:length(rad_name)
    eval(['E_tot=1E+3*E_tot_', rad_name{nm},';']); % now in keV
    if DoEnSmearing
        E_tot = E_tot + sgmFunc(E_tot).*randn(1,length(E_tot));
    end
    eval(['E_tot_',rad_name{nm},'=E_tot;']);
    clear E_tot
end

% plot MC
if makeplots
    E_tot_U238 = [E_tot_Pb214 E_tot_Bi214];
    E_tot_Th232 = [E_tot_Ac228 E_tot_Pb212 E_tot_Tl208];
    % make plotrd array
    i = 1; plotrd{i} = 'U238';
    i = i + 1; plotrd{i} = 'Th232';
    for nm = 6:length(rad_name)
        i = i + 1;
        plotrd{i} = rad_name{nm};
    end
    
    fig(3); clf;
    set(gca,'Fontsize',14); hold off;
    for nm = 1:length(plotrd)
        eval(...
         ['stairs(0:20:2800, histc(E_tot_',plotrd{nm},',0:20:2800),''',...
         clr{nm},''')'])
        hold on; grid on;
    end
    %set(gca,'YScale','log');  % no need for a log scale for now
    legend(plotrd)
    xlabel('Energy (keV)','FontSize',14)
    ylabel('Events/ 20 keV','FontSize',14)
    title(['Gopher MC: ',sname,', ',...
        num2str(n*n_length),' simulated events'])
    if savefigs
        print('-dpng',['-r' res],[figdir,...
            'mc_spectra.png']);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% now let's fit MC
load([files_dir, sname, '_rdc.mat']);
for j = 1:length(rad_name)
    eval(['[g4{j}.y,g4{j}.x]=hist(E_tot_',rad_name{j},',enr'');']);
end
for i = 1:length(loi)
    j = 0;
    for k = 1:length(rdi)
        if ismember(loi(i),rdi(k).loi)
            j = k; % rad_name index
        end
    end
    [t, ft, y, pgl, tbnum] =gausslinFixedSgmFit...
        (g4{j}.y, g4{j}.x, loi(i), -rng*sgm(i), rng*sgm(i),...
        rngs*sgm(i), sgm(i));
    g4rdc(i).t = t;
    g4rdc(i).ft = ft;
    g4rdc(i).y = y;
    g4rdc(i).pgl = pgl;
    g4rdc(i).tbnum = tbnum;
    % make plots if needed
    if makeplots
        fig(4); clf;
        set(gca,'Fontsize',14); hold off;
        stairs((g4rdc(i).t-0.5*(enr(2)-enr(1))),g4rdc(i).ft,'b-','LineWidth',1)
        hold on; grid on;
        plot(g4rdc(i).t,g4rdc(i).y,'r-','LineWidth',Lwidth)

        xlabel('Energy (keV)','FontSize',14);
        ylabel('Counts','FontSize',14);
        legend('MC','MC fit')%,'Location','Best')
        title([sname,': MC events in +/-',num2str(rngs),' sgm - p1Fitbkg: ',...
            num2str(0.1*round(10*(g4rdc(i).tbnum(1)-g4rdc(i).tbnum(2))))])
        if savefigs
            print('-dpng',['-r' res],[figdir,...
                'mc_loi',num2str(loi(i)),'_fit.png']);
        end
    end
end
% now let's calculate peak detection ratio and contamination
for i = 1:length(loi)
    st = g4rdc(i).tbnum(1); % total
    sb = g4rdc(i).tbnum(2); % p1-fit background
    g4rdc(i).pdr = (st-sb)/(n*n_length);
    g4rdc(i).pdr_err = g4rdc(i).pdr*sqrt((st+sb)/(st-sb)^2+1/(n*n_length));
    % contamination
    r(i).ct = r(i).rt/(g4rdc(i).pdr*mass);
    r(i).ct_err = abs(r(i).ct)*sqrt((r(i).rt_err/r(i).rt)^2+...
        (g4rdc(i).pdr_err/g4rdc(i).pdr)^2);
    r(i).ctUL = calcUL(r(i).ct,r(i).ct_err,r(i).s,r(i).b);
end
if table
    clear smn3
    for i = 1:length(r)
        smn3(i,1) = g4rdc(i).pdr;
        smn3(i,2) = g4rdc(i).pdr_err;
        smn3(i,3) = r(i).ct;
        smn3(i,4) = r(i).ct_err;
        smn3(i,5) = r(i).ctUL;
    end
    GTHTMLtable('Table_3',[loi' smn3],'%0.3e',{'Line (keV)'...
        'Peak Detection Ratio' 'PDR error'...
        'Contamination (Bq/kg)'...
        'Contamination error'...
        'UL at 90%CL'...
        },rdloi,'save');
    eval(['!mv TABLE_Table_3.html ', note_dir]);
end
save([files_dir, sname, '_rdc.mat'],'rdc','enr','dh','ltsec','loi','r','g4rdc');
if makeplots
    fig(5); clf;
    set(gca,'Fontsize',14); hold off;
    
    nm=1; vb=1; ve=vb-1+length(rdi(1).loi)+length(rdi(2).loi);
    errorbar(vb:ve,smn3(vb:ve,3),smn3(vb:ve,4),clr{nm})
    hold on; grid on;
    nm=2; vb=ve+1; ve=vb-1+length(rdi(3).loi)+...
        length(rdi(4).loi)+length(rdi(5).loi);
    errorbar(vb:ve,smn3(vb:ve,3),smn3(vb:ve,4),clr{nm})
    for nm=3:length(plotrd)
        vb=ve+1;
        ve=vb-1+length(rdi(nm+3).loi);
        errorbar(vb:ve,smn3(vb:ve,3),smn3(vb:ve,4),clr{nm})
    end
    legend(plotrd,'Location','Best')
    xlabel('Index for lines of interest','FontSize',14)
    ylabel('Contamination (Bq/kg)','FontSize',14)
    title(['Contamination with error-bars (UL not plotted): ',sname])
    axis tight
    if savefigs
        print('-dpng',['-r' res],[figdir,...
            'contamin.png']);
    end
end
