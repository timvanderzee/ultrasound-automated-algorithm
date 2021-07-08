clear all; close all; clc

% imname = input('Type the name of your ultrasound image ','s');
imname = 'example_ultrasound_image4.png';

rgb_image = imread(imname);
if size(rgb_image,3) > 1
    gray_image = rgb2gray(rgb_image);
end

figure(1); imshow(gray_image);

%% Flipping
% need_flipping = input('Does your image require flipping? (Y/N) ','s');
need_flipping = 'N';

if strcmp(need_flipping, 'Y')
    gray_image = flip(gray_image,2);
    figure(1); imshow(gray_image);
end
    
%% Cutting
% need_cutting = input('Does your image require cutting? (Y/N) ','s');
need_cutting = 'Y';

if strcmp(need_cutting, 'Y')
    ROI = cut_image(gray_image);
    data = gray_image(ROI(2,1):ROI(2,2), ROI(1,1):ROI(1,2));
    figure(1); imshow(data);
else, data = gray_image;
end

%% Pixtocm
% idepth = input('Specify the image depth (cm): ');
idepth = 4;
pixtocm = size(data,1) / idepth;

imfold = which(imname);
cd(imfold(1:end-length(imname)))
%% Saving
save([imname(1:end-4),'.mat'], 'data', 'pixtocm')
