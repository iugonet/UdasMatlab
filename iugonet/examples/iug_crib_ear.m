%   IUG_CRIB_EAR.M
%     A sample crib sheet that explains how to use the "iug_load_ear.m"
%     function. You can run this crib sheet by copying & pasting each 
%     command below (except for input) into the MATLAB command line.
%     Or alternatively compile and run using the command:
%         > iug_crib_ear

%----- Delete all variables -----%
clear all;

%----- Load 1 site data (troposphere data) -----%
iug_load_ear('2005-8-24', '2005-8-25', 'datatype', 'e_region', 'parameter', 'eb3p4b');

%----- Check the loaded data -----%
whos

%----- Display metadata -----%
disp_info(info);

%----- Pause -----%
input('Press any key.');

%----- Plot basic ionospheric parameters -----%
figure;

subplot(4, 1, 1);
iug_ear_faieb3p4b_dpl_1(find(iug_ear_faieb3p4b_dpl_1 > 9999999999))=NaN;
pcolor(iug_ear_faieb3p4b_time, iug_ear_faieb3p4b_alt_1, iug_ear_faieb3p4b_dpl_1);
shading flat;
set(gca, 'clim', [-100, 100]);
h=colorbar;
h.Label.String='LOC Doppler vel.  [m/s]';
datetick('x', 'HH:MM')
title('LOC Doppler velocity')
ylabel('Altitude [km]')

subplot(4, 1, 2);
iug_ear_faieb3p4b_pwr_1(find(iug_ear_faieb3p4b_pwr_1 > 9999999999))=NaN;
pcolor(iug_ear_faieb3p4b_time, iug_ear_faieb3p4b_alt_1, iug_ear_faieb3p4b_pwr_1);
shading flat;
% set(gca, 'clim', [0, 5000]);
h=colorbar;
h.Label.String='Echo power [dB]';
datetick('x', 'HH:MM')
title('Echo power')
ylabel('Altitude [km]')

subplot(4, 1, 3);
iug_ear_faieb3p4b_wdt_1(find(iug_ear_faieb3p4b_wdt_1 > 9999999999))=NaN;
pcolor(iug_ear_faieb3p4b_time, iug_ear_faieb3p4b_alt_1, iug_ear_faieb3p4b_wdt_1);
shading flat;
%set(gca, 'clim', [0, 3000]);
h=colorbar;
h.Label.String='Spectral width [m/s]';
datetick('x', 'HH:MM')
title('Spectral width')
ylabel('Altitude [km]')

subplot(4, 1, 4);
iug_ear_faieb3p4b_pn_1(find(iug_ear_faieb3p4b_wdt_1 > 9999999999))=NaN;
plot(iug_ear_faieb3p4b_time, iug_ear_faieb3p4b_pn_1);
datetick('x', 'HH:MM')
title('Noise level')
xlabel('UT');
ylabel('[dB]')


