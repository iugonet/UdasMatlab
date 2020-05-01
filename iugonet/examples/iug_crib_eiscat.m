%   IUG_CRIB_EISCAT.M
%     A sample crib sheet that explains how to use the "iug_load_eiscat.m"
%     function. You can run this crib sheet by copying & pasting each 
%     command below (except for input) into the MATLAB command line.
%     Or alternatively compile and run using the command:
%         > iug_crib_eiscat

%----- Delete all variables -----%
clear all;

%----- Load 1 site data (ESR-42m) -----%
iug_load_eiscat('2015-03-20', '2015-03-21', 'site', 'esr', 'antenna', '42m');

%----- Check the loaded data -----%
whos

%----- Display metadata -----%
disp_info(eiscat_esr_42m_info);

%----- Pause -----%
input('Press any key.');

%----- Plot basic ionospheric parameters -----%
figure;
colormap(jet);

subplot(4, 1, 1);
pcolor(eiscat_esr_42m_time, eiscat_esr_42m_alt, log10(eiscat_esr_42m_Ne));
shading flat;
set(gca, 'clim', [10, 12]);
h=colorbar;
h.Label.String='log10(Ne) [m^-3]';
datetick('x', 'HH:MM')
title('Ne')
ylabel('Altitude [km]')

subplot(4, 1, 2);
pcolor(eiscat_esr_42m_time, eiscat_esr_42m_alt, eiscat_esr_42m_Te);
shading flat;
set(gca, 'clim', [0, 5000]);
h=colorbar;
h.Label.String='Te [K]';
datetick('x', 'HH:MM')
title('Te')
ylabel('Altitude [km]')

subplot(4, 1, 3);
pcolor(eiscat_esr_42m_time, eiscat_esr_42m_alt, eiscat_esr_42m_Ti);
shading flat;
set(gca, 'clim', [0, 3000]);
h=colorbar;
h.Label.String='Ti [K]';
datetick('x', 'HH:MM')
title('Ti')
ylabel('Altitude [km]')

subplot(4, 1, 4);
pcolor(eiscat_esr_42m_time, eiscat_esr_42m_alt, eiscat_esr_42m_Vi);
shading flat;
set(gca, 'clim', [-200, 200]);
h=colorbar;
h.Label.String='Vi [m/s]';
datetick('x', 'HH:MM')
title('Te')
xlabel('UT');
ylabel('Altitude [km]')

%----- Pause -----%
input('Press any key.');


%----- Load several sites' data -----%
iug_load_eiscat('2015-03-21', '2015-03-22', 'site', {'esr', 'tro'}, 'antenna', 'all');

%----- Check the loaded data -----%
whos

%----- Pause -----%
input('Press any key.');

%----- Plot electron density at 3 sites -----%
figure;
colormap(jet);

subplot(3, 1, 1);
pcolor(eiscat_esr_42m_time, eiscat_esr_42m_alt, log10(eiscat_esr_42m_Ne));
shading flat;
set(gca, 'clim', [10, 12]);
h=colorbar;
h.Label.String='log10(Ne) [m^-3]';
datetick('x', 'HH:MM')
title('Ne at ESR-42m')
ylabel('Altitude [km]')

subplot(3, 1, 2);
pcolor(eiscat_tro_uhf_time, eiscat_tro_uhf_alt, log10(eiscat_tro_uhf_Ne));
shading flat;
set(gca, 'clim', [10, 12]);
h=colorbar;
h.Label.String='log10(Ne) [m^-3]';
datetick('x', 'HH:MM')
title('Ne at TRO-UHF')
ylabel('Altitude [km]')

subplot(3, 1, 3);
pcolor(eiscat_tro_vhf_time, eiscat_tro_vhf_alt, log10(eiscat_tro_vhf_Ne));
shading flat;
set(gca, 'clim', [10, 12]);
h=colorbar;
h.Label.String='log10(Ne) [m^-3]';
datetick('x', 'HH:MM')
title('Ne at TRO-VHF')
ylabel('Altitude [km]')
xlabel('UT');

