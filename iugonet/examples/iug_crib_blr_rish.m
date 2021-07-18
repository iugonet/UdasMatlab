%   IUG_CRIB_BLR_RISH.M
%     A sample crib sheet that explains how to use the "iug_load_blr_rish.m" 
%     function. You can run this crib sheet by copying & pasting each 
%     command below (except for input) into the MATLAB command line. 
%     Or alternatively compile and run using the command:
%         > iug_crib_blr_rish
% 

%----- Delete all variables -----%
clear all

% *************************
% BLR radar:
% *************************

%----- Load 1 site data -----%
% Load all the data of zonal, meridional and vertical wind velocities
% at Kototabang for the selected parameter in timespan:
iug_load_blr_rish('2007-8-1', '2007-8-6', 'site', 'ktb', 'parameter', {'uwnd','vwnd','wwnd'});

%----- Check the loaded data -----%
whos

%----- Display metadata -----%
disp_info(iug_blr_ktb_uwnd_info);

%----- Pause -----%
input('Press any key.');

%----- Change 999 to NaN -----%
inan=find(iug_blr_ktb_uwnd==999);
iug_blr_ktb_uwnd(inan)=NaN;
inan=find(iug_blr_ktb_vwnd==999);
iug_blr_ktb_vwnd(inan)=NaN;
inan=find(iug_blr_ktb_wwnd==999);
iug_blr_ktb_wwnd(inan)=NaN;

%----- Plot wind data -----%
figure;
colormap(jet);

subplot(3,1,1);
pcolor(iug_blr_ktb_uwnd_time, iug_blr_ktb_uwnd_alt, iug_blr_ktb_uwnd);
shading flat;
set(gca, 'clim', [-10, 10]);
h=colorbar;
h.Label.String='[m/s]';
datetick('x', 'mm/dd')
title('Zonal wind')
ylabel('Altitude [km]')

subplot(3,1,2);
pcolor(iug_blr_ktb_vwnd_time, iug_blr_ktb_vwnd_alt, iug_blr_ktb_vwnd);
shading flat;
set(gca, 'clim', [-10, 10]);
h=colorbar;
h.Label.String='[m/s]';
datetick('x', 'mm/dd')
title('Meridional wind')
ylabel('Altitude [km]')

subplot(3,1,3);
pcolor(iug_blr_ktb_wwnd_time, iug_blr_ktb_wwnd_alt, iug_blr_ktb_wwnd);
shading flat;
set(gca, 'clim', [-10, 10]);
h=colorbar;
h.Label.String='[m/s]';
datetick('x', 'mm/dd')
title('Vertical wind')
ylabel('Altitude [km]')

