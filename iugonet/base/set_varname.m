function    set_varname(info, data, prefix)
%
% set_varname(info, data, prefix)
%
% Return variables to the caller function from info and data. 
% 
% (Input arguments)
%   info:     Metadata obtained by load_cdf or load_netcdf
%   data:     Data obtained by load_cdf or load_netcdf
%   prefix:   Prefix for the return variables
%
% (Return)
%   automatically-named variables with the prefix and 
%   variable name from info.
%
% Written by Y.-M. Tanaka, April 30, 2020
%

if nargin < 3
    error('Lack of input arguments!');
end

% Check format
type  = [];
if isfield(info, 'Format')
    switch lower(info.Format)
        case 'cdf'
            type = 'cdf';
        otherwise
            type = 'netcdf';
    end
else
    disp('ERROR: Invalid info.');
    return;
end

switch type
    case 'cdf'
        % Case: CDF
        nvar = size(info.Variables, 1);
        for i=1:nvar
            % Variable Name
            var_name = info.Variables{i,1};
            eval(['assignin(''caller'', ''', prefix, var_name, ''', ', 'data{i});']);
        end

    case 'netcdf'
        % Case: NetCDF
        nvar = length({info.Variables.Name});
        for i=1:nvar
            % Variable Name
            var_name = info.Variables(i).Name;
            eval(['assignin(''caller'', ''', prefix, var_name, ''', ', 'data{i});']);
        end
    otherwise
        error(['Such file format is not supported! :', lower(info.Format)]); 
end


