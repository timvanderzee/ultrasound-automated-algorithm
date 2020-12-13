clear all; close all; clc

%% Frangi
% aponeurosis
parms.apo.frangi.FrangiScaleRange = [18 20];
parms.apo.frangi.BlackWhite = 0;
parms.apo.frangi.FrangiScaleRatio = 1;

% fascicle
parms.fas.frangi.FrangiScaleRange = [1 2];
parms.fas.frangi.BlackWhite = 0;
parms.fas.frangi.FrangiScaleRatio = 1;

%% Aponeurosis
parms.apo.supercut = 0.32; % fraction of vertical ascribed to superficial aponeurosis
parms.apo.deepcut = 0.62; % fraction of vertical ascribed to deep aponeurosis
parms.apo.superrange(1) = -10; % smallest superficial aponeurosis angle considered (deg)
parms.apo.superrange(2) = 30; % largest superficial aponeurosis considered (deg)
parms.apo.deeprange(1) = -20; % smallest deep aponeurosis angle considered (deg)
parms.apo.deeprange(2) = 10; % largest deep aponeurosis considered (deg)
parms.apo.minlength = 200; % minimal length for aponeurosis object (pixels) 
parms.apo.maxlengthratio = 0.8; % maximal ratio between longest and second longest object
parms.apo.fillgap = 5; % gap filling in the aponeurosis (pixels)

%% Fascicle
parms.fas.cut(1) = 0.11; % relative amount kept from the middle
parms.fas.cut(2) = 0.24; % relative amount cut on the sides

% Hough parameters
parms.fas.range(1) = 10; % smallest fascicle angle considered (deg)
parms.fas.range(2) = 30; % largest fascicle angle considered (deg)
parms.fas.npeaks = 5; % amount of Hough angles included in weighted average

parms.fas.thetares =.5;
parms.fas.rhores =1;
parms.fas.houghangles = 'manual';

parms.show = false;
save('parms.mat','parms')