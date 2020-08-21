function   [st, et] = set_timespan(startTime, num, res_unit)
%
% [st, et] = set_timespan(startTime, num, res_unit)
%
% Get startTime and endTime in serial date number from startTime 
% and number of days (or years, months, hours,...) from the startTime. 
% 
% (Input arguments)
%   startTime:     Start time (datetime or char or datenum)
%   num:           Number of days (depend on res_unit)
%   res_unit:      'year' or 'month' or 'day' or 'hour' or 'minute' or 'second'
%
% (Output arguments)
%   st:            Start time (datenum)
%   et:            End time (datenum)
%
% (Examples)
%   [st, et] = set_timespan('2017-1-1 10:00', 5, 'hour');
%
% Written by Y.-M. Tanaka, April 30, 2020
%

if nargin < 3, res_unit='day'; end
if nargin < 2, error('Lack of input arguments!'); end

if isa(startTime, 'datetime')
    st = datenum(startTime);
elseif ischar(startTime)
    st = datenum(datetime(startTime));
elseif isnumeric(startTime)
    st = startTime;
else
    error('Error on startTime. Please check it.');
end

[syr, smon, sday, shr, smin, ssec]=datevec(st);

switch res_unit
    case 'year'
        et=datenum(syr + num, smon, sday, shr, smin, ssec);
    case 'month'
        et=datenum(syr, smon + num, sday, shr, smin, ssec);
    case 'day'
        et=datenum(syr, smon, sday + num, shr, smin, ssec);
    case 'hour'
        et=datenum(syr, smon, sday, shr + num, smin, ssec);
    case 'minute'
        et=datenum(syr, smon, sday, shr, smin + num, ssec);
    case 'second'
        et=datenum(syr, smon, sday, shr, smin, ssec + second);
    otherwise
        error('Such a res_unit is now allowed!');
end 
