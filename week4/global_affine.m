clearvars
close all

dirinput = '..\datasets\data_stereo_flow\training\image_0\';

im_number = 45;
% im_number = 157;

filename_old = strcat(sprintf('%06d', im_number), '_10.png');
filename_curr = strcat(sprintf('%06d', im_number), '_11.png');

I_old = double(imread(strcat(dirinput, filename_old))) / 255;
I_curr = double(imread(strcat(dirinput, filename_curr))) / 255;

% I_old = imresize(I_old, [100, 400]);
% I_curr = imresize(I_curr, [100, 400]);

% I_old = imresize(I_old, [10, 20]);
% I_curr = imresize(I_curr, [10, 20]);

% p0 = [1, 0, 0, 1, 0, 0]';
p0 = [0.8028  -0.0982   0.0332   0.9110   1.7177   0.6123]';
maxiter = 100000;
dt = 0.00001;
delta = 0.00000001;

% Compute the model parameters:
p = gradient_descent_global_affine5(I_curr, I_old, p0, dt, maxiter, delta);
p = p0;

% Visualize the result:
step = 20;
global_affine_visualize2(I_old, p, step);



