% Week 2 task 2
% Task 2.1: Adaptive modelling
% Task 2.2: Comparison adaptive vs non

function task2
    close all;

    addpath('../../datasets');
    addpath('../../utils');
    addpath('../../week2');

    % Datasets to use 'highway', 'fall' or 'traffic'
    % Choose dataset images to work on from the above:
    data = 'highway';

    [start_img, range_images, dirInputs] = load_data(data);

    % open dataset
    input_files = list_files(dirInputs);

    % Evaluating data and metrics
    dirGT = strcat('../datasets/cdvd/dataset/baseline/', data, '/groundtruth/');
    background = 55;
    foreground = 250;

    [mu_matrix, sigma_matrix] = train_background(start_img, range_images, input_files, dirInputs);

    alpha_vals = 0.25:0.25:10;
    rho_vals = 0.025:0.025:1;
%     alpha_vals = [1, 2];
%     rho_vals = [0.1, 0.5, 0.9];
    results = struct;
    results_f1 = zeros(size(rho_vals, 2), size(alpha_vals, 2));
    struct_ind = 1;
    i = 1;
    j = 1;
    for alpha_val = alpha_vals
        for rho_val = rho_vals
            [precision, recall, F1] = single_alpha_adaptive(alpha_val, rho_val, mu_matrix, sigma_matrix, range_images, start_img, dirInputs, input_files, background, foreground, dirGT);
            results(struct_ind).alpha_val = alpha_val;
            results(struct_ind).rho_val = rho_val;
            results(struct_ind).precision = precision;
            results(struct_ind).recall = recall;
            results(struct_ind).F1 = F1;
            results(struct_ind).F1_mean = mean(F1);
            results_f1(i,j) = mean(F1);
            i = i+1;
            struct_ind = struct_ind+1;
        end
        i = 1;
        j = j+1;
    end

    figure;
    surf(alpha_vals, rho_vals, results_f1);
end


function [precision, recall, F1] = single_alpha_adaptive(alpha_val, rho_val, mu_matrix, sigma_matrix, range_images, start_img, dirInputs, input_files, background, foreground, dirGT)

%     video_name = strcat('task2_single_alpha_adaptive_alpha_', num2str(alpha_val), '_rho_', num2str(rho_val), '.avi');
%     v = VideoWriter(video_name, 'Grayscale AVI');
%     v.FrameRate = 15;

    TP = 0;
    TN = 0;
    FP = 0;
    FN = 0;

    TPvector = zeros(size(round(range_images/2)));
    TNvector = zeros(size(round(range_images/2)));
    FPvector = zeros(size(round(range_images/2)));
    FNvector = zeros(size(round(range_images/2)));

    for i=1:(round(range_images/2))
        index = i + (start_img + range_images/2) - 1;
        file_number = input_files(index).name(3:8);
        test_backg_in(:,:,i) = double(rgb2gray(imread(strcat(dirInputs,'in',file_number,'.jpg'))));
        detection(:,:,i) = abs(mu_matrix-test_backg_in(:,:,i)) >= (alpha_val * (sigma_matrix + 2));
        gt = imread(strcat(dirGT,'gt',file_number,'.png'));
        
        gt_fore = gt >= foreground;
        [TP, TN, FP, FN] = get_metrics( gt_fore, detection(:,:,i));
        frame(:,:,i) = mat2gray(detection(:,:,i));
        
        % adapt model 
        gt_back = gt <= background;
        [mu_matrix, sigma_matrix] = adaptModel(mu_matrix, sigma_matrix, gt_back, test_backg_in, rho_val);

        % option of getting frame by frame metrics
        TPvector(i) = TP;
        TNvector(i) = TN;
        FPvector(i) = FP;
        FNvector(i) = FN;
        [precision(i), recall(i), F1(i)] = evaluation_metrics(TP,TN,FP,FN);
    
    end
    
%     open(v)
%     writeVideo(v,frame)
%     close(v)
%     
%        
%     % Frame by frame plotting
%     x= 1:range_images/2;
%     figure(1)
%     plot(x, transpose(precision), x, transpose(recall), x, transpose(F1));
%     title('Metrics')
%     xlabel('Frame')
%     ylabel('Measure')
%     legend('Precision','Recall','F1');
end


function [adaptedMean, adaptedVariance] = adaptModel(mean, variance, background, image, rho)

    adaptedMean = mean;
    adaptedVariance = variance;

    adaptedMean(background) = rho * image(background) + (1 - rho) * mean(background);
    adaptedVariance(background) = rho * (image(background) - adaptedMean(background)).^2 + (1 - rho) * variance(background);

end
