%   IUG_CRIB_GMAG_ISEE_INDUCTION.M
%     A sample crib sheet that explains how to use the "iug_load_gmag_isee_induction.m"
%     function. You can run this crib sheet by copying & pasting each
%     command below (except for input) into the MATLAB command line.
%     Or alternatively compile and run using the command:
%         > iug_crib_gmag_isee_induction

%----- Delete all variables -----%
clear all;

%----- Load 1 site data -----%
iug_load_gmag_isee_induction('2009-01-03 09:40:00', '2009-01-03 10:10:00', 'site', {'ath', 'msr'});

%----- Check the loaded data -----%
whos

%----- Display metadata -----%
disp_info(isee_induction_ath_info);

%----- Pause -----%
input('Press any key.');

%----- Plot NS-component of 2 sites -----%
[s1,f1,t1] = spectrogram(isee_induction_ath_db_dt(:,1), 8192, 7168, 8192, 64);
[s2,f2,t2] = spectrogram(isee_induction_msr_db_dt(:,1), 8192, 7168, 8192, 64);

figure;

subplot(4,1,1);
plot(isee_induction_ath_time, isee_induction_ath_db_dt(:,1))
datetick('x', 'HH:MM')
set(gca, 'xlim', [datenum('2009-01-03 09:40'), datenum('2009-01-03 10:10')]);
title('NS-component at ATH')
ylabel('V')

subplot(4,1,2);
plot(isee_induction_msr_time, isee_induction_msr_db_dt(:,1))
datetick('x', 'HH:MM')
set(gca, 'xlim', [datenum('2009-01-03 09:40'), datenum('2009-01-03 10:10')]);
title('NS-component at MSR')
ylabel('V')

subplot(4,1,3);
pcolor(isee_induction_ath_time(1)+double(t1/86400), f1, 20*log10(abs(s1)+eps));
shading flat;
colormap('jet');
% colorbar;
datetick('x', 'HH:MM')
set(gca, 'yscale', 'log', 'clim', [-40, 40],...
         'xlim', [datenum('2009-01-03 09:40'), datenum('2009-01-03 10:10')]);
title('Dynamic Spectrum of NS-component at ATH')
xlabel('UT');
ylabel('frequency [Hz]')

subplot(4,1,4);
pcolor(isee_induction_msr_time(1)+double(t2/86400), f2, 20*log10(abs(s2)+eps));
shading flat;
colormap('jet');
% colorbar;
datetick('x', 'HH:MM')
set(gca, 'yscale', 'log', 'clim', [-20, 40],...
         'xlim', [datenum('2009-01-03 09:40'), datenum('2009-01-03 10:10')]);
title('Dynamic Spectrum of NS-component at MSR')
xlabel('UT');
ylabel('frequency [Hz]')

