clear all; close all; clc

codepath = 'C:\Users\Tim\Documents\GitHub\ultrasound-automated-algorithm';
datapath = 'C:\Users\Tim\Google Drive\william ultrasound\For manual estimation';

addpath(genpath(codepath));
addpath(genpath(datapath));
cd(datapath)
files = dir('*.png');

cd('C:\Users\Tim\Documents\GitHub\ultrasound-automated-algorithm\Parameters')
load('parms.mat')

%% get estimates
parms.show = false;
alpha.auto = nan(length(files),1);
betha.auto = nan(length(files),1);
thickness.auto = nan(length(files),1);

for i = 1:length(files)
    filename = files(i).name;
    disp(['Trial #', num2str(i),': ', filename])
    
    data = imread(filename);
    parms.apo.apox = 100:10:(size(data,2)-100);
    
    % subjects 4, 8, 9 and 10 have thicker skin and need different
    % superficial aponeurosis region
    if strcmp(filename(2:3), '4_') || strcmp(filename(2:3), '8_')|| strcmp(filename(2:3), '9_') || strcmp(filename(2:3), '10')
        parms.apo.super.cut = [.1 .4];
    else
        parms.apo.super.cut = [.05 .15];
    end
    
    [alpha.auto(i,1), betha.auto(i,1), thickness.auto(i,1)] = auto_ultrasound(data,parms);
end

% don't allow betha > 0
betha.auto(betha.auto>0) = 0;

% load manual estimates
load('manual_estimates.mat');

% pennation: difference between fascicle and superficial aponeurosis angle
phi.auto = alpha.auto - betha.auto;
phi.manual = manual.alpha - manual.betha;
thickness.manual = manual.height .* cosd(manual.betha);

% calculate fascicle length in cm
faslen.manual = manual.pixtocmratio .* thickness.manual ./ sind(phi.manual);
faslen.auto = manual.pixtocmratio .* thickness.auto ./ sind(phi.auto);

%% compare estimates
figure;
subplot(231); plot(faslen.manual(:,1), faslen.manual(:,2),'.'); 
subplot(232); plot(faslen.manual(:,1), faslen.manual(:,3),'.'); 
subplot(233); plot(faslen.manual(:,2), faslen.manual(:,3),'.');
subplot(234); plot(faslen.manual(:,1), faslen.auto, '.');
subplot(235); plot(faslen.manual(:,2), faslen.auto, '.'); 
subplot(236); plot(faslen.manual(:,3), faslen.auto, '.');

% Make nice
titles = {'Manual 1 versus Manual 2', 'Manual 1 versus Manual 3', 'Manual 2 versus Manual 3', 'Algorithm vs. Manual 1', 'Algorithm vs. Manual 2', 'Algorithm vs. Manual 3'};

for i = 1:6
    subplot(2,3,i);
    xlabel('Fascicle length (cm)'); ylabel('Fascicle length (cm)');
    hold on; plot([0 15], [0 15], 'k-')
    axis equal
    axis([0 15 0 15])
    title(titles{i})
end

set(gcf,'units','normalized','position', [.2 .2 .6 .6])

% Compute stats
RMSE = mean(abs(faslen.manual - faslen.auto),'omitnan'); % cm
RMSD = mean(abs([faslen.manual(:,1) - faslen.manual(:,2), faslen.manual(:,1) - faslen.manual(:,3), faslen.manual(:,2) - faslen.manual(:,3)]),'omitnan'); % cm

disp(['RMSDs between manual estimates: ', num2str(RMSD), ' cm'])
disp(['RMSEs between algorithm and manual estimates: ', num2str(RMSE), ' cm'])

% CMC
subj = repmat(1:9, 18, 1);
subj = subj(1:numel(subj)); subj = subj(:);
overall_mean = mean([mean(faslen.manual,2) faslen.auto],2);

for s = 1:9
    idx = subj == s;
    
        MSDR = mean((faslen.auto(idx) - overall_mean(idx)).^2, 'omitnan');
        MSDT = mean((faslen.auto(idx) - mean(overall_mean(idx),'omitnan')).^2, 'omitnan');

        CMC(s) = sqrt(1 - MSDR/MSDT);

end

% ICC
disp(['Mean CMC = ', num2str(mean(CMC))])
disp(['ICC = ', num2str(ICC(faslen.manual,'1-1'))])

%% plot fascicle length versus mean of algorithm
frange = [0 15];
fig = figure(4);
color = get(gca,'colororder');

[bf, bfint] = regress(faslen.auto, mean(faslen.manual,2));
plot(frange, frange*bf,'-','color', color(2,:),'linewidth',3); hold on
plot(frange,frange, 'k:','linewidth',2);

plot(faslen.manual, faslen.auto,'o','linewidth',2,'color', color(1,:).^1.1, 'markerfacecolor',color(1,:).^.9); hold on

axis equal
axis([frange frange])

ylabel('Algorithm estimate (cm)');
xlabel('Human estimate (cm)');
title('Algorithm vs. Human')


%% investigate bad trials
dcm_obj = datacursormode(fig);
set(dcm_obj,'DisplayStyle','datatip','SnapToDataVertex','off','Enable','on')
pause
c_info = getCursorInfo(dcm_obj);
i = find(faslen.auto == c_info.Position(2));
parms.show = 1;
filename = files(i).name;
data = imread(filename);

tic
figure;
auto_ultrasound(data,parms);
toc

