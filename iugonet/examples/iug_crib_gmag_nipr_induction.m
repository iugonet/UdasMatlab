%   IUG_CRIB_GMAG_NIPR_INDUCTION.M
%     A sample crib sheet that explains how to use the "iug_load_gmag_nipr_induction.m"
%     function. You can run this crib sheet by copying & pasting each
%     command below (except for input) into the MATLAB command line.
%     Or alternatively compile and run using the command:
%         > iug_crib_gmag_nipr_induction

%----- Delete all variables -----%
clear all;

%----- Load 1 site data -----%
iug_load_gmag_nipr_induction('2016-5-1', '2016-5-2', 'site', 'syo');

%----- Check the loaded data -----%
whos

%----- Display metadata -----%
disp_info(nipr_imag_syo_20hz_info);

%----- Pause -----%
input('Press any key.');

%----- Plot H-component -----%
figure;

subplot(2,1,1);
plot(nipr_imag_syo_20hz_time, nipr_imag_syo_20hz_db_dt(:,1))
datetick('x', 'HH:MM')
title('NS-component at SYO')
xlabel('UT');
ylabel('V')

[s,f,t] = spectrogram(nipr_imag_syo_20hz_db_dt(:,1), 8192, 4096, 8192, 20);
subplot(2,1,2);
pcolor(nipr_imag_syo_20hz_time(1)+t/86400, f, 20*log10(abs(s)+eps));
shading flat;
set(gca, 'ylim', [0, 2], 'clim', [-20, 50]);
colormap('jet');
% colorbar;
datetick('x', 'HH:MM')
title('Dinamic Spectrum of NS-component at SYO')
xlabel('UT');
ylabel('frequency [Hz]')

