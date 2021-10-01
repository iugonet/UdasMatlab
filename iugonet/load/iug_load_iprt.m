function   iug_load_iprt(startTime, endTime, varargin)
%
% iug_load_iprt(startTime, endTime, varargin)
% 
% (Input arguments)
%   startTime:          Start time (datetime or char or datenum)
%   endTime:            End time (datetime or char or datenum)
% (Options)
%   datatype:           Data type (ex., 'Sun' or {'Sun', 'Jupiter'})
%   downloadonly:       0:Load data after download, 1:Download only
%   no_download:        0:Download files, 1:No download before loading data
%
% (Returns)
%   all:                a cell array that includes all data
%   info:               Metadata
%   time:               a serial date number
%   freq:               Frequency (Hz)
%   R:                  Power flux density in right-handed circular polarization
%   L:                  Power flux density in left-handed circular polarization
%
% (Examples)
%   iug_load_iprt('2010-11-1 00:00', '2010-11-1 00:10', 'datatype', 'sun');
% 
% Written by Y.-M. Tanaka, April 30, 2020
% Modified by Y.-M. Tanaka, July 27, 2020
%

%********************************%
%***** Step1: Set parameters *****%
%********************************%
file_format = 'fits'; % 'cdf' or 'netcdf'
url = 'http://radio.gp.tohoku.ac.jp/db/IPRT-SUN/DATA2/YYYY/YYYYMMDD_IPRT.fits';
prefix = 'iprt';
site_list = {''}; % ex. {'sta1', 'sta2', 'sta3'}
datatype_list = {'Sun', 'Jupiter'}; % ex. {'1sec', '1min', '1hr'}
parameter_list = {''}; % ex. {'par1', 'par2', 'par3'}
version_list = {''}; % ex. {'01', '02', '03'}
acknowledgement = sprintf(['\n',...
    '********************************************************************************* \n',...
    'We would like to present the following two guidelines.\n',...
    'The 1st one concerns what we would like you to do when you use the data.\n',...
    '1. Tell us what you are working on.\n',...
    'This is partly because to protect potential Ph.D. thesis projects.\n',...
    'Also, if your project coincides with one that team members are working on,\n',...
    'that can lead to a fruitful collaboration. The 2nd one concerns what you do \n',...
    'when you make any presentations and publications using the data.\n',...
    '2. Co-authorship:\n',...
    'When the data forms an important part of your work, we would like you to \n',...
    'offer us co-authorship.\n',...
    '3. Acknowledgements:\n',...
    'All presentations and publications should carry the following sentence:\n',...
    ' "IPRT(Iitate Planetary Radio Telescope) is a Japanese radio telescope \n',...
    'developed and operated by Tohoku University." \n',...
    '4. Entry to publication list:\n',...
    'When your publication is accepted, or when you make a presentation at a \n',...
    'conference on your result, please let us know by sending email to PI. \n',...
    'Contact person & PI: Dr. Hiroaki Misawa (misawa@pparc.gp.tohoku.ac.jp) \n',...
    '********************************************************************************* \n']);
rootpath = default_rootpath;

%----- Set parameters for ascii files -----%
% [SysLab]
%time_dimension = 1;
time_dimension = 2;

%*************************************%
%***** Step2: Set default values *****%
%*************************************%
site_def = '';
datatype_def = 'Sun';
parameter_def = '';
version_def = version_list;
downloadonly_def = 0;
no_download_def = 0;
username_def = '';
password_def = '';
time_format='yyyy-MM-dd HH:mm:ss Z'; % Time format string for NetCDF

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
            relpath = 'iugonet/tohokuU/iit/YYYY/YYYYMMDD_IPRT.fits';
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
                    case 'fits'
                        [data, info]=load_fits(startTime, endTime, files, 'time_dimension', time_dimension);
                    otherwise
                        error('Such a file_format is not allowed in this version.');
                end

                if ~isempty(data)
                    varname_base=[varname_st_dt_pr, '_'];
                    time = data.time;
                    freq = data.dimj{2};
                    LCP = squeeze(data.data1(:,:,1));
                    RCP = squeeze(data.data1(:,:,2));
                    eval(['assignin(''base'', ''', varname_base, 'all'', ', 'data);']);
                    eval(['assignin(''base'', ''', varname_base, 'info'', ', 'info);']);
                    eval(['assignin(''base'', ''', varname_base, 'time'', ', 'time);']);
                    eval(['assignin(''base'', ''', varname_base, 'freq'', ', 'freq);']);
                    eval(['assignin(''base'', ''', varname_base, 'L'', ', 'LCP);']);
                    eval(['assignin(''base'', ''', varname_base, 'R'', ', 'RCP);']);
                    clear data info;
                end
            end
        end
    end
end

%===== Display acknowledgement =====%
disp(acknowledgement);

