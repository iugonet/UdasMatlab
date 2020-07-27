function   iug_load_mf_rish(startTime, endTime, varargin)
%
% iug_load_mf_rish(startTime, endTime, varargin)
% 
% (Input arguments)
%   startTime:          Start time (datetime or char or datenum)
%   endTime:            End time (datetime or char or datenum)
% (Options)
%   site:               Site name (ex., 'pam' or {'pam', 'pon'})
%   downloadonly:       0: Load data after download, 1: Download only
%   no_download:        0: Download files, 1: No download before loading data
%
% (Returns)
%   all:                a cell array that includes all data
%   info:               Metadata
%   time:               a serial date number
%   range:              Range (km)
%   uwind:              Zonal wind velocity (m/s)
%   vwind:              Meridional wind velocity (m/s)
%   wwind:              Vertical wind velocity (m/s)
%
% (Examples)
%   iug_load_mf_rish('2010-02-12', '2010-3-12', 'site', 'pam');
%   iug_load_mf_rish('2010-02-12', '2010-3-12', 'site', {'pam', 'pon'});
%
% Written by Y.-M. Tanaka, April 30, 2020
%

%********************************%
%***** Step1: Set paramters *****%
%********************************%
file_format = 'netcdf';
prefix='iug_mf_';
site_list = {'pam', 'pon'};
datatype_list = {''};
parameter_list = {''};
acknowledgement = sprintf(['\n',...
    '****************************************************************\n',...
    'Acknowledgement\n',...
    '****************************************************************\n',...
    'Note: If you would like to use following data for scientific purpose,\n',...
    'please read and follow the DATA USE POLICY\n',...
    '(http://database.rish.kyoto-u.ac.jp/arch/iugonet/data_policy/Data_Use_Policy_e.html\n',...
    'The distribution of MF radar data has been partly supported by the IUGONET\n',...
    '(Inter-university Upper atmosphere Global Observation NETwork) project\n',...
    '(http://www.iugonet.org/) funded by the Ministry of Education, Culture, Sports, Science\n',...
    'and Technology (MEXT), Japan.\n',...
    ' ']);
rootpath = default_rootpath;

%*************************************%
%***** Step2: Set default values *****%
%*************************************%
site_def = 'pam';
datatype_def = '';
parameter_def = '';
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

%===== Loop for site, datatype, and parameter =====%
%----- Loop for site -----%
for ist=1:length(st_vec)
    st=st_vec{ist};
    st=check_valid_name(st, site_list);
    disp(st);
    if isempty(st)
        varname_st=prefix;
    else
        varname_st=[prefix, st];
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
            %%%%% Added below %%%%%
            switch st
                case 'pam'
                    st1='pameungpeuk';
                    url='http://database.rish.kyoto-u.ac.jp/arch/iugonet/data/mf/SITE/nc/ver1_0_1/YYYY/YYYYMMDD_pam.nc';
                    relpath='iugonet/rish/mf/SITE/nc/ver1_0_1/YYYY/YYYYMMDD_pam.nc';
                    time_format='yyyy-MM-dd HH:mm:ss';
                case 'pon'
                    st1='pontianak';
                    url='http://database.rish.kyoto-u.ac.jp/arch/iugonet/data/mf/SITE/nc/YYYY/YYYYMMDD_fca.nc';
                    relpath='iugonet/rish/mf/SITE/nc/YYYY/YYYYMMDD_fca.nc';
                    time_format='yyyy-MM-dd HH:mm:ss Z';
            end
            %%%%%%%%%%%%%%%%%%%%%%%

            file_url = replace_string(url, startTime, endTime, st1, dt, pr);
            file_relpath = replace_string(relpath, startTime, endTime, st1, dt, pr);
            file_local = replace_string([rootpath, relpath], startTime, endTime, st1, dt, pr);

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
                    otherwise
                        error('Such a file_format is not allowed in this version.');
                end

                if ~isempty(data)
                    varname_base=[varname_st_dt_pr, '_'];
                    set_varname(info, data, '');

                    switch st
                        case 'pam'
                            eval(['rng = range*0.001;']);
                            uwind = squeeze(uwind);
                            vwind = squeeze(vwind);
                            wwind = squeeze(wwind);
                        case 'pon'
                            rng = height;
                            uwind = uwind';
                            vwind = vwind';
                            wwind = wwind';
                    end

                    eval(['assignin(''base'', ''', varname_base, 'all'', ', 'data);']);
                    eval(['assignin(''base'', ''', varname_base, 'info'', ', 'info);']);
                    eval(['assignin(''base'', ''', varname_base, 'time'', ', 'time);']);
                    eval(['assignin(''base'', ''', varname_base, 'range'', ', 'rng);']);
                    eval(['assignin(''base'', ''', varname_base, 'uwind'', ', 'uwind);']);
                    eval(['assignin(''base'', ''', varname_base, 'vwind'', ', 'vwind);']);
                    eval(['assignin(''base'', ''', varname_base, 'wwind'', ', 'wwind);']);
                    clear data info;
                end
            end
        end
    end
end

%===== Display acknowledgement =====%
disp(acknowledgement);

