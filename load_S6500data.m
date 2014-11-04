function dt = load_S6500data(files_dir, files_list)
% Loads data in S6500 format from all txt files in files_list.
% Extracts date, time, spectrum info from files and saves into struct.
% Returns struct dt. 
%
% Oleg Kamaev - oleg.v.kamaev AT gmail.com

fnml = 12; % length of file name including extension

% current directory
curdir = pwd;

% go to directory with files and load them
cd(files_dir);
fid = fopen(files_list);
filename = fscanf(fid, '%c',[(1+fnml),inf]);
filename = filename';
fclose(fid);

for i = 1:size(filename,1)
    
    fid = fopen(filename(i,1:fnml));
    
    tj = fgetl(fid); % skip first line
    tj = fgetl(fid); % line #2: time when data acquisition started
    i_sl = find(tj=='/'); % find index for '/'
    i_dd = find(tj==':'); % find index for ':'
    dt(i).date.m = str2double(tj(15:i_sl(1)-1));
    dt(i).date.d = str2double(tj(i_sl(1)+1:i_sl(2)-1));
    dt(i).date.y = str2double(tj(i_sl(2)+1:i_sl(2)+4));
    % time
    tm = str2double(tj(i_sl(2)+6:i_dd(1)-1)); % hour
    
    if ~isempty(strfind(tj,'PM')) % there is PM in the line
        if tm ~= 12
            % convert to 24-hour format
            dt(i).time.h = tm + 12;
        else
            dt(i).time.h = tm;
        end
    else
        if tm == 12
            dt(i).time.h = 0;
        else
            dt(i).time.h = tm;
        end
    end
    dt(i).time.m = str2double(tj(i_dd(1)+1:i_dd(2)-1));
    dt(i).time.s = str2double(tj(i_dd(2)+1:i_dd(2)+2));
    tj = fgetl(fid); % line #3
    dt(i).livet = str2double(tj(15:end)); % in seconds
    tj = fgetl(fid); % line #4
    dt(i).realt = str2double(tj(15:end));
    % skip the following lines:
    tj = fgetl(fid); % line #5
    tj = fgetl(fid); % line #6
    tj = fgetl(fid); % line #7
    tj = fgetl(fid); % line #8
    tj = fgetl(fid); % line #9
    
    dt(i).data = (fscanf(fid,'%d', [1,inf]))';
    fclose(fid);
    
end

% go back to the original directory
cd(curdir)

end
