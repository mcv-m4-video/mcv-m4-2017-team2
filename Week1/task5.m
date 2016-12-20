% Task 5: optical flow plot
% Plot the optical flow (Quiver function in Matlab)
%   Dense representation -> too many motion vectors
%       --> Propose a simplification method for a clean visualization.


clear all; close all;

addpath('../datasets');
addpath('../datasets/KITTI_devkit');
addpath('../utils');
addpath('../week1');

% First, show color representation of optical flow
filename = '000000_10.png';
original_image = imread(strcat('../datasets/KITTI_devkit/data_stereo_flow/training/image_0/', filename));
F = flow_read(strcat('../datasets/KITTI_devkit/data_stereo_flow/training/flow_noc/', filename));  % loads flow field F from png file
optical_flow_image = flow_to_color(F);  % computes color representation of optical flow field

figure(1);
subplot(2,1,1); imshow(original_image); title('Original Image');
subplot(2,1,2); imshow(optical_flow_image); title('Color representation of optical flow field');
imshow(I);

