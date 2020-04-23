function   [st, et] = set_timespan(startTime, num, res_unit)

% startTime='2010/1/2 3:10:20';
% endTime='2010/1/3 5:40:50';
% tformat='YYYYMMDDhh';
% res_unit='hour'

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

end    
