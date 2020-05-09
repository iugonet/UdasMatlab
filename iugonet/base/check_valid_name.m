 function   names_out = check_valid_name(names_in, valid_names)
%
% names_out = check_valid_name(names_in, valid_names)
%
% Compare names_in with valid_names to check if it is valid.
%
% (Input arguments)
%   names_in:      a character array  (ex., 'aaa')
%   valid_names:   a cell array (ex., {'aaa', 'bbb', 'ccc'})
%
% (Output arguments)
%   names_out:     Valid:names_in, Not valide:''
%
% Written by Y.-M. Tanaka, April 30, 2020
%

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

