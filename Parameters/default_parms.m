clear all; close all; clc
P = mfilename('fullpath');
F = mfilename;
cd(P(1:end-length(F)))
cd ..
addpath(genpath(cd))

load('parms.mat');

%% Frangi
% Aponeurosis
parms.apo.frangi.FrangiScaleRange = [18 20];
parms.apo.frangi.BlackWhite = 0;
parms.apo.frangi.FrangiScaleRatio = 1;

% Fascicle
parms.fas.frangi.FrangiScaleRange = [1 2];
parms.fas.frangi.BlackWhite = 0;
parms.fas.frangi.FrangiScaleRatio = 1;

%% Aponeurosis
parms.apo.supercut = [.05 .32]; % fraction of vertical ascribed to superficial aponeurosis
parms.apo.deepcut = [.62 .9]; % fraction of vertical ascribed to deep aponeurosis
parms.apo.superrange = [-10 30]; %  superficial aponeurosis angles considered (deg)
parms.apo.deeprange = [-20 10]; %  deep aponeurosis angles considered (deg)
parms.apo.minlength = 100; % minimal length for aponeurosis object (pixels) 
parms.apo.maxlengthratio = 0.7; % maximal ratio between longest and second longest object
parms.apo.fillgap = 5; % gap filling in the aponeurosis (pixels)
parms.apo.apomargin = 100; % distance between start aponeurosis objects and the sides (pixels)
parms.apo.apospacing = 10; % horizontal spacing for aponeurosis (pixels) 
[n,m,~,~] = size(data); % data needs to be a n-by-m numeric array
parms.apo.apox = parms.apo.apomargin:parms.apo.apospacing:(m-parms.apo.apomargin);

%% Fascicle
parms.fas.cut = .2;

% Hough parameters
parms.fas.range = [10 80]; % fascicle angles considered (deg)
parms.fas.npeaks = 5; % amount of Hough angles included in weighted average

parms.fas.thetares =.5;
parms.fas.rhores =1;
parms.fas.houghangles = 'manual';

parms.show = false;
save('parms.mat','parms')