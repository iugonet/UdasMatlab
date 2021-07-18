%   IUG_CRIB_WPR_RISH.M
%     A sample crib sheet that explains how to use the "iug_load_wpr_rish.m" 
%     function. You can run this crib sheet by copying & pasting each 
%     command below (except for input) into the MATLAB command line. 
%     Or alternatively compile and run using the command:
%         > iug_crib_wpr_rish
% 

%----- Delete all variables -----%
clear all

% *************************
% WPR radar:
% *************************

%----- Load WPR data -----%
iug_load_wpr_rish('2006-4-1', '2006-4-8', 'site', 'sgk', 'parameter', {'uwnd','vwnd','wwnd'});

%----- Check the loaded data -----%
whos

%----- Display metadata -----%
disp_info(iug_wpr_sgk_uwnd_info);

%----- Pause -----%
input('Press any key.');

%----- Change 999 to NaN -----%
inan=find(iug_wpr_sgk_uwnd==999);
iug_wpr_sgk_uwnd(inan)=NaN;
inan=find(iug_wpr_sgk_vwnd==999);
iug_wpr_sgk_vwnd(inan)=NaN;
inan=find(iug_wpr_sgk_wwnd==999);
iug_wpr_sgk_wwnd(inan)=NaN;

%----- Plot wind data -----%
figure;
colormap(jet);

subplot(3,1,1);
pcolor(iug_wpr_sgk_uwnd_time, iug_wpr_sgk_uwnd_alt, iug_wpr_sgk_uwnd);
shading flat;
set(gca, 'clim', [-50, 50]);
h=colorbar;
h.Label.String='[m/s]';
datetick('x', 'mm/dd')
title('Zonal wind')
ylabel('Altitude [km]')

subplot(3,1,2);
pcolor(iug_wpr_sgk_vwnd_time, iug_wpr_sgk_vwnd_alt, iug_wpr_sgk_vwnd);
shading flat;
set(gca, 'clim', [-30, 30]);
h=colorbar;
h.Label.String='[m/s]';
datetick('x', 'mm/dd')
title('Meridional wind')
ylabel('Altitude [km]')

subplot(3,1,3);
pcolor(iug_wpr_sgk_wwnd_time, iug_wpr_sgk_wwnd_alt, iug_wpr_sgk_wwnd);
shading flat;
set(gca, 'clim', [-10, 10]);
h=colorbar;
h.Label.String='[m/s]';
datetick('x', 'mm/dd')
title('Vertical wind')
ylabel('Altitude [km]')

