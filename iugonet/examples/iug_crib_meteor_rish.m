%   IUG_CRIB_METEOR_RISH.M
%     A sample crib sheet that explains how to use the "iug_load_meteor_rish.m" 
%     function. You can run this crib sheet by copying & pasting each 
%     command below (except for input) into the MATLAB command line. 
%     Or alternatively compile and run using the command:
%         > iug_crib_meteor_rish
% 

%----- Delete all variables -----%
clear all

%----- Load 1 site data -----%
% Load all the data of zonal, meridional and vertical wind velocities
% at Biak for the selected parameter in timespan:
iug_load_meteor_rish('2011-10-01', '2011-11-01', 'site', 'bik', 'parameter', 'h2t60min00');

%----- Check the loaded data -----%
whos

%----- Display metadata -----%
disp_info(iug_meteor_bik_h2t60min00_info);

%----- Pause -----%
input('Press any key.');

%----- Plot wind data -----%
figure;
colormap(jet);

subplot(2,1,1);
pcolor(iug_meteor_bik_h2t60min00_time, iug_meteor_bik_h2t60min00_range, iug_meteor_bik_h2t60min00_uwind);
shading flat;
set(gca, 'ylim', [70, 110]);
set(gca, 'clim', [-100, 100]);
h=colorbar;
h.Label.String='[m/s]';
datetick('x', 'mm/dd')
title('Zonal wind')
ylabel('Altitude [km]')

subplot(2,1,2);
pcolor(iug_meteor_bik_h2t60min00_time, iug_meteor_bik_h2t60min00_range, iug_meteor_bik_h2t60min00_vwind);
shading flat;
set(gca, 'ylim', [70, 110]);
set(gca, 'clim', [-100, 100]);
h=colorbar;
h.Label.String='[m/s]';
datetick('x', 'mm/dd')
title('Meridional wind')
ylabel('Altitude [km]')

%----- Pause -----%
input('Press any key.');

%----- Load 2 site data as predefined variable names -----%
iug_load_meteor_rish('2011-10-01', '2011-11-01', 'site', {'bik', 'ktb'}, 'parameter', 'h2t60min00');

%----- Plot wind data -----%
figure;
colormap(jet);

subplot(2,1,1);
pcolor(iug_meteor_bik_h2t60min00_time, iug_meteor_bik_h2t60min00_range, iug_meteor_bik_h2t60min00_uwind);
shading flat;
set(gca, 'ylim', [70, 110]);
set(gca, 'clim', [-100, 100]);
h=colorbar;
h.Label.String='[m/s]';
datetick('x', 'mm/dd')
title('Zonal wind at Biak')
ylabel('Altitude [km]')

subplot(2,1,2);
pcolor(iug_meteor_ktb_h2t60min00_time, iug_meteor_ktb_h2t60min00_range, iug_meteor_ktb_h2t60min00_uwind);
shading flat;
set(gca, 'ylim', [70, 110]);
set(gca, 'clim', [-100, 100]);
h=colorbar;
h.Label.String='[m/s]';
datetick('x', 'mm/dd')
title('Zonal wind at Kototabang')
ylabel('Altitude [km]')

