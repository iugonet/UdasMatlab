%   IUG_CRIB_MF_RISH.M
%     A sample crib sheet that explains how to use the "iug_load_mf_rish.m" 
%     function. You can run this crib sheet by copying & pasting each 
%     command below (except for input) into the MATLAB command line. 
%     Or alternatively compile and run using the command:
%         > iug_crib_mf_rish
% 

%----- Delete all variables -----%
clear all

% *************************
% Pameungpeuk mf radar:
% *************************

%----- Load 1 site data -----%
% Load all the data of zonal, meridional and vertical wind velocities
% at Pameungpeuk for the selected parameter in timespan:
iug_load_mf_rish('2010-2-12', '2010-3-12', 'site', 'pam');

%----- Check the loaded data -----%
whos

%----- Display metadata -----%
disp_info(iug_mf_pam_info);

%----- Pause -----%
input('Press any key.');

%----- Plot wind data -----%
figure;
colormap(jet);

subplot(3,1,1);
pcolor(iug_mf_pam_time, iug_mf_pam_range, iug_mf_pam_uwind);
shading flat;
set(gca, 'clim', [-100, 100]);
h=colorbar;
h.Label.String='[m/s]';
datetick('x', 'mm/dd')
set(gca, 'ylim', [50, 100], 'xlim', [datenum('2010-02-12'), datenum('2010-03-12')]);
title('Zonal wind')
ylabel('Altitude [km]')

subplot(3,1,2);
pcolor(iug_mf_pam_time, iug_mf_pam_range, iug_mf_pam_vwind);
shading flat;
set(gca, 'clim', [-100, 100]);
h=colorbar;
h.Label.String='[m/s]';
datetick('x', 'mm/dd')
set(gca, 'ylim', [50, 100], 'xlim', [datenum('2010-02-12'), datenum('2010-03-12')]);
title('Meridional wind')
ylabel('Altitude [km]')

subplot(3,1,3);
pcolor(iug_mf_pam_time, iug_mf_pam_range, iug_mf_pam_wwind);
shading flat;
set(gca, 'clim', [-10, 10]);
h=colorbar;
h.Label.String='[m/s]';
datetick('x', 'mm/dd')
set(gca, 'ylim', [50, 100], 'xlim', [datenum('2010-02-12'), datenum('2010-03-12')]);
title('Vertical wind')
ylabel('Altitude [km]')

%----- Pause -----%
input('Press any key.');

%----- Load 2 site data as predefined variable names -----%
iug_load_mf_rish('2010-02-12', '2010-2-15', 'site', {'pam', 'pon'});

%----- Plot wind data -----%
figure;
colormap(jet);

subplot(2,1,1);
pcolor(iug_mf_pam_time, iug_mf_pam_range, iug_mf_pam_uwind);
shading flat;
set(gca, 'clim', [-100, 100]);
h=colorbar;
h.Label.String='[m/s]';
datetick('x', 'mm/dd')
set(gca, 'ylim', [50, 100], 'xlim', [datenum('2010-02-12'), datenum('2010-02-15')]);
title('Zonal wind at Pameungpeuk')
ylabel('Altitude [km]')

subplot(2,1,2);
iug_mf_pon_uwind(find(iug_mf_pon_uwind < -9990))=NaN;
pcolor(iug_mf_pon_time, iug_mf_pon_range, iug_mf_pon_uwind);
shading flat;
set(gca, 'clim', [-100, 100]);
h=colorbar;
h.Label.String='[m/s]';
datetick('x', 'mm/dd')
set(gca, 'ylim', [50, 100], 'xlim', [datenum('2010-02-12'), datenum('2010-02-15')]);
title('Zonal wind at Pontianak')
ylabel('Altitude [km]')

