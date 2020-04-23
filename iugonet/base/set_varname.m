function    set_varname(info, data, prefix)
% disp_info(info, opt)
%
% Display information.
%
% (argument)
%   info:               Saved metadata infomation.
%   opt (option):       opt = 'global': show global attributes.
%
% (return value)
%
% (Example)
% disp_info(info);
% disp_info(info, 'global');    % Show global info
% disp_info(info, 'lat');       % Show specific variable in metadata
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


