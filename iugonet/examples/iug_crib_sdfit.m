%   IUG_CRIB_SDFIT.M
%     A sample crib sheet that explains how to use the "iug_load_sdfit.m"
%     function. You can run this crib sheet by copying & pasting each 
%     command below (except for input) into the MATLAB command line.
%     Or alternatively compile and run using the command:
%         > iug_crib_sdfit

%----- Delete all variables -----%
clear all;

%----- Load 1 site data (ESR-42m) -----%
iug_load_sdfit('2015-03-01', '2015-03-02', 'site', 'hok');

%----- Check the loaded data -----%
whos

%----- Display metadata -----%
disp_info(sd_hok_info);

%----- Pause -----%
input('Press any key.');

%----- Plot basic ionospheric parameters -----%
figure;
colormap(jet)

subplot(3, 1, 1);
sd_hok_pwr_1(find(sd_hok_pwr_1>9000))=NaN;
pcolor(sd_hok_time, sd_hok_rgate_no_1, sd_hok_pwr_1);
shading flat;
set(gca, 'clim', [0, 30]);
h=colorbar;
h.Label.String='Backscatter power [dB]';
datetick('x', 'HH:MM')
title('Backscatter power')
ylabel('Altitude [km]')

subplot(3, 1, 2);
sd_hok_vlos_1(find(sd_hok_vlos_1>9000))=NaN;
pcolor(sd_hok_time, sd_hok_rgate_no_1, sd_hok_vlos_1);
shading flat;
set(gca, 'clim', [-200, 200]);
h=colorbar;
h.Label.String='LOS Doppler vel. [m/s]';
datetick('x', 'HH:MM')
title('LOS Doppler velocity')
ylabel('Altitude [km]')

subplot(3, 1, 3);
sd_hok_spec_width_1(find(sd_hok_spec_width_1>9000))=NaN;
pcolor(sd_hok_time, sd_hok_rgate_no_1, sd_hok_spec_width_1);
shading flat;
set(gca, 'clim', [0, 200]);
h=colorbar;
h.Label.String='Spectral width [m/s]';
datetick('x', 'HH:MM')
title('Spectral width')
ylabel('Altitude [km]')


%----- Load several sites' data -----%
iug_load_sdfit('2015-03-01', '2015-03-02', 'site', {'sye', 'sys'});

%----- Check the loaded data -----%
whos

%----- Pause -----%
input('Press any key.');

%----- Plot electron density at 3 sites -----%
figure;
colormap(jet)

subplot(2, 1, 1);
sd_sye_vlos_1(find(sd_sye_vlos_1>9000))=NaN;
pcolor(sd_sye_time, sd_sye_rgate_no_1, sd_sye_vlos_1);
shading flat;
set(gca, 'clim', [-200, 200]);
h=colorbar;
h.Label.String='LOS Doppler vel. [m/s]';
datetick('x', 'HH:MM')
title('LOS Doppler velocity at Syowa East radar')
ylabel('Altitude [km]')

subplot(2, 1, 2);
sd_sys_vlos_1(find(sd_sys_vlos_1>9000))=NaN;
pcolor(sd_sys_time, sd_sys_rgate_no_1, sd_sys_vlos_1);
shading flat;
set(gca, 'clim', [-200, 200]);
h=colorbar;
h.Label.String='LOS Doppler vel. [m/s]';
datetick('x', 'HH:MM')
title('LOS Doppler velocity at Syowa South radar')
ylabel('Altitude [km]')
