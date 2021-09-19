function   iug_load_irio_nipr(startTime, endTime, varargin)
%
% iug_load_irio_nipr(startTime, endTime, varargin)
% 
% (Input arguments)
%   startTime:          Start time (datetime or char or datenum)
%   endTime:            End time (datetime or char or datenum)
% (Options)
%   site:               Site name (ex., 'syo' or {'syo', 'tjo', 'hus'})
%   datatype:           Observation frequency (MHz) (ex., '30' or {'30', '38'}, 
%                           where 38 means 38.2MHz.)
%   version:            Version number (ex., '1')
%   downloadonly:       0: Load data after download, 1: Download only
%   no_download:        0: Download files, 1: No download before loading data
%
% (Returns)
%   all:                a cell array that includes all data
%   info:               Metadata
%   time_1sec:          a serial date number at 1sec resolution
%   time_1min:          a serial date number at 1min resolution
%   cna:                cosmic noise absorption (CNA) (dB) at 1sec resolution
%   qdc:                quiet day curve (QDC) at 1min resolution
%   glat:               geographic latitude (degree) for each beam
%   glon:               geographic longutude (degree) for each beam
%   ze:                 zenith angle (degree) for each beam
%   az:                 azimuth angle (degree) for each beam
%
% (Examples)
%   iug_load_irio_nipr('2017-1-1', '2017-1-2', 'site', 'syo');
%   iug_load_irio_nipr('2017-1-1', '2017-1-2', 'site', {'syo','hus'});
% 

%********************************%
%***** Step1: Set paramters *****%
%********************************%
file_format = 'cdf';
url = 'http://iugonet0.nipr.ac.jp/data/irio/SITE/YYYY/nipr_h0_irioDATATYPE_SITE_YYYYMMDD_vVERSION.cdf';
prefix='nipr_irio';
site_list = {'syo', 'hus', 'tjo'};
datatype_list = {'30', '38'};
parameter_list = {''};
version_list = {'01', '02', '03'}; % possible version number list
% acknowledgement = sprintf(['You can write the data use policy here.\n',...
%    'This description is displayed when you use this load procedure.']);
rootpath = default_rootpath;

%*************************************%
%***** Step2: Set default values *****%
%*************************************%
site_def = 'syo';
datatype_def = 'all';
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
            relpath = 'iugonet/nipr/irio/SITE/YYYY/nipr_h0_irioDATATYPE_SITE_YYYYMMDD_vVERSION.cdf';
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
                    disp(['Information about ', info.GlobalAttributes.Station_code{1}]);
                    disp(' ');
                    disp(['PI: ', info.GlobalAttributes.PI_name{1}]);
                    disp(' ');
                    disp('Affiliations:');
                    disp_str_maxlet(info.GlobalAttributes.PI_affiliation{1});
                    disp(' ');
                    disp('Rules of the Road for Imaging Riometer Data:');
                    for i=1:length(info.GlobalAttributes.TEXT)
                        disp_str_maxlet(info.GlobalAttributes.TEXT{i});
                    end
                    disp(' ');
                    disp([info.GlobalAttributes.LINK_TEXT{1}, ' ', info.GlobalAttributes.HTTP_LINK{1}]);
                    disp('**************************************************************************************');
                    disp(' ');
                end

                if ~isempty(data)
                    varname_base = [varname_st_dt_pr, '_'];
                    set_varname(info, data, '');

                    eval(['assignin(''base'', ''', varname_base, 'all'', ', 'data);']);
                    eval(['assignin(''base'', ''', varname_base, 'info'', ', 'info);']);
                    eval(['assignin(''base'', ''', varname_base, 'time_1sec'', ', 'epoch_1sec);']);
                    eval(['assignin(''base'', ''', varname_base, 'time_1min'', ', 'epoch_1min);']);
                    eval(['assignin(''base'', ''', varname_base, 'cna'', ',  'cna);']);
                    eval(['assignin(''base'', ''', varname_base, 'qdc'', ',  'qdc);']);
                    eval(['assignin(''base'', ''', varname_base, 'az'', ',  'azimuth_angle);']);
                    eval(['assignin(''base'', ''', varname_base, 'ze'', ',  'zenith_angle);']);
                    eval(['assignin(''base'', ''', varname_base, 'glat'', ',  'glat_beam);']);
                    eval(['assignin(''base'', ''', varname_base, 'glon'', ',  'glon_beam);']);
                    clear data info;
                end
            end
        end
    end
end

%===== Display acknowledgement =====%
% disp(acknowledgement);

