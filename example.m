clear all; close all; clc

% Create path
fullpath = which('example.m');
mainfolder = fullpath(1:end-9);
cd(mainfolder)
addpath(genpath(cd))

% Load image and parameters
load('parms.mat')

%% Example 1: single image (vastus lateralis, resting)
% image in .mat format (pre-processed)
imagename = 'example_ultrasound_image.mat';
load(['Example images\raw\single_images\', imagename]);

% Determine alpha, beta, thickness
h = figure(1); geofeatures = do_TimTrack(data,parms);

% Determine fascicle length and pennation angle for typical image
phi = geofeatures.alpha - geofeatures.betha;
thickness_cm = geofeatures.thickness / pixtocm;
faslen_TimTrack_gastroc_jumping_cm = thickness_cm ./ sind(phi);

disp(['Fascicle length = ', num2str(round(faslen_TimTrack_gastroc_jumping_cm,2)), ' cm'])
disp(['Pennation angle = ', num2str(round(phi,2)), ' deg'])

% cd([mainfolder, 'Example images\analyzed'])
% saveas(h,'analyzed_VL_image','jpg')

%% Example 2: video of multiple images (gastrocnemius lateralis, jumping)
% images in .png format
cd([mainfolder,'Example images\raw\video\jumping'])
files = dir('*png');

% load manual estimates and pixel-to-centimeter ratio
load('manual_estimates_gastroc_jumping.mat');
faslen_manual_gastroc_jumping_cm = faslen_manual /  pixtocm_gastroc;

% cut the ultrasound image out of total image
parms.ROI = [115   685;    66   510];
parms.extrapolation = 0;
parms.apo.method = 'Frangi';
parms.apo.deep.order = 2;

% do TimTrack analysis
figure(2)
[geofeatures_gastoc_jumping, parms] = do_TimTrack(files, parms);
 
for j = 1:length(geofeatures_gastoc_jumping)
    faslen_TimTrack_gastroc_jumping_cm(j,1) = geofeatures_gastoc_jumping(j).faslen / pixtocm_gastroc;
end

% plot vs. time
N = length(faslen_TimTrack_gastroc_jumping_cm);
dt =  0.0786; % s
time = 0:dt:(N-1)*dt;

figure(3)
subplot(211);
color = get(gca,'colororder'); hold on
plot(time, faslen_TimTrack_gastroc_jumping_cm,'o','color',color(1,:),'markerfacecolor',color(1,:))
plot(time, mean(faslen_manual_gastroc_jumping_cm,2),'o','color',color(2,:), 'markerfacecolor',color(2,:))
for i = 1:length(faslen_manual_gastroc_jumping_cm)
    plot([time(i) time(i)], [min(faslen_manual_gastroc_jumping_cm(i,:)) max(faslen_manual_gastroc_jumping_cm(i,:))], 'color',color(2,:),'linewidth',2)
end

% spline fit
c1 = polyfit(time(:), faslen_TimTrack_gastroc_jumping_cm(:), 10);
plot(linspace(0, time(end), 100), polyval(c1,  linspace(0, time(end), 100)), 'color', color(1,:))
c2 = polyfit(time(:), mean(faslen_manual_gastroc_jumping_cm,2), 10);
plot(linspace(0, time(end), 100), polyval(c2,  linspace(0, time(end), 100)), 'color', color(2,:))

% make nice
RMSE_TT = round(sqrt(mean((faslen_TimTrack_gastroc_jumping_cm - mean(faslen_manual_gastroc_jumping_cm,2)).^2)),2);
ylim([0 10])
xlabel('Time (s)'); ylabel('Fascicle length (cm)')
legend(['TimTrack (RMSE = ', num2str(RMSE_TT), ' cm)'],'Manual','location','best')
title('Gastrocnemius lateralis during a jump')

%% Example 3: video of multiple images (gastrocnemius lateralis, range-of-motion)
% images in .png format
cd([mainfolder,'Example images\raw\video\range-of-motion'])
files = dir('*png');

% load manual estimates and pixel-to-centimeter ratio
load('manual_estimates_gastroc_range-of-motion.mat');
faslen_manual_gastroc_ROM_cm = faslen_manual(1:length(files),:) /  pixtocm_gastroc;
faslen_TimTrack_gastroc_ROM_cm = nan(length(files),1);

% do TimTrack analysis
figure(2)
[geofeatures_gastoc_ROM, parms] = do_TimTrack(files, parms);
 
for j = 1:length(geofeatures_gastoc_ROM)
    faslen_TimTrack_gastroc_ROM_cm(j,1) = geofeatures_gastoc_ROM(j).faslen / pixtocm_gastroc;
end

% plot vs. time
N = length(faslen_TimTrack_gastroc_ROM_cm);
dt =  1.1756; % s
time = 0:dt:(N-1)*dt;

figure(3)
subplot(212);
color = get(gca,'colororder'); hold on
plot(time, faslen_TimTrack_gastroc_ROM_cm,'o','color',color(1,:),'markerfacecolor',color(1,:))
plot(time, mean(faslen_manual_gastroc_ROM_cm,2),'o','color',color(2,:), 'markerfacecolor',color(2,:))
for i = 1:length(faslen_manual_gastroc_ROM_cm)
    plot([time(i) time(i)], [min(faslen_manual_gastroc_ROM_cm(i,:)) max(faslen_manual_gastroc_ROM_cm(i,:))], 'color',color(2,:),'linewidth',2)
end

% spline fit
c1 = polyfit(time(:), faslen_TimTrack_gastroc_ROM_cm(:), 10);
plot(linspace(0, time(end), 100), polyval(c1,  linspace(0, time(end), 100)), 'color', color(1,:))
c2 = polyfit(time(:), mean(faslen_manual_gastroc_ROM_cm,2), 10);
plot(linspace(0, time(end), 100), polyval(c2,  linspace(0, time(end), 100)), 'color', color(2,:))

% make nice
ylim([0 10])
xlabel('Time (s)'); ylabel('Fascicle length (cm)')
RMSE_TT = round(sqrt(mean((faslen_TimTrack_gastroc_ROM_cm - mean(faslen_manual_gastroc_ROM_cm,2)).^2)),2);
legend(['TimTrack (RMSE = ', num2str(RMSE_TT), ' cm)'],'Manual','location','best')
title('Gastrocnemius lateralis during slow range-of-motion movement')

cd([mainfolder, 'Example images\analyzed'])
saveas(gcf,'TimTrack_vs_manual_gastrocnemius','jpg')

