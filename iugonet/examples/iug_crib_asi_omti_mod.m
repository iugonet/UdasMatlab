%   IUG_CRIB_ASI_OMTI_MOD.M
%     A sample crib sheet that explains how to use the "iug_load_asi_omti.m"
%     function. You can run this crib sheet by copying & pasting each
%     command below (except for input) into the MATLAB command line.
%     Or alternatively compile and run using the command:
%         > iug_crib_asi_omti_mod

%----- Delete all variables -----%
clear all;

%----- Load 1 site data -----%
iug_load_asi_omti_mod('2022-9-13 11:00', '2022-9-13 11:10', 'site', 'drw', 'wavelength', '6300')

%----- Check the loaded data -----%
whos

%----- Display metadata -----%
disp_info(omti_asi_drw_6300_info);

%----- Pause -----%
input('Press any key.');

%----- Plot image -----%
disp(datevec(omti_asi_drw_6300_time(1)))

figure;

pcolor(squeeze(omti_asi_drw_6300_image(:,:,1)));
shading flat;
colormap(gray);
% set(gca, 'clim', [0, 250], 'dataaspectratio', [1,1,1]);
h=colorbar;
h.Label.String='counts';
title('630.0nm image at DRW at 11:00:00 UT');

