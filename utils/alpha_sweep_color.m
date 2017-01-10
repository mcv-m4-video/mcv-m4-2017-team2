%function for sweeping through several thresholds to compare performance
function [best_alpha, best_f1] = alpha_sweep_color(alpha_vect, mu_matrix, sigma_matrix, range_images, start_img, dirInputs, input_files, background, foreground, dirGT, colorspace)

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
    for i=1:(round(range_images/2))
        index = i + (start_img + range_images/2) - 1;
        file_number = input_files(index).name(3:8);
        test_backg_in(:,:,:,i) = double(imread(strcat(dirInputs,'in',file_number,'.jpg')));
        
        if strcmp(colorspace,'RGB')
            test_backg_in(:,:,:,i) = double(imread(strcat(dirInputs,'in',file_number,'.jpg')));
        elseif strcmp(colorspace,'YUV')
            test_backg_in(:,:,:,i) = double(imread(strcat(dirInputs,'in',file_number,'.jpg')));
            test_backg_in(:,:,:,i) = rgb2yuv(test_backg_in(:,:,:,i));
        elseif strcmp(colorspace,'HSV')
            test_backg_in(:,:,:,i) = double(rgb2hsv(imread(strcat(dirInputs,'in',file_number,'.jpg'))));
            test_backg_in(:,:,:,i) = 255.* test_backg_in(:,:,:,i); 
    
        else
            error('colorspace not recognized');
        end
        
        detection(:,:,i) = abs(test_backg_in(:,:,1,i)-mu_matrix(:,:,1)) >= (alpha * (sigma_matrix(:,:,1) + 2)) | ...
            abs(test_backg_in(:,:,2,i)-mu_matrix(:,:,2)) >= (alpha * (sigma_matrix(:,:,2) + 2)) | ...
            abs(test_backg_in(:,:,3,i)-mu_matrix(:,:,3)) >= (alpha * (sigma_matrix(:,:,3) + 2)) ;
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


[best_f1, f1_idx] = max(F1);
best_alpha = alpha_vect(f1_idx);

fprintf('\tWEEK 2 TASK 4 BG NON ADAPTATIVE RESULTS\n');
fprintf('--------------------------------------------------\n');
fprintf(['Alpha = \t', num2str(best_alpha),'\n']);
fprintf(['Precision = \t', num2str(precision(f1_idx)),'\n']);
fprintf(['Recall = \t', num2str(recall(f1_idx)),'\n']);
fprintf(['F1 = \t\t', num2str(best_f1),'\n']);

% graphs
% x= alpha_vect;%1:size(alpha_vect,2);
% figure(1)
% plot(x, transpose(precision), 'b', x, transpose(recall), 'r',  x, transpose(F1), 'k');
% title('Precision, Recall & F1 vs Threshold')
% xlabel('Threshold')
% ylabel('Measure')
% legend('Precision','Recall','F1');
% 
% figure(2)
% plot(x, transpose(TP_),'b', x, transpose(TN_),'g', x, transpose(FP_),'r', x, transpose(FN_));
% title('TP, TN, FP & FN vs Threshold')
% xlabel('Threshold')
% ylabel('Pixels')
% legend('TP','TN','FP','FN');
% 
% figure(3)
% plot(recall, transpose(precision), 'g', recall, transpose(precision .* recall),'b');
% title('Recall vs Precision & AUC');
% xlabel('Recall')
% ylabel('Precision')
% legend('Recall vs Precision','Area under the curve');

end
