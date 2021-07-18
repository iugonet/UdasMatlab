%   IUG_CRIB_IRIO_NIPR.M
%     A sample crib sheet that explains how to use the "iug_load_irio_nipr.m"
%     function. You can run this crib sheet by copying & pasting each
%     command below (except for input) into the MATLAB command line.
%     Or alternatively compile and run using the command:
%         > iug_crib_irio_nipr

%----- Delete all variables -----%
clear all;

%----- Load 1 site data -----%
iug_load_irio_nipr('2005-1-21', '2005-1-22', 'site', 'tjo');
% iug_load_irio_nipr('2005-1-21', '2005-1-22', 'site', {'syo', 'tjo'});

%----- Check the loaded data -----%
whos

%----- Display metadata -----%
disp_info(nipr_irio_tjo_30_info);

%----- Pause -----%
input('Press any key.');

%----- Plot beam(4,4) -----%
figure;
plot(nipr_irio_tjo_30_time_1sec, squeeze(nipr_irio_tjo_30_cna(4, 4, :)))
set(gca, 'ylim', [-1, 10])
datetick('x', 'mm/dd')
title('CNA at beam(4,4) at SYO')
xlabel('UT');
ylabel('dB')

%----- Pause -----%
input('Press any key.');

%----- Plot 2D data -----%
idx=17*3600+10*60+1;
disp(datevec(nipr_irio_tjo_30_time_1sec(idx)))

figure;
pcolor(squeeze(nipr_irio_tjo_30_cna(:,:,idx)));
shading flat;
colormap(jet);
set(gca, 'clim', [0, 6], 'dataaspectratio', [1,1,1]);
h=colorbar;
h.Label.String='counts';
title('CNA image at TJO at 17:10:00 UT');

