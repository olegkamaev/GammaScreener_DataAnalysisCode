function m = g4_ev_uniq(sname, files_matdir,...
                rad_name)
% Groups steps that belong to the same MC event.
%
% Oleg Kamaev - oleg.v.kamaev AT gmail.com

for nm = 1:length(rad_name)
    disp(['EV Unique: processing ',...
        files_matdir,rad_name{nm},'_',sname,'.mat'])
    mc = load([files_matdir,rad_name{nm},'_',sname,'.mat']);

    if mc.EV ~= sort(mc.EV)
        disp('!!! error !!! MC array is not sorted by EV.')
    else

        ind = 1;
        un = 1;
        ev_un(un) = mc.EV(1);
        ev_uniq{un}(ind) = 1;
        
        for i = 2:length(mc.EV)
            
            if mc.EV(i) == mc.EV(i-1)
                ind = ind + 1;
            else
                un = un + 1;
                ind = 1;
                ev_un(un) = mc.EV(i);
            end
            ev_uniq{un}(ind) = i;    
            
        end
    end
    
    save([files_matdir,rad_name{nm},'_',sname,'_evu.mat'],...
        'mc*','ev_un','ev_uniq')
    
%     evlist=unique(mc.EV);
%     for evind=1:length(evlist)
%         E_tot(evind)=sum(mc.D3(mc.EV==evlist(evind)));
%     end
%     eval(['E_tot_',rad_name{nm},'=E_tot;']);
    
    clear mc ev_un ev_uniq

end

m = 1;
end
