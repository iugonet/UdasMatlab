function [data_new, time_datenum_new, time_datetime_new] = load_ascii_format2(data, time_datenum, time_datetime)

data_new = [];
time_datenum_new = [];
time_datetime_new = [];

nfile = length(time_datenum);

for i=1:nfile
    % Pick up the same time data.
    % (Caution!) time data will be sorted.
    [unique_time, ia,ic] = unique(time_datenum{i});
    data_tmp = data(i,:);
    [~, sx] = size(data_tmp);
    % Separate data per unique time
    unique_time_num = length(unique_time);
    for j=1:unique_time_num
        for k=1:sx
            data_tmp{j,k} = data{i,k}(ic==j,:);
        end
    end
    % Connect data into matrix
    data_tmp_new = data_tmp(1,:);
    for k=1:sx
        max_row = 0;
        tmprow = zeros(unique_time_num,1);
        for j=1:unique_time_num
            [tmprow(j), ~] = size(data_tmp{j,k});
            if tmprow(j) > max_row
                max_row = tmprow(j);
            end
        end
        ydata_k = NaN(unique_time_num, max_row);
        for j=1:unique_time_num
            data_tmp0 = data_tmp{j,k};
            ydata_k(j, 1:tmprow(j)) = data_tmp0(:);
        end
        data_tmp_new{1,k} = ydata_k;
    end

    %data_new{i,1} = data_tmp_new;
    data_new = [data_new; data_tmp_new];
    time_datenum_new{i} = unique_time;
    time_datetime_new{i} = time_datetime{i}(ia);
end
    
end