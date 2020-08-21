function   tstr=file_dailynames(startTime, endTime, tformat, res_unit)
%
% tstr=file_dailynames(startTime, endTime, tformat, res_unit)
%
% Display a character array on the console with 
% appropreate returns. 
% 
% (Input arguments)
%   startTime:     Start time (datetime or char or datenum)
%   endTime:       End time (datetime or char or datenum)
%   tformat:       format of time string (ex., 'YYYY', 'MM', 'DD')
%   res_unit:      'day' or 'hour'
%
% (Output arguments)
%   tstr:          a cell array of time string
%
% (Examples)
%   tstr=file_dailynames('2017-1-1', '2017-1-2', 'YYYYMMDD');
%
% Written by Y.-M. Tanaka, April 30, 2020
%

if nargin < 4, res_unit='day'; end
if nargin < 3, error('Lack of input arguments!'); end

[syr, smon, sday, shr, smin, ssec]=datevec([startTime]);
[eyr, emon, eday, ehr, emin, esec]=datevec([endTime]);

switch res_unit
    case 'day'
        res=1;
        nvec=datenum(eyr, emon, eday)-datenum(syr, smon, sday);
        if datenum(eyr, emon, eday, ehr, emin, esec)-datenum(eyr, emon, eday) > 0,
            nvec=nvec+1;
        end
        [YYYY, MM, DD, hh, mm, ss]=datevec(datenum(syr, smon, sday)+res*[0:nvec-1]);

    case 'hour'
        res=1/24;
        nvec=datenum(eyr, emon, eday, ehr, 0, 0)*24-datenum(syr, smon, sday, shr, 0, 0)*24;
        if datenum(eyr, emon, eday, ehr, emin, esec)-datenum(eyr, emon, eday, ehr, 0, 0) > 0,
            nvec=nvec+1;
        end
        [YYYY, MM, DD, hh, mm, ss]=datevec(datenum(syr, smon, sday, shr, 0, 0)+res*[0:nvec-1]);

    case 'minute'
        res=1/1440;
        nvec=datenum(eyr, emon, eday, ehr, emin, 0)*1440-datenum(syr, smon, sday, shr, smin, 0)*1440;
        if datenum(eyr, emon, eday, ehr, emin, esec)-datenum(eyr, emon, eday, ehr, emin, 0) > 0,
            nvec=nvec+1;
        end
        [YYYY, MM, DD, hh, mm, ss]=datevec(datenum(syr, smon, sday, shr, smin, 0)+res*[0:nvec-1]);

    otherwise
        error('Such a res_unit is now allowed!');
end 

switch tformat
    case 'YYYY'
        tstr=num2str(YYYY', '%04d');    
    case 'MM'
        tstr=num2str(MM', '%02d');
    case 'DD'
        tstr=num2str(DD', '%02d');
    case 'hh'
        tstr=num2str(hh', '%02d');
    case 'mm'
        tstr=num2str(mm', '%02d'); 
    case 'yy'
        YYYY=num2str(YYYY', '%04d');  
        tstr=YYYY(:, 3:4);
    case 'YYYYMM'
        tstr=strcat(num2str(YYYY', '%04d'), num2str(MM', '%02d'));
    case 'yyMM'
        YYYY=num2str(YYYY', '%04d');
        tstr=strcat(YYYY(:, 3:4), num2str(MM', '%02d'));
    case 'YYYYMMDD'
        tstr=strcat(num2str(YYYY', '%04d'), num2str(MM', '%02d'), num2str(DD', '%02d'));
    case 'yyMMDD'
        YYYY=num2str(YYYY', '%04d');
        tstr=strcat(YYYY(:, 3:4), num2str(MM', '%02d'), num2str(DD', '%02d'));
    case 'YYYYMMDDhh'
        tstr=strcat(num2str(YYYY', '%04d'), num2str(MM', '%02d'), num2str(DD', '%02d'), num2str(hh', '%02d'));
    case 'yyMMDDhh'
        YYYY=num2str(YYYY', '%04d');
        tstr=strcat(YYYY(:, 3:4), num2str(MM', '%02d'), num2str(DD', '%02d'), num2str(hh', '%02d'));
    otherwise
        tstr='';
end    

tstr=cellstr(tstr);

