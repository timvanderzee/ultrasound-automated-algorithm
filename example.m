clear all; close all; clc

% Create path
fullpath = which('example.m');
mainfolder = fullpath(1:end-9);
cd(mainfolder)
addpath(genpath(cd))

% Load image and parameters
load('parms.mat')

%% Example 1: single image (vastus lateralis, resting)
imagename = 'example_ultrasound_image.mat';
load(['Example images\single_images\', imagename]);

% Determine alpha, beta, thickness
figure(1); geofeatures = auto_ultrasound(data,parms);

% Determine fascicle length and pennation angle for typical image
phi = geofeatures.alpha - geofeatures.betha;
thickness_cm = geofeatures.thickness / pixtocm;
faslen_TimTrack_gastroc_jumping_cm = thickness_cm ./ sind(phi);

disp(['Fascicle length = ', num2str(round(faslen_TimTrack_gastroc_jumping_cm,2)), ' cm'])
disp(['Pennation angle = ', num2str(round(phi,2)), ' deg'])

%% Example 2: video of multiple images (gastrocnemius lateralis, jumping)
parms.extrapolation = 0;

cd([mainfolder,'Example images\video\jumping'])
files = dir('*png');

% load manual estimates and pixel-to-centimeter ratio
load('manual_estimates_gastroc_jumping.mat');
faslen_manual_gastroc_jumping_cm = faslen_manual /  pixtocm_gastroc;
faslen_TimTrack_gastroc_jumping_cm = nan(length(files),1);

for i = 1:length(files)
    rgbimage = imread(files(i).name); % load image
    grayimage = rgb2gray(rgbimage); % convert to grayscale
    
    % cut the ultrasound image out of total image
    ROI = [115   685;    66   525];
    
    if ~exist('ROI','var')
        ROI = cut_image(grayimage);
    end
    data = grayimage(ROI(2,1):ROI(2,2), ROI(1,1):ROI(1,2));

    % analyse ultrasound image
    figure(2); 
    [geofeatures_gastoc_jumping, apovecs, parms] = auto_ultrasound(data, parms); drawnow
    faslen_TimTrack_gastroc_jumping_cm(i,1) = geofeatures_gastoc_jumping.faslen / pixtocm_gastroc;
        
    % store gcf to write video
    J(i) = getframe(gcf);      
end

% Time between frames;
dt =  0.0786; % s
fs = 1/dt;

% Write video
writerObj = VideoWriter('gastroc_jumping_timtrack.avi');
writerObj.FrameRate = fs;
open(writerObj); % open the video writer
% write the frames to the video
for i=1:length(files)
    frame = J(i); % convert the image to a frame    
    writeVideo(writerObj, frame);
end
close(writerObj); % close the writer object

% load ultratrack estimates
load('jumping_ultratrack.mat')
faslen_UltraTrack_gastroc_jumping_cm = Fdat.Region.FL(48:2:92)/10;

% some stats
MAE_TT = mean(abs(faslen_TimTrack_gastroc_jumping_cm - mean(faslen_manual_gastroc_jumping_cm,2)));
RMSE_TT = round(sqrt(mean((faslen_TimTrack_gastroc_jumping_cm - mean(faslen_manual_gastroc_jumping_cm,2)).^2)),2);
MAE_UT = mean(abs(faslen_UltraTrack_gastroc_jumping_cm(:) - mean(faslen_manual_gastroc_jumping_cm,2)));
RMSE_UT = round(sqrt(mean((faslen_UltraTrack_gastroc_jumping_cm(:) - mean(faslen_manual_gastroc_jumping_cm,2)).^2)),2);

% plot vs. time
N = length(faslen_TimTrack_gastroc_jumping_cm);
time = 0:dt:(N-1)*dt;
figure(3)
subplot(211);
color = get(gca,'colororder'); hold on
plot(time, faslen_TimTrack_gastroc_jumping_cm,'o','color',color(1,:),'markerfacecolor',color(1,:))
plot(time, faslen_UltraTrack_gastroc_jumping_cm,'o','color',color(3,:),'markerfacecolor',color(3,:))
plot(time, mean(faslen_manual_gastroc_jumping_cm,2),'o','color',color(2,:), 'markerfacecolor',color(2,:))
for i = 1:length(faslen_manual_gastroc_jumping_cm)
    plot([time(i) time(i)], [min(faslen_manual_gastroc_jumping_cm(i,:)) max(faslen_manual_gastroc_jumping_cm(i,:))], 'color',color(2,:),'linewidth',2)
end
ylim([0 10])
xlabel('Time (s)'); ylabel('Fascicle length (cm)')
legend(['TimTrack (RMSE = ', num2str(RMSE_TT), ' cm)'],['UltraTrack (RMSE = ', num2str(RMSE_UT), ' cm)'],'Manual','location','best')
title('Gastrocnemius lateralis during a jump')

% spline fit
c1 = polyfit(time(:), faslen_TimTrack_gastroc_jumping_cm(:), 10);
plot(linspace(0, time(end), 100), polyval(c1,  linspace(0, time(end), 100)), 'color', color(1,:))
c2 = polyfit(time(:), mean(faslen_manual_gastroc_jumping_cm,2), 10);
plot(linspace(0, time(end), 100), polyval(c2,  linspace(0, time(end), 100)), 'color', color(2,:))

%% Example 3: video of multiple images (gastrocnemius lateralis, range-of-motion)
cd([mainfolder,'Example images\video\range-of-motion'])
files = dir('*png');

% load manual estimates and pixel-to-centimeter ratio
load('manual_estimates_gastroc_range-of-motion.mat');
faslen_manual_gastroc_ROM_cm = faslen_manual(1:length(files),:) /  pixtocm_gastroc;
faslen_TimTrack_gastroc_ROM_cm = nan(length(files),1);

for i = 1:length(files)
    rgbimage = imread(files(i).name); % load image
    grayimage = rgb2gray(rgbimage); % convert to grayscale
    
    % cut the ultrasound image out of total image
    if ~exist('ROI','var')
        ROI = cut_image(grayimage);
    end
    data = grayimage(ROI(2,1):ROI(2,2), ROI(1,1):ROI(1,2));

    % analyse ultrasound image
    figure(4); 
    geofeatures_gastoc_ROM = auto_ultrasound(data, parms); drawnow
    faslen_TimTrack_gastroc_ROM_cm(i,1) = geofeatures_gastoc_ROM.faslen / pixtocm_gastroc;
    drawnow
    
    % store gcf to write video
    R(i) = getframe(gcf);      
end

% Time between frames;
dt =  1.1756; % s
fs = 1/dt;

% Write video
writerObj = VideoWriter('gastroc_range-of-motion_timtrack.avi');
writerObj.FrameRate = fs;

% open the video writer
open(writerObj);
% write the frames to the video
for i=1:length(R)
    % convert the image to a frame
    frame = R(i) ;    
    writeVideo(writerObj, frame);
end
% close the writer object
close(writerObj);

% load ultratrack estimates
load('range-of-motion_ultratrack.mat')
faslen_UltraTrack_gastroc_ROM_cm = Fdat.Region.FL(2:30:966)/10;

% display some stats
MAE_TT = mean(abs(faslen_TimTrack_gastroc_ROM_cm - mean(faslen_manual_gastroc_ROM_cm,2)));
RMSE_TT = round(sqrt(mean((faslen_TimTrack_gastroc_ROM_cm - mean(faslen_manual_gastroc_ROM_cm,2)).^2)),2);
MAE_UT = mean(abs(faslen_UltraTrack_gastroc_ROM_cm(:) - mean(faslen_manual_gastroc_ROM_cm,2)));
RMSE_UT = round(sqrt(mean((faslen_UltraTrack_gastroc_ROM_cm(:) - mean(faslen_manual_gastroc_ROM_cm,2)).^2)),2);

% plot vs. time
N = length(faslen_TimTrack_gastroc_ROM_cm);
time = 0:dt:(N-1)*dt;
figure(3)
subplot(212);
color = get(gca,'colororder'); hold on
plot(time, faslen_TimTrack_gastroc_ROM_cm,'o','color',color(1,:),'markerfacecolor',color(1,:))
plot(time, faslen_UltraTrack_gastroc_ROM_cm,'o','color',color(3,:), 'markerfacecolor',color(3,:))
plot(time, mean(faslen_manual_gastroc_ROM_cm,2),'o','color',color(2,:), 'markerfacecolor',color(2,:))
for i = 1:length(faslen_manual_gastroc_ROM_cm)
    plot([time(i) time(i)], [min(faslen_manual_gastroc_ROM_cm(i,:)) max(faslen_manual_gastroc_ROM_cm(i,:))], 'color',color(2,:),'linewidth',2)
end
ylim([0 10])
xlabel('Time (s)'); ylabel('Fascicle length (cm)')
legend(['TimTrack (RMSE = ', num2str(RMSE_TT), ' cm)'],['UltraTrack (RMSE = ', num2str(RMSE_UT), ' cm)'],'Manual','location','best')
title('Gastrocnemius lateralis during slow range-of-motion movement')

% spline fit
c1 = polyfit(time(:), faslen_TimTrack_gastroc_ROM_cm(:), 10);
plot(linspace(0, time(end), 100), polyval(c1,  linspace(0, time(end), 100)), 'color', color(1,:))
c2 = polyfit(time(:), mean(faslen_manual_gastroc_ROM_cm,2), 10);
plot(linspace(0, time(end), 100), polyval(c2,  linspace(0, time(end), 100)), 'color', color(2,:))

