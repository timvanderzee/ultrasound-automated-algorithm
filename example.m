clear all; close all; clc

% Create path
addpath(genpath(cd))

% Load parameters
load('parms.mat')
parms.show = 1;
parms.fas.cut = .2;


% Load image
load('Data\example_ultrasound_image.mat');
[n,m] = size(data); % data needs to be a n-by-m numeric array

apomargin = 100; % distance between start aponeurosis objects and the sides (pixels)
apospacing = 20; % horizontal spacing for aponeurosis (pixels) 
parms.apo.apox = apomargin:apospacing:(m-apomargin);

%% Determine alpha, beta, thickness
parms.fas.npeaks = 5;
[alpha, betha, thickness] = auto_ultrasound(data,parms);

%% Determine fascicle length and pennation angle
pixtocm = 463/4;
phi = alpha - betha;
thickness_cm = thickness / pixtocm;
faslen = thickness_cm ./ sind(phi);

disp(['Fascicle length = ', num2str(round(faslen,2)), ' cm'])
disp(['Pennation angle = ', num2str(round(phi,2)), ' deg'])

