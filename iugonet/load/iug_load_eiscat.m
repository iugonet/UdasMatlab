function   iug_load_eiscat(startTime, endTime, varargin)
%
% iug_load_eiscat(startTime, endTime, varargin)
% 
% (Input arguments)
%   startTime:          Start time (datetime or char or datenum)
%   endTime:            End time (datetime or char or datenum)
% (Options)
%   site:               Site name (ex., 'tro' or {'tro', 'esr'})
%   antenna:            Antenna type (ex., 'uhf' or {'vhf', '32m', '42m'})
%   version:            Version number (ex., '1')
%   downloadonly:       0: Load data after download, 1: Download only
%   no_download:        0: Download files, 1: No download before loading data
%
% (Returns)
%   all:                a cell array that includes all data
%   info:               Metadata
%   time:               a serial date number
%   alt:                Altitude (km)
%   range:              Range (km)
%   Ne:                 Electron density (m^-3)
%   Ne_err:             Error of electron density (m^-3)
%   Te:                 Electron temperature (K)
%   Te_err:             Error of electron temperature (K)
%   Ti:                 Ion temperature (K)
%   Ti_err:             Error of ion temperature (K)
%   Vi:                 Ion velocity (m/s)
%   Vi_err:             Error of ion velocity (m/s)
%
% (Examples)
%   iug_load_eiscat('2017-1-1', '2017-1-2', 'site', 'asb');
%   iug_load_eiscat('2017-1-1', '2017-1-2', 'site', {'asb','kuj'});
% 
% Written by Y.-M. Tanaka, April 30, 2020
% 

%********************************%
%***** Step1: Set paramters *****%
%********************************%
site_list = {'tro', 'esr', 'kir', 'sod'};
% datatype_list = {'uhf', 'vhf', '32m', '42m'};
parameter_list = {''};
version_list = {'03'}; % possible version number list
file_format = 'cdf';
url = 'http://pc115.seg20.nipr.ac.jp/www/eiscatdata/cdf/basic/SITE/DATATYPE/YYYY/eiscat_kn_SITE_DATATYPE_YYYYMMDD_vVERSION.cdf';
rootpath = default_rootpath;
acknowledgement = sprintf(['']);
prefix='eiscat_';

%*************************************%
%***** Step2: Set default values *****%
%*************************************%
site_def = 'tro';
datatype_def = 'uhf';
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
addParameter(p, 'antenna', datatype_def, validDataType);
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
datatype     = p.Results.antenna;
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
dt_vec_org=cellstr(datatype);
pr_vec=cellstr(parameter);
if strcmp(lower(st_vec{1}),'all') || strcmp(st_vec{1},'*')
    st_vec=site_list;
end
% if strcmp(lower(dt_vec{1}),'all') || strcmp(dt_vec{1},'*')
%     dt_vec=datatype_list;
% end
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
        varname_st=[prefix, st];
    end
    
    %%%%% Added below %%%%%
    if (strcmp(st, 'tro') || strcmp(st, 'kir') || strcmp(st, 'sod'))
        datatype_list = {'uhf', 'vhf'};
    else
        datatype_list = {'32m', '42m'};
    end
    if strcmp(lower(dt_vec_org{1}),'all') || strcmp(dt_vec_org{1},'*')
        dt_vec=datatype_list;
    else
        dt_vec=dt_vec_org;
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
            relpath = 'iugonet/nipr/eiscat/SITE/DATATYPE/YYYY/eiscat_kn_SITE_DATATYPE_YYYYMMDD_vVERSION.cdf';
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
                    disp('**************************************************************************************');
                    disp(info.GlobalAttributes.Logical_source_description{1});
                    disp(' ');
                    disp(['Information about EISCAT radar data']);
                    disp(' ');
                    disp(['PI: ', info.GlobalAttributes.PI_name{1}]);
                    disp(' ');
                    disp('Rules of the Road for EISCAT Radar Data:');
                    disp(' ');
                    disp_str_maxlet([info.GlobalAttributes.Rules_of_use{1}]);
                    disp(' ');
                    disp([info.GlobalAttributes.LINK_TEXT{1}, ' ', info.GlobalAttributes.HTTP_LINK{1}]);
                    disp('**************************************************************************************');
                    disp(' ');
                end

                if ~isempty(data)
                    varname_base=[varname_st_dt_pr, '_'];
                    set_varname(info, data, '');

                    alt = alt_0'; 
                    [sy, sx] = size(alt);
                    time = Epoch_0;
                    time = time(:, ones(1, sy))';
                    range = range_0';
                    Ne = ne_0';
                    Ne_err = ne_err_0';
                    Te = te_0';
                    Te_err = te_err_0';
                    Ti = ti_0';
                    Ti_err = ti_err_0';
                    Vi = vi_0';
                    Vi_err = vi_err_0';

                    eval(['assignin(''base'', ''', varname_base, 'all'', ', 'data);']);
                    eval(['assignin(''base'', ''', varname_base, 'info'', ', 'info);']);
                    eval(['assignin(''base'', ''', varname_base, 'time'', ', 'time);']);
                    eval(['assignin(''base'', ''', varname_base, 'alt'', ',  'alt);']);
                    eval(['assignin(''base'', ''', varname_base, 'range'', ', 'range);']);
                    eval(['assignin(''base'', ''', varname_base, 'Ne'', ', 'Ne);']);
                    eval(['assignin(''base'', ''', varname_base, 'Ne_err'', ', 'Ne_err);']);
                    eval(['assignin(''base'', ''', varname_base, 'Te'', ', 'Te);']);
                    eval(['assignin(''base'', ''', varname_base, 'Te_err'', ', 'Te_err);']);
                    eval(['assignin(''base'', ''', varname_base, 'Ti'', ', 'Ti);']);
                    eval(['assignin(''base'', ''', varname_base, 'Ti_err'', ', 'Ti_err);']);
                    eval(['assignin(''base'', ''', varname_base, 'Vi'', ', 'Vi);']);
                    eval(['assignin(''base'', ''', varname_base, 'Vi_err'', ', 'Vi_err);']);
                    clear data info;
                end
            end
        end
    end
end

%===== Display acknowledgement =====%
% disp(acknowledgement);

