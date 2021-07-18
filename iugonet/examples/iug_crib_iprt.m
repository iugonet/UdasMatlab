%   IUG_CRIB_IPRT.M
%     A sample crib sheet that explains how to use the "iug_load_iprt.m"
%     function. You can run this crib sheet by copying & pasting each 
%     command below (except for input) into the MATLAB command line.
%     Or alternatively compile and run using the command:
%         > iug_crib_iprt

%----- Delete all variables -----%
clear all;

%----- Load IPRT data -----%
iug_load_iprt('2010-11-1 00:00', '2010-11-1 00:10', 'datatype', 'sun');

%----- Check the loaded data -----%
whos

%----- Display metadata -----%
disp_info(iprt_sun_info);

%----- Pause -----%
input('Press any key.');

%----- Plot the loaded data -----%
figure;
colormap(jet);

subplot(2,1,1);
pcolor(iprt_sun_time, iprt_sun_freq, iprt_sun_L);
shading flat;
h=colorbar;
h.Label.String='[dB from background]';
datetick('x', 'mm/dd HH:MM')
title('Left-handed Circular Polarization')
ylabel('Frequency [MHz]')

subplot(2,1,2);
pcolor(iprt_sun_time, iprt_sun_freq, iprt_sun_R);
shading flat;
h=colorbar;
h.Label.String='[dB from background]';
datetick('x', 'mm/dd HH:MM')
title('Right-handed Circular Polarization')
ylabel('Frequency [MHz]')

