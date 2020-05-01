%   IUG_CRIB_BRIO_ISEE.M
%     A sample crib sheet that explains how to use the "iug_load_brio_isee.m"
%     function. You can run this crib sheet by copying & pasting each
%     command below (except for input) into the MATLAB command line.
%     Or alternatively compile and run using the command:
%         > iug_crib_brio_isee

%----- Delete all variables -----%
clear all;

%----- Load 1 site data -----%
iug_load_brio_isee('2017-03-30', '2017-03-31', 'site', 'ath');

%----- Check the loaded data -----%
whos

%----- Display metadata -----%
disp_info(isee_brio30_ath_info);

%----- Pause -----%
input('Press any key.');

%----- Plot CNA, QDC, and raw data -----%
figure;

subplot(2,1,1);
isee_brio30_ath_cna(find(isee_brio30_ath_cna > 900))=NaN;
plot(isee_brio30_ath_time, isee_brio30_ath_cna)
datetick('x', 'HH:MM')
set(gca, 'ylim', [-2, 4])
title('CNA at ATH')
ylabel('dB')

subplot(2,1,2);
plot(isee_brio30_ath_time, isee_brio30_ath_qdc, 'k-.', isee_brio30_ath_time, isee_brio30_ath_raw, '-')
datetick('x', 'HH:MM')
set(gca, 'ylim', [0, 3]);
title('Raw and QDC data at ATH')
xlabel('UT')
ylabel('V')

