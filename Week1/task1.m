clear all;
close all;

addpath('functions_task1');
dirGT = '../../highway/groundtruth/';
dirResults = '../../results/highway/';

results_files = list_files(dirResults);
files_number = size(results_files,1);

TP_A = 0;
FP_A = 0;
FN_A = 0;
TN_A = 0;

TP_B = 0;
FP_B = 0;
FN_B = 0;
TN_B = 0;

% The groundtruth images contain 5 labels namely:
% 0 : Static
% 50 : Hard shadow
% 85 : Outside region of interest
% 170 : Unknown motion (usually around moving objects, due to semi-transparency and motion blur)
% 255 : Motion

motion = 170;

for i=1:files_number
    file_class  = results_files(i).name(6);
    file_number = results_files(i).name(8:13);%example: take '001201' from 'test_A_001201.png'
    
    if file_class == 'A'
        gt_A = imread(strcat(dirGT,'gt',file_number,'.png')); % Read the A image
        test_A = imread(strcat(dirResults,'test_A_',file_number,'.png')); % Read the GT image
        gt_A = gt_A >= motion; %binarize gt mask
        [TP, TN, FP, FN] = get_metrics (gt_A, test_A);
        TP_A = TP_A + TP;
        FP_A = FP_A + FP;
        FN_A = FN_A + FN;
        TN_A = TN_A + TN;
    else % B
        gt_B = imread(strcat(dirGT,'gt',file_number,'.png')); % Read the B image
        test_B = imread(strcat(dirResults,'test_B_',file_number,'.png')); % Read the GT image
        gt_B = gt_B >= motion; %binarize gt mask
        [TP, TN, FP, FN] = get_metrics (gt_B, test_B);
        TP_B = TP_B + TP;
        FP_B = FP_B + FP;
        FN_B = FN_B + FN;
        TN_B = TN_B + TN;
    end
    
end

%get the metrics
[precision_A,recall_A, F1_A] = evaluation_metrics(TP_A,TN_A,FP_A,FN_A);
[precision_B,recall_B, F1_B] = evaluation_metrics(TP_B,TN_B,FP_B,FN_B);

precision_A
recall_A
F1_A

precision_B
recall_B
F1_B