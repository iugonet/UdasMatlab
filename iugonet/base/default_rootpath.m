function   rootpath = default_rootpath
%
% rootpath = default_rootpath
%
% Set the default root path of local data diretory.
%
% (Output arguments)
%   rootpath:     Path to the local data directory
%
% Written by Y.-M. Tanaka, April 30, 2020
%

if ispc
    rootpath = 'C:/data/';
else
    rootpath = '~/data/';
end
