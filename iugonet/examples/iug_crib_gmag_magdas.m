%   IUG_CRIB_GMAG_MAGDAS.M
%     A sample crib sheet that explains how to use the "iug_load_gmag_magdas.m"
%     function. You can run this crib sheet by copying & pasting each
%     command below (except for input) into the MATLAB command line.
%     Or alternatively compile and run using the command:
%         > iug_crib_gmag_magdas

%----- Delete all variables -----%
clear all;

%----- Load 1 site data -----%
iug_load_gmag_magdas('2007-3-1', '2007-3-5', 'site', 'asb');

%----- Check the loaded data -----%
whos

%----- Display metadata -----%
disp_info(magdas_mag_asb_1sec_info);

%----- Pause -----%
input('Press any key.');

%----- Plot H-component -----%
figure;
plot(magdas_mag_asb_1sec_time, magdas_mag_asb_1sec_hdz(:,1))
datetick('x', 'mm/dd')
title('H-component at ASB')
xlabel('UT');
ylabel('nT')

%----- Pause -----%
input('Press any key.');

%----- Load all site data and output data in the workspace -----%
iug_load_gmag_magdas('2007-3-1', '2007-3-2', 'site', 'all');
%iug_load_gmag_magdas('2007-3-1', '2007-3-2', 'site', {'ama', 'asb', 'kuj'}, 'fixed_varname', 1);

%----- Check the loaded data -----%
whos

%----- Pause -----%
input('Press any key.');

%----- Plot H-component of 3 sites -----%
figure;

subplot(4,1,1);
plot(magdas_mag_ama_1sec_time, magdas_mag_ama_1sec_hdz(:,1))
datetick('x', 'HH:MM')
title('H-component at AMA')
ylabel('nT')

subplot(4,1,2);
plot(magdas_mag_asb_1sec_time, magdas_mag_asb_1sec_hdz(:,1))
datetick('x', 'HH:MM')
title('H-component at ASB')
ylabel('nT')

subplot(4,1,3);
plot(magdas_mag_kuj_1sec_time, magdas_mag_kuj_1sec_hdz(:,1))
datetick('x', 'HH:MM')
title('H-component at KUJ')
xlabel('UT');
ylabel('nT')

[s,f,t] = spectrogram(detrend(magdas_mag_kuj_1sec_hdz(:,1)), 1024, 512, 1024, 1);
subplot(4,1,4);
pcolor(magdas_mag_kuj_1sec_time(1)+double(t/86400), f, 20*log10(abs(s)+eps));
shading flat;
set(gca, 'ylim', [0, 0.1], 'yscale', 'log', 'clim', [-40 80]);
colormap('jet');
% colorbar;
datetick('x', 'HH:MM')
title('Dynamic Spectrum of H-component at KUJ')
xlabel('UT');
ylabel('frequency [Hz]')


