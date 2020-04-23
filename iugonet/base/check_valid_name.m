 function   names_out = check_valid_name(names_in, valid_names)
%
%
%
% valid_names={'aaa', 'bbb', 'ccc'};
% names_in='aaa';


%===== Keyword check =====%
if nargin < 2, error('Lack of input argument!'); end

ni=lower(cellstr(names_in));
vn=lower(cellstr(valid_names));

if length(ni) > 1, error('The number of names_in must be one.'); end

names_out='';

%----- check names_in -----%
idx=strcmp(ni, vn);
if sum(idx) > 0,
    names_out=names_in;
else
    disp('Valid names are as follows:');
    disp(valid_names); 
    error('Such name is not allowed! : %s', names_in);
end

