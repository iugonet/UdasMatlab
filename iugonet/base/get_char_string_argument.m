function ret_val = get_char_string_argument(urls, i, name)
% ret_val = get_char_string_argument(urls, i, name)
% Get the char array from cell of char array or string array

if isstring(urls)
    ret_val = char(urls(i));
elseif iscell(urls)
    if ischar(urls{i})
        ret_val = char(urls{i});
    else
        error(['Invalid input type of ' name '.']);
    end
elseif ischar(urls)
    ret_val = urls;
else
    error(['Invalid input type of ' name '.']);
end
