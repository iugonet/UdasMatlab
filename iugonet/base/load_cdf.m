function   [data_ret, info_ret]=load_cdf(startTime, endTime, files, varargin)
%
% [data_ret, info_ret] = load_cdf(startTime, endTime, files, var_type)
%
% Load CDF files. 
%
% (argument)
%   startTime:          Start time (datetime or datenum)
%   endTime:            End time (datetime or datenum)
%   files:              File names of save files
%   var_type (option):  Choose 'data', 'support_data', and 'metadata'.
%                       Default is all types selected.
%                       var_type = {'data, 'support_data', 'metadata'};
%
% (return value)
%   data_ret:           Data from output of spdfcdfread(file).
%                       [data1, info1] = spdfcdfread(file);
%                       Connected data of data1 from files.
%                       Only set per var_type selected. (Default is all
%                       set.)
%                       Picked up data between startTime and endTime;
%   info_ret:           The same value of info1 mentioned above.
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
validVarType = @(x) iscell(x) || ischar(x);
addParameter(p, 'var_type', [], validVarType);

parse(p, startTime, endTime, files, varargin{:});

startTime   = p.Results.startTime;
endTime     = p.Results.endTime;
files       = p.Results.files;
var_type    = p.Results.var_type;

% -------------------------------------------------

% Output arguments
data_ret={};
info_ret=struct([]);

% Read Data from SPDF files
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

if nfile > 0
    for i=1:nfile
        file_tmp=char(files(i));
        disp(['Reading ... ' file_tmp]);
        try
            [data_tmp, info_tmp]=spdfcdfread(file_tmp);
        catch ME
            disp(['File not found: ' file_tmp]);
            disp(ME.message);
            continue;
        end
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

% Look for time dependency
variable_name = info(1).Variables(:,1);
depend_variable = info(1).VariableAttributes.DEPEND_0;
time_variable = unique(depend_variable(:,2));

% Pick up time dependent variables
depend_unique = unique(depend_variable);

n_depend = length(depend_unique);
n_variable_name = size(variable_name, 1);
% ind = zeros(n_variable_name,1,'logical');
ind = zeros(n_variable_name,1);  % for v8.5
for i=1:n_depend
    for k=1:n_variable_name
        if strcmp(depend_unique(i), variable_name(k))
            ind(k) = true;
            break;
        end
    end
end
% Set index of time dependent variable.
idx_td = find(ind);


% Connect time dependet variables
if nfile > 1
    data_ret = data(1,:);
    for i=2:nfile
        for k=1:length(idx_td)
            tmp_data = data(i,:);
            % if dimension of time-dependent variable is 1 or 2, time is the first dimension. 
            if ndims(data{i,idx_td(k)}) == 2
                data_ret{1, idx_td(k)} = cat(1, data_ret{1, idx_td(k)}, tmp_data{1, idx_td(k)});
            else
                % if dimension of time-dependent variable is more than 2,
                % the last dimension is time.
                data_ret{1, idx_td(k)} = cat(ndims(data{i,idx_td(k)}), data_ret{1, idx_td(k)}, tmp_data{1, idx_td(k)});
            end
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
%        % Suppose startTime is CDF Epoch.
%        st = spdfepochtodatenum(startTime);
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
%        % Suppose endTime is CDF Epoch.
%        ed = spdfepochtodatenum(endTime);
    else
        error('Error on endTime. Please check it.');
    end
end

% Time variable is defiled by DEPEND_0
for itv=1:length(time_variable)
    % Search time variable
    time_variable_idx = find(strcmp(variable_name, time_variable{itv}),1);
    % Cut data between startTime and endTime
    ind = (data_ret{1,time_variable_idx} >= st) & (data_ret{1,time_variable_idx} <= ed);
    data_ret{1, time_variable_idx} = data_ret{1, time_variable_idx}(ind, :);

    for i=1:length(idx_td)
        idx_dv=find(strcmp(depend_variable(:,1), variable_name{idx_td(i)}),1);
        if ~isempty(idx_dv) && strcmp(depend_variable{idx_dv, 2}, time_variable{itv})
            tmp = data_ret{1, idx_td(i)};
            % data dimension is up to 2-d?
            if ndims(tmp) <= 2
                data_ret{1, idx_td(i)} = data_ret{1,idx_td(i)}(ind, :);
            else
                % data dimension > 2
                % In this case, the time variable is supposed to be the last
                % dimension.
                SizeNum = size(tmp); % e.g. SizeNum = [100, 200, 300];
                tmp2 = reshape(tmp, prod(SizeNum(1:end-1)), SizeNum(end));
                % e.g. tmp2 is [100*200, 300] array
                tmp3 = tmp2(:,ind); % only selected time range
                SizeNum2 = [SizeNum(1:end-1), sum(ind)];
                tmp4 = reshape(tmp3, SizeNum2);
                data_ret{1, idx_td(i)} = tmp4;
            end
        end
    end
end

% Select return data by var_type
if ischar(var_type)
    [sy, sx] = size(var_type);
    tmp_var_type = [];
    for i=1:sy
        tmp_var_type{i} = deblank(var_type(i,:));
    end
    var_type = tmp_var_type;
end

if ~isempty(var_type)
%    ind= zeros(n_variable_name, 1, 'logical');
    ind= zeros(n_variable_name, 1);  % for v8.5
    attr_var_type = [info(1).VariableAttributes.VAR_TYPE(:,2)];
    for i=1:length(var_type)
        switch lower(var_type{i})
            case 'data'
                ind_tmp = strcmpi(attr_var_type, 'data');
                ind = ind | ind_tmp;
            case 'support_data'
                ind_tmp = strcmpi(attr_var_type, 'support_data');
                ind = ind | ind_tmp;
            case 'metadata'
                ind_tmp = strcmpi(attr_var_type, 'metadata');
                ind = ind | ind_tmp;
        end
    end
    data_ret = data_ret(1,ind);
end

% Set info_ret (return first info)
info_ret = info(1);



