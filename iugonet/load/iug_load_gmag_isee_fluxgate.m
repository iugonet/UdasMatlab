function   [data, info]=iug_load_gmag_isee_fluxgate(startTime, endTime, varargin)
%
% [data, info]=iug_load_gmag_isee_fluxgate(startTime, endTime, varargin)
%
% (Input arguments)
%   startTime:          Start time (datetime or char or datenum)
%   endTime:            End time (datetime or char or datenum)
%   site:               Site name (ex., 'msr' or {'msr', 'rik', 'kag'})
%   datatype:           Data type (ex., '1sec')
%   version:            Version number (ex., '1')
%   downloadonly:       0: Load data after download, 1: Download only
%   no_download:        0: Download files, 1: No download before loading data
%   fixed_varname:      0: Return output arguments only
%                       1: Output data as predefined variable names into the
%                       workspace. (ex., 'iug_mag_asb_1sec')
%
% (Output arguments)
%   data:               Loaded data in cell array
%   info:               Loaded metadata in struct array
%                       You can see the metadata by "disp_info(info)".
%
% (Examples)
%   [data, info]=iug_load_gmag_isee_fluxgate('2013-1-1', '2013-1-2', 'site', 'msr');
%   iug_load_gmag_isee_fluxgate('2013-1-1', '2013-1-2', 'site', {'asb','kuj'}, 'fixed_varname', 1);
%

%********************************%
%***** Step1: Set paramters *****%
%********************************%
site_list = {'msr', 'rik', 'kag', 'ktb', 'mdm', 'tew'};
datatype_list = {'1sec', '1min', '1h'};
parameter_list = {''};
version_list = {'1'}; % possible version number list
file_format = 'cdf';
url = 'https://ergsc.isee.nagoya-u.ac.jp/data/ergsc/ground/geomag/isee/fluxgate/DATATYPE/SITE/YYYY/isee_fluxgate_DATATYPE_SITE_YYYYMMDD_v0VERSION.cdf';
rootpath = default_rootpath;
% acknowledgement = sprintf(['You can write the data use policy here.\n',...
%     'This description is displayed when you use this load procedure.']);
prefix='isee_fluxgate_mag_';

%*************************************%
%***** Step2: Set default values *****%
%*************************************%
site_def = 'msr';
datatype_def = 'all';
parameter_def = '';
version_def = version_list;
downloadonly_def = 0;
no_download_def = 0;
username_def = '';
password_def = '';
fixed_varname_def = 0;

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
validFixed_Varname = @(x) isscalar(x);
addParameter(p, 'fixed_varname', fixed_varname_def, validFixed_Varname);

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
fixed_varname     = p.Results.fixed_varname;

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
if (length(st_vec)>1 || length(dt_vec)>1 || length(pr_vec)>1) && fixed_varname==0
    error('Please set fixed_varname=1, if you input vectors of parameters.');
end
vs=cellstr(version);

%%%%% Added below %%%%%
idx=find(strcmp(dt_vec, '1s'));
if ~isempty(idx), dt_vec{idx}='1sec'; end
idx=find(strcmp(dt_vec, '1m'));
if ~isempty(idx), dt_vec{idx}='1min'; end
idx=find(strcmp(dt_vec, '1hr'));
if ~isempty(idx), dt_vec{idx}='1h'; end

dt_vec_org=dt_vec;
idx_1h=find(strcmp(dt_vec, '1h'), 1);
if ~isempty(idx_1h) 
    dt_vec{idx_1h}='1min';
    dt_vec=unique(dt_vec);
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
            file_url = replace_string(url, startTime, endTime, st, dt, pr, vs);
            relpath='ergsc/ground/geomag/isee/fluxgate/DATATYPE/SITE/YYYY/isee_fluxgate_DATATYPE_SITE_YYYYMMDD_v0VERSION.cdf';
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
                    disp(['PI and Host PI(s): ', info.GlobalAttributes.PI_name{1}]);
                    piaff=strsplit(info.GlobalAttributes.PI_affiliation{1}, '\([1-9]\)',...
                        'DelimiterType','RegularExpression');
                    disp('Affiliations:');
                    for i=1:length(piaff)
                        disp_str_maxlet(piaff{i});
                    end
                    disp(' ');
                    disp('Rules of the Road for ISEE Fluxgate Magnetometer Data Use:');
                    for i=1:length(info.GlobalAttributes.TEXT)
                        disp_str_maxlet(info.GlobalAttributes.TEXT{i});
                    end
                    disp(' ');
                    disp([info.GlobalAttributes.LINK_TEXT{1}, ' ', info.GlobalAttributes.HTTP_LINK{1}]);
                    disp('**************************************************************************************');
                    disp(' ');
                end

                if fixed_varname==1 && ~isempty(data)
                    varname_base = [prefix, st, '_'];
                    set_varname(info, data, '');

                    eval(['assignin(''base'', ''', varname_base, 'info'', ', 'info);']);
                    switch dt
                        case '1sec'
                            eval(['assignin(''base'', ''', varname_base, '1sec_time'', ', 'epoch_1sec);']);
                            eval(['assignin(''base'', ''', varname_base, '1sec_hdz'', ',  'hdz_1sec);']);
                            eval(['assignin(''base'', ''', varname_base, '1sec_f'', ', 'f_1sec);']);
                        case '1min'
                            if ~isempty(find(strcmp(dt_vec_org, '1min'), 1))
                                eval(['assignin(''base'', ''', varname_base, '1min_time'', ', 'epoch_1min);']);
                                eval(['assignin(''base'', ''', varname_base, '1min_hdz'', ',  'hdz_1min);']);
                                eval(['assignin(''base'', ''', varname_base, '1min_f'', ', 'f_1min);']);
                            end
                            if ~isempty(find(strcmp(dt_vec_org, '1h'), 1))
                                eval(['assignin(''base'', ''', varname_base, '1h_time'', ', 'epoch_1h);']);
                                eval(['assignin(''base'', ''', varname_base, '1h_hdz'', ',  'hdz_1h);']);
                                eval(['assignin(''base'', ''', varname_base, '1h_f'', ', 'f_1h);']);
                            end
                        otherwise
                            error('Such datatype is not allowed!');
                    end

                    clear data info;
                end
            end
        end
    end
end

%===== Display acknowledgement =====%
% disp(acknowledgement);

