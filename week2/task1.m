function task1

clear all; close all;

addpath('../datasets');
addpath('../utils');
addpath('../week2');

%Datasets to use 'highway' , 'fall' or 'traffic'
%Choose dataset images to work on from the above:
data = 'highway';

[start_img, range_images, dirInputs] = load_data(data);

%open dataset
input_files = list_files(dirInputs);

%Evaluating data and metrics
dirGT = '../datasets/cdvd/dataset/baseline/highway/groundtruth/';
background = 55;
foreground = 250;

[mu_matrix, sigma_matrix] = train_background(start_img, range_images, input_files, dirInputs);

%Alpha parameter for sigma weight in background comparison (for frame by
%frame plot set alpha to scalar, for threshold sweep set alpha to vector)
alpha_vect = 1.75; %0.25:0.25:10;


%Use when alpha_vect is a single value
single_alpha(alpha_vect, mu_matrix, sigma_matrix, range_images, start_img, dirInputs, input_files, background, foreground, dirGT);

%Use when alpha_vect is a vector of thresholds
%[time] = alpha_sweep(alpha_vect, mu_matrix, sigma_matrix, range_images, start_img, dirInputs, input_files, background, foreground, dirGT)

end