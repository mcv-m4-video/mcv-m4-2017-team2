% Week 3 task 4: shadow removal

function task4
    close all;

    addpath('../datasets');
    addpath('../utils');
    addpath('../week2');

    %% load data
    % Datasets to use 'highway', 'fall' or 'traffic'
    % Choose dataset images to work on from the above:
    dataset = 'highway';
    [start_img, range_images, dirInputs] = load_data(dataset);
    input_files = list_files(dirInputs);

    switch dataset
        case 'highway'
            % Best results: Alpha = 2.75, Rho = 0.2, F1 = 0.72946
            alpha_val = 2.75;
            rho_val = 0.2;
            dirGT = strcat('../datasets/cdvd/dataset/baseline/highway/groundtruth/');
        case 'fall'
            % Best results: Alpha = 3.25, Rho = 0.05, F1 = 0.70262
            alpha_val = 3.25;
            rho_val = 0.05;
            dirGT = strcat('../datasets/cdvd/dataset/dynamicBackground/fall/groundtruth/');
        case 'traffic'
            % Best results: Alpha = 3.25, Rho = 0.15, F1 = 0.66755
            alpha_val = 3.25;
            rho_val = 0.15; 
            dirGT = strcat('../datasets/cdvd/dataset/cameraJitter/traffic/groundtruth/');
    end

    background = 55;
    foreground = 250;

    exhaustive_grid_search(start_img, range_images, dirInputs, input_files, dirGT, background, foreground, alpha_val, rho_val);

    exhaustive_grid_search2(start_img, range_images, dirInputs, input_files, dirGT, background, foreground, alpha_val, rho_val);

end


function exhaustive_grid_search(start_img, range_images, dirInputs, input_files, dirGT, background, foreground, alpha_val, rho_val)

    [mu_matrix, sigma_matrix, background_rgb] = train_background_rgb(start_img, range_images, input_files, dirInputs);

    %% adaptive modelling with the last 50% of the images
    beta1_vals = 0.1:0.05:1;
    beta2_vals = 0.1:0.05:1;
    ts = 0.5;
    th = 0.1;
    % beta1_vals = [0.05];
    % beta2_vals = [0.2];
    create_animated_gif = false;
    max_f1 = 0;
    max_beta1 = 0;
    max_beta2 = 0;
    for beta1_val = beta1_vals
        for beta2_val = beta2_vals

            fprintf(['trying beta1 = ', num2str(beta1_val), ' and beta2 = ', num2str(beta2_val), '\n']);
            
            [precision, recall, F1] = single_alpha_adaptive(alpha_val, rho_val, mu_matrix, sigma_matrix, range_images, start_img, dirInputs, input_files, background, foreground, background_rgb, dirGT, create_animated_gif, beta1_val, beta2_val, ts, th);
            
            if mean(F1) > max_f1
                max_f1 = mean(F1);
                max_beta1 = beta1_val;
                max_beta2 = beta2_val;
            end
        end
    end

    % Show results in tabular format
    fprintf('\tWEEK 3 TASK 4 RESULTS\n');
    fprintf('--------------------------------------------------\n');
    fprintf(['beta1 = \t', num2str(max_beta1),'\n']);
    fprintf(['beta2 = \t', num2str(max_beta2),'\n']);
    fprintf(['F1 = \t\t', num2str(mean(max_f1)),'\n']);

end


function exhaustive_grid_search2(start_img, range_images, dirInputs, input_files, dirGT, background, foreground, alpha_val, rho_val)

    [mu_matrix, sigma_matrix, background_rgb] = train_background_rgb(start_img, range_images, input_files, dirInputs);

    %% adaptive modelling with the last 50% of the images
    beta1_vals = 0.1:0.05:1;
    beta2_vals = 0.1:0.05:1;
    ts_vals = 0.1:0.05:1;
    th_vals = 0.1:0.05:1;

    create_animated_gif = false;
    max_f1 = 0;
    max_beta1 = 0;
    max_beta2 = 0;
    max_ts = 0;
    max_th = 0;
    for beta1_val = beta1_vals
        for beta2_val = beta2_vals
            for ts_val = ts_vals
                for th_val = th_vals
                                
                    fprintf(['trying beta1 = ', num2str(beta1_val), ' and beta2 = ', num2str(beta2_val), ' and ts = ', num2str(ts_val), ' and th = ', num2str(th_val), '\n']);
                    
                    [precision, recall, F1] = single_alpha_adaptive(alpha_val, rho_val, mu_matrix, sigma_matrix, range_images, start_img, dirInputs, input_files, background, foreground, background_rgb, dirGT, create_animated_gif, beta1_val, beta2_val, ts_val, th_val);
                    
                    if mean(F1) > max_f1
                        max_f1 = mean(F1);
                        max_beta1 = beta1_val;
                        max_beta2 = beta2_val;
                        max_ts = ts_val;
                        max_th = th_val;

                        % Show results in tabular format
                        fprintf('\tbest results so far\n');
                        fprintf('--------------------------------------------------\n');
                        fprintf(['beta1 = \t', num2str(max_beta1),'\n']);
                        fprintf(['beta2 = \t', num2str(max_beta2),'\n']);
                        fprintf(['ts = \t', num2str(max_ts),'\n']);
                        fprintf(['th = \t', num2str(max_th),'\n']);
                        fprintf(['F1 = \t\t', num2str(mean(max_f1)),'\n']);

                    end
                end
            end
        end
    end

    % Show results in tabular format
    fprintf('\tWEEK 3 TASK 4 RESULTS\n');
    fprintf('--------------------------------------------------\n');
    fprintf(['beta1 = \t', num2str(max_beta1),'\n']);
    fprintf(['beta2 = \t', num2str(max_beta2),'\n']);
    fprintf(['F1 = \t\t', num2str(mean(max_f1)),'\n']);

end

function [precision, recall, F1] = single_alpha_adaptive(alpha_val, rho_val, mu_matrix, sigma_matrix, range_images, start_img, dirInputs, input_files, background, foreground, background_rgb, dirGT, create_animated_gif, beta1, beta2, ts, th)

    TP_global = 0;
    TN_global = 0;
    FP_global = 0;
    FN_global = 0;

    for i=1:(round(range_images/2)+1)
        
        % read frame and ground truth
        index = i + (start_img + range_images/2) - 1;
        file_number = input_files(index).name(3:8);
        frame_rgb = imread(strcat(dirInputs,'in',file_number,'.jpg'));
        frame = double(rgb2gray(frame_rgb));
        gt = imread(strcat(dirGT,'gt',file_number,'.png'));
        gt_back = gt <= background;
        gt_fore = gt >= foreground;

        % compute detection using model
        detection_with_shadows = abs(frame - mu_matrix) >= alpha_val.*(sigma_matrix+2);

        % remove shadows

        % thresholds optimised empirically in paper "Shadow Detection: A Survey and Comparative Evaluation of Recent Methods"
        % beta1 = 0.4;
        % beta2 = 0.6;
        % ts = 0.5;
        % th = 0.1;
        % beta1 = 0.05; 
        % beta2 = 0.2;
        % ts = 0.2;
        % th = 0.6;
        [detection, shadows] = removeShadows(frame_rgb, detection_with_shadows, background_rgb, beta1, beta2, ts, th);

        
        % compute metrics with detection and gt
        % [TP, TN, FP, FN] = get_metrics(gt_foreground, detection);
        [TP, TN, FP, FN] = get_metrics_2val(gt_back, gt_fore, detection);

        TP_global = TP_global + TP;
        TN_global = TN_global + TN;
        FP_global = FP_global + FP;
        FN_global = FN_global + FN;

        % adapt model using pixels belonging to the background
        % [mu_matrix, sigma_matrix] = adaptModel(mu_matrix, sigma_matrix, rho_val, detection, frame);
        [mu_matrix, sigma_matrix] = adaptModel(frame, detection, mu_matrix, sigma_matrix, rho_val);
    
        % Create animated gif to add to the slides
        if create_animated_gif
            fig = figure(1);
            subplot(2,2,1); imshow(frame_rgb); title('original');
            subplot(2,2,2); imshow(detection_with_shadows); title('foreground with shadows');
            subplot(2,2,3); imshow(shadows); title('shadows');
            subplot(2,2,4); imshow(detection); title('foreground without shadows');

            outfile = strcat('task4_shadow_detection.gif');
            fig_frame = getframe(fig);
            im = frame2im(fig_frame);
            if i == 1
                imwrite(rgb2gray(im),outfile,'gif','LoopCount',Inf,'DelayTime',0.1);
            else
                imwrite(rgb2gray(im),outfile,'gif','WriteMode','append','DelayTime',0.1);
            end
        end

    end

    [precision, recall, F1] = evaluation_metrics(TP_global,TN_global,FP_global,FN_global);
end


function [mean_matrix,variance_matrix] = adaptModel(frame, detection, mean_matrix, variance_matrix, rho)
    % background pixels: ~detection
    mean_matrix(~logical(detection))=rho*frame(~logical(detection)) + (1-rho)*mean_matrix(~logical(detection));
    variance_matrix(~logical(detection))=sqrt(rho*(frame(~logical(detection))-mean_matrix(~logical(detection))).^2 + (1-rho)*variance_matrix(~logical(detection)).^2);
end


function [foreground, shadows] = removeShadows(frame, foreground, background, beta1, beta2, ts, th)
% Shadow removal alogrithm: Chromacity-based method

    % convert images to HSV colorspace
    frame_hsv = rgb2hsv(frame);
    background_hsv = rgb2hsv(background);
    
    % a pixel p is considered to be part of a shadow if the following three conditions are satisfied
    cond1_value = frame_hsv(:,:,3)./background_hsv(:,:,3);
    cond1 = (cond1_value>=beta1) & (cond1_value<=beta2);
    cond2 = abs(frame_hsv(:,:,2)-background_hsv(:,:,2)) <= ts;
    cond3 = abs(frame_hsv(:,:,1)-background_hsv(:,:,1)) <= th;

    % apply conditions to remove shadows form foreground
    shadows = foreground&cond1&cond2&cond3;
    foreground = (~shadows)&foreground;

end


function [mu_matrix, sigma_matrix, background_rgb] = train_background_rgb(start_img, range_images, input_files, dirInputs)
    
    mean_rgb_image = zeros();
    
    for i=1:(1 + round(range_images/2))
        index = i + start_img - 1;
        file_number = input_files(index).name(3:8);  % example: take '001050' from 'im001050.png'
        rgb_image = imread(strcat(dirInputs,'in',file_number,'.jpg'));
        if exist('mean_rgb_image','var')
            mean_rgb_image = mean_rgb_image + double(rgb_image);
        else
            mean_rgb_image = double(rgb_image);
        end
        train_backg_in(:,:,i) = double(rgb2gray(rgb_image));
    end

    mu_matrix = mean(train_backg_in,3);
    sigma_matrix = std(train_backg_in, 1, 3);
    background_rgb = uint8(mean_rgb_image / (1 + round(range_images/2)));
end
