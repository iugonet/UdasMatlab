function   iug_load_ear(startTime, endTime, varargin)
%
% iug_load_ear(startTime, endTime, varargin)
% 
% (Input arguments)
%   startTime:          Start time (datetime or char or datenum)
%   endTime:            End time (datetime or char or datenum)
%   site:               Site name (ex., 'asb' or {'asb', 'ama', 'kuj'})
%   datatype:           Data type (ex., '1sec' or {'1sec', '1min', '1hr'})
%   parameter:          Parameter (ex., 'par1' or {'par1', 'par2', 'par3'})
%   downloadonly:       0: Load data after download, 1: Download only
%   no_download:        0: Download files, 1: No download before loading data
%   username:           Username (for https)
%   password:           Password (for https)
%
% (Output arguments)
%   data:               Loaded data in cell array
%   info:               Loaded metadata in struct array
%                       You can see the metadata by "disp_info(info)"
%
% (Examples)
%   [data, info]=template_loadfun('2017-1-1', '2017-1-2', 'site', 'asb');
%   template_loadfun('2017-1-1', '2017-1-2', 'site', {'asb','kuj'}, 'fixed_varname', 1);
% 

%********************************%
%***** Step1: Set paramters *****%
%********************************%
site_list = {''};
datatype_list = {'troposphere', 'e_region', 'ef_region', 'v_region', 'f_region'};
version_list = {''}; % possible version number list
file_format = 'netcdf';
rootpath = default_rootpath;
acknowledgement = sprintf(['\n',...
    '****************************************************************\n',...
    'Acknowledgement\n',...
    '****************************************************************\n',...
    'The Equatorial Atmosphere Radar belongs to Research Institute for \n',...
    'Sustainable Humanosphere (RISH), Kyoto University and is operated by \n',...
    'RISH and National Institute of Aeronautics and Space (LAPAN) Indonesia. \n',...
    'Distribution of the data has been partly supported by the IUGONET \n',...
    '(Inter-university Upper atmosphere Global Observation NETwork) project \n',...
    '(http://www.iugonet.org/) funded by the Ministry of Education, Culture, \n',...
    'Sports, Science and Technology (MEXT), Japan.']);
prefix='iug_ear';

%*************************************%
%***** Step2: Set default values *****%
%*************************************%
site_def = '';
datatype_def = 'e_region';
version_def = version_list;
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

%%%%% Added below %%%%%
switch datatype
    case 'troposphere'
        parameter_list = {''};
    case 'e_region'
        parameter_list = {'eb1p2a', 'eb1p2b', 'eb1p2c', 'eb2p1a', 'eb3p2a', 'eb3p2b', 'eb3p4a',...
             'eb3p4b', 'eb3p4c', 'eb3p4d', 'eb3p4e', 'eb3p4f', 'eb3p4g', 'eb3p4h',...
             'eb4p2c', 'eb4p2d', 'eb4p4',  'eb4p4a', 'eb4p4b', 'eb4p4d', 'eb5p4a'};
    case 'ef_region'
        parameter_list = {'efb1p16', 'efb1p16a', 'efb1p16b'};
    case 'v_region'
        parameter_list = {'vb3p4a', '150p8c8a', '150p8c8b', '150p8c8c',...
             '150p8c8d', '150p8c8e', '150p8c8b2a', '150p8c8b2b',...
             '150p8c8b2c', '150p8c8b2d', '150p8c8b2e', '150p8c8b2f'};
    case 'f_region'
        parameter_list = {'fb1p16a', 'fb1p16b', 'fb1p16c', 'fb1p16d', 'fb1p16e', 'fb1p16f',...
             'fb1p16g', 'fb1p16h', 'fb1p16i', 'fb1p16j1', 'fb1p16j2', 'fb1p16j3',...
             'fb1p16j4', 'fb1p16j5', 'fb1p16j6', 'fb1p16j7', 'fb1p16j8', 'fb1p16j9',...
             'fb1p16j10', 'fb1p16j11', 'fb1p16k1', 'fb1p16k2', 'fb1p16k3', 'fb1p16k4',...
             'fb1p16k5', 'fb1p16m2', 'fb1p16m3', 'fb1p16m4', 'fb8p16', 'fb8p16k1',...
             'fb8p16k2', 'fb8p16k3', 'fb8p16k4', 'fb8p16m1', 'fb8p16m2'};
end
%%%%%%%%%%%%%%%%%%%%%%%

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
            %%%%% Added below %%%%%
            time_format='yyyy-MM-dd HH:mm:ss Z';
            if strcmp(dt, 'troposphere')
                    url='http://www.rish.kyoto-u.ac.jp/ear/data/data/ver02.0212/YYYYMM/YYYYMMDD/YYYYMMDD.nc';
                    relpath='iugonet/rish/misc/ktb/ear/fai/DATATYPE/nc/YYYYMMDD.nc';
            else
                    url='http://www.rish.kyoto-u.ac.jp/ear/data-fai/data/nc/YYYY/YYYYMMDD/YYYYMMDD.faiPARAMETER.nc';
                    relpath='iugonet/rish/misc/ktb/ear/fai/DATATYPE/nc/YYYYMMDD.faiPARAMETER.nc';
            end
            %%%%%%%%%%%%%%%%%%%%%%%

            file_url = replace_string(url, startTime, endTime, st, dt, pr, vs);
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
                    otherwise
                        error('Such a file_format is not allowed in this version.');
                end

                if ~isempty(data)
                    varname_base=[varname_st_dt_pr, '_'];
                    set_varname(info, data, '');

%                     if strcmp(dt, 'troposphere')
%                         varname_base=[prefix, 'trop_'];
%                         time = [data{10}]';
%                         range = double(data{6});
%                         beam=data{5};
%                         pn=double(data{29});
%                         pwr=double(data{23});
%                         nbeam=length(beam);
% 
%                     else
%                         varname_base=[prefix, 'fai', pr, '_'];
% 
%                         time = [data{16}]';
%                         range = double(data{12});
%                         beam=data{11};
%                         pn=double(data{21});
%                         pwr=double(data{18});
%                         nfft=double(data{8});
%                         nbeam=length(beam);
%                         for ibm=1:nbeam
%                             alt = double(data{17}(:,ibm));
%                             pn=[double(data{21}(:, ibm))]';
%                             pn_mat=pn(ones(size(alt)), :); 
%                             if nbeam == 1
%                                 pwr = double(data{18});
%                                 wdt = double(data{19});
%                                 dpl = double(data{20});
%                                 snr=pwr-(pn_mat+log10(nfft));
%                             else
%                                 pwr = squeeze(double(data{18}(:, :, ibm)));
%                                 wdt = squeeze(double(data{19}(:, :, ibm)));
%                                 dpl = squeeze(double(data{20}(:, :, ibm)));
%                                 snr=pwr-(pn_mat+log10(nfft));
%                             end
%                       
%                             eval(['assignin(''base'', ''', varname_base, 'alt_', num2str(beam(ibm)+1), ''', alt);']);
%                             eval(['assignin(''base'', ''', varname_base, 'pwr_', num2str(beam(ibm)+1), ''', pwr);']);
%                             eval(['assignin(''base'', ''', varname_base, 'wdt_', num2str(beam(ibm)+1), ''', wdt);']);
%                             eval(['assignin(''base'', ''', varname_base, 'dpl_', num2str(beam(ibm)+1), ''', dpl);']);
%                             eval(['assignin(''base'', ''', varname_base, 'snr_', num2str(beam(ibm)+1), ''', snr);']);
%                             eval(['assignin(''base'', ''', varname_base, 'pn_', num2str(beam(ibm)+1), ''', pn);']);
%                         end 
%                     end
%                     eval(['assignin(''base'', ''', varname_base, 'time'', ', 'time);']);
%                     eval(['assignin(''base'', ''', varname_base, 'range'', ', 'range);']);
                    eval(['assignin(''base'', ''', varname_base, 'all'', ', 'data);']);
                    eval(['assignin(''base'', ''', varname_base, 'info'', ', 'info);']);

                    clear data info;
                end
            end
        end
    end
end

%===== Display acknowledgement =====%
disp(acknowledgement);

