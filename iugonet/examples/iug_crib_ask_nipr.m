%   IUG_CRIB_ASK_NIPR.M
%     A sample crib sheet that explains how to use the "iug_load_ask_nipr.m"
%     function. You can run this crib sheet by copying & pasting each
%     command below (except for input) into the MATLAB command line.
%     Or alternatively compile and run using the command:
%         > iug_crib_ask_nipr

%----- Delete all variables -----%
clear all;

%----- Load 1 site data -----%
iug_load_ask_nipr('2012-1-22', '2012-1-23', 'site', 'tro', 'wavelength', '0000');

%----- Check the loaded data -----%
whos

%----- Display metadata -----%
disp_info(nipr_ask_tro_0000_info);

%----- Pause -----%
input('Press any key.');

%----- Plot Keogram -----%
figure;
colormap(jet);

subplot(2,1,1);
pcolor(nipr_ask_tro_0000_time, nipr_ask_tro_0000_index_ns, nipr_ask_tro_0000_keo_ns);
shading flat;
set(gca, 'clim', [0, 250]);
h=colorbar;
h.Label.String='counts';
datetick('x', 'HH:SS')
set(gca, 'xlim', [datenum('2012-1-22 16:00'), datenum('2012-1-22 24:00')]);
title('NS keogram at TRO')
ylabel('N-S')

subplot(2,1,2);
pcolor(nipr_ask_tro_0000_time, nipr_ask_tro_0000_index_ew, nipr_ask_tro_0000_keo_ew);
shading flat;
set(gca, 'clim', [0, 250]);
h=colorbar;
h.Label.String='counts';
datetick('x', 'HH:SS')
set(gca, 'xlim', [datenum('2012-1-22 16:00'), datenum('2012-1-22 24:00')]);
title('EW keogram at TRO')
xlabel('UT');
ylabel('E-W')

%----- Pause -----%
input('Press any key.');

%----- Load all site data as predifined variable names -----%
iug_load_ask_nipr('2018-2-17 20:00', '2018-2-18 4:00', 'site', 'all', 'wavelength', 'all');

%----- Check the loaded data -----%
whos

%----- Pause -----%
input('Press any key.');

%----- Plot NS keogram of 3 sites -----%
figure;
colormap(jet);

subplot(3,1,1);
pcolor(nipr_ask_tro_5577_time, nipr_ask_tro_5577_index_ns, nipr_ask_tro_5577_keo_ns);
shading flat;
set(gca, 'clim', [0, 250]);
h=colorbar;
h.Label.String='counts';
datetick('x', 'HH:SS')
title('NS keogram at TRO')
ylabel('N-S')

subplot(3,1,2);
pcolor(nipr_ask_lyr_0000_time, nipr_ask_lyr_0000_index_ns, nipr_ask_lyr_0000_keo_ns);
shading flat;
set(gca, 'clim', [0, 250]);
h=colorbar;
h.Label.String='counts';
datetick('x', 'HH:SS')
title('NS keogram at LYR')
ylabel('N-S')

subplot(3,1,3);
pcolor(nipr_ask_hus_0000_time, nipr_ask_hus_0000_index_ns, nipr_ask_hus_0000_keo_ns);
shading flat;
set(gca, 'clim', [0, 250]);
h=colorbar;
h.Label.String='counts';
datetick('x', 'HH:SS')
title('NS keogram at HUS')
xlabel('UT');
ylabel('N-S')

