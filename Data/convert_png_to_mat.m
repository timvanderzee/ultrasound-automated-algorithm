clear all; close all; clc

%% Example 1
data = imread('example_ultrasound_image2.png');
data = rgb2gray(data);
data = flip(data,2);
pixtocm = (1032-9) / 5;
figure; imshow(data);
save('example_ultrasound_image2.mat', 'data','pixtocm')

%% Example 2
data = imread('example_ultrasound_image3.png');
data = rgb2gray(data);
data = flip(data,2);
figure; imshow(data);
pixtocm = (1026-1) / 5;

save('example_ultrasound_image3.mat', 'data','pixtocm')