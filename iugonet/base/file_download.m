function   outfiles = file_download(urls, varargin) 
%
% outfiles = file_download(urls, rootpath, files, username, password)
%
% Download files. 
%
% (argument)
%   urls:               cell char array or string array of URLs
%   rootpath (option):  root path of save folders
%   files (option) :    file names of save files
%   username (option):  username (char) for https
%   password (option):  password (char) for https
%
% (return value)
%   outfiles:           information of saved data (cell char array)
%
% (Example)
%   urls = {'http://iugonet0.nipr.ac.jp/data/aaa_20180101_v02.cdf',...
%           'http://iugonet0.nipr.ac.jp/data/aaa_20180102_v02.cdf',...
%           'http://iugonet0.nipr.ac.jp/data/aaa_20180103_v02.cdf'};
%   files = {'/home/iugonet/data/aaa_20180101_v02.cdf',...
%            '/home/iugonet/data/aaa_20180102_v02.cdf',...
%            '/home/iugonet/data/aaa_20180103_v02.cdf');
%   outfiles = file_download(urls, 'files', files);
%

% Set input arguments
p = inputParser;

validUrls = @(x) ischar(x) || iscell(x);
addRequired(p, 'urls', validUrls);

validRootPath = @(x) ischar(x);
addParameter(p, 'rootpath', '', validRootPath);
validFiles = @(x) ischar(x) || iscell(x);
addParameter(p, 'files', '', validFiles);
validUserName = @(x) ischar(x);
addParameter(p, 'username', '', validUserName);
validPassWord = @(x) ischar(x);
addParameter(p, 'password', '', validPassWord);

parse(p, urls, varargin{:});

urls = p.Results.urls;
rootpath = p.Results.rootpath;
files = p.Results.files;
username = p.Results.username;
password = p.Results.password;

% Set rootpath default
if isempty(rootpath)
    if ispc
        rootpath = 'C:/data/';
    else
        rootpath = '~/data/';
    end
end

% Check number of urls and files
[a,b] = size(urls);
if a>b
    n_urls = a;
else
    n_urls = b;
end
%n_urls = size(urls, 1);
if ~isempty(files)
    [a,b] = size(files);
    if a>b
        n_files = a;
    else
        n_files = b;
    end
    %n_files = size(files, 1);
    if n_urls ~= n_files
        error('Not the same number between urls and files.');
    end
end

% Clear return value
outfiles = cell(n_urls,1);

for i=1:n_urls
    % Set URL
    % url_tmp = get_char_string_argument(urls, i, 'urls');
    url_tmp = cellstr(urls);
    url_tmp = url_tmp{i};
 
    % Check connection of URL
%    J = java.net.URL(url_tmp);
%    conn = openConnection(J);
%    status = getResponseCode(conn);

%    if status == 200
        % URL page responeded
        % Create save folder
        if isempty(files)
            % Create save folder from
            ipos = strfind(url_tmp, '/');
            ipos = ipos(end);
            %[Sys Lab]
            if contains(url_tmp, 'http://')
                filepath = url_tmp(8:ipos-1);
            else
                filepath = url_tmp(9:ipos-1);
            end
            save_dir = fullfile(rootpath, filepath);
            %local_tmp = fullfile(rootpath, url_tmp(8:ipos-1));
            local_tmp = fullfile(rootpath, url_tmp(8:length(url_tmp)));
        else
            % Create save folder from files
            % files_tmp = get_char_string_argument(files, i, 'files');
            files_tmp = cellstr(files);
            files_tmp = files_tmp{i};
            [filepath,~,~] = fileparts(files_tmp);
            save_dir = fullfile(rootpath, filepath);
            local_tmp = fullfile(rootpath, files_tmp);
        end
        
        % Create forlder for save data
        if exist(save_dir, 'dir') ~= 7
            mkdir(save_dir);
        end

        % Download data
        disp(['Data Downloading ... ', url_tmp]);
        
        if isempty(username) || isempty(password)
            try
                outfile_tmp = websave(local_tmp, url_tmp);
                disp(['Data Saving ... ', local_tmp]);
            catch ME
                outfile_tmp = [];
                disp('ERROR: File not found or data was not able to be saved.');
                disp(ME.message);
            end
        else
            try
                % Set username and password
                options = weboptions('Username', username, 'Password', password);
                outfile_tmp = websave(local_tmp, url_tmp, options);
                disp(['Data Saving ... ', local_tmp]);
            catch ME
                outfile_tmp = [];
                disp('ERROR: File not found or authorization failed or data was not able to be saved.');
                disp(ME.message);
            end
        end

        %%%%% Added by Tanaka %%%%%
        htmlfile=dir([save_dir, '/*.html']);
        if ~isempty(htmlfile),
            eval(['delete ', save_dir, '/*.html;']);
        end

        outfiles{i} = char(outfile_tmp);
%    end
end


