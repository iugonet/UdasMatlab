function url_ret = replace_string(url, startTime, endTime,...
    site, datatype, parameter, version_list)
%
% url_ret = replace_string(url, startTime, endTime,...
%                  site, datatype, parameter, version_list)
%
% Replace reserved words in the url with strings. 
%
% (argument)
%   url:          a character array of URL which includes reserved words
%   startTime:    Start time (datetime or char or datenum)
%   endTime:      End time (datetime or char or datenum)
%   site:         a character array of site to be replaced with SITE
%   datatype:     a character array of datatype to be replaced with DATATYPE
%   parameter:    a character array of parameter to be replaced with PARAMETER
%   version_list: a cell array of version to be replaced with VERSION
%
% (return value)
%   url_ret:      a cell array of URLs
%
% (Example)
%   url = 'http://iugonet0.nipr.ac.jp/DATATYPE/SITE_YYYYMMDD_v0VERSION.cdf';
%           'http://iugonet0.nipr.ac.jp/data/aaa_20180102_v02.cdf',...
%           'http://iugonet0.nipr.ac.jp/data/aaa_20180103_v02.cdf'};
%   url_ret = replace_string(url, '2017-01-01', '2017-01-02',...
%                            'abc', '1sec', '', {'1','2'})
%
% Written by Y.-M. Tanaka, April 30, 2020
%

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
url_tmp=strrep(cellstr(url), 'SITE', site);
url_tmp=strrep(url_tmp, 'DATATYPE', datatype);
url_tmp=strrep(url_tmp, 'PARAMETER', parameter);
url_tmp=cellstr(repmat(url_tmp, size(YYYY)));
url_tmp=strrep(url_tmp, cellstr(repmat('YYYY', size(YYYY))), YYYY);
url_tmp=strrep(url_tmp, cellstr(repmat('MM', size(MM))), MM);
url_tmp=strrep(url_tmp, cellstr(repmat('DD', size(DD))), DD);
url_tmp=strrep(url_tmp, cellstr(repmat('hh', size(hh))), hh);

%----- Replace version number -----%
vl=cellstr(version_list);
[m, n]=size(version_list);
if n > m, vl=version_list'; end

strvec=cellstr(repmat(url_tmp(1), size(vl)));
url_ret=strrep(strvec, cellstr(repmat('VERSION', size(vl))), vl);
if length(url_tmp) > 1
    for i=2:length(url_tmp)
        strvec=cellstr(repmat(url_tmp(i), size(vl)));
        strvec=strrep(strvec, cellstr(repmat('VERSION', size(vl))), vl);
        url_ret=cat(1, url_ret, strvec);
    end
end
url_ret=cellstr(url_ret);
