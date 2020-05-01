%   IUG_CRIB_GMAG_NIPR.M
%     A sample crib sheet that explains how to use the "iug_load_gmag_nipr.m"
%     function. You can run this crib sheet by copying & pasting each
%     command below (except for input) into the MATLAB command line.
%     Or alternatively compile and run using the command:
%         > iug_crib_gmag_nipr

%----- Delete all variables -----%
clear all;

%----- Load 1 site data -----%
iug_load_gmag_nipr('2010-3-1', '2010-3-5', 'site', 'syo', 'datatype', '1sec');

%----- Check the loaded data -----%
whos

%----- Display metadata -----%
disp_info(nipr_mag_syo_1sec_info);

%----- Pause -----%
input('Press any key.');

%----- Plot H-component -----%
figure;
nipr_mag_syo_1sec_hdz(find(nipr_mag_syo_1sec_hdz < -100000))=NaN;
plot(nipr_mag_syo_1sec_time, nipr_mag_syo_1sec_hdz(:,1))
set(gca, 'ylim', [-1500, -1000])
datetick('x', 'mm/dd')
title('H-component at SYO')
xlabel('UT');
ylabel('nT')

%----- Pause -----%
input('Press any key.');

%----- Load all site data and output data in the workspace -----%
iug_load_gmag_nipr('2010-3-1', '2010-3-2', 'site', 'all', 'datatype', 'all');

%----- Check the loaded data -----%
whos

%----- Pause -----%
input('Press any key.');

%----- Plot H-component of 3 sites -----%
figure;

subplot(3,1,1);
nipr_mag_syo_1sec_hdz(find(nipr_mag_syo_1sec_hdz < -100000))=NaN;
plot(nipr_mag_syo_1sec_time, nipr_mag_syo_1sec_hdz(:,1))
datetick('x', 'HH:MM')
title('H-component at SYO')
ylabel('nT')

subplot(3,1,2);
nipr_mag_hus_02hz_hdz(find(nipr_mag_hus_02hz_hdz < -100000))=NaN;
plot(nipr_mag_hus_02hz_time, nipr_mag_hus_02hz_hdz(:,1))
datetick('x', 'HH:MM')
title('H-component at HUS')
ylabel('nT')

subplot(3,1,3);
nipr_mag_tjo_02hz_hdz(find(nipr_mag_tjo_02hz_hdz < -100000))=NaN;
plot(nipr_mag_tjo_02hz_time, nipr_mag_tjo_02hz_hdz(:,1))
datetick('x', 'HH:MM')
title('H-component at TJO')
xlabel('UT');
ylabel('nT')

