clear all; close all;

addpath('../datasets');
addpath('../utils');
addpath('../week1');

dirGT = '../datasets/cdvd/dataset/baseline/highway/groundtruth/';
dirResults = '../datasets/cdvd/dataset/baseline/highway/results/';

results_files = list_files(dirResults);
files_number = size(results_files,1);

TP_A = 0; FP_A = 0; FN_A = 0; TN_A = 0;
TP_B = 0; FP_B = 0; FN_B = 0; TN_B = 0;

% The groundtruth images contain 5 labels namely:
% 0 : Static
% 50 : Hard shadow
% 85 : Outside region of interest
% 170 : Unknown motion (usually around moving objects, due to semi-transparency and motion blur)
% 255 : Motion

motion = 170;
count_a=1;
count_b=1;
for i=1:files_number
    file_class  = results_files(i).name(6); % A or B
    file_number = results_files(i).name(8:13);  % example: take '001201' from 'test_A_001201.png'
    
    if file_class == 'A'
        gt_A = imread(strcat(dirGT,'gt',file_number,'.png'));  % Read the A image
        test_A = imread(strcat(dirResults,'test_A_',file_number,'.png'));  % Read the GT image
        gt_A = gt_A >= motion;  % binarize gt mask
        [TP, TN, FP, FN] = get_metrics(gt_A, test_A);
        TP_A = TP_A + TP;
        FP_A = FP_A + FP;
        FN_A = FN_A + FN;
        TN_A = TN_A + TN;
        
        % % Plot some results to add to the slides
        % figure(1);
        % subplot(2,2,1); imshow(gt_A*255); title('Ground truth');
        % subplot(2,2,2); imshow(test_A*255); title('Method A Result');


        % % Create animated gif to add to the slides
        % fig = figure(1);
        % subplot(1,2,1); imshow(gt_A*255); title('Ground truth');
        % subplot(1,2,2); imshow(test_A*255); title('Method A Result');
        % outfile = 'task1_method_A.gif';
        % frame = getframe(fig);
        % im = frame2im(frame);
        % if i == 1
        %     imwrite(rgb2gray(im),outfile,'gif','LoopCount',Inf,'DelayTime',0.1);
        % else
        %     imwrite(rgb2gray(im),outfile,'gif','WriteMode','append','DelayTime',0.1);
        % end

    else % B
        gt_B = imread(strcat(dirGT,'gt',file_number,'.png'));  % Read the B image
        test_B = imread(strcat(dirResults,'test_B_',file_number,'.png'));  % Read the GT image
        gt_B = gt_B >= motion;  % binarize gt mask
        [TP, TN, FP, FN] = get_metrics (gt_B, test_B);
        TP_B = TP_B + TP;
        FP_B = FP_B + FP;
        FN_B = FN_B + FN;
        TN_B = TN_B + TN;
        
        % % Plot some results to add to the slides
        % figure(1);
        % subplot(2,2,3); imshow(gt_B*255); title('Ground truth');
        % subplot(2,2,4); imshow(test_B*255); title('Method B Result');

        % % Create animated gif to add to the slides
        % fig2 = figure(2);
        % subplot(1,2,1); imshow(gt_B*255); title('Ground truth');
        % subplot(1,2,2); imshow(test_B*255); title('Method B Result');
        % outfile2 = 'task1_method_B.gif';
        % frame2 = getframe(fig2);
        % im2 = frame2im(frame2);
        % if count_b == 1
        %     imwrite(rgb2gray(im2),outfile2,'gif','LoopCount',Inf,'DelayTime',0.1);
        %     count_b=2
        % else
        %     imwrite(rgb2gray(im2),outfile2,'gif','WriteMode','append','DelayTime',0.1);
        % end
    end
    
end

% Compute evaluation metrics
[precision_A, recall_A, F1_A] = evaluation_metrics(TP_A,TN_A,FP_A,FN_A);
[precision_B, recall_B, F1_B] = evaluation_metrics(TP_B,TN_B,FP_B,FN_B);

% Show results in tabular format
fprintf('\t\tWEEK 1 TASK 1 RESULTS\n');
fprintf('Metric\t\t\tTest A\t\tTest B\n');
fprintf('--------------------------------------------------\n');
fprintf(['True Positive\t\t', num2str(TP_A), '\t\t', num2str(TP_B),'\n']);
fprintf(['True Negative\t\t', num2str(TN_A), '\t', num2str(TN_B),'\n']);
fprintf(['False Positive\t\t', num2str(FP_A), '\t\t', num2str(FP_B),'\n']);
fprintf(['False Negative\t\t', num2str(FN_A), '\t\t', num2str(FN_B),'\n']);
fprintf(['Precission\t\t', num2str(precision_A), '\t\t', num2str(precision_B),'\n']);
fprintf(['Recall\t\t\t', num2str(recall_A), '\t\t', num2str(recall_B),'\n']);
fprintf(['F1 score\t\t', num2str(F1_A), '\t\t', num2str(F1_B),'\n']);
