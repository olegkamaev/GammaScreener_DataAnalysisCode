% Master file to analyze data collected by HPGe gamma screener.
%
% Oleg Kamaev - oleg.v.kamaev AT gmail.com

clear

%======================================
% SETUP:

% Set path and directories:

% Collected HPGe gamma Data:
files_dir = 'example/data/';
files_list = '1397T1428.list';
do_data_wrangling = true;  % "true" if data merging, wrangling was not done

% Info about the sample:
sname = 'vespelSP22';  % name of the sample
mass = 0.82;  % sample mass in kg
% Settings for the report:
note_dir = 'example/results/';  % directory for html report
table = true;  % make table?
makeplots = true;  % make plots?
savefigs = true;  % save plots?
figdir = [note_dir, 'figs/'];

% HPGe gamma background:
bpath = 'example/background/';
bfile = 'bkgPoly';

% Monte Carlo simulation:
DoMCAna = true;  % Do you want to calculate contamination with Geant4 MC?
if DoMCAna
    mc_files_dir = 'example/montecarlo/';
    mc_files_matdir = 'example/montecarlo/';
    n = 4; % number of generated files for every element
    n_length = 2.5E+5; % max number of generated events per file
    % SWITCHES (do not modify unless you know what you're doing)
    DoRaw = true;
    DoEvUniq = true;
    DoDepEnergy = true;
    DoEnSmearing = true;
end

% Parameters that should not be changed unless you know what you're doing:
% Parameters for fit range:
rng = 15;
rngs = 2.36;
% Radioactive isotopes to look for and analyze:
% Sequence of elements MATTERS and should match G4 Monte Carlo sequence!
i=1; rdi(i).name='Pb214'; rdi(i).loi=[295 351]; % in keV!
i=i+1; rdi(i).name='Bi214'; rdi(i).loi=[609 1120 1764];
i=i+1; rdi(i).name='Ac228'; rdi(i).loi=[911 969];
i=i+1; rdi(i).name='Pb212'; rdi(i).loi=[238];
i=i+1; rdi(i).name='Tl208'; rdi(i).loi=[511 583 2614];
i=i+1; rdi(i).name='Co60'; rdi(i).loi=[1173 1332];
i=i+1; rdi(i).name='K40'; rdi(i).loi=[1461];
i=i+1; rdi(i).name='Cs137'; rdi(i).loi=[661];
% Misc.
sid = 86400; % seconds in one day

%======================================
% DATA WRANGLING: 

if do_data_wrangling
    dt = load_S6500data(files_dir, files_list);  % struct with all data
    
    % Store data in vectors for plots, analysis
    i = 1;
    dn_start(i) = datenum(dt(i).date.y, dt(i).date.m, dt(i).date.d,...
                    dt(i).time.h, dt(i).time.m, dt(i).time.s);
    dn_stop(i) = dn_start(i) + dt(i).realt/sid;
    livet(i) = dt(i).livet;  % livetime in seconds
    dh(i).data = dt(i).data(3:end);
    if length(dt) > 1  % if there was > 1 data file
        for i = 2:length(dt)
            % check if this is not the first file in a sequence
            if (dt(i).time.s == dt(i-1).time.s &&...
                    dt(i).time.m == dt(i-1).time.m &&...
                    dt(i).time.h == dt(i-1).time.h &&...
                    dt(i).date.d == dt(i-1).date.d &&...
                    dt(i).date.m == dt(i-1).date.m &&...
                    dt(i).date.y == dt(i-1).date.y)

                dn_start(i) = dn_stop(i-1);
                dn_stop(i) = dn_start(i) + (dt(i).realt - dt(i-1).realt)/sid;
                livet(i) = dt(i).livet - dt(i-1).livet; % in seconds

                dh(i).data = dt(i).data(3:end) - dt(i-1).data(3:end);

            else  % first file in the sequence

                dn_start(i) = datenum(dt(i).date.y, dt(i).date.m, dt(i).date.d,...
                                dt(i).time.h, dt(i).time.m, dt(i).time.s);
                dn_stop(i) = dn_start(i) + dt(i).realt/sid;
                livet(i) = dt(i).livet; % in seconds

                dh(i).data = dt(i).data(3:end);
            end
        end
    end
    save([files_dir, files_list(1:(length(files_list)-5)), '.mat'],...
        'dt',...    % data as they come from file, i.e. concatenated data 
        'dn_start','dn_stop','livet','dh') % data accumulated in this chunk of time
    
    % Combine, chain together data chunks 
    all_livet = 0; all_realt = -999999; 
    all_data = zeros(length(dh(1).data), 1);
    for i = 1:length(livet)
        all_livet = all_livet + livet(i);
        all_data = all_data + dh(i).data;
    end
    % Save in .dat file
    fid = fopen([files_dir, sname, '.dat'], 'w');
    fprintf(fid, '%d\n', all_livet);
    fprintf(fid, '%d\n', all_realt);
    for k = 1:length(all_data)
        fprintf(fid, '%d\n', all_data(k));
    end
    fclose(fid);
end

%======================================
% ANALYSIS:

% lines of interest (loi) in keV:
loi = [];
j = 0;
for i = 1:length(rdi)
    loi = [loi rdi(i).loi];
    for k = 1:length(rdi(i).loi)
        j = j + 1;
        rdloi{j} = rdi(i).name;
    end
end
% sigma for loi:
sgm = sgmFunc(loi);

ana_data

% Analyze Geant4 Monte Carlo results:
if DoMCAna
    for i = 1:length(rdi)
        rad_name{i} = rdi(i).name;
    end

    ana_g4
end
