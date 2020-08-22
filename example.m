clear all; close all; clc

% Create path
filename = mfilename; % name of this script
loca = mfilename('fullpath'); % full name, including path
fold = loca(1:end-length(filename)); % folder, excluding name
cd(fold); % set cd to that folder
addpath(genpath(cd)); % add all subfolders of cd to path

load('parms.mat')
n = length(parms.apo.apox);

%% Step 0: load image
% data must be an NxMx3 uint8
load('example_ultrasound_image.mat')
parms.fas.middle = round(size(data,1)/2);
pixtocm = (522-61)/4;

%% Step 1: Frangi filtering
% aponeurosis
parms.frangi.FrangiScaleRange = [8 15];
aponeurosis = FrangiFilter2D(double(rgb2gray(data)), parms.frangi);

% fascicle
parms.frangi.FrangiScaleRange = [1 3];
fascicle = FrangiFilter2D(double(rgb2gray(data)), parms.frangi);

%% Step 2: Feature detection
% Cutting
aponeurosis_cutted = cut_apo(data, aponeurosis);

% Aponeurosis
deep_aponeurosis = deepapo_func(aponeurosis_cutted, parms.apo);
super_aponeurosis = superapo_func(aponeurosis_cutted, parms.apo);

% Fascicle (Hough)
[alpha, fascicle_lines] = dohough(fascicle,parms.fas);

%% Step 3: Variables extraction
height = mean(deep_aponeurosis-super_aponeurosis,'omitnan');

dx = parms.apo.apox(end) - parms.apo.apox(round(n/2));
dy = super_aponeurosis(:,round(n/2)) - super_aponeurosis(:,end); % negative if downward
betha = atan2d(dy,dx);  

% Pennation angle (phi) and fascicle length
phi = alpha - betha;
faslen = height ./ sind(phi);
faslen_cm = faslen ./ pixtocm;

%% Plotting
figure
imshow(data)
line('xdata',parms.apo.apox,'ydata',deep_aponeurosis,'color','red','linewidth',2)
line('xdata',parms.apo.apox,'ydata',super_aponeurosis,'color','red','linewidth',2)
line('xdata',[fascicle_lines(1,1) fascicle_lines(1,3)],'ydata',[fascicle_lines(1,2) fascicle_lines(1,4)],'LineWidth',2,'Color','green');
title({['Pennation angle: ' , num2str(round(phi,1)), ' deg'], ['Fascicle length: ', num2str(round(faslen_cm,1)), ' cm']})
