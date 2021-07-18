function tbl = readtable_str(tmp_file_data, header_lines, delimiter)
% read data from str buffer and return table.
% replace from tmpfile output and readtable procedure.

Num = length(tmp_file_data);
st = 1;

if header_lines > 0
    st = header_lines + 1;
end

dat = [];
for i=st:Num
    tline = tmp_file_data{i};
    C = strsplit(tline, delimiter);
    nCol = length(C);
    tmpdat = reshape(C, 1, nCol);
    dat = [dat;tmpdat];
end

try
    dat2 = str2double(dat);
    tbl = array2table(dat2);
catch ME
    disp('ERROR: Data file may contain not numerical data or variable length of columns');
    rethrow(ME);
end



