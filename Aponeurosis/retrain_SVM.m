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
[parms.apo.SVM.super.model, parms.apo.SVM.super.X, parms.apo.SVM.super.Y] = train_apo_SVM(data(:,:,:,random_order),parms,'super');
[parms.apo.SVM.deep.model, parms.apo.SVM.deep.X, parms.apo.SVM.deep.Y] = train_apo_SVM(data(:,:,:,random_order),parms,'deep');
    
% save new SVM model
cd('Parameters')
load('parms.mat','parms');