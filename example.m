clear all; close all; clc

% Create path
addpath(genpath(cd))

% Load parameters
load('parms.mat')
parms.show = 1;

% Load image
load('Data\example_ultrasound_image.mat');

% Convert to grayscale
graydata = rgb2gray(data);

% Trim the data
trimdata = graydata(61:521, 112:689);

%% Determine alpha, beta, thickness
[alpha, betha, thickness] = auto_ultrasound(trimdata,parms);

%% Determine fascicle length and pennation angle
pixtocm = 463/4;
phi = alpha - betha;
thickness_cm = thickness / pixtocm;
faslen = thickness_cm ./ sind(phi);

disp(['Fascicle length = ', num2str(round(faslen,2)), ' cm'])
disp(['Pennation angle = ', num2str(round(phi,2)), ' deg'])

