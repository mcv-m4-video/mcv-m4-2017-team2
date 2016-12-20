clear all; close all;

addpath('../datasets');
addpath('../utils');
addpath('../week1');

dirGT = '../datasets/cdvd/dataset/baseline/highway/groundtruth/';
dirResults = '../datasets/cdvd/dataset/baseline/highway/results/';

results_files = list_files(dirResults);
files_number = size(results_files,1);
vectsize = files_number/2;

TP_A = 0;
FP_A = 0;
FN_A = 0;
TN_A = 0;

TP_B = 0;
FP_B = 0;
FN_B = 0;
TN_B = 0;

% TPAvect=zeros(1,vectsize);
% FPAvect=zeros(size(TPAvect));
% FNAvect=zeros(size(TPAvect));
% TNAvect=zeros(size(TPAvect));
% 
% TPBvect=zeros(size(TPAvect));
% FPBvect=zeros(size(TPAvect));
% FNBvect=zeros(size(TPAvect));
% TNBvect=zeros(size(TPAvect));

%For F1 vs De Sync
desync= 0:25;

% %For frame by frame comparisson
% desync = [0 5 10 25];
% precision_A = zeros(size(desync,2),vectsize);
% recall_A = zeros(size(desync,2),vectsize);
% F1_A = zeros(size(desync,2),vectsize);
% 
% precision_B = zeros(size(desync,2),vectsize);
% recall_B = zeros(size(desync,2),vectsize);
% F1_B = zeros(size(desync,2),vectsize);

motion = 170;
tic
for n=1:size(desync,2)

    for i=1:files_number - desync(n)
        file_class  = results_files(i).name(6);
        file_number = results_files(i).name(8:13);%example: take '001201' from 'test_A_001201.png'
        file_number_desync = results_files(i+desync(n)).name(8:13);
        
        if file_class == 'A'
            gt_A = imread(strcat(dirGT,'gt',file_number,'.png')); % Read the A image
            test_A = imread(strcat(dirResults,'test_A_',file_number_desync,'.png')); % Read the GT image
            gt_A = gt_A >= motion; %binarize gt mask
            [TP, TN, FP, FN] = get_metrics (gt_A, test_A);
            
%             %metrics vectors for plotting F1 vs De Sync
%             TPAvect(i) = TP;
%             FPAvect(i) = FP;
%             FNAvect(i) = FN;
%             TNAvect(i) = TN;
            
            TP_A = TP_A + TP;
            FP_A = FP_A + FP;
            FN_A = FN_A + FN;
            TN_A = TN_A + TN;
        else % B
            gt_B = imread(strcat(dirGT,'gt',file_number,'.png')); % Read the B image
            test_B = imread(strcat(dirResults,'test_B_',file_number_desync,'.png')); % Read the GT image
            gt_B = gt_B >= motion; %binarize gt mask
            [TP, TN, FP, FN] = get_metrics (gt_B, test_B);
            
%             %metrics vectors for plotting F1 vs De Sync
%             TPBvect(i-200) = TP;
%             FPBvect(i-200) = FP;
%             FNBvect(i-200) = FN;
%             TNBvect(i-200) = TN;
%             
            TP_B = TP_B + TP;
            FP_B = FP_B + FP;
            FN_B = FN_B + FN;
            TN_B = TN_B + TN;
        end
        
    end

%     %get the metrics for frame by frame F1
%     [precision_A(n,:),recall_A(n,:), F1_A(n,:)] = evaluation_metrics(TPAvect,TNAvect,FPAvect,FNAvect);   
%     [precision_B(n,:),recall_B(n,:), F1_B(n,:)] = evaluation_metrics(TPBvect,TNBvect,FPBvect,FNBvect);

    %For plotting total F1 vs De Sync
    [precision_A(n),recall_A(n), F1_A(n)] = evaluation_metrics(TP_A,TN_A,FP_A,FN_A);
    [precision_B(n),recall_B(n), F1_B(n)] = evaluation_metrics(TP_B,TN_B,FP_B,FN_B);
    
end
  
time = toc

% figure(1)
% plot(transpose(F1_A(:,1:175)));
% title('Forward de-syncronized results for A test')
% xlabel('Frame')
% ylabel('F1 measure')
% legend('No delay',...
%     strcat('Delay of ', int2str(desync(2)),' frames'),...
%     strcat('Delay of ', int2str(desync(3)),' frames'),...
%     strcat('Delay of ', int2str(desync(4)),' frames'));
% 
% figure(2)
% plot(transpose(F1_B(:,1:175)));
% title('Forward de-syncronized results for B test')
% xlabel('Frame')
% ylabel('F1 measure')
% legend('No delay',...
%     strcat('Delay of ', int2str(desync(2)),' frames'),...
%     strcat('Delay of ', int2str(desync(3)),' frames'),...
%     strcat('Delay of ', int2str(desync(4)),' frames'));

%For plotting F1 vs De Sync
plot(desync, F1_A,desync ,F1_B);
title('F1 relation to de syncronization')
xlabel('Frame de syncronization')
ylabel('F1 measure')
legend('Test A','Test B')


