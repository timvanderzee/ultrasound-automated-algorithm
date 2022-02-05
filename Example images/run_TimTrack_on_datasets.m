clear all; close all; clc
fullpath = which('run_TimTrack_on_datasets.m');
mainfolder = fullpath(1:end-26);

%% dataset 1
load('data1setparms.mat')
parms.show = 1; parms.fas.show = 1;
parms.extrapolation = 1;

for S = [1:5, 8:11]
    cd([mainfolder, 'raw\TimTrack paper\dataset 1\S', num2str(S)])
    
    files = dir('*.png');
    for i = 1:length(files)
        cd([mainfolder, 'raw\TimTrack paper\dataset 1\S', num2str(S)])
        data = imread(files(i).name);
        figure(1)
        do_TimTrack(data, parms);
        cd([mainfolder, 'analyzed\TimTrack paper\dataset 1\S', num2str(S)])
        saveas(gcf, files(i).name(1:end-4), 'jpeg')
    end
end
        
%% dataset 2
tasks = {'jumping','range-of-motion'};

parms.apo.method = 'Frangi';
parms.apo.deep.order = 2;
parms.ROI = [119   682;  67   511];

for S = 1:2
    
    cd([mainfolder, 'raw\TimTrack paper\dataset 2\',tasks{S}])
    
    files = dir('*.png');
    for i = 1:length(files)
        cd([mainfolder, 'raw\TimTrack paper\dataset 2\',tasks{S}])
        data = rgb2gray(imread(files(i).name));
        figure(1)
        do_TimTrack(data, parms);
        cd([mainfolder, 'analyzed\TimTrack paper\dataset 2\',tasks{S}])
        saveas(gcf, files(i).name(1:end-4), 'jpeg')
    end
end

%% dataset 3
tasks = {'030','120','210','500','isometric'};
parms.apo.method = 'Hough';
parms.apo.deep.order = 1;
parms.apo.deep.cut = [.3 .7];
parms.apo.super.cut = [.02 .2];
parms.ROI = [384 1281; 97 807];

for S = 1:5
    
    cd([mainfolder, 'raw\TimTrack paper\dataset 3\',tasks{S}])
    
    files = dir('*.jpg');
    for i = 1:length(files)
        cd([mainfolder, 'raw\TimTrack paper\dataset 3\',tasks{S}])
        data = rgb2gray(imread(files(i).name));
        figure(1)
        [~,parms] = do_TimTrack(data, parms);
        cd([mainfolder, 'analyzed\TimTrack paper\dataset 3\',tasks{S}])
        saveas(gcf, files(i).name(1:end-4), 'jpeg')
    end
end

%% dataset 4
samples = {'SampleA','SampleB'};
parms.fas.redo_ROI = 1;
parms.apo.deep.cut = [.3 .9];
parms.apo.super.cut = [.03 .3];
parms.flip_image = 1;

for S = 1:2
    
    cd([mainfolder, 'raw\TimTrack paper\dataset 4\',samples{S}])
    
    if S == 1,      files = dir('*.png'); parms.ROI = [245   988; 48   688];
    elseif S == 2,  files = dir('*.bmp'); parms.ROI = [250   600; 79   506];
    end
    
    for i = 1:length(files)
        cd([mainfolder, 'raw\TimTrack paper\dataset 4\',samples{S}])
        data = rgb2gray(imread(files(i).name));
        figure(1)
        [~,parms] = do_TimTrack(data, parms);
        cd([mainfolder, 'analyzed\TimTrack paper\dataset 4\',samples{S}])
        saveas(gcf, files(i).name(1:end-4), 'jpeg')
    end
end