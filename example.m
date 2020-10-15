function [faslen_cm] = example(imagepath,show)

if nargin == 1
    show = 0;
end

% Create path
githubfolder = fileparts(which('example.m'));
addpath(genpath(githubfolder)); % add all subfolders of cd to path

load('parms.mat')
n_apo = length(parms.apo.apox);

%% Step 0: Load image
% data must be an NxMx3 uint8

if strcmp(imagepath(end-3:end), '.mat') == 1
    load(imagepath)
else
    data = imread(imagepath);
end

if parms.do_flip
    data = flip(data,2);
end

pixtocm = (522-61)/4;
[n,m,p] = size(data);

%% Step 1: Frangi filtering
% aponeurosis
aponeurosis = FrangiFilter2D(double(rgb2gray(data)), parms.apo.frangi);

% fascicle
fascicle = FrangiFilter2D(double(rgb2gray(data)), parms.fas.frangi);
%% Step 2: Feature detection
% Cutting
if parms.do_cutting
    [aponeurosis_cutted, vert, hori] = cut_apo(data, aponeurosis); % Cutting the muscle pixels out of the total image
else
    aponeurosis_cutted = aponeurosis;
    hori = [1 size(aponeurosis,1)];
    vert = [1 size(aponeurosis,2)];
end

% Aponeurosis
deep_aponeurosis = deepapo_func(aponeurosis_cutted, parms.apo);
super_aponeurosis = superapo_func(aponeurosis_cutted, parms.apo);

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
if show
c = parms.apo.cut;

% plot regions
figure; color = get(gca,'colororder'); imshow(data); hold on; 
plot([vert(1) vert(2) vert(2) vert(1) vert(1)],[hori(1) hori(1) hori(2) hori(2) hori(1)], 'linewidth',3,'color',color(1,:)); % image region

plot([vert(1) vert(2)], [n*c(1) n*c(1)], '--','linewidth', 2, 'color', color(6,:))
plot([vert(1) vert(2)], [n*(1-c(2)) n*(1-c(2))], '--','linewidth', 2,'color', color(3,:))

c = parms.fas.cut;
plot([m*c(2) m*(1-c(2)) m*(1-c(2)) m*c(2) m*c(2)], ...
    [parms.fas.middle-(n*c(1)), parms.fas.middle-(n*c(1)) parms.fas.middle+(n*c(1)) parms.fas.middle+(n*c(1)) parms.fas.middle-(n*c(1))] ...
    ,'--', 'linewidth', 2, 'color', color(2,:))

plot(parms.apo.apox, deep_aponeurosis,'linewidth',3, 'color', color(3,:)); hold on
plot(parms.apo.apox, super_aponeurosis,'linewidth',3, 'color', color(6,:)); 
plot([fascicle_lines(1,1) fascicle_lines(1,3)],[fascicle_lines(1,2) fascicle_lines(1,4)],'LineWidth',3, 'color', color(2,:))

title({['Pennation angle: ' , num2str(round(phi,1)), ' deg'], ['Fascicle length: ', num2str(round(faslen_cm,1)), ' cm']})
end
end

