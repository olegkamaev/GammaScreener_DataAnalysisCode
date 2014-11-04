function m = g4_dep_energy(sname, files_matdir,...
                    rad_name)
% Calculates energy deposited to sensitive detector by Monte Carlo events.
%
% Oleg Kamaev - oleg.v.kamaev AT gmail.com

for nm = 1:length(rad_name)
    disp(['Deposited energy: processing ',...
        files_matdir,rad_name{nm},'_',sname,'_evu.mat'])
    load([files_matdir,rad_name{nm},'_',sname,'_evu.mat']);

    for i = 1:length(ev_un)
        E_tot(i) = sum(mc.D3(ev_uniq{i}));
    end

    eval(['E_tot_',rad_name{nm},'=E_tot;']);
    clear E_tot mc ev_un ev_uniq

end

save([files_matdir,'edep_',sname,'.mat'],'E_tot_*')

m = 1;
end
