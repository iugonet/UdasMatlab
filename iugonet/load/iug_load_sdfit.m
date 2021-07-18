function   iug_load_sdfit(startTime, endTime, varargin)
%
% [data, info]=template_loadfun(startTime, endTime, varargin)
% 
% (Input arguments)
%   startTime:          Start time (datetime or char or datenum)
%   endTime:            End time (datetime or char or datenum)
%   site:               Site name (ex., 'ade' or {'ade', 'adw', 'bks'})
%   parameter:          Parameter (ex., 'par1' or {'par1', 'par2', 'par3'})
%   version:            Version number (ex., '01')
%   downloadonly:       0: Load data after download, 1: Download only
%   no_download:        0: Download files, 1: No download before loading data
%
% (Output arguments)
%   data:               Loaded data in cell array
%   info:               Loaded metadata in struct array
%                       You can see the metadata by "disp_info(info)"
%
% (Examples)
%   iug_load_sdfit('2017-1-1', '2017-1-2', 'site', 'asb');
% 

%********************************%
%***** Step1: Set paramters *****%
%********************************%
file_format = 'cdf';
url = 'https://ergsc.isee.nagoya-u.ac.jp/data/ergsc/ground/radar/sd/fitacf/SITE/YYYY/sd_fitacf_l2_SITE_YYYYMMDD_vVERSION.cdf';
prefix='sd';
site_list = {'ade', 'adw', 'bks', 'bpk', 'cly', 'cve', 'cvw', 'dce', 'fhe',... 
    'fhw', 'fir', 'gbr', 'hal', 'han', 'hok', 'hkw', 'inv', 'kap', 'ker', 'kod',... 
    'ksr', 'mcm', 'pgr', 'pyk', 'rkn', 'san', 'sas', 'sps', 'sto', 'sye',... 
    'sys', 'tig', 'unw', 'wal', 'zho', 'lyr'};
datatype_list = {''};
parameter_list = {''};
version_list = {'01'}; % possible version number list
acknowledgement = sprintf(['You can write the data use policy here.\n',...
    'This description is displayed when you use this load procedure.']);
rootpath = default_rootpath;

%*************************************%
%***** Step2: Set default values *****%
%*************************************%
site_def = 'ade';
datatype_def = '';
parameter_def = '';
version_def = version_list;
downloadonly_def = 0;
no_download_def = 0;
username_def = '';
password_def = '';

%===== Set input arguments =====%
p = inputParser;

%----- Required input arguments -----%
validTime = @(x) isdatetime(x) || ischar(x) || isscalar(x);
addRequired(p, 'startTime', validTime);
addRequired(p, 'endTime', validTime);

%----- Input arguments as parameters -----%
validSite = @(x) iscell(x) || ischar(x) || isstring(x);
addParameter(p, 'site', site_def, validSite);
validDataType = @(x) iscell(x) || ischar(x) || isstring(x);
addParameter(p, 'datatype', datatype_def, validDataType);
validParameters = @(x) iscell(x) || ischar(x) || isstring(x);
addParameter(p, 'parameter', parameter_def, validParameters);
validVersion = @(x) isscalar(x);
addParameter(p, 'version', version_def, validVersion);
validDownloadOnly = @(x) isscalar(x);
addParameter(p, 'downloadonly', downloadonly_def, validDownloadOnly);
validNo_Download = @(x) isscalar(x);
addParameter(p, 'no_download', no_download_def, validNo_Download);
validUserName = @(x) ischar(x);
addParameter(p, 'username', username_def, validUserName);
validPassWord = @(x) ischar(x);
addParameter(p, 'password', password_def, validPassWord);

parse(p, startTime, endTime, varargin{:});
startTime    = p.Results.startTime;
endTime      = p.Results.endTime;
site         = p.Results.site;
datatype     = p.Results.datatype;
parameter    = p.Results.parameter;
version      = p.Results.version;
downloadonly = p.Results.downloadonly;
no_download  = p.Results.no_download;
username     = p.Results.username;
password     = p.Results.password;

%===== Set local dierectory for saving data files =====%
% ipos=strfind(url, '://')+3;
% relpath = url(ipos:end);

%===== Input of 'all'and '*' means all elements =====%
st_vec=cellstr(site); % convert to cell of char
dt_vec=cellstr(datatype);
pr_vec=cellstr(parameter);
if strcmp(lower(st_vec{1}),'all') || strcmp(st_vec{1},'*')
    st_vec=site_list;
end
if strcmp(lower(dt_vec{1}),'all') || strcmp(dt_vec{1},'*')
    dt_vec=datatype_list;
end
if strcmp(lower(pr_vec{1}),'all') || strcmp(pr_vec{1},'*')
    pr_vec=parameter_list;
end
vs=cellstr(version);

%===== Loop for site, datatype, and parameter =====%
%----- Loop for site -----%
for ist=1:length(st_vec)
    st=st_vec{ist};
    st=check_valid_name(st, site_list);
    disp(st);
    if isempty(st)
        varname_st=prefix;
    else
        varname_st=[prefix, '_', st];
    end
    
    %----- Loop for datatype -----%
    for idt=1:length(dt_vec)
        dt=dt_vec{idt}; 
        dt=check_valid_name(dt, datatype_list);
        disp(dt);
        if isempty(dt)
            varname_st_dt=varname_st;
        else
            varname_st_dt=[varname_st, '_', dt];
        end

        %----- Loop for parameter -----%
        for ipr=1:length(pr_vec)
            pr=pr_vec{ipr};
            pr=check_valid_name(pr, parameter_list); 
            disp(pr);
            if isempty(pr)
                varname_st_dt_pr=varname_st_dt;
            else
                varname_st_dt_pr=[varname_st_dt, '_', pr];
            end
            
            %===== Download files =====%
            file_url = replace_string(url, startTime, endTime, st, dt, pr, vs);
            relpath='iugonet/ergsc/ground/radar/sd/fitacf/SITE/YYYY/sd_fitacf_l2_SITE_YYYYMMDD_v01.cdf';
            file_relpath = replace_string(relpath, startTime, endTime, st, dt, pr, vs);
            file_local = replace_string([rootpath, relpath], startTime, endTime, st, dt, pr, vs);
            if no_download==1,
                files = file_local;
            else
                files = file_download(file_url, 'rootpath', rootpath, 'files', file_relpath,...
                          'username', username, 'password', password);
            end
            
            %=====  Load data into variables =====%
            if downloadonly==0,
                switch file_format
                    case 'cdf'
                        [data, info]=load_cdf(startTime, endTime, files);
                    case 'netcdf'
                        [data, info]=load_netcdf(startTime, endTime, files);
                    otherwise
                        error('Such a file_format is not allowed in this version.');
                end

                if ~isempty(info)
                    %===== Display acknowledgement =====%
                    disp(' ');
                    disp('############## RULES OF THE ROAD ################');
                    for i=1:length(info.GlobalAttributes.Rules_of_use)
                        disp_str_maxlet(info.GlobalAttributes.Rules_of_use{i}, 78);
                    end
                    disp('############## RULES OF THE ROAD ################');
                    disp(' ');
                end

                if ~isempty(data)
                    varname_base=[varname_st_dt_pr, '_'];

                    set_varname(info, data, '');

                    eval(['assignin(''base'', ''', varname_base, 'all'', ', 'data);']);
                    eval(['assignin(''base'', ''', varname_base, 'info'', ', 'info);']);


%                    eval([varname_base, 'time = [data{17}]'';']);
%                    eval([varname_base, 'rgate_no_1 = [double(data{15})]'';']);
%                    eval([varname_base, 'pwr_1 = [double(data{22})]'';']);
%                    eval([varname_base, 'pwr_err_1 = [double(data{23})]'';']);
%                    eval([varname_base, 'spec_width_1 = [double(data{24})]'';']);
%                    eval([varname_base, 'spec_width_err_1 = [double(data{25})]'';']);
%                    eval([varname_base, 'vlos_1 = [double(data{22})]'';']);
%                    eval([varname_base, 'vlos_err_1 = [double(data{23})]'';']);
%                    eval([varname_base, 'info = info;']);

%                    eval(['assignin(''base'', ''', varname_base, 'time'', ', varname_base, 'time);']);
%                    eval(['assignin(''base'', ''', varname_base, 'rgate_no_1'', ', varname_base, 'rgate_no_1);']);
%                    eval(['assignin(''base'', ''', varname_base, 'pwr_1'', ', varname_base, 'pwr_1);']);
%                    eval(['assignin(''base'', ''', varname_base, 'pwr_err_1'', ', varname_base, 'pwr_err_1);']);
%                    eval(['assignin(''base'', ''', varname_base, 'spec_width_1'', ', varname_base, 'spec_width_1);']);
%                    eval(['assignin(''base'', ''', varname_base, 'spec_width_err_1'', ', varname_base, 'spec_width_err_1);']);
%                    eval(['assignin(''base'', ''', varname_base, 'vlos_1'', ', varname_base, 'vlos_1);']);
%                    eval(['assignin(''base'', ''', varname_base, 'vlos_err_1'', ', varname_base, 'vlos_err_1);']);
%                    eval(['assignin(''base'', ''', varname_base, 'info'', ', varname_base, 'info);']);
                    clear data info;
                end
            end
        end
    end
end

%===== Display acknowledgement =====%
% disp(acknowledgement);

