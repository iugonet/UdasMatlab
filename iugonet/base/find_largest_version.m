function file_hit_list = find_largest_version(file_hit_list, reg_pattern)
% Pick up largest version in matched file lists.

% Locate the position of #.
ind_sharp = strfind(reg_pattern, '#');
if length(ind_sharp) > 2
    error('# can contain only one separate part.');
elseif length(ind_sharp) == 1
        ind_sharp(2) = ind_sharp(1);
end
len_sharp = ind_sharp(2) - ind_sharp(1) + 1;

% Set the regular expression pattern to separate #.
if ind_sharp(1) > 1
    pattern2 = ['(' reg_pattern(1:ind_sharp(1)-1) ')(' ...
        repmat('.', [1,len_sharp]) ')(' reg_pattern(ind_sharp(2)+1:end) ')'];
else
    error('# cannot put the beginning of the file name.');
end

% find matched file list.
keep_file = [];
idx_kp = 1;
while ~isempty(file_hit_list)
    ind_hit = ones(1,length(file_hit_list));

    % The letters other than # letters may contains seveal candidates.
    % E.g. file_hit_list =  {'foo_v01.cdf', 'foo_v02.cdf', 'fog_v01.cdf'}
    %      and reg_pattern = 'fo._v##\.cdf'
    %      the result will be {'foo_v02.cdf', 'fog_v01.cdf'}
    %
    tokens = regexp(file_hit_list{1}, pattern2, 'tokens');
    if isempty(tokens)
        error('All file_hit_list must contain pattern.');
    end
    tokens = tokens{1};

    % Pattern for separating #.
    pattern3 = [regexptranslate('escape', tokens{1}) '(' repmat('.', [1,len_sharp]) ...
        ')' regexptranslate('escape', tokens{3})];

    % find same version list.
    same_version_list = [];
    idx_svl = 1;
    for i=1:length(file_hit_list)
        tmpfile = regexp(file_hit_list{i}, pattern3, 'match');
        if isempty(tmpfile)
            continue;
        else
            same_version_list{idx_svl} = tmpfile{1};
            idx_svl = idx_svl + 1;
            ind_hit(i) = 0;
        end
    end

    % search largest version.
    candidate_file = [];
    v = -inf;
    for i=1:length(same_version_list)
        tmpfile2 = same_version_list{i};
        tmptokens = regexp(tmpfile2, pattern3, 'tokens');
        v2 = str2double(tmptokens{1});
        if v2 > v
            candidate_file = tmpfile2;
            v = v2;
        end
    end

    % Set the result.
    keep_file{idx_kp} = candidate_file;
    idx_kp = idx_kp + 1;

    % delete files from hit_file_list
    file_hit_list = file_hit_list(find(ind_hit));
end

% replace file_hit_list
file_hit_list = keep_file;

