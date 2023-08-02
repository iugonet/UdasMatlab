function [file_url_ret, file_relpath_ret, file_local_ret] =...
    make_filelist_wildcard(url, relpath, startTime, endTime,...
    site, datatype, parameter, version_list, rootpath)
%
% [file_url2, file_relpath2, file_local2] =...
%    make_filelist_wildcard(url_ref, relpath, startTime, endTime, site, datatype, parameter, version_list, rootpath)
%
% Find downloadable url files with using wild cards, and return url lists. 
%
% (argument)
%   url:          a character array of URL which includes reserved words
%   relpath:      folder of local saved files
%   startTime:    Start time (datetime or char or datenum)
%   endTime:      End time (datetime or char or datenum)
%   site:         a character array of site to be replaced with SITE
%   datatype:     a character array of datatype to be replaced with DATATYPE
%   parameter:    a character array of parameter to be replaced with PARAMETER
%   version_list: a cell array of version to be replaced with VERSION
%   rootpath:     root path for saved files
%
% (return value)
%   file_url_ret:       a cell array of URLs
%   file_relpath_ret:   a cell array of folder of local saved files
%   file_local_ret:     a cell array of path of local files 
%

% Initialization of return values.
file_url_ret = {};     % List of url
file_relpath_ret = {}; % List of relpath
file_local_ret = {};   % List of local

% Make file url. (Using wild cards are acceptable.)
file_url = replace_string(url, startTime, endTime, site, datatype, parameter, version_list); 
file_relpath = replace_string(relpath, startTime, endTime, site, datatype, parameter, version_list);

% Cell index of return value.
idx = 1;

prev_folder_url = [];

for ifile = 1:length(file_url)

    % Search directory path in URL.
    [folder_url, file_name] = get_folder_path(file_url{ifile});

    if ~strcmp(folder_url, prev_folder_url)
        % Get file lists of URL directory.
        try
            string_folder = webread(folder_url);    % Get html file of URL page.
            prev_folder_url = folder_url;
        catch
            continue
        end
    end

    % Search the file name (with wild cards) in the file list of the URL
    % page.
    pattern_with_sharp = regexptranslate('wildcard', file_name);

    % Whether pick up largest number or not (using '#' as wild card)
    flag_pickup_largest = false;
    if ~isempty(strfind(pattern_with_sharp, '#'))   % Before R2016b doesn't have contains().
        pattern2 = regexprep(pattern_with_sharp, '#', '.');
        flag_pickup_largest = true;
    else
        pattern2 = pattern_with_sharp;
    end

    % Search hit file list.
    string_folder = strrep(string_folder, '<', ' ');
    string_folder = strrep(string_folder, '>', ' ');
    tmphit = regexp(strsplit(string_folder), pattern2, 'match');
    tmphit2 = tmphit(~cellfun(@isempty, tmphit));
    file_hit_list = unique([tmphit2{:}]);

    if isempty(file_hit_list)
        continue;
    end

    if flag_pickup_largest
        % Hit list contains files of several versions.
        file_hit_list = find_largest_version(file_hit_list, pattern_with_sharp);
    end
    
    % Set folder of relpath.
    folder_relpath = get_folder_path(file_relpath{ifile});

    % Make return lists.
    for i = 1:length(file_hit_list)
        file_url2 = [folder_url, file_hit_list{i}]; 
        file_relpath2 = [folder_relpath, file_hit_list{i}]; 
        file_local2 = [rootpath, file_relpath2];

        file_url_ret{idx} = file_url2; 
        file_relpath_ret{idx} = file_relpath2;
        file_local_ret{idx} = file_local2;

        idx = idx + 1;
    end
end
