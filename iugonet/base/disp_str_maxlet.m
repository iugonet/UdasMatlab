function   disp_str_maxlet(str, maxlet)
%
% Display a string or char. 
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
