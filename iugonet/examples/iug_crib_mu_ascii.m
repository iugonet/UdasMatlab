%   IUG_CRIB_MU_ASCII.M
%     A sample crib sheet that explains how to use the "loadfunc_mu_ascii.m"
%     function. You can run this crib sheet by copying & pasting each 
%     command below (except for input) into the MATLAB command line.
%     Or alternatively compile and run using the command:
%         > iug_crib_mu_ascii

%----- Delete all variables -----%
clear all;

%----- Load 1 site data (ESR-42m) -----%
loadfunc_mu_ascii('1992-1-21', '1992-1-23');

%----- Check the loaded data -----%
whos

%----- Display metadata -----%
disp_info(iug_mu_info);


