clear all; close all; clc

% Create path
addpath(genpath(cd))

% Load image and parameters
imagename = 'example_ultrasound_image.mat';
load(['Example images\', imagename]);
load(['Parameters\parms_for_', imagename]);

%% Determine alpha, beta, thickness
figure(1)
geofeatures = auto_ultrasound(data,parms);

%% Determine fascicle length and pennation angle for typical image
phi = geofeatures.alpha - geofeatures.betha;
thickness_cm = geofeatures.thickness / pixtocm;
faslen = thickness_cm ./ sind(phi);

disp(['Fascicle length = ', num2str(round(faslen,2)), ' cm'])
disp(['Pennation angle = ', num2str(round(phi,2)), ' deg'])

%% Determine fascicle length and pennation angle for series of images ("video")
load('example_ultrasound_video.mat');

for i = 1:size(data,4)
    figure(2); 
    geofeatures_vid(i) = auto_ultrasound(rgb2gray(data(:,:,:,i)), parms);
    drawnow
end
