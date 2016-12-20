clear all; close all;

addpath('../datasets');
addpath('../utils');
addpath('../week1');

dirGT = '../datasets/cdvd/dataset/baseline/highway/groundtruth/';
dirResults = '../datasets/cdvd/dataset/baseline/highway/results/';

% dirGT = '../../highway/groundtruth/';
% dirResults = '../../results/highway/';

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

TPAvect=zeros(1,files_number/2);
FPAvect=zeros(1,files_number/2);
FNAvect=zeros(1,files_number/2);
TNAvect=zeros(1,files_number/2);

desync= [0 4 10 25];

precision_A = zeros(size(desync,2),files_number/2);
recall_A = zeros(size(desync,2),files_number/2);
F1_A = zeros(size(desync,2),files_number/2);

motion = 170;

for n=1:size(desync,2)

    for i=1:files_number-desync(n)
        file_class  = results_files(i).name(6);
        file_number = results_files(i).name(8:13);%example: take '001201' from 'test_A_001201.png'
        file_number_desync = results_files(i+desync(n)).name(8:13);
        
        if file_class == 'A'
            gt_A = imread(strcat(dirGT,'gt',file_number,'.png')); % Read the A image
            test_A = imread(strcat(dirResults,'test_A_',file_number_desync,'.png')); % Read the GT image
            gt_A = gt_A >= motion; %binarize gt mask
            [TP, TN, FP, FN] = get_metrics (gt_A, test_A);
            %metrics vectors
            TPAvect(i) = TP;
            FPAvect(i) = FP;
            FNAvect(i) = FN;
            TNAvect(i) = TN;
            
            TP_A = TP_A + TP;
            FP_A = FP_A + FP;
            FN_A = FN_A + FN;
            TN_A = TN_A + TN;
        else % B
%             gt_B = imread(strcat(dirGT,'gt',file_number,'.png')); % Read the B image
%             test_B = imread(strcat(dirResults,'test_B_',file_number_desync,'.png')); % Read the GT image
%             gt_B = gt_B >= motion; %binarize gt mask
%             [TP, TN, FP, FN] = get_metrics (gt_B, test_B);
%             TP_B = TP_B + TP;
%             FP_B = FP_B + FP;
%             FN_B = FN_B + FN;
%             TN_B = TN_B + TN;
        end
        
    end

    %get the metrics
    [precision_A(n,:),recall_A(n,:), F1_A(n,:)] = evaluation_metrics(TPAvect,TNAvect,FPAvect,FNAvect);
    %[precision_B(n),recall_B(n), F1_B(n)] = evaluation_metrics(TP_B,TN_B,FP_B,FN_B);
    
end

figure
plot(transpose(F1_A));
title('Forward de-syncronized results')
xlabel('Frame')
ylabel('F1')
legend('No delay',...
    strcat('Delay of ',int2str(desync(2)),' frames'),...
    strcat('Delay of ',int2str(desync(3)),' frames'),...
    strcat('Delay of ',int2str(desync(4)),' frames'));
