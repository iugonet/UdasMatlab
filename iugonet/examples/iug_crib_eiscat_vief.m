%   IUG_CRIB_EISCAT_VIEF.M
%     A sample crib sheet that explains how to use the "iug_load_eiscat_vief.m"
%     function. You can run this crib sheet by copying & pasting each
%     command below (except for input) into the MATLAB command line.
%     Or alternatively compile and run using the command:
%         > iug_crib_eiscat_vief

%----- Delete all variables -----%
clear all;

%----- Load 1 site data -----%
iug_load_eiscat_vief('2011-2-4', '2011-2-6', 'site', 'kst');

%----- Check the loaded data -----%
whos

%----- Display metadata -----%
disp_info(eiscat_kst_info);

%----- Pause -----%
input('Press any key.');

%----- Plot Vi and E -----%
figure;
subplot(4,1,1);
plot(eiscat_kst_time, eiscat_kst_vi)
set(gca, 'ylim', [-1000, 1000])
datetick('x', 'mm/dd')
title('Ion velocity')
xlabel('UT');
ylabel('m/s')

subplot(4,1,2);
plot(eiscat_kst_time, eiscat_kst_vierr)
set(gca, 'ylim', [0, 1000])
datetick('x', 'mm/dd')
title('Error of ion velocity')
xlabel('UT');
ylabel('m/s')

subplot(4,1,3);
plot(eiscat_kst_time, eiscat_kst_E)
set(gca, 'ylim', [-50, 50])
datetick('x', 'mm/dd')
title('Electric field')
xlabel('UT');
ylabel('mV/m')

subplot(4,1,4);
plot(eiscat_kst_time, eiscat_kst_Eerr)
set(gca, 'ylim', [0, 50])
datetick('x', 'mm/dd')
title('Error of electric field')
xlabel('UT');
ylabel('mV/m')

%----- Pause -----%
input('Press any key.');

%----- Plot some parameters -----%
figure;
subplot(3,1,1);
plot(eiscat_kst_time, eiscat_kst_lat)
% set(gca, 'ylim', [0, 40])
datetick('x', 'mm/dd')
title('Latitude')
xlabel('UT');
ylabel('degrees')

subplot(3,1,2);
plot(eiscat_kst_time, eiscat_kst_long)
% set(gca, 'ylim', [0, 40])
datetick('x', 'mm/dd')
title('Longitude')
xlabel('UT');
ylabel('degrees')

subplot(3,1,3);
plot(eiscat_kst_time, eiscat_kst_alt)
% set(gca, 'ylim', [0, 40])
datetick('x', 'mm/dd')
title('Altitude')
xlabel('UT');
ylabel('km')

%----- Pause -----%
input('Press any key.');

%----- Plot some parameters -----%
figure;
subplot(4,1,1);
plot(eiscat_kst_time, eiscat_kst_pulse)
set(gca, 'ylim', [0, 40])
datetick('x', 'mm/dd')
title('Pulse code ID')
xlabel('UT');
% ylabel('m/s')

subplot(4,1,2);
plot(eiscat_kst_time, eiscat_kst_inttim)
% set(gca, 'ylim', [0, 40])
datetick('x', 'mm/dd')
title('Int. time (nominal)')
xlabel('UT');
ylabel('sec')

subplot(4,1,3);
plot(eiscat_kst_time, eiscat_kst_inttimr)
% set(gca, 'ylim', [0, 40])
datetick('x', 'mm/dd')
title('Int. time (real)')
xlabel('UT');
ylabel('sec')

subplot(4,1,4);
plot(eiscat_kst_time, eiscat_kst_q)
% set(gca, 'ylim', [0, 40])
datetick('x', 'mm/dd')
title('Quality')
xlabel('UT');
% ylabel('')


