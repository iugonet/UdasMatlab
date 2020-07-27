function   iug_load_meteor_rish(startTime, endTime, varargin)
%
% iug_load_meteor_rish(startTime, endTime, varargin)
% 
% (Input arguments)
%   startTime:          Start time (datetime or char or datenum)
%   endTime:            End time (datetime or char or datenum)
% (Options)
%   site:               Site name (ex., 'sgk' or {'bik', 'ktb', 'srp'})
%   parameter:          Parameter (ex., 'h2t60min00' or {'h2t60min00', 'h2t60min30'})
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
%   sig_uwind:          Standard deviation of zonal wind velocity (m/s)
%   sig_vwind:          Standard deviation of meridional wind velocity (m/s)
%
% (Examples)
%   iug_load_meteor_rish('2011-10-01', '2011-11-01', 'site', 'bik', 'parameter', 'h2t60min00');
%   iug_load_meteor_rish('2011-10-01', '2011-11-01', 'site', {'bik', 'ktb'});
%
% Written by Y.-M. Tanaka, April 30, 2020
%

%********************************%
%***** Step1: Set paramters *****%
%********************************%
file_format = 'netcdf';
prefix='iug_meteor_';
site_list = {'bik', 'ktb', 'sgk', 'srp'};
datatype_list = {''};
parameter_list = {'h2t60min00', 'h2t60min30', 'h4t60min00', 'h4t60min30', 'h4t240min00'};
acknowledgement = sprintf(['\n',...
    '****************************************************************\n',...
    'Acknowledgement\n',...
    '****************************************************************\n',...
    'If you acquire meteor wind radar data, we ask that you acknowledge us in your use \n',...
    'of the data. This may be done by including text such as meteor wind radar data \n',...
    'provided by Research Institute for Sustainable Humanosphere of Kyoto University. \n',...
    'We would also appreciate receiving a copy of the relevant publications. The \n',...
    'distribution of meteor wind radar data has been partly supported by the IUGONET \n',...
    '(Inter-university Upper atmosphere Global Observation NETwork) project\n',...
    '(http://www.iugonet.org/) funded by the Ministry of Education, Culture, Sports, Science.\n',...
    ' ']);
rootpath = default_rootpath;

%*************************************%
%***** Step2: Set default values *****%
%*************************************%
site_def = 'sgk';
datatype_def = '';
parameter_def = 'all';
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
            dt1=[pr(1:2), 'km_', pr(3:end)];
            time_format='yyyy-MM-dd HH:mm:ss Z';
            switch st
                case 'sgk'
                    url='http://database.rish.kyoto-u.ac.jp/arch/mudb/data/mwr/nc/ver1_0/DATATYPE/YYYY/WsYYYYMMDD.PARAMETER.nc';
                    relpath='iugonet/rish/misc/sgk/meteor/nc/ver1_0/DATATYPE/YYYY/WsYYYYMMDD.PARAMETER.nc';
                case 'bik'
                    url='http://database.rish.kyoto-u.ac.jp/arch/iugonet/data/mwr/biak/nc/ver1_0/DATATYPE/YYYY/WbYYYYMMDD.PARAMETER.nc';
                    relpath='iugonet/rish/misc/bik/meteor/nc/ver1_0/DATATYPE/YYYY/WbYYYYMMDD.PARAMETER';
                case 'ktb'
                    url='http://database.rish.kyoto-u.ac.jp/arch/iugonet/data/mwr/kototabang/nc/ver1_1_2/DATATYPE/YYYY/WkYYYYMMDD.PARAMETER.nc';
                    relpath='iugonet/rish/misc/ktb/meteor/nc/ver1_1_2/DATATYPE/YYYY/WkYYYYMMDD.PARAMETER';
                case 'srp'
                    url='http://database.rish.kyoto-u.ac.jp/arch/iugonet/data/mwr/serpong/nc/ver1_0_2/DATATYPE/YYYY/jktYYYYMMDD.PARAMETER.nc';
                    relpath='iugonet/rish/misc/srp/meteor/nc/ver1_0_2/DATATYPE/YYYY/jktYYYYMMDD.PARAMETER';
                otherwise 
                    error('Such site name is not supported!');
            end
            %%%%%%%%%%%%%%%%%%%%%%%

            file_url = replace_string(url, startTime, endTime, st, dt1, pr);
            file_relpath = replace_string(relpath, startTime, endTime, st, dt1, pr);
            file_local = replace_string([rootpath, relpath], startTime, endTime, st, dt1, pr);

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

                    eval(['rng = range*0.001;']);
                    uwind = squeeze(uwind);
                    vwind = squeeze(vwind);
                    sig_uwind = squeeze(sig_uwind);
                    sig_vwind = squeeze(sig_vwind);

                    eval(['assignin(''base'', ''', varname_base, 'all'', ', 'data);']);
                    eval(['assignin(''base'', ''', varname_base, 'info'', ', 'info);']);
                    eval(['assignin(''base'', ''', varname_base, 'time'', ', 'time);']);
                    eval(['assignin(''base'', ''', varname_base, 'range'', ', 'rng);']);
                    eval(['assignin(''base'', ''', varname_base, 'uwind'', ', 'uwind);']);
                    eval(['assignin(''base'', ''', varname_base, 'vwind'', ', 'vwind);']);
                    eval(['assignin(''base'', ''', varname_base, 'sig_uwind'', ', 'sig_uwind);']);
                    eval(['assignin(''base'', ''', varname_base, 'sig_vwind'', ', 'sig_vwind);']);
                    clear data info;
                end
            end
        end
    end
end

%===== Display acknowledgement =====%
disp(acknowledgement);

