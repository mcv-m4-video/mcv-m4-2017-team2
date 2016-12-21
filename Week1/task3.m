clear all; close all;

addpath('../datasets');
addpath('../datasets/KITTI_devkit');
addpath('../utils');
addpath('../week1');

%for sequence 45
seq_1_gt = flow_read('../datasets/KITTI_devkit/data_stereo_flow/training/flow_noc/000045_10.png');
seq_1_estimated = flow_read('../datasets/KITTI_devkit/results_opticalflow_kitti/results/LKflow_000045_10.png');

%for sequence 157
seq_2_gt = flow_read('../datasets/KITTI_devkit/data_stereo_flow/training/flow_noc/000157_10.png');
seq_2_estimated = flow_read('../datasets/KITTI_devkit/results_opticalflow_kitti/results/LKflow_000157_10.png');

%get the error mat between the estimated motion and gt motion: 
[error1,F1_gt_val] = flow_error_map (seq_1_gt,seq_1_estimated);
[error2,F2_gt_val] = flow_error_map (seq_2_gt,seq_2_estimated);



%MSEN
msen1 = sum(error1(:))/sum(error1(:)>0);%mean of the matrix elements 
msen2 = sum(error2(:))/sum(error2(:)>0);


%PEPN
pepn1 = length(find(error1>3))/length(find(F1_gt_val));
pepn2 = length(find(error2>3))/length(find(F2_gt_val));

fprintf('\t\tWEEK 1 TASK 3 RESULTS\n');
fprintf('Sequence\t\tMSEN\t\tPEPN\n');
fprintf('--------------------------------------------------\n');
fprintf(['Seq 45\t\t', num2str(msen1), '\t\t', num2str(pepn1*100),'\n']);
fprintf(['Seq 157\t\t', num2str(msen2), '\t\t', num2str(pepn2*100),'\n']);

disp('Error visualization for sequence 45')
F1_err = flow_error_image(seq_1_gt,seq_1_estimated,0);
figure,imshow(F1_err);
% title(sprintf('PEPN Error for seq 45: %.2f %%',pepn1*100));
%msen histogram
msen1reshaped = reshape(error1,[numel(error1),1]);
figure,
histogram(msen1reshaped(msen1reshaped>0),50,'Normalization','probability'),
xlabel('MSEN value'),
ylabel('Percentage of pixels'),
title('Sequence 45');
% figure,flow_error_histogram(seq_1_gt,seq_1_estimated);

disp('Error visualization for sequence 157')
F2_err = flow_error_image(seq_2_gt,seq_2_estimated,0);
figure,imshow(F2_err);
% title(sprintf('PEPN Error for seq 157: %.2f %%',pepn2*100));
%msen histogram
msen2reshaped = reshape(error2,[numel(error2),1]);
figure,
histogram(msen2reshaped(msen2reshaped>0),50,'Normalization','probability'),
xlabel('MSEN value'),
ylabel('Percentage of pixels'),
title('Sequence 157');;
