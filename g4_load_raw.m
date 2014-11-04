function m = g4_load_raw(files_dir,...
                sname, files_matdir,...
                rad_name, n_length,n)
% Reads, chains together Monte Carlo result files and saves in .mat file.
%
% Oleg Kamaev - oleg.v.kamaev AT gmail.com

for j = 1:length(rad_name)

    MCdata = [];
    for i = (n*j-n+1):(n*j)
        if i < 11
            temp = load([files_dir,sname,'_',...
                rad_name{j},'_00',num2str(i-1),'_0000.txt']);
            MCdata = [MCdata; temp(:,1)+(i-1)*n_length temp(:,2:end)];
        else
            temp = load([files_dir,sname,'_',...
                rad_name{j},'_0',num2str(i-1),'_0000.txt']);
            MCdata = [MCdata; temp(:,1)+(i-1)*n_length temp(:,2:end)];
        end
        clear temp
    end

    field = {'EV','DT','TS','P','Type','E1','D3','PX3','PY3','PZ3','X3','Y3','Z3'};
    % ,...
    % 'GT3','PX1','PY1','PZ1','X1','Y1','Z1','GT1'};

    for i = 1:length(field)
        eval([field{i},'=MCdata(:,i);']);
    end

    save([files_matdir,rad_name{j},'_',sname,'.mat'],'EV','DT','TS','P',...
        'Type','E1','D3','PX3','PY3','PZ3','X3','Y3','Z3')
end

m = 1;
end
