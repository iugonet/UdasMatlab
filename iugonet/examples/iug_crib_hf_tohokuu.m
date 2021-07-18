%   IUG_CRIB_HF_TOHOKUU.M
%     A sample crib sheet that explains how to use the "iug_load_hf_tohokuu.m"
%     function. You can run this crib sheet by copying & pasting each 
%     command below (except for input) into the MATLAB command line.
%     Or alternatively compile and run using the command:
%         > iug_crib_hf_tohokuu

%----- Delete all variables -----%
clear all;

%----- Load HF data -----%
iug_load_hf_tohokuu('2004-1-9 22:00', '2004-1-9 23:00');

%----- Check the loaded data -----%
whos

%----- Display metadata -----%
disp_info(iug_iit_hf_info);

%----- Pause -----%
input('Press any key.');

%----- Plot the loaded data -----%
figure;
colormap(jet);

subplot(2,1,1);
pcolor(iug_iit_hf_time, iug_iit_hf_freq, iug_iit_hf_R);
shading flat;
h=colorbar;
h.Label.String='[dB]';
datetick('x', 'mm/dd HH:MM')
set(gca, 'yscale', 'log', ...
    'xlim', [datenum('2004-1-9 22:00:00'), datenum('2004-1-9 23:00:00')]);
title('Right-handed Circular Polarization')
ylabel('Frequency [MHz]')

subplot(2,1,2);
pcolor(iug_iit_hf_time, iug_iit_hf_freq, iug_iit_hf_L);
shading flat;
h=colorbar;
h.Label.String='[dB';
datetick('x', 'mm/dd HH:MM')
set(gca, 'yscale', 'log', ...
    'xlim', [datenum('2004-1-9 22:00:00'), datenum('2004-1-9 23:00:00')]);
title('Left-handed Circular Polarization')
ylabel('Frequency [MHz]')

