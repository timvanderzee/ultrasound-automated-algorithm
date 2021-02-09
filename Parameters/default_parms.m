clear all; close all; clc
P = mfilename('fullpath');
F = mfilename;
cd(P(1:end-length(F)))
cd ..
addpath(genpath(cd))

%% Retrieve the SVM from the old parameters
load('parms.mat');

super.SVM = parms.apo.super.SVM;
deep.SVM = parms.apo.deep.SVM;
clear parms

parms.apo.deep = deep;
parms.apo.super = super;
parms.apo.ntraining = 4;

parms.apo.deep.method = 'longest';
parms.apo.super.method = 'longest';


%% Filtering parameters
% These parameters are used in the function filter_usimage

% General aponeurosis
parms.apo.show = 0;
parms.apo.frangi.FrangiScaleRange = [18 20];
parms.apo.frangi.BlackWhite = 0;
parms.apo.frangi.FrangiScaleRatio = 1;
parms.apo.frangi.verbose = false;

% Superficial aponeurosis
parms.apo.super.th = .5;
parms.apo.super.filtfac = 1;
parms.apo.super.cut = [.05 .32]; % fraction of vertical ascribed to superficial aponeurosis

% Deep aponeurosis
parms.apo.deep.th = .5;
parms.apo.deep.filtfac = 1;
parms.apo.deep.cut = [.62 .9]; % fraction of vertical ascribed to deep aponeurosis

% Fascicle
parms.fas.frangi.FrangiScaleRange = [1 2];
parms.fas.frangi.BlackWhite = 0;
parms.fas.frangi.FrangiScaleRatio = 1;
parms.fas.frangi.verbose = false;
parms.fas.th = .5;

%% Aponeurosis select parameters
% These parameters are used in the function apo_func
parms.apo.apomargin = 100; % distance between start aponeurosis objects and the sides (pixels)
parms.apo.apospacing = 10; % horizontal spacing for aponeurosis (pixels) 

load('example_ultrasound_image.mat')
[n,m,~,~] = size(data); % data needs to be a n-by-m numeric array

% Superficial
parms.apo.super.apox = parms.apo.apomargin:parms.apo.apospacing:(m-parms.apo.apomargin);
parms.apo.super.fillgap = 50; % gap filling in the aponeurosis (pixels)

% Deep
parms.apo.deep.apox = parms.apo.apomargin:parms.apo.apospacing:(m-parms.apo.apomargin);
parms.apo.deep.fillgap = 5; % gap filling in the aponeurosis (pixels)

%% Fascicle selection
% These are used in the function dohough

% Hough parameters
parms.fas.cut = .2;
parms.fas.npeaks = 5; % amount of Hough angles included in weighted average
parms.fas.range = [10 80]; % fascicle angles considered (deg)
parms.fas.thetares = .5;
parms.fas.rhores = 1;
parms.fas.houghangles = 'manual';

%% Other & Save
parms.show = true;

cd('Parameters')
save('parms.mat','parms')