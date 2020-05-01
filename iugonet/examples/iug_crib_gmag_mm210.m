%   IUG_CRIB_GMAG_MM210.M
%     A sample crib sheet that explains how to use the "iug_load_gmag_mm210.m"
%     function. You can run this crib sheet by copying & pasting each
%     command below (except for input) into the MATLAB command line.
%     Or alternatively compile and run using the command:
%         > iug_crib_gmag_mm210

%----- Delete all variables -----%
clear all;

%----- Load 1 site data -----%
iug_load_gmag_mm210('2006-11-20', '2006-11-21', 'site', 'msr', 'datatype', '1min');

%----- Check the loaded data -----%
whos

%----- Display metadata -----%
disp_info(mm210_mag_msr_info);

%----- Pause -----%
input('Press any key.');

%----- Plot H-component -----%
figure;
plot(mm210_mag_msr_1min_time, mm210_mag_msr_1min_hdz(:,1))
datetick('x', 'HH:MM')
title('H-component at MSR')
xlabel('UT');
ylabel('nT')

%----- Pause -----%
input('Press any key.');

%----- Load two sites data and output data in the workspace -----%
iug_load_gmag_mm210('2006-11-20', '2006-11-21', 'site', {'msr', 'rik'});

%----- Check the loaded data -----%
whos

%----- Pause -----%
input('Press any key.');

%----- Plot H-component of 3 sites -----%
figure;

subplot(2,1,1);
plot(mm210_mag_msr_1sec_time, mm210_mag_msr_1sec_hdz(:,1))
datetick('x', 'HH:MM')
title('H-component at MSR')
ylabel('nT')

subplot(2,1,2);
plot(mm210_mag_rik_1sec_time, mm210_mag_rik_1sec_hdz(:,1))
datetick('x', 'HH:MM')
title('H-component at RIK')
xlabel('UT');
ylabel('nT')

