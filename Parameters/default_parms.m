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
parms.apo.sigma = 10;
parms.apo.th = .5;
parms.apo.filtfac = 1;
parms.apo.maxlengthratio = .9;

% Frangi aponeurosis
parms.apo.frangi.FrangiScaleRange = [18 20];
parms.apo.frangi.BlackWhite = 0;
parms.apo.frangi.FrangiScaleRatio = 1;
parms.apo.frangi.verbose = false;

% Superficial aponeurosis
parms.apo.super.cut = [.05 .4]; % fraction of vertical ascribed to superficial aponeurosis
parms.apo.super.order = 1; % order of fit
parms.apo.super.maxangle = .5;

% Deep aponeurosis
parms.apo.deep.cut = [.65 .95]; % fraction of vertical ascribed to deep aponeurosis
parms.apo.deep.order = 1; % order of fit
parms.apo.deep.maxangle = .5;

% Fascicle
parms.fas.frangi.FrangiScaleRange = [1 2];
parms.fas.frangi.BlackWhite = 0;
parms.fas.frangi.FrangiScaleRatio = 1;
parms.fas.frangi.verbose = false;
parms.fas.th = .5;
parms.fas.w_ellipse_rel = .8;

%% Aponeurosis select parameters
% These parameters are used in the function apo_func
parms.apo.apomargin = 20; % distance between start aponeurosis objects and the sides (pixels)
parms.apo.nextrap = 5;
parms.apo.napo = 10;
parms.apo.x = parms.apo.apomargin;

%% Fascicle selection
% Hough parameters
parms.fas.npeaks = 10; % amount of Hough angles included in weighted average
parms.fas.range = [10 80]; % fascicle angles considered (deg)
parms.fas.thetares = 1;
parms.fas.rhores = 1;
parms.fas.houghangles = 'manual';

%% Other & Save
parms.show = true;
parms.show2 = false;
parms.extrapolation = true;
parms.apo.show = false;

cd('Parameters')
save('parms.mat','parms')