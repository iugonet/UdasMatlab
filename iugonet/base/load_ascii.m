function   [data_ret, info_ret]=load_ascii(startTime, endTime, files,varargin)
%
% [data_ret, info_ret] = load_cdf(startTime, endTime, files, var_type)
%
% Load ascii files.
%
% (argument)
%   startTime:          Start time (datetime or datenum)
%   endTime:            End time (datetime or datenum)
%   files:              File names of save files
%
%   format_type(option):
%   time_column(option):
%   time_format(option):
%   input_time(option):
%   localtime(option):
%   delimiter(option):
%   data_start(option):
%   comment_symbol(option):
%   no_convert_time(option):
%   header_only(option):
%
% (return value)
%   data_ret:           Data from ascii files.
%                       Picked up data between startTime and endTime;
%   info_ret:           Header info of ascii files.
%
% (Example)
%
%

% -------------------------------------------------

p = inputParser;

validTime = @(x) isdatetime(x) || ischar(x) || isscalar(x);
addRequired(p, 'startTime', validTime);
addRequired(p, 'endTime', validTime);
validFiles = @(x) iscell(x) || ischar(x);
addRequired(p, 'files', validFiles);
validFormat_type = @(x) x==1 || x==2 || x==3;
addParameter(p, 'format_type', 1, validFormat_type);
validTime_column = @(x) isscalar(x) || isvector(x);
addParameter(p, 'time_column', 1, validTime_column);
validTime_Format = @(x) ischar(x) || iscell(x);
addParameter(p, 'time_format', 'yyyy MM dd hh mm ss', validTime_Format);
validInput_Time = @(x) isvector(x);
addParameter(p, 'input_time', [-1 -1 -1 -1 -1 -1], validInput_Time);
validLocalTime = @(x) isvector(x);
addParameter(p, 'localtime', 0, validLocalTime);
validDelimiter = @(x) ischar(x) || iscell(x);
addParameter(p, 'delimiter', ' ', validDelimiter);
validData_Start = @(x) isvector(x);
addParameter(p, 'data_start', 1, validData_Start);
validComment_Symbol = @(x) ischar(x) || iscell(x);
addParameter(p, 'comment_symbol', '%', validComment_Symbol);
validNo_Convert_Time = @(x) x==0 || x==1;
addParameter(p, 'no_convert_time', 0, validNo_Convert_Time);
validHeader_Only = @(x) x==0 || x==1;
addParameter(p, 'header_only', 0, validHeader_Only);

parse(p, startTime, endTime, files, varargin{:});

startTime       = p.Results.startTime;
endTime         = p.Results.endTime;
files           = p.Results.files;
format_type     = p.Results.format_type;
time_column     = p.Results.time_column;
time_format     = p.Results.time_format;
input_time      = p.Results.input_time;
localtime       = p.Results.localtime;
delimiter       = p.Results.delimiter;
data_start      = p.Results.data_start;
comment_symbol  = p.Results.comment_symbol;
no_convert_time = p.Results.no_convert_time;
header_only     = p.Results.header_only;


% -------------------------------------------------

% Output arguments
% Output arguments
data_ret={};
info_ret=struct([]);

% Read Data from ascii files
data = [];
info = [];
time_datenum = [];
time_datetime = [];
tmp_file_name = 'tmpfile.txt';
tmp_file_name_org = tmp_file_name;

nfile=length(files);

jdg = false;

% If the cell is empty, delete it.
no_files = [];
[a, b] = size(files);

if nfile > 0
    if(a>b)
        for i=1:nfile
            if(isequal(files{i,:}, []))
                no_files = [no_files,i];
            end
        end
    else
        for i=1:nfile
            if(isequal(files{:,i}, []))
                no_files = [no_files,i];
            end
        end
    end
end
files(no_files, :) = [];
nfile = nfile-length(no_files);


% Time format pre-processing
if isscalar(time_column) % && (time_column == 1) % Delete time_column = 1 constrain.
    % Only length of time_format = 1 can process time_format which contains space.
    if iscell(time_format) && (length(time_format) > 1)
        disp('Error: Inconsistency between time_column and time_format');
        return;
    elseif iscell(time_format)
        time_format = time_format{1};
    end
    % Here, time_format is char.
    % Set the flag on time_column_1 processing.
    flag_time_column_scalar = true;
else
    flag_time_column_scalar = false;
end

% Pre-process input_time
% input_time is set by caller in order to cover undefined time variables.
input_time_format = {'yyyy', 'MM', 'dd', 'HH', 'mm', 'ss'};
ind = input_time ~= -1;
input_format_str = [];
input_time_str = [];
if any(ind)
    for l=find(ind)
        input_format_str = [input_format_str, input_time_format{l}];
        if l==1
            % Year
            input_time_str = [input_time_str, sprintf('%04d',input_time(l))];
        else
            % Others
            input_time_str = [input_time_str, sprintf('%02d',input_time(l))];
        end
    end
end

% Read and analyze file.
if nfile > 0
    for i=1:nfile
        % Initialization
        info_tmp = [];
        tmp_file_data = [];
        
        time_datetime_file = [];
        time_text = [];
        f_made_tmp_file = false;
        
        file_tmp = char(files(i));
        disp(['Reading ... ' file_tmp]);
        
        % Process if header_only
        if header_only
            try
                f = fopen(file_tmp, 'r');
                if f<0
                    disp(['Error: Cannot open input file. ' file_tmp]);
                    return;
                end
            catch ME
                disp(['Error: Cannot open input file. ' file_tmp]);
                disp(ME.message);
                continue;
            end
            
            if data_start > 1
                % Header is in the file. Keep header info.
                for j=1:data_start-1
                    tline = fgetl(f);
                    info_tmp{end+1} = tline;
                end
            elseif ~isempty(comment_symbol)
                while(true)
                    % Read line from file.
                    tline = fgetl(f);
                    if tline < 0
                        break;
                    end
                    idx = strfind(tline, comment_symbol);
                    if ~isempty(idx)
                        if idx(1) == 1
                            % Maybe header line. Keep the line as header
                            info_tmp{end+1} = tline;
                            continue;
                        end
                        % Delete after comment_symbol.
                        %tline = tline(1:idx(1)-1);
                    end
                end
            end
            fclose(f);
            
            % In this case, just read header and return this function.
            % Set info
            tmp = [];
            tmp.Text = info_tmp';
            tmp.Format = 'ascii';
            info_ret = tmp;
            data_ret = [];
            return;
        end
        
        % Analyze individual file.
        if flag_time_column_scalar
            % In case of flag_time_column_scalar
            try
                f = fopen(file_tmp, 'r');
                if f<0
                    disp(['Error: Cannot open input file. ' file_tmp]);
                    return;
                end
            catch ME
                disp(['Error: Cannot open input file. ' file_tmp]);
                disp(ME.message);
                continue;
            end
            % Separate header area at first.
            if data_start > 1
                % Header is in the file. Keep header info.
                for j=1:data_start-1
                    tline = fgetl(f);
                    info_tmp{end+1} = tline;
                end
            end
            header_lines = 0;
            
            % Now header is stored in the info_tmp.
            % Process line by line, and save data into temp variable.
%             fw = fopen(tmp_file_name, 'w');
%             if fw<0
%                 disp(['Error: Cannot open input file. ' tmp_file_name]);
%                 return;
%             end
            while(true)
                % Read line from file.
                tline = fgetl(f);
                if tline < 0
                    break;
                end
                
                % Get rid of comment.
                if ~isempty(comment_symbol)
                    idx = strfind(tline, comment_symbol);
                    if ~isempty(idx)
                        if idx(1) == 1
                            % Maybe header line. Keep the line as header
                            info_tmp{end+1} = tline;
                            continue;
                        end
                        % Delete after comment_symbol.
                        tline = tline(1:idx(1)-1);
                    end
                end
                
                % Time format processing.
                if flag_time_column_scalar
                    % time_column = 1 only special processing.
                    % In this case, time_format can contain space char.
                    time_format_len = length(time_format);
                    
                    time_text = [time_text; tline(1:time_format_len)];
                    
                    % Delete time data from tline.
                    if any(~strcmp(delimiter, ' '))
                        % Usually after the time column, there is delimiter.
                        tline = strtrim(tline(time_format_len + 1 + 1:end));
                    else
                        % Delimiter is spece, it may contain no space just
                        % after the time data.
                        %tline = tline(time_format_len + 1:end);
                        tline = strtrim(tline(time_format_len + 1:end));
                    end
                end
                
                % Now time format is clear. Write data area.
%                 fprintf(fw, '%s\n', tline);
                tmp_file_data{end+1} = tline;
                
            end
%             fclose(fw);
            fclose(f);
%            f_made_tmp_file = true;
            pause(0.1);
            
        else
            % In case of NOT flag_time_column_scalar
            
            if data_start > 1
                try
                    f = fopen(file_tmp, 'r');
                    if f<0
                        disp(['Error: Cannot open input file. ' file_tmp]);
                        return;
                    end
                catch ME
                    disp(['Error: Cannot open input file. ' file_tmp]);
                    disp(ME.message);
                    continue;
                end
                % Header is in the file. Keep header info.
                for j=1:data_start-1
                    tline = fgetl(f);
                    info_tmp{end+1} = tline;
                end
                fclose(f);
            end
            
            tmp_file_name = file_tmp;
            header_lines = data_start - 1;
        end
        
        % Read data area
        try
            if flag_time_column_scalar
                tbl = readtable_str(tmp_file_data, header_lines, delimiter);
            else
                tbl = readtable(tmp_file_name, 'DatetimeType', 'text', 'HeaderLines', header_lines, ...
                    'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'ReadVariableNames', false);
            end

        catch ME
            disp(['ERROR: Analyzing ' tmp_file_name ' failed.']);
            disp(ME.message);
            continue;
        end
        if f_made_tmp_file
           pause(0.1);
           delete(tmp_file_name_org);
        end
        
        data_tmp = {[]};
        for j=1:width(tbl)
            entry = table2cell(tbl(1,j));
            if isnumeric(entry{1})
                data_tmp{j} = table2array(tbl(:,j));
            elseif ischar(entry{1})
                data_tmp{j} = table2cell(tbl(:,j));
            else
                disp('Error: Unknown data type in the file.');
                return;
            end
        end
        
        % time data processing
        if ~flag_time_column_scalar
            % time_column is not 1 or contains several columns.
            % In this case, the number of valid time_columns and the number
            % of valid time_format should be the same.
            try
                %cnt = 1;
                time_format_new = [];
                for j=1:length(time_column)
                    if time_column(j) ~= -1
                        tmp = data_tmp{time_column(j)};
                        if isnumeric(tmp(1))
                            ind_dot = strfind(time_format{j}, '.');
                            len = length(time_format{j});
                            if isempty(ind_dot)
                                sfmt = ['%0' num2str(len) 'd'];
                            else
                                % time_format contains '.'
                                len_fl = len - ind_dot;
                                sfmt = ['%0' num2str(len) '.' num2str(len_fl) 'f'];
                            end
                            stmp = [];
                            for k=1:length(tmp)
                                stmp = [stmp; sprintf(sfmt, tmp(k))];
                            end
                            
                            time_text = [time_text, stmp];
                        else
                            time_text = [time_text, tmp];
                        end
                        time_format_new = [time_format_new, time_format{j}];
                        %cnt = cnt + 1;
                    end
                end
            catch ME
                disp('Error: inconsistency of time_format and time_column.');
                disp(ME.message);
                if ~isempty(tmp)
                    if any(contains(tmp, ' ')) && ~any(contains(delimiter, ' '))
                        disp('One possibility is time column contains space and is not set in delimiter.');
                    end
                end
                return;
            end
        else
            time_format_new = time_format;
        end
        
        % Get datetime.
        try
            for j=1:length(time_text)
                % if the '0' is eliminated, add '0'.
                %str = tline(1:time_format_len);
                str = time_text(j,:);
                ind = xor(time_format_new == ' ', str == ' ');
                str(ind) = '0';
                
                % Convert to datetime
                tmp = datetime([input_time_str, str], 'InputFormat', [input_format_str, time_format_new]);
                
                % Adjust local time 
                % if localtime =9, world time = file time - 9.
                tmp = tmp - hours(localtime);
                
                % Put the time data into time_datetime
                time_datetime_file = [time_datetime_file; tmp];
            end
        catch ME
            disp('Error: time_format is not valid.');
            disp(ME.message);
            return;
        end
        
        
        
        % Set time data into time_datenum
        time_datetime{i} = time_datetime_file;
        time_datenum{i} = datenum(time_datetime_file);
        
        % Set data
        data = [data; data_tmp];
        
        % Set info
        tmp = [];
        tmp.Text = info_tmp';
        tmp.Format = 'ascii';
        info = [info, tmp];
    end
else
    disp('No file is set. Need at least 1 file to read.');
    return;
end

% Cannot read all files.
if isempty(data)
    return;
end

%% Re-arrangement, depend on format type.

switch format_type
    case 1
        % Connect ydata.
        % In case, time num = n, ydata{k} is 1xn matrix. (Time dependent
        % variable is 2nd dimension.)
        [data, time_datenum, time_datetime] = load_ascii_format1(data, time_datenum, time_datetime);
    case 2
        % Pick up unique time, and connect data.
        % In case, unique time num = n, ydata{k} is mxn matrix. (m is the
        % max data size of every ydata. Fill up with NaN.
        [data, time_datenum, time_datetime] = load_ascii_format2(data, time_datenum, time_datetime);
    case 3
        % Connect ydata matrix.
        % In case, time num = n, ydata is mxn matrix.
        [data, time_datenum, time_datetime] = load_ascii_format3(data, time_datenum, time_datetime);
        
    otherwise
        disp('Error: Invalid format_type.');
        return;
end


%% Connect time dependet variables
% For ASCII file, all the variables are time dependent.
[sy, sx] = size(data);
time_datenum_ret = [];
time_datetime_ret = [];
if nfile > 1
    data_ret = data(1,:);
    time_datenum_ret = time_datenum{1};
    time_datetime_ret = time_datetime{1};
    for i=2:nfile
        for k=1:sx
            % In case format 2 has variable columns.
            cat1 = data_ret{1, k};
            cat2 = data{i,k};
            [ssy1, ssx1] = size(cat1);
            [ssy2, ssx2] = size(cat2);
            if ssx1 ~= ssx2
                ssx_max = max(ssx1, ssx2);
                cat1_base = nan(ssy1, ssx_max);
                cat1_base(1:ssy1, 1:ssx1) = cat1;
                cat2_base = nan(ssy2, ssx_max);
                cat2_base(1:ssy2, 1:ssx2) = cat2;
                cat1 = cat1_base;
                cat2 = cat2_base;
            end
            data_ret{1, k} = cat(1, cat1, cat2);
        end
        time_datenum_ret = cat(1, time_datenum_ret, time_datenum{i});
        time_datetime_ret = cat(1, time_datetime_ret, time_datetime{i});
    end
else
    data_ret = data;
    time_datenum_ret = time_datenum{1};
    time_datetime_ret = time_datetime{1};
end


%% Select data between startTime and endTime
if isempty(startTime)
    st = 0;
else
    if isa(startTime, 'datetime')
        st = datenum(startTime);
    elseif ischar(startTime)
        st = datenum(datetime(startTime));
    elseif isnumeric(startTime)
        st = startTime;
        %         % Suppose startTime is CDF Epoch.
        %         st = spdfepochtodatenum(startTime);
    else
        error('Error on startTime. Please check it.');
    end
    % adjust local time
    st = st  - datenum(hours(localtime));
end
if isempty(endTime)
    ed = inf;
else
    if isa(endTime, 'datetime')
        ed = datenum(endTime);
    elseif ischar(endTime)
        ed = datenum(datetime(endTime));
    elseif isnumeric(endTime)
        ed = endTime;
        %         % Suppose endTime is CDF Epoch.
        %         ed = spdfepochtodatenum(endTime);
    else
        error('Error on endTime. Please check it.');
    end
    % adjust local time
    ed = ed  - datenum(hours(localtime));
end

% time_data is time variable
% For ASCII file, all the variables are time dependent.
[sy, sx] = size(data);
ind = (time_datenum_ret >= st) & (time_datenum_ret <= ed);

for i=1:sx
    % data demension is up to 2-d?
    tmp = data_ret{1, i};
    %[tmp, perm, nshifts] = shiftdata(tmp_data, tm_dim(i));
    switch ndims(tmp)
        case 2
            tmp = tmp(ind, :);
        case 3
            tmp = tmp(ind, :, :);
        case 4
            tmp = tmp(ind, :, :, :);
        case 5
            tmp = tmp(ind, :, :, :, :);
    end
    %tmp_data = unshiftdata(tmp, perm, nshifts);
    data_ret{1, i} = tmp;
end
time_datenum_ret = time_datenum_ret(ind);
time_datetime_ret = time_datetime_ret(ind);


% Add time data to data_ret.
% The first column is time data.
% If time_column == 1, no change of the number of columns.
% If time_column is not 1, the first column is time data which is added.
tmp = [];
if no_convert_time == 0
    % serial time
    tmp{1} = time_datenum_ret;
else
    % separate time
    time_datetime_ret.Format = 'yyyy MM dd HH mm ss';
    tmp{1} = char(time_datetime_ret);
end
data_ret = [tmp, data_ret];


% Set info_ret (return first info)
info_ret = info(1);

end


