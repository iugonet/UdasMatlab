function url_ret = replace_string(url, startTime, endTime,...
    site, datatype, parameter, version_list)
%
% url = 'https://ergsc.isee.nagoya-u.ac.jp/data/ergsc/ground/geomag/magdas/DATATYPE/SITE/YYYY/magdas_DATATYPE_SITE_YYYYMMDD_v0VERSION.cdf';
% site='ath';
% startTime='2010-03-01';
% endTime='2010-03-05';
% datatype='1sec';
% parameter='';
% version_list={'1','2','3'};

if nargin < 3,
    error('Need a char, startTime, and endTime as input arguments.');
end
if nargin < 4, site=''; end
if nargin < 5, datatype=''; end
if nargin < 6, parameter=''; end
if nargin < 7, version_list=''; end
 
%----- Make date & time string array -----%
ipos=strfind(url, 'hh');
if length(ipos) >  0, 
    res_unit='hour';
else
    res_unit='day';
end

YYYY = file_dailynames(startTime, endTime, 'YYYY', res_unit);
yy = file_dailynames(startTime, endTime, 'yy', res_unit);
MM = file_dailynames(startTime, endTime, 'MM', res_unit);
DD = file_dailynames(startTime, endTime, 'DD', res_unit);
hh = file_dailynames(startTime, endTime, 'hh', res_unit);

%----- Replace strings -----%
url_tmp=strrep(string(url), 'SITE', site);
url_tmp=strrep(url_tmp, 'DATATYPE', datatype);
url_tmp=strrep(url_tmp, 'PARAMETER', parameter);
url_tmp=strrep(url_tmp, 'YYYY', string(YYYY));
url_tmp=strrep(url_tmp, 'MM', string(MM));
url_tmp=strrep(url_tmp, 'DD', string(DD));
url_tmp=strrep(url_tmp, 'hh', string(hh));

%----- Replace version number -----%
vl=version_list;
[m, n]=size(version_list);
if n > m, vl=version_list'; end

str=url_tmp(1);
url_ret=strrep(str, 'VERSION', vl);
if length(url_tmp) > 1
    for i=2:length(url_tmp)
        str=url_tmp(i);
        strvec=strrep(str, 'VERSION', vl);
        url_ret=cat(1, url_ret, strvec);
    end
end
url_ret=cellstr(url_ret);

end

