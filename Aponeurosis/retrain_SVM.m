clear all; clc; close all;
P = mfilename('fullpath');
F = mfilename;
cd(P(1:end-length(F)))
cd ..
addpath(genpath(cd))

% load parameters and training data
load('parms.mat');
load('example_ultrasound_video.mat')

% shuffle data
random_order = randperm(size(data,4));

% train SVM model
[parms.apo.super.SVM.model, parms.apo.super.SVM.X, parms.apo.super.SVM.Y] = train_apo_SVM(data(:,:,:,random_order),parms,'super');
[parms.apo.deep.SVM.model, parms.apo.deep.SVM.X, parms.apo.deep.SVM.Y] = train_apo_SVM(data(:,:,:,random_order),parms,'deep');
    
% save new SVM model
cd('Parameters')
save('parms.mat','parms');