clear all; close all; clc
set(0, 'DefaultLineLineWidth', 1.5);

cd('C:\Users\tim.vanderzee\Documents\ultrasound-automated-algorithm')
addpath(genpath(cd))
load('parms.mat')
parms.show = 1;
parms.fas.show = parms.show;

%% load video
cd('D:\Ultrasound\Sample Videos\Sample Videos\Sample Subject Data\S1\Ultrasound\MP4')
files = dir('*.mp4');
ROI =    [219   922;    51   400];

for j = 1:length(files)
    filename = files(j).name;
    cd('D:\Ultrasound\Sample Videos\Sample Videos\Sample Subject Data\S1\Ultrasound\MP4')
    vidObj = VideoReader(filename);
        
    i = 0;
    clear geofeatures apovecs

    while(hasFrame(vidObj))
        i = i+1;  disp(i)
    
        vidFrame = rgb2gray(flip(readFrame(vidObj),2));
    
        data = vidFrame(ROI(2,1):ROI(2,2), ROI(1,1):ROI(1,2));
        
        figure(1)
        [geofeatures(i), apovecs(i)] = auto_ultrasound(data,parms);
        drawnow;
    
        if i == 1,     gif(['TimTrack_on_Drazan_data_',filename(1:end-4),'.gif'])
        else, gif;
        end   
  
    end
    cd('D:\Ultrasound\TimTrack')
    save(['TimTrack_on_Drazan_data_',filename(1:end-4),'.mat'], 'geofeatures', 'apovecs', 'parms','ROI','vidObj');
end


