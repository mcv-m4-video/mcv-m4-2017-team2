function [msen, pepn]= task1_1(seq_id, block_size, search_area)

%clear all; close all;

addpath('../datasets');
addpath('../datasets/KITTI_devkit');
addpath('../utils');
addpath('../week1');

%for sequence 45
%seq_id = 45;
if seq_id == 45
    gt = flow_read('../datasets/KITTI_devkit/data_stereo_flow/training/flow_noc/000045_10.png');
    img1 = imread('../datasets/KITTI_devkit/data_stereo_flow/training/image_0/000045_10.png');
    img2 = imread('../datasets/KITTI_devkit/data_stereo_flow/training/image_0/000045_11.png');
elseif seq_id == 157
    %for sequence 157
    gt = flow_read('../datasets/KITTI_devkit/data_stereo_flow/training/flow_noc/000157_10.png');
    img1 = imread('../datasets/KITTI_devkit/data_stereo_flow/training/image_0/000157_10.png');
    img2 = imread('../datasets/KITTI_devkit/data_stereo_flow/training/image_0/000157_11.png');
end


%block_size = 40;
%search_area = 20;
% optical flow using block matching
[flow_estimation_x, flow_estimation_y]  = block_matching(img1, img2, block_size, search_area);

%combine the flow_estimations to calculate error using kitti dev functions
flow_estimated(:,:,2) = flow_estimation_x;
flow_estimated(:,:,1) = flow_estimation_y;

%get the error mat between the estimated motion and gt motion: 
[error,F_gt_val] = flow_error_map (gt,flow_estimated);

%MSEN
msen = sum(error(:))/sum(error(:)>0);%mean of the matrix elements 

%PEPN
pepn = length(find(error>3))/length(find(F_gt_val));

% fprintf('\t\tWEEK 4 TASK 1.1 RESULTS\n');
% fprintf('Sequence\t\tMSEN\t\tPEPN\n');
% fprintf('--------------------------------------------------\n');
% fprintf(['Seq ',num2str(seq_id),'\t\t', num2str(msen), '\t\t', num2str(pepn),'\n']);%*100),'\n']);
end


