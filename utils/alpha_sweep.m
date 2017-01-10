%function for sweeping through several thresholds to compare performance
function [time] = alpha_sweep(data, alpha_vect, mu_matrix, sigma_matrix, range_images, start_img, dirInputs, input_files, background, foreground, dirGT)
tic

precision = zeros(1,size(alpha_vect,2));
recall = zeros(1,size(alpha_vect,2));
F1 = zeros(1,size(alpha_vect,2));

TP_ = [];
TN_ = [];
FP_ = [];
FN_ = [];

for n=1:size(alpha_vect,2)
    
    alpha = alpha_vect(n);
    
    %Metrics for alpha sweep
    TP_global = 0;
    TN_global = 0;
    FP_global = 0;
    FN_global = 0;
    
    %detect foreground and compare results
    for i=1:(round(range_images/2)+1)
        index = i + (start_img + range_images/2) - 1;
        file_number = input_files(index).name(3:8);
        test_backg_in(:,:,i) = double(rgb2gray(imread(strcat(dirInputs,'in',file_number,'.jpg'))));
        detection(:,:,i) = (abs(test_backg_in(:,:,i)-mu_matrix) >= (alpha * (sigma_matrix + 2)));
        gt = imread(strcat(dirGT,'gt',file_number,'.png'));
        gt_back = gt <= background;
        gt_fore = gt >= foreground;
%         [TP, TN, FP, FN] = get_metrics (gt_fore, detection(:,:,i));
        [TP, TN, FP, FN] = get_metrics_2val(gt_back, gt_fore, detection(:,:,i));

        %option of getting overall metrics
        TP_global = TP_global + TP;
        TN_global = TN_global + TN;
        FP_global = FP_global + FP;
        FN_global = FN_global + FN;
    end

    %global metrics for threshold sweep:
    [precision(n), recall(n), F1(n)] = evaluation_metrics(TP_global,TN_global,FP_global,FN_global);
    TP_(n) = TP_global;
    TN_(n) = TN_global;
    FP_(n) = FP_global;
    FN_(n) = FN_global;

end    

time = toc;

save(strcat(data,'_task1_results.mat'),'TP_','TN_','FP_','FN_', 'precision', 'recall', 'F1','alpha_vect');

x= alpha_vect;
figure(1)
plot(x, transpose(precision), 'b', x, transpose(recall), 'r',  x, transpose(F1), 'k');
title(strcat({'Precision, Recall & F1 vs Threshold for dataset '},data));
xlabel('Threshold');
ylabel('Measure');
legend('Precision','Recall','F1');

figure(2)
plot(x, transpose(TP_),'b', x, transpose(TN_),'g', x, transpose(FP_),'r', x, transpose(FN_));
title(strcat({'TP, TN, FP & FN vs Threshold for '},data));
xlabel('Threshold');
ylabel('Pixels');
legend('TP','TN','FP','FN');

%AUC
% figure(3)
% plot(recall, transpose(precision), 'g');%, recall, transpose(precision .* recall),'b');
% title(strcat({'Recall vs Precision & AUC for dataset '},data));
% xlabel('Recall');
% ylabel('Precision');
% legend('Recall vs Precision','Area under the curve');
end
