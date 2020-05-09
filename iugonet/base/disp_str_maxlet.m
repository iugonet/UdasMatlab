function   disp_str_maxlet(str, maxlet)
%
% disp_str_maxlet(str, maxlet)
%
% Display a character array on the console with appropreate returns. 
% 
% (Input arguments)
%   str:      a character array (ex., 'This is an example.')
%   maxlet:   maximum number of characters per line (ex., 100)
%
% Written by Y.-M. Tanaka, April 30, 2020
%

if nargin < 2, maxlet=80; end
if nargin < 1, error('Lack of input arguments!'); end

str = char(str);

remstr=str;
remstrlen=length(remstr);

while remstrlen > maxlet
    line1=remstr(1:maxlet);

    %--- Find space ---%
    ispace=findstr(line1, ' ');
    if isempty(ispace)
        line1=line1(1:maxlet);
        remstr=remstr(maxlet+1:end);
    else
        line1=line1(1:ispace(end));
        remstr=remstr(ispace(end)+1:end);
    end
    disp(line1);
    remstrlen=length(remstr);
end

disp(remstr);

%end
