%   IUG_CRIB_ASI_NIPR.M
%     A sample crib sheet that explains how to use the "iug_load_asi_nipr.m"
%     function. You can run this crib sheet by copying & pasting each
%     command below (except for input) into the MATLAB command line.
%     Or alternatively compile and run using the command:
%         > iug_crib_asi_nipr

%----- Delete all variables -----%
clear all;

%----- Load 1 site data -----%
iug_load_asi_nipr('2018-2-16 0:00', '2018-2-16 1:00', 'site', 'tro', 'wavelength', '5577');

%----- Check the loaded data -----%
whos

%----- Display metadata -----%
disp_info(nipr_asi_tro_5577_info);

%----- Pause -----%
input('Press any key.');

%----- Plot image -----%
disp(datevec(nipr_asi_tro_5577_time(1)))

figure;

pcolor(squeeze(nipr_asi_tro_5577_image(:,:,1)));
shading flat;
colormap(gray);
set(gca, 'clim', [0, 250], 'dataaspectratio', [1,1,1]);
h=colorbar;
h.Label.String='counts';
title('557.7nm image at TRO at 00:00:00 UT');

