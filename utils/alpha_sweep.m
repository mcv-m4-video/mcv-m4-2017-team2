%function for sweeping through several thresholds to compare performance
function [time] = alpha_sweep(alpha_vect, mu_matrix, sigma_matrix, range_images, start_img, dirInputs, input_files, background, foreground, dirGT)
tic

precision = zeros(1,size(alpha_vect,2));
recall = zeros(1,size(alpha_vect,2));
F1 = zeros(1,size(alpha_vect,2));


for n=1:size(alpha_vect,2)
    
    alpha = alpha_vect(n);
    
    %Metrics for alpha sweep
    TP_global = 0;
    TN_global = 0;
    FP_global = 0;
    FN_global = 0;
    
    %detect foreground and compare results
    for i=1:(round(range_images/2))
        index = i + (start_img + range_images/2) - 1;
        file_number = input_files(index).name(3:8);
        test_backg_in(:,:,i) = double(rgb2gray(imread(strcat(dirInputs,'in',file_number,'.jpg'))));
        detection(:,:,i) = abs(mu_matrix-test_backg_in(:,:,i)) >= (alpha * (sigma_matrix + 2));
        gt = imread(strcat(dirGT,'gt',file_number,'.png'));
        gt_back = gt <= background;
        gt_fore = gt >= foreground;
%         [TP, TN, FP, FN] = get_metrics_2val (gt_back, gt_fore, detection(:,:,i));
        [TP, TN, FP, FN] = get_metrics(gt_fore, detection(:,:,i));

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

x= alpha_vect;%1:size(alpha_vect,2);
figure(1)
plot(x, precision, 'k');
hold on
plot(x, recall, 'r');
plot(x, F1, 'b');
title('Metrics')
xlabel('Threshold')
ylabel('Measure')
legend('Precision','Recall','F1');

figure(2)
plot(x, transpose(TP_),'b', x, transpose(TN_),'g', x, transpose(FP_),'r', x, transpose(FN_));
title('Metrics 2')
xlabel('Threshold')
ylabel('Measure')
legend('TP','TN','FP','FN');

figure(3)
plot(recall, transpose(precision), 'g', recall, transpose(precision .* recall),'b');
xlabel('Recall')
ylabel('Precision')
legend('Recall vs Precision','Recall x Precision');
end
