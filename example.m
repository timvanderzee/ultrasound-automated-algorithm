clear all; close all; clc

% Create path
addpath(genpath(cd))

% Load parameters
load('parms.mat')

% Load image
% load('Example images\example_ultrasound_image.mat');
load('Example images\example_ultrasound_image4.mat');

%% Determine alpha, beta, thickness
parms.apo.deep.order = 2;
parms.extrapolation = 0;
geofeatures = auto_ultrasound(data,parms);

%% Determine fascicle length and pennation angle
phi = geofeatures.alpha - geofeatures.betha;
thickness_cm = geofeatures.thickness / pixtocm;
faslen = thickness_cm ./ sind(phi);

disp(['Fascicle length = ', num2str(round(faslen,2)), ' cm'])
disp(['Pennation angle = ', num2str(round(phi,2)), ' deg'])

