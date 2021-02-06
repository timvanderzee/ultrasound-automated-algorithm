clear all; close all; clc

% Create path
addpath(genpath(cd))

% Load parameters
load('parms.mat')

% Load image
load('Data\example_ultrasound_image.mat');
[n,m] = size(data); % data needs to be a n-by-m numeric array
parms.apo.apox = parms.apo.apomargin:parms.apo.apospacing:(m-parms.apo.apomargin);

%% Determine alpha, beta, thickness
[alpha, betha, thickness] = auto_ultrasound(data,parms);

%% Determine fascicle length and pennation angle
phi = alpha - betha;
thickness_cm = thickness / pixtocm;
faslen = thickness_cm ./ sind(phi);

disp(['Fascicle length = ', num2str(round(faslen,2)), ' cm'])
disp(['Pennation angle = ', num2str(round(phi,2)), ' deg'])

