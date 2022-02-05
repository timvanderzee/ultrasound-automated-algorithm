clear all; close all; clc
P = mfilename('fullpath');
F = mfilename;
cd(P(1:end-length(F)))
cd ..
addpath(genpath(cd))

%% used in filter_usimage.m
% General aponeurosis
parms.apo.sigma = 10;
parms.apo.th = .5;
parms.apo.filtfac = 1;
parms.apo.maxlengthratio = .9;
parms.apo.method = 'Frangi'; % options: 'Hough' or 'Frangi'
parms.apo.minangle = -45; % [deg]
parms.apo.filter_method = 'multiply';

% General fascicle
parms.fas.th = .5;
parms.fas.w_ellipse_rel = 1;
parms.fas.redo_ROI = 0;

% Frangi aponeurosis
parms.apo.frangi.FrangiScaleRange = [18 20];
parms.apo.frangi.BlackWhite = 0;
parms.apo.frangi.FrangiScaleRatio = 1;
parms.apo.frangi.verbose = false;

% Frangi fascicle
parms.fas.frangi.FrangiScaleRange = [1 2];
parms.fas.frangi.BlackWhite = 0;
parms.fas.frangi.FrangiScaleRatio = 1;
parms.fas.frangi.verbose = false;

% Superficial aponeurosis
parms.apo.super.cut = [.05 .4]; % fraction of vertical ascribed to superficial aponeurosis

% Deep aponeurosis
parms.apo.deep.cut = [.65 .95]; % fraction of vertical ascribed to deep aponeurosis

%% used in apo_func.m
parms.apo.fillgap = 50;

%% used in fit_apo.m
% Superficial aponeurosis
parms.apo.super.fit_method = 'enforce_maxangle';
parms.apo.super.order = 1; % order of fit
parms.apo.super.maxangle = .5; % [deg]

% Deep aponeurosis
parms.apo.deep.fit_method = 'enforce_maxangle';
parms.apo.deep.order = 1; % order of fit
parms.apo.deep.maxangle = .5; % [deg]

%% used in auto_ultrasound.m (for aponeurosis sampling)
parms.apo.apomargin = 20; % distance between start aponeurosis objects and the sides (pixels)
parms.apo.nextrap = 5;
parms.apo.napo = 10;
parms.apo.x = parms.apo.apomargin;

%% used in dohough.m (for fascicle angle estimation)
% Hough parameters
parms.fas.npeaks = 10; % amount of Hough angles included in weighted average
parms.fas.range = [8 80]; % fascicle angles considered (deg)
parms.fas.thetares = 1;
parms.fas.rhores = 1;
parms.fas.houghangles = 'specified';

%% Other & Save
parms.show = true;
parms.show2 = false;
parms.fas.show = true;
parms.extrapolation = true;
parms.apo.show = false;

cd('Parameters')
save('parms.mat','parms')