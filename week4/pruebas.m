%%% pruebas

clearvars
close all

dirinput = '..\datasets\data_stereo_flow\training\image_0\';

im_number = 45;
% im_number = 157;

filename_old = strcat(sprintf('%06d', im_number), '_10.png');
filename_curr = strcat(sprintf('%06d', im_number), '_11.png');

I_old = double(imread(strcat(dirinput, filename_old))) / 255;
I_curr = double(imread(strcat(dirinput, filename_curr))) / 255;

p = [0.1, 0.01, -0.02, 0.02, -3, -3];




