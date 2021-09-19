function   iug_load_blr_rish(startTime, endTime, varargin)
%
% iug_load_blr_rish(startTime, endTime, varargin)
% 
% (Input arguments)
%   startTime:          Start time (datetime or char or datenum)
%   endTime:            End time (datetime or char or datenum)
% (Options)
%   site:               Site name (ex., 'ktb' or {'ktb', 'sgk', 'srp'})
%   parameter:          Parameter (ex., 'uwnd' or {'uwnd', 'vwnd', 'wwnd', 
%                           'pwr1', 'pwr2', 'pwr3', 'pwr4', 'pwr5', 
%                           'wdt1', 'wdt2', 'wdt3', 'wdt4', 'wdt5'})
%   downloadonly:       0: Load data after download, 1: Download only
%   no_download:        0: Download files, 1: No download before loading data
%
% (Returns)
%   all:                a cell array that includes all data
%   info:               Metadata
%   time:               a serial date number
%   alt:                Altitude (km)
%   uwnd:               Zonal wind velocity (m/s)
%   vwnd:               Meridional wind velocity (m/s)
%   wwnd:               Vertical wind velocity (m/s)
%
% (Examples)
%   iug_load_blr_rish('2007-8-1', '2007-8-6', 'site', 'ktb');
%   iug_load_blr_rish('2007-8-1', '2007-8-6', 'site', 'ktb', 'parameter', {'uwnd','vwnd','wwnd'});
% 
% Written by Y.-M. Tanaka, April 30, 2020
% Modified by Y.-M. Tanaka, July 27, 2020
%

%********************************%
%***** Step1: Set parameters *****%
%********************************%
file_format = 'ascii'; % 'cdf' or 'netcdf'
url='http://www.rish.kyoto-u.ac.jp/radar-group/blr/SITE/data/data/ver02.0212/YYYYMM/YYYYMMDD/YYYYMMDD.PARAMETER.csv'
prefix = 'iug_blr';
site_list = {'ktb', 'sgk', 'srp'}; % ex. {'sta1', 'sta2', 'sta3'}
datatype_list = {''}; % ex. {'1sec', '1min', '1hr'}
parameter_list = {'uwnd', 'vwnd', 'wwnd', 'pwr1', 'pwr2', 'pwr3', 'pwr4',...
    'pwr5', 'wdt1', 'wdt2', 'wdt3', 'wdt4', 'wdt5'}; % ex. {'par1', 'par2', 'par3'}
version_list = {''}; % ex. {'01', '02', '03'}
acknowledgement = sprintf(['If you acquire the boundary layer radar (BLR) data, \n',...
    'we ask that you acknowledge us in your use of the data. This may be done by \n',...
    'including text such as the BLR data provided by Research Institute \n',...
    'for Sustainable Humanosphere of Kyoto University. We would also \n',...
    'appreciate receiving a copy of the relevant publications. The distribution of \n',...
    'BLR data has been partly supported by the IUGONET (Inter-university Upper \n',...
    'atmosphere Global Observation NETwork) project (http://www.iugonet.org/) funded \n',...
    'by the Ministry of Education, Culture, Sports, Science and Technology (MEXT), Japan.']);
rootpath = default_rootpath;

%----- Set parameters for ascii files -----%
format_type = 3;
% time_column = 1;   % for test
time_column = [1,2,3,4,5];
% time_format = 'yyyy/MM/dd HH:mm';  % for test
time_format = {'yyyy', 'MM', 'dd', 'HH', 'mm'};
input_time = [-1, -1, -1, -1, -1, 0];
%input_time = [2013, 1, 1, -1, -1, -1]; % input_time should be made from startTime and endTime.
%localtime = 9;
delimiter = {'/', ' ', ':', ','};
% [SysLab]
data_start = 2;
comment_symbol = '';
no_convert_time = 0;
header_only = 0;

%*************************************%
%***** Step2: Set default values *****%
%*************************************%
site_def = 'all';
datatype_def = '';
parameter_def = 'all';
version_def = version_list;
downloadonly_def = 0;
no_download_def = 0;
username_def = '';
password_def = '';
%time_format='yyyy-MM-dd HH:mm:ss Z'; % Time format string for NetCDF

%===== Set input arguments =====%
p = inputParser;

%----- Required input arguments -----%
validTime = @(x) isdatetime(x) || ischar(x) || isscalar(x);
addRequired(p, 'startTime', validTime);
addRequired(p, 'endTime', validTime);

%----- Input arguments as parameters -----%
validSite = @(x) iscell(x) || ischar(x);
addParameter(p, 'site', site_def, validSite);
validDataType = @(x) iscell(x) || ischar(x);
addParameter(p, 'datatype', datatype_def, validDataType);
validParameters = @(x) iscell(x) || ischar(x);
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

%===== Set local directory for saving data files =====%
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
    
    switch st
        case 'ktb'
            st1 = 'kototabang';
            localtime = 7;
        case 'sgk'
            st1 = 'shigaraki';
            localtime = 9;
        case 'srp'
            st1 = 'serpong';
            localtime = 7;
        otherwise
            error('Such site name is not supported!');
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
            relpath='iugonet/rish/misc/SITE/blr/csv/YYYYMM/YYYYMMDD/YYYYMMDD.PARAMETER.csv';
            
            file_url = replace_string(url, startTime, endTime, st1, dt, pr, vs);
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
                        [data, info]=load_netcdf(startTime, endTime, files, 'time_format', time_format);
                    case 'ascii'
                        [data, info]=load_ascii(startTime, endTime, files,...
							'format_type', format_type, 'time_column', time_column,...
							'time_format', time_format, 'input_time', input_time,...
							'localtime', localtime, 'delimiter', delimiter,...
							'data_start',  data_start, 'comment_symbol', comment_symbol,...
							'no_convert_time', no_convert_time, 'header_only', header_only);
                    otherwise
                        error('Such a file_format is not allowed in this version.');
                end

                if ~isempty(data)
                    varname_base=[varname_st_dt_pr];
                    time = data{1};
                    dat_pr = [data{2}(:, 6:end)]';
                    alt=str2num(info.Text{1})';
                    eval(['assignin(''base'', ''', varname_base, '_all'', ', 'data);']);
                    eval(['assignin(''base'', ''', varname_base, '_info'', ', 'info);']);
                    eval(['assignin(''base'', ''', varname_base, '_time'', ', 'time);']);
                    eval(['assignin(''base'', ''', varname_base, '_alt'', ', 'alt);']);
                    eval(['assignin(''base'', ''', varname_base, ''', ', 'dat_pr);']);
                    clear data info;
                end
            end
        end
    end
end

%===== Display acknowledgement =====%
disp(acknowledgement);

