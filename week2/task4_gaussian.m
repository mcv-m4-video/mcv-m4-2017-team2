close all;

addpath('../datasets');
addpath('../utils');
addpath('../week2');

%Datasets to use 'highway' , 'fall' or 'traffic'
%Choose dataset images to work on from the above:
data = 'fall';

[start_img, range_images, dirInputs, dirGT] = load_data(data);

%open dataset
input_files = list_files(dirInputs);

%Evaluating metrics
background = 50;
foreground = 255;

%color space
colorspace = 'YUV'; % 'YUV' 'HSV' 
[mu_matrix, sigma_matrix] = train_background_color(start_img, range_images, input_files, dirInputs, colorspace);

%Alpha parameter for sigma weight in background comparison (for frame by
%frame plot set alpha to scalar, for threshold sweep set alpha to vector)
alpha_vect = 0:0.25:5;
% alpha_vect = 2;


%Use when alpha_vect is a single value
% single_alpha(alpha_vect, mu_matrix, sigma_matrix, range_images, start_img, dirInputs, input_files, background, foreground, dirGT);

%Use when alpha_vect is a vector of thresholds
time = alpha_sweep_color(alpha_vect, mu_matrix, sigma_matrix, range_images, start_img, dirInputs, input_files, background, foreground, dirGT, colorspace)
