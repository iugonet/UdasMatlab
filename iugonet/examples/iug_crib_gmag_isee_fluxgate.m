%   IUG_CRIB_GMAG_ISEE_FLUXGATE.M
%     A sample crib sheet that explains how to use the "iug_load_gmag_isee_fluxgate.m"
%     function. You can run this crib sheet by copying & pasting each
%     command below (except for input) into the MATLAB command line.
%     Or alternatively compile and run using the command:
%         > iug_crib_gmag_isee_fluxgate

%----- Delete all variables -----%
clear all;

%----- Load 1 site data -----%
iug_load_gmag_isee_fluxgate('2006-11-20', '2006-11-21', 'site', 'msr', 'datatype', '1min');

%----- Check the loaded data -----%
whos

%----- Display metadata -----%
disp_info(isee_fluxgate_mag_msr_info);

%----- Pause -----%
input('Press any key.');

%----- Plot H-component -----%
figure;
plot(isee_fluxgate_mag_msr_1min_time, isee_fluxgate_mag_msr_1min_hdz(:,1))
datetick('x', 'mm/dd')
title('H-component at MSR')
xlabel('UT');
ylabel('nT')

%----- Pause -----%
input('Press any key.');


%----- Load two sites data and output data in the workspace -----%
iug_load_gmag_isee_fluxgate('2006-11-20', '2006-11-21', 'site', {'msr', 'kag'});

%----- Check the loaded data -----%
whos

%----- Pause -----%
input('Press any key.');

%----- Plot H-component of 3 sites -----%
figure;

subplot(2,1,1);
plot(isee_fluxgate_mag_msr_1sec_time, isee_fluxgate_mag_msr_1sec_hdz(:,1))
datetick('x', 'HH:MM')
title('H-component at MSR')
ylabel('nT')

subplot(2,1,2);
plot(isee_fluxgate_mag_kag_1sec_time, isee_fluxgate_mag_kag_1sec_hdz(:,1))
datetick('x', 'HH:MM')
title('H-component at KAG')
xlabel('UT');
ylabel('nT')

