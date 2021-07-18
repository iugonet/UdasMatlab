function   [data_ret, info_ret]=load_fits(startTime, endTime, files, varargin)
%
% [data_ret, info_ret] = load_fits(startTime, endTime, files, var_type)
%
% Load fits files.
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
validTime_Dimension = @(x) isnumeric(x);
addParameter(p, 'time_dimension', 1, validTime_Dimension);

parse(p, startTime, endTime, files, varargin{:});

startTime   = p.Results.startTime;
endTime     = p.Results.endTime;
files       = p.Results.files;
time_dimension    = p.Results.time_dimension;

% -------------------------------------------------

% Output arguments
data_ret = {};
info_ret = struct([]);
time = [];
dimj = [];

% Read data
data = [];
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
    % Initialize
    
    for i=1:nfile
        file_tmp=char(files(i));
        disp(['Reading ... ' file_tmp]);
        try
            %[data_tmp, info_tmp]=fitsread(file_tmp);
            data_tmp = fitsread(file_tmp);
            info_tmp  = fitsinfo(file_tmp);
        catch ME
            disp(['File not found: ' file_tmp]);
            disp(ME.message);
            continue;
        end
        
        % Cannot read all files.
        if isempty(data_tmp)
            return;
        end
        
        %% Calculate axis information
        
        fits_format     = info_tmp.PrimaryData.Keywords;
        keys            = fits_format(:,1);
        vals            = fits_format(:,2);
        
        % Search 'time' in CTYPEi
        NAXIS = fits_get_val(keys, vals, 'NAXIS');
        TimeInCtype = zeros(1,NAXIS, 'logical');
        for j=1:NAXIS
            tmpCTYPE = fits_get_val(keys, vals, strcat('CTYPE', num2str(j)));
            idx = strfind(lower(tmpCTYPE), 'time');
            if ~isempty(idx)
                TimeInCtype(j) = true;
            end
        end
        TimeInCtypeIdx = find(TimeInCtype);
        if isempty(TimeInCtypeIdx)
            TimeInCTypeIdx = 0;
        end
        
        if ~isempty(time_dimension)
            % time_dimension is set by caller.
            if ~any(TimeInCtypeIdx == time_dimension)
                % No match time_dimension
                if TimeInCtypeIdx ~= 0
                    % At least one time is found in CTYPE.
                    str = fits_get_val(keys, vals, strcat('CTYPE', num2str(time_dimension)));
                    disp(['Warning: time_dimension = ' num2str(time_dimension)...
                        ' was specified as an input argument, but CTYPE' num2str(time_dimension) ' = ' str '.']);
                    ctype_time_dimension = TimeInCtypeIdx(1);
                    str = fits_get_val(keys, vals, strcat('CTYPE', num2str(ctype_time_dimension)));
                    disp(['Calculate time axis infomation = ' num2str(ctype_time_dimension)...
                        ' was selected, because CTYPE' num2str(ctype_time_dimension) ' = ' str '.']);
                else
                    ctype_time_dimension = time_dimension;
                end
            else
                ctype_time_dimension = time_dimension;
            end
        else
            % time_dimension is not set by caller.
            if TimeInCtypeIdx ~= 0
                % time is found in CTYPE
                ctype_time_dimension = TimeInCtypeIdx(1);
                str = fits_get_val(keys, vals, strcat('CTYPE', num2str(ctype_time_dimension)));
                disp(['time_dimension = ' num2str(ctype_time_dimension)... 
                    ' was selected, because CTYPE' num2str(ctype_time_dimension) ' = ' str '.']);
            else
                % time is not found in CTYPE
                disp('ERROR: time_dimension was not found.');
                for j=1:NAXIS
                    str = fits_get_val(keys, vals, strcat('CTYPE', num2str(j)));
                    disp(['CTYPE' num2str(j) ' = ' str]);
                end
                return;
            end
        end
        
        % disp info of time dimension related.
        disp(['time_dimension of CTYPE = ' num2str(ctype_time_dimension) ' was selected.']);
        str = fits_get_val(keys, vals, strcat('CTYPE', num2str(ctype_time_dimension)));
        disp(['CTYPE info = ' str]);
        S = size(data_tmp);
        disp(['time_dimension of data = ' num2str(time_dimension) ' was selected.']);
        disp('Read data num:');
        for k=1:length(S)
            disp(['Dim(' num2str(k) '): ' num2str(S(k))]);
        end
        
        
        % Calculate time axis
        idx_StartTime   = [find(strcmp(keys, 'DATE-OBS')), find(strcmp(keys, 'TIME-OBS'))];
        StartTime       = [vals{idx_StartTime(1)} ' ' vals{idx_StartTime(2)}];
        StartTime       = datetime(StartTime, 'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSS');
        
        time_flag = true;
        add_time        = calc_dimj(keys, vals, ctype_time_dimension, time_flag);    % Serial datenum
        time_tmp        = datenum(StartTime) + add_time;
        
        % Calculate other axis
        dimj_tmp = [];
        %cnt = 1;
        for j=1:NAXIS
            if j ~= ctype_time_dimension
                dimj_tmp{j} = calc_dimj(keys, vals, j);
                %cnt = cnt + 1;
            else
                dimj_tmp{j} = time_tmp;
            end
        end
        
        % Set val
        data{i} = data_tmp;
        info{i} = info_tmp;
        time{i} = time_tmp;
        dimj    = [dimj; dimj_tmp];
    end
else
    disp('No file is set. Need at least 1 file to read.');
    return;
end

% Set the info anyway in case of error happened.
info1 = info{1};
info1.Format = 'fits';
info_ret = info1;

% Connect time dependent variables
data1_ret = data{1};
time_ret = time{1};
dimj_ret = dimj(1,:);
if nfile > 1
    for i=2:nfile
        tmp_data = data{i};
        data1_ret = cat(time_dimension, data1_ret, tmp_data);
        time_ret = cat(1, time_ret, time{i});
        dimj_ret{1, ctype_time_dimension} = cat(1, dimj_ret{1, ctype_time_dimension}, dimj{i, ctype_time_dimension});
    end
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

% time_data is time variable
% For ASCII file, all the variables are time dependent.
%[sy, sx] = size(data1_ret);
ind = (time_ret >= st) & (time_ret <= ed);

try
%for i=1:sx
    % data demension is up to 2-d?
    tmp_data = data1_ret;
    [tmp, perm, nshifts] = shiftdata(tmp_data, time_dimension);
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
    data1_ret = tmp_data;
%end
catch 
    disp('ERROR: inconsistency between data num of selected time_dimension and ctype info.');
    return;
end

time_ret = time_ret(ind);
dimj_ret{1,ctype_time_dimension} = dimj_ret{1,ctype_time_dimension}(ind);

% Make return value
data_ret.data1 = data1_ret;
data_ret.time = time_ret;
data_ret.dimj = dimj_ret;
info1 = info{1};
info1.Format = 'fits';
info_ret = info1;

end


function dimj_tmp = calc_dimj(keys, vals, i, time_flag)

if nargin < 4
    time_flag = false;
end

CRVALi      = fits_get_val(keys, vals, strcat('CRVAL', num2str(i)));
NAXISi      = fits_get_val(keys, vals, strcat('NAXIS', num2str(i)));
CRPIXi      = fits_get_val(keys, vals, strcat('CRPIX', num2str(i)));
CDELTi      = fits_get_val(keys, vals, strcat('CDELT', num2str(i)));
if time_flag
    % Calclate time. CDELTi seems to be seconds.
    dimj_tmp    = CRVALi + ([0:NAXISi-1]'-CRPIXi)*CDELTi * (seconds(1)/days(1));
else
    dimj_tmp    = CRVALi + ([0:NAXISi-1]'-CRPIXi)*CDELTi;
end
end

function val = fits_get_val(keys, vals, key)
idx  = strcmp(keys, key);
val  = vals{idx};
end
