%%%%%%% Optical flow with Lucas - Kanade
function task1_2_lucas_kanade(seq_id)

addpath('../utils');
addpath('../datasets/KITTI_devkit');

if seq_id == 45
    gt = flow_read('../datasets/KITTI_devkit/data_stereo_flow/training/flow_noc/000045_10.png');
    img1 = imread('../datasets/KITTI_devkit/data_stereo_flow/training/image_0/000045_10.png');
    img2 = imread('../datasets/KITTI_devkit/data_stereo_flow/training/image_0/000045_11.png');
elseif seq_id == 157
    %for sequence 157
    gt = flow_read('../datasets/KITTI_devkit/data_stereo_flow/training/flow_noc/000157_10.png');
    img1 = imread('../datasets/KITTI_devkit/data_stereo_flow/training/image_0/000157_10.png');
    img2 = imread('../datasets/KITTI_devkit/data_stereo_flow/training/image_0/000157_11.png');
else
    error('Sequence not recognized')
end


% Optical flow using Horn-Schunk:
opticFlow = opticalFlowLK;
estimateFlow(opticFlow, img1);
flow = estimateFlow(opticFlow, img2);
flow_estimation_x = flow.Vx;
flow_estimation_y = flow.Vy;

% figure()
% subplot(2,2,1)
% imshow(flow.Vx)
% subplot(2,2,2)
% imshow(flow.Vy)
% subplot(2,2,3)
% imshow(flow.Orientation)
% subplot(2,2,4)
% imshow(flow.Magnitude)

%combine the flow_estimations to calculate error using kitti dev functions
flow_estimated(:,:,1) = flow_estimation_x;
flow_estimated(:,:,2) = flow_estimation_y;

%get the error mat between the estimated motion and gt motion: 
[err,F_gt_val] = flow_error_map (gt,flow_estimated);

%MSEN
msen = sum(err(:))/sum(err(:)>0);%mean of the matrix elements 

%PEPN
pepn = length(find(err>3))/length(find(F_gt_val));

fprintf('\t\tWEEK 4 TASK 1.2 - Lucas-Kanade RESULTS\n');
fprintf('Sequence\t\tMSEN\t\tPEPN\n');
fprintf('--------------------------------------------------\n');
fprintf(['Seq ',num2str(seq_id),'\t\t', num2str(msen), '\t\t', num2str(pepn*100),'\n']);

return

end