clear all; close all; clc

% Create path
fold = fileparts(which('example.m'));
cd(fold); % set cd to that folder
addpath(genpath(cd)); % add all subfolders of cd to path

load('parms.mat')
n_apo = length(parms.apo.apox);

%% Step 0: Load and plot image
% data must be an NxMx3 uint8
load('example_ultrasound_image.mat')
pixtocm = (522-61)/4;
[n,m,p] = size(data);

figure
color = get(gca,'colororder');
imshow(data); hold on

%% Step 1: Frangi filtering
% aponeurosis
aponeurosis = FrangiFilter2D(double(rgb2gray(data)), parms.apo.frangi);

% fascicle
fascicle = FrangiFilter2D(double(rgb2gray(data)), parms.fas.frangi);
%% Step 2: Feature detection
% Cutting
[aponeurosis_cutted, vert, hori] = cut_apo(data, aponeurosis);

% Aponeurosis
deep_aponeurosis = deepapo_func(aponeurosis_cutted, parms.apo);
super_aponeurosis = superapo_func(aponeurosis_cutted, parms.apo);

% plot regions
parms.fas.middle = round((mean(deep_aponeurosis,'omitnan') + mean(super_aponeurosis,'omitnan'))/2);
c = [parms.fas.cut parms.apo.cut];
plot([vert(1) vert(2) vert(2) vert(1) vert(1)],[hori(1) hori(1) hori(2) hori(2) hori(1)], 'linewidth',3); % image region
plot([m*c(2) m*(1-c(2)) m*(1-c(2)) m*c(2) m*c(2)], [parms.fas.middle-(n*c(1)), parms.fas.middle-(n*c(1)) parms.fas.middle+(n*c(1)) parms.fas.middle+(n*c(1)) parms.fas.middle-(n*c(1))] ,'--', 'linewidth', 2)
plot([vert(1) vert(2)], [n*c(3) n*c(3)], '--','linewidth', 2, 'color', color(6,:))
plot([vert(1) vert(2)], [n*(1-c(3)) n*(1-c(3))], '--','linewidth', 2,'color', color(6,:))

% Fascicle (Hough)
[alpha, fascicle_lines] = dohough(fascicle,parms.fas);

%% Step 3: Variables extraction
height = mean(deep_aponeurosis-super_aponeurosis,'omitnan');

dx = parms.apo.apox(end) - parms.apo.apox(round(n_apo/2));
dy = super_aponeurosis(:,round(n_apo/2)) - super_aponeurosis(:,end); % negative if downward
betha = atan2d(dy,dx);  

% Pennation angle (phi) and fascicle length
phi = alpha - betha;
faslen = height ./ sind(phi);
faslen_cm = faslen ./ pixtocm;

%% Plot objects
plot(parms.apo.apox, deep_aponeurosis, parms.apo.apox,super_aponeurosis,'linewidth',3, 'color', color(6,:)); hold on
plot([fascicle_lines(1,1) fascicle_lines(1,3)],[fascicle_lines(1,2) fascicle_lines(1,4)],'LineWidth',3, 'color', color(2,:))

title({['Pennation angle: ' , num2str(round(phi,1)), ' deg'], ['Fascicle length: ', num2str(round(faslen_cm,1)), ' cm']})


