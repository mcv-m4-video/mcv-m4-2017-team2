clearvars;
close all;

addpath('../datasets');
addpath('../utils');
addpath('../week1');

dirGT = '../datasets/cdvd/dataset/baseline/highway/groundtruth/';
dirResults = '../datasets/cdvd/dataset/baseline/highway/results/';

results_files = list_files(dirResults);
nfiles = size(results_files,1);

TP_A = zeros(1,200);
FP_A = zeros(1,200);
FN_A = zeros(1,200);
TN_A = zeros(1,200);
precision_A = zeros(1,200);
recall_A = zeros(1,200);
F1_A = zeros(1,200);

TP_B = zeros(1,200);
FP_B = zeros(1,200);
FN_B = zeros(1,200);
TN_B = zeros(1,200);
precision_B = zeros(1,200);
recall_B = zeros(1,200);
F1_B = zeros(1,200);

TFG = zeros(1,200); % Total Foreground pixels.

count_A = 0;
count_B = 0;

% The groundtruth images contain 5 labels namely:
% 0 : Static
% 50 : Hard shadow
% 85 : Outside region of interest
% 170 : Unknown motion (usually around moving objects, due to semi-transparency and motion blur)
% 255 : Motion

motion = 170;

for i = 1:nfiles
    file_class  = results_files(i).name(6);
    file_number = results_files(i).name(8:13);%example: take '001201' from 'test_A_001201.png'
    gt_im = imread(strcat(dirGT,'gt',file_number,'.png')); % Read the GT image
    
    if file_class == 'A'
        count_A = count_A + 1;
        test_A = imread(strcat(dirResults,'test_A_',file_number,'.png')); % Read the A image
        gt_im = gt_im >= motion; %binarize gt mask
        [TP_A(count_A), TN_A(count_A), FP_A(count_A), FN_A(count_A)] = get_metrics (gt_im, test_A);
        [precision_A(count_A), recall_A(count_A), F1_A(count_A)] = ...
            evaluation_metrics(TP_A(count_A), TN_A(count_A), FP_A(count_A), FN_A(count_A));
        TFG(count_A) = sum(sum(gt_im));
        
    else % B
        count_B = count_B + 1;
        test_B = imread(strcat(dirResults,'test_B_',file_number,'.png')); % Read the B image
        gt_im = gt_im >= motion; %binarize gt mask
        [TP_B(count_B), TN_B(count_B), FP_B(count_B), FN_B(count_B)] = get_metrics (gt_im, test_B);
        [precision_B(count_B), recall_B(count_B), F1_B(count_B)] = ...
            evaluation_metrics(TP_B(count_B), TN_B(count_B), FP_B(count_B), FN_B(count_B));
    end
end

frames = [1201:1400];

max_F1 = max([F1_A, F1_B]);
min_F1 = min([F1_A, F1_B]);

figure(1)
plot(frames, F1_A, 'b', 'LineWidth', 2)
hold on
plot(frames, F1_B, 'r', 'LineWidth', 2)
title('F1')
legend('F1 test A', 'F1 test B', 'Location', 'southeast')
axis([1201 1400 min_F1 max_F1])

figure(2)
plot(frames, TFG, 'k', 'LineWidth', 2)
hold on
plot(frames, TP_A, 'b', 'LineWidth', 2)
plot(frames, TP_B, 'r', 'LineWidth', 2)
title('F1')
legend('Total Foreground pixels', 'True Positives test A', 'True Positives test B', 'North', 'Location', 'North')
axis([1201 1400 0 max(TFG)])





