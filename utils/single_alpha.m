%function for using detection with a single alpha value
function detection = single_alpha(alpha, mu_matrix, sigma_matrix, range_images, start_img, dirInputs, input_files, background, foreground, dirGT)

% v = VideoWriter('detection.avi','Grayscale AVI');
% v.FrameRate = 15;

TP = 0;
TN = 0;
FP = 0;
FN = 0;

TPvector = zeros(size(round(range_images/2)));
TNvector = zeros(size(round(range_images/2)));
FPvector = zeros(size(round(range_images/2)));
FNvector = zeros(size(round(range_images/2)));

%detect foreground and compare results
    for i=1:range_images%(round(range_images/2))
        index = i + start_img - 1;%(start_img + range_images/2) - 1;
        file_number = input_files(index).name(3:8);
        test_backg_in(:,:,i) = double(rgb2gray(imread(strcat(dirInputs,'in',file_number,'.jpg'))));
        detection(:,:,i) = abs(mu_matrix-test_backg_in(:,:,i)) >= (alpha * (sigma_matrix + 2));
        gt = imread(strcat(dirGT,'gt',file_number,'.png'));
        gt_back = gt <= background;
        gt_fore = gt >= foreground;
%         [TP, TN, FP, FN] = get_metrics( gt_fore, detection(:,:,i));
        [TP, TN, FP, FN] = get_metrics_2val (gt_back, gt_fore, detection(:,:,i));
        frame(:,:,i) = mat2gray(detection(:,:,i));
        
        
        %option of getting frame by frame metrics
        TPvector(i) = TP;
        TNvector(i) = TN;
        FPvector(i) = FP;
        FNvector(i) = FN;
        [precision(i), recall(i), F1(i)] = evaluation_metrics(TP,TN,FP,FN);
    
    end
    
%     open(v)
%         writeVideo(v,frame)
%         close(v)
%     
       
%     %Frame by frame plotting
%     x= 1:range_images/2;
%     figure(1)
%     plot(x, transpose(precision), x, transpose(recall), x, transpose(F1));
%     title('Metrics for alpha = 2')
%     xlabel('Frame')
%     ylabel('Measure')
%     legend('Precision','Recall','F1');
end