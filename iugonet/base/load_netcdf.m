function [data_ret, info_ret] = load_netcdf(startTime, endTime, files, varargin)
%
% [data_ret, info_ret] = load_netcdf(startTime, endTime, files)
%
% Load NetCDF files.
%
% (argument)
%   startTime:          Start time (datetime or datenum)
%   endTime:            End time (datetime or datenum)
%   files:              File names of save files
%   time_varname(opt):  Variable name for time in NetCDF
%   time_format(opt):   Format for time in NetCDF
%
% (return value)
%   data_ret:           Data from output of ncread(file).
%                       data1 = ncread(file);
%                       Connected data of data1 from files.
%                       Picked up data between startTime and endTime;
%   info_ret:           Data from output of ncinfo(file).
%                       info1 = ncinfo(file);
%                       If several files are selected, the first one will
%                       be returned.
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
validTime_Varname = @(x) ischar(x);
addParameter(p, 'time_varname', '', validTime_Varname);
validTime_Format = @(x) ischar(x);
addParameter(p, 'time_format', 'yyyy-MM-dd HH:mm:ss Z', validTime_Format);

parse(p, startTime, endTime, files, varargin{:});

startTime    = p.Results.startTime;
endTime      = p.Results.endTime;
files        = p.Results.files;
time_varname = p.Results.time_varname;
time_format  = p.Results.time_format;

% -------------------------------------------------

% Output arguments
data_ret={};
info_ret=struct([]);

% Read Data from NetCDF files
data=[];
info=[];
nfile=length(files);

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

flg_tvar=0;
time_VariableName = time_varname;
if nfile > 0
    for i=1:nfile
        file_tmp = char(files(i));
        disp(['Reading ... ' file_tmp]);
        try
            info_tmp = ncinfo(file_tmp);
        catch ME
            disp(['File not found: ' file_tmp]);
            disp(ME.message);
            continue;
        end
        if isempty(time_VariableName) && flg_tvar==0
            time_VariableName = find_time_varname(info_tmp);
            flg_tvar=1;
        end
        nvar = size(info_tmp.Variables, 2);
        for j=1:nvar
            varname = info_tmp.Variables(j).Name;
            vardata = ncread(file_tmp, varname);
            data_tmp{1,j} = vardata;
        end

        % Convert time into datenum
        [data_tmp, info_tmp, time_idx] = ConvertTime(data_tmp, info_tmp, time_VariableName, time_format);

        % Append data
        data=[data; data_tmp];
        info=[info, info_tmp];
    end
else
    disp('No file is set. Need at least 1 file to read.');
    return;
end

% Cannot read all files.
if isempty(data)
    return;
end


dimensions = {info(1).Variables.Dimensions};
% ind = zeros(nvar,1,'logical');
ind = zeros(nvar,1);
tm_dim = zeros(nvar, 1);
for i=1:length(dimensions)
    if isempty(dimensions{i})
        continue;
    end
    tmp = dimensions{i};
    for k=1:length(tmp)
        if strcmp(tmp(k).Name, time_VariableName)
            ind(i) = true;
            tm_dim(i) = k;
            break;
        end
    end
end
% Set index of time dependent variable.
idx_td = find(ind);
tm_dim = tm_dim(idx_td);


% Connect time dependet variables
if nfile > 1
    data_ret = data(1,:);
    for i=2:nfile
        for k=1:length(idx_td)
            tmp_data = data(i,:);
            % find time dimension based on the name 'time' in
            % info.Variables.Dimensions.Name.
            time_dim = find(strcmpi(vertcat({info(i).Variables(idx_td(k)).Dimensions.Name}), time_VariableName), 1);
            if isempty(time_dim)
                disp('Error: Cannot find time variable in info.Variables.Dimensiions.Name.');
                return;
            end
            data_ret{1, idx_td(k)} = cat(time_dim, data_ret{1, idx_td(k)}, tmp_data{1, idx_td(k)});
        end
    end
else
    data_ret = data;
end


% Select data between startTime and endTime
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
end

% data_ret{1,time_idx} is time variable
ind = (data_ret{1,time_idx} >= st) & (data_ret{1,time_idx} <= ed);
for i=1:length(idx_td)
    % data demension is up to 2-d?
    tmp_data = data_ret{1, idx_td(i)};
    [tmp, perm, nshifts] = shiftdata(tmp_data, tm_dim(i));
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
    tmp_data = unshiftdata(tmp, perm, nshifts);
    data_ret{1, idx_td(i)} = tmp_data;
end


% Set info_ret (return first info)
info_ret = info(1);

end

function [data2, info2, time_idx] = ConvertTime(data, info, time_varname, time_format)
% Convert time

% Set return value
data2 = data;
info2 = info;

% Look for time variable
%time_idx = find(strcmp(vertcat({info.Variables.Name}), 'time'), 1);
% for i=1:length(info.Variables)
%     attr_name = {info.Variables(i).Attributes.Name};
%     name_idx = find(strcmp(attr_name, 'units'),1);
%     attr_value = {info.Variables(i).Attributes.Value};
%     str = attr_value{name_idx};
%     str_idx = strfind(str, 'since');
%     if (isempty(str_idx) == false)
%         time_idx = i;
%         break
%     end
% end

% Look for base time information
time_idx = find(strcmp(vertcat({info.Variables.Name}), time_varname), 1);
attr_name = {info.Variables(time_idx).Attributes.Name};
name_idx = find(strcmp(attr_name, 'units'), 1);
attr_value = {info.Variables(time_idx).Attributes.Value};
str = attr_value{name_idx};
str_idx = strfind(str, 'since');

% Set time unit information
unit_time = str(1:str_idx-2);

% Set base time
str_time = str(str_idx+6:end);
st_datetime = datetime(str_time, 'TimeZone', 'UTC', 'InputFormat', time_format);
% st_datetime = datetime(str_time, 'TimeZone', 'UTC')

% Change time to datenum
switch lower(unit_time)
    case 'days'
        t = st_datetime + days(data{time_idx});
    case 'hours'
        t = st_datetime + hours(data{time_idx});
    case 'minutes'
        t = st_datetime + minutes(data{time_idx});
    case 'seconds'
        t = st_datetime + seconds(data{time_idx});
    case 'milliseconds'
        t = st_datetime + milliseconds(data{time_idx});
    otherwise
        disp('ERROR: Wrong time unit setting in the netcdf file.');
        return;
end
data2{time_idx} = datenum(t);
end


function   time_VariableName = find_time_varname(info)
% Look for time dependency
% Suppose the data structure is the same as the first one.
% Look for time variable
%time_idx = find(strcmp(vertcat({info.Variables.Name}), 'time'), 1);
for j=1:length(info.Variables)
    attr_name = {info.Variables(j).Attributes.Name};
    name_idx = find(strcmp(attr_name, 'units'),1);
    if ~isempty(name_idx)
        attr_value = {info.Variables(j).Attributes.Value};
        str = attr_value{name_idx};
        str_idx = strfind(str, 'since');
        if (isempty(str_idx) == false)
            time_idx = j;
            time_VariableName = info.Variables(time_idx).Name;
            break
        end
    end
end

end
