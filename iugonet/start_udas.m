arch = computer;

[filepath, name, ext] = fileparts(mfilename('fullpath'));
f = filesep;

% Add path of cdf371
switch upper(arch)
    case 'PCWIN64'
        addpath([filepath, filesep, 'matlab_cdf371/win64/matlab_cdf371_patch']);
    case 'MACI64'
        addpath([filepath, filesep, 'matlab_cdf371/mac64/matlab_cdf371_patch']);
    case 'GLNXA64'
        addpath([filepath, filesep, 'matlab_cdf371_patch-64']);
    otherwise
        error('No supported SPDF library for this OS.');
end

% Add path of UDAS
addpath([filepath, filesep, 'base']);
addpath([filepath, filesep, './load']);
addpath([filepath, filesep, './examples']);

clear filepath name ext f;

