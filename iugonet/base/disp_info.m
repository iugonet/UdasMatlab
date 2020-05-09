function disp_info(info, varargin)
%
% disp_info(info, opt)
%
% Display information (metadata).
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

varargin = cell2mat(varargin);
judge = false;
% Check arguments
if nargin < 2, varargin = char([]); end
if nargin < 1
    disp('Need info as argument.');
    return;
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
        switch lower(varargin)
            % Show global attributes
            case 'global'
                disp(' ');
                info.GlobalAttributes
                disp(' ');
            % Show variable metadata
            case []
                for i=1:nvar
                    % Variable Name
                    var_name = info.Variables{i,1};
                    disp([num2str(i) '. ' var_name]);
                    % Metadata
                    va = info.VariableAttributes;
                    fields = fieldnames(va);
                    for j=1:length(fields)
                        fieldvar = va.(fields{j});
                        nfv = size(fieldvar, 1);
                        for k=1:nfv
                            if strcmp(deblank(fieldvar{k,1}), deblank(var_name))
                                % disp attributes
                                disp(['        ' fields{j} ': ' fieldvar{k,2:end}]);
                                break;
                            end
                        end
                    end
                    disp(' ');
                end
            % Show Variable data
            otherwise
                for i=1:nvar
                    % Variable Name
                    if strcmp(info.Variables{i,1}, varargin)
                        var_name = info.Variables{i,1};
                        disp(['VariableName: ' var_name]);
                        % Metadata
                        va = info.VariableAttributes;
                        fields = fieldnames(va);
                        for j=1:length(fields)
                            fieldvar = va.(fields{j});
                            nfv = size(fieldvar, 1);
                            for k=1:nfv
                                if strcmp(deblank(fieldvar{k,1}), deblank(var_name))
                                    % disp attributes
                                    disp(['        ' fields{j} ': ' fieldvar{k,2:end}]);
                                    judge = true;
                                    break;
                                end
                            end
                        end
                        disp(' ');
                    end
                end
                if judge == false
                    disp('Could not find a Variable Name');
                end

        end
        
       
    case 'netcdf'
        % Case: NetCDF
        % Show variable metadata
        nvar = length({info.Variables.Name});
        
        switch lower(varargin)
            % Show global attributes
            case 'global'
                disp(' ');
                for i=1:length(info.Attributes)
                    fprintf('%s: %s\n', info.Attributes(i).Name, info.Attributes(i).Value);
                end
                disp(' ');
            case []
                for i=1:nvar
                    % Variable Name
                    var_name = info.Variables(i).Name;
                    disp([num2str(i) '. ' var_name]);
                    % Metadata
                    va = info.Variables(i).Attributes;
                    fields = {va.Name};
                    fieldvar = {va.Value};
                    for j=1:length(fields)
                        % disp attributes
                        if isnumeric(fieldvar{j})
                            tmp = num2str(fieldvar{j});
                        else
                            tmp = fieldvar{j};
                        end
                        fprintf('        %s: %s\n', fields{j}, tmp);
                    end
                    disp(' ');
                end
            otherwise
                for i=1:nvar
                    % Variable Name
                    if strcmp(info.Variables(i).Name, varargin)
                        judge = true;
                        var_name = info.Variables(i).Name;
                        disp(['VarialbeName: ' var_name]);
                        % Metadata
                        va = info.Variables(i).Attributes;
                        fields = {va.Name};
                        fieldvar = {va.Value};
                        for j=1:length(fields)
                            % disp attributes
                            if isnumeric(fieldvar{j})
                                tmp = num2str(fieldvar{j});
                            else
                                tmp = fieldvar{j};
                            end
                            fprintf('        %s: %s\n', fields{j}, tmp);
                        end
                        disp(' ');
                    end
                end
                if judge == false
                    disp('Could not find a Variable Name');
                end

        end

        
end

