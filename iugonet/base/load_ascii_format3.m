function [data_new, time_datenum_new, time_datetime_new] = load_ascii_format3(data, time_datenum, time_datetime)

data_new = [];
time_datenum_new = [];
time_datetime_new = [];

nfile = length(time_datenum);

for i=1:nfile
    data_tmp = data(i,:);
    ydata = cell2mat(data_tmp);
    data_new{i,1} = ydata;
end
    
time_datenum_new = time_datenum;
time_datetime_new = time_datetime;

end