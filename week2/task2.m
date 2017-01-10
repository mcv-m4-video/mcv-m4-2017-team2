% Week 2 task 2
% Task 2.1: Adaptive modelling
% Task 2.2: Comparison adaptive vs non

function task2
    close all;

    addpath('../../datasets');
    addpath('../../utils');
    addpath('../../week2');

    %% load data
    % Datasets to use 'highway', 'fall' or 'traffic'
    % Choose dataset images to work on from the above:
    data = 'highway';
    [start_img, range_images, dirInputs] = load_data(data);
    input_files = list_files(dirInputs);

    dirGT = strcat('../datasets/cdvd/dataset/baseline/highway/groundtruth/');
    % dirGT = strcat('../datasets/cdvd/dataset/dynamicBackground/fall/groundtruth/');
    % dirGT = strcat('../datasets/cdvd/dataset/cameraJitter/traffic/groundtruth/');
    background = 55;
    foreground = 250;

    % Either perform an exhaustive grid search to find the best alpha and rho,
    % or just use the adaptive model if they are already computed.
    exhaustive_search = true;
    if exhaustive_search
        exhaustive_grid_search(start_img, range_images, dirInputs, input_files, dirGT, background, foreground);
    else
        adaptive_model(start_img, range_images, dirInputs, input_files, dirGT, background, foreground);
    end

end


function adaptive_model(start_img, range_images, dirInputs, input_files, dirGT, background, foreground)
    [mu_matrix, sigma_matrix] = train_background(start_img, range_images, input_files, dirInputs);
    alpha_val = 4.5;
    rho_val = 0.35;
    create_animated_gif = true;
    [precision, recall, F1] = single_alpha_adaptive(alpha_val, rho_val, mu_matrix, sigma_matrix, range_images, start_img, dirInputs, input_files, background, foreground, dirGT, create_animated_gif);
    % [precision, recall, F1] = single_alpha_dual(alpha_val, rho_val, mu_matrix, sigma_matrix, range_images, start_img, dirInputs, input_files, background, foreground, dirGT, create_animated_gif);

    % Show results in tabular format
    fprintf('\tWEEK 2 TASK 2 RESULTS\n');
    fprintf('--------------------------------------------------\n');
    fprintf(['Alpha = \t', num2str(alpha_val),'\n']);
    fprintf(['Rho = \t\t', num2str(rho_val),'\n']);
    fprintf(['Precision = \t', num2str(mean(precision)),'\n']);
    fprintf(['Recall = \t', num2str(mean(recall)),'\n']);
    fprintf(['F1 = \t\t', num2str(mean(F1)),'\n']);
end


function exhaustive_grid_search(start_img, range_images, dirInputs, input_files, dirGT, background, foreground)
    %% train model with the first 50% of the images
    [mu_matrix, sigma_matrix] = train_background(start_img, range_images, input_files, dirInputs);

    %% adaptive modelling with the last 50% of the images
    alpha_vals = 0.25:0.25:10;
    rho_vals = 0.025:0.025:1;
    create_animated_gif = false;
    results_f1 = zeros(size(rho_vals, 2), size(alpha_vals, 2));
    i = 1;
    j = 1;
    max_f1 = 0;
    max_alpha = 0;
    max_rho = 0;
    for alpha_val = alpha_vals
        for rho_val = rho_vals
            [precision, recall, F1] = single_alpha_adaptive(alpha_val, rho_val, mu_matrix, sigma_matrix, range_images, start_img, dirInputs, input_files, background, foreground, dirGT, create_animated_gif);
            results_f1(i,j) = mean(F1);
            if mean(F1) > max_f1
                max_f1 = mean(F1);
                max_alpha = alpha_val;
                max_rho = rho_val;
            end
            i = i+1;
        end
        i = 1;
        j = j+1;
    end

    % Show results in tabular format
    fprintf('\tWEEK 2 TASK 2 RESULTS\n');
    fprintf('--------------------------------------------------\n');
    fprintf(['Alpha = \t', num2str(max_alpha),'\n']);
    fprintf(['Rho = \t\t', num2str(max_rho),'\n']);
    fprintf(['F1 = \t\t', num2str(mean(max_f1)),'\n']);

    %% plot results
    figure;
    surf(alpha_vals, rho_vals, results_f1);
end


function [precision, recall, F1] = single_alpha_dual(alpha_val, rho_val, mu_matrix, sigma_matrix, range_images, start_img, dirInputs, input_files, background, foreground, dirGT, create_animated_gif)
    % function to create an animated gif with the gt, non-adaptive detection and adaptive detection

    mu_matrix_adapted = mu_matrix;
    sigma_matrix_adapted = sigma_matrix;

    for i=1:(round(range_images/2))
        
        % read frame and ground truth
        index = i + (start_img + range_images/2) - 1;
        file_number = input_files(index).name(3:8);
        frame(:,:,i) = double(rgb2gray(imread(strcat(dirInputs,'in',file_number,'.jpg'))));
        gt = imread(strcat(dirGT,'gt',file_number,'.png'));
        gt_back = gt <= background;
        gt_fore = gt >= foreground;

        % compute detection using model
        detection_non_adapted(:,:,i) = abs(mu_matrix-frame(:,:,i)) >= alpha_val*(sqrt(sigma_matrix) + 2);  % +2 to prevent low sigma values
        detection_adapted(:,:,i) = abs(mu_matrix_adapted-frame(:,:,i)) >= alpha_val*(sqrt(sigma_matrix_adapted) + 2);  % +2 to prevent low sigma values
        
        % adapt model using pixels belonging to the background
        [mu_matrix_adapted, sigma_matrix_adapted] = adaptModel(mu_matrix, sigma_matrix, rho_val, detection_adapted(:,:,i), frame(:,:,i));

        % compute metrics with detection and gt
        % [TP, TN, FP, FN] = get_metrics(gt_foreground, detection);
        [TP, TN, FP, FN] = get_metrics_2val(gt_back, gt_fore, detection_adapted(:,:,i));
        [precision_adapted(i), recall_adapted(i), F1_adapted(i)] = evaluation_metrics(TP,TN,FP,FN);

        [TP, TN, FP, FN] = get_metrics_2val(gt_back, gt_fore, detection_non_adapted(:,:,i));
        [precision_non_adapted(i), recall_non_adapted(i), F1_non_adapted(i)] = evaluation_metrics(TP,TN,FP,FN);

    
        % Create animated gif to add to the slides
        if create_animated_gif
            fig = figure(1);
            subplot(1,3,1); imshow(gt*255); title('Ground truth');
            subplot(1,3,2); imshow(detection_non_adapted(:,:,i)*255); title('non adaptative method');
            subplot(1,3,3); imshow(detection_adapted(:,:,i)*255); title('adaptative method');
            outfile = strcat('task2_adaptative_dual_alpha', num2str(alpha_val), '_rho', num2str(rho_val), '.gif');
            fig_frame = getframe(fig);
            im = frame2im(fig_frame);
            if i == 1
                imwrite(rgb2gray(im),outfile,'gif','LoopCount',Inf,'DelayTime',0.1);
            else
                imwrite(rgb2gray(im),outfile,'gif','WriteMode','append','DelayTime',0.1);
            end
        end

    end
end


function [precision, recall, F1] = single_alpha_adaptive(alpha_val, rho_val, mu_matrix, sigma_matrix, range_images, start_img, dirInputs, input_files, background, foreground, dirGT, create_animated_gif)

    for i=1:(round(range_images/2))
        
        % read frame and ground truth
        index = i + (start_img + range_images/2) - 1;
        file_number = input_files(index).name(3:8);
        frame(:,:,i) = double(rgb2gray(imread(strcat(dirInputs,'in',file_number,'.jpg'))));
        gt = imread(strcat(dirGT,'gt',file_number,'.png'));
        gt_back = gt <= background;
        gt_fore = gt >= foreground;

        % compute detection using model
        detection(:,:,i) = abs(mu_matrix-frame(:,:,i)) >= alpha_val*(sqrt(sigma_matrix) + 2);  % +2 to prevent low sigma values
        
        % adapt model using pixels belonging to the background
        [mu_matrix, sigma_matrix] = adaptModel(mu_matrix, sigma_matrix, rho_val, detection(:,:,i), frame(:,:,i));

        % compute metrics with detection and gt
        % [TP, TN, FP, FN] = get_metrics(gt_foreground, detection);
        [TP, TN, FP, FN] = get_metrics_2val(gt_back, gt_fore, detection(:,:,i));
        [precision(i), recall(i), F1(i)] = evaluation_metrics(TP,TN,FP,FN);
    
        % Create animated gif to add to the slides
        if create_animated_gif
            fig = figure(1);
            subplot(1,2,1); imshow(gt*255); title('Ground truth');
            subplot(1,2,2); imshow(detection(:,:,i)*255); title('Detection with adaptative method');
            outfile = strcat('task2_adaptative_alpha', num2str(alpha_val), '_rho', num2str(rho_val), '.gif');
            fig_frame = getframe(fig);
            im = frame2im(fig_frame);
            if i == 1
                imwrite(rgb2gray(im),outfile,'gif','LoopCount',Inf,'DelayTime',0.1);
            else
                imwrite(rgb2gray(im),outfile,'gif','WriteMode','append','DelayTime',0.1);
            end
        end

    end
end


function [mean_matrix, variance_matrix] = adaptModel(mean_matrix, variance_matrix, rho, detection, frame)
    % background pixels: ~detection
    mean_matrix(~detection) = rho.*frame(~detection) + (1-rho).*mean_matrix(~detection);
    variance_matrix(~detection) = rho.*(frame(~detection) - mean_matrix(~detection)).^2 + (1 - rho).*variance_matrix(~detection);
end
