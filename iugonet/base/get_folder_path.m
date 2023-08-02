function [folder_url, file_name] = get_folder_path(file_url)
% Get folder path from url.

tmp = strsplit(file_url, '/');
file_name = tmp{end};
folder_url = file_url(1:end - length(file_name));