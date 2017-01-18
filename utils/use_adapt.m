function use_adapt
    close all;

    addpath('../datasets');
    addpath('../utils');
    addpath('../week2');

    %% load data
    % Datasets to use 'highway', 'fall' or 'traffic'
    % Choose dataset images to work on from the above:
    data = 'highway';
    [start_img, range_images, dirInputs] = load_data(data);
    input_files = list_files(dirInputs);

    if strcmp(data, 'highway')
        % Best results: Alpha = 2.75, Rho = 0.2, F1 = 0.72946
        alpha_val = 2.75;
        rho_val = 0.2;
        dirGT = strcat('../datasets/cdvd/dataset/baseline/highway/groundtruth/');
    else
        if strcmp(data, 'fall')
            % Best results: Alpha = 3.25, Rho = 0.05, F1 = 0.70262
            alpha_val = 3.25;
            rho_val = 0.05;
            dirGT = strcat('../datasets/cdvd/dataset/dynamicBackground/fall/groundtruth/');
        else
            % Best results: Alpha = 3.25, Rho = 0.15, F1 = 0.66755
            alpha_val = 3.25;
            rho_val = 0.15; 
            dirGT = strcat('../datasets/cdvd/dataset/cameraJitter/traffic/groundtruth/');
        end
    end

    background = 55;
    foreground = 250;

    % Either perform an exhaustive grid search to find the best alpha and rho,
    % or just use the adaptive model if they are already computed.
    exhaustive_search = true;
    if exhaustive_search
        exhaustive_grid_search(start_img, range_images, dirInputs, input_files, dirGT, background, foreground);
    else
        adaptive_model(start_img, range_images, dirInputs, input_files, dirGT, background, foreground, alpha_val, rho_val);
    end

end


function adaptive_model(start_img, range_images, dirInputs, input_files, dirGT, background, foreground, alpha_val, rho_val)
    [mu_matrix, sigma_matrix] = train_background(start_img, range_images, input_files, dirInputs);

    create_animated_gif = false;
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





function [detection] = single_alpha_adaptive(alpha_val, rho_val, mu_matrix, sigma_matrix, range_images, start_img, dirInputs, input_files, background, foreground, dirGT, create_animated_gif)

     for i=1:(round(range_images/2)+1)
        
        % read frame and ground truth
        index = i + (start_img + range_images/2) - 1;
        file_number = input_files(index).name(3:8);
        frame = double(rgb2gray(imread(strcat(dirInputs,'in',file_number,'.jpg'))));
        gt = imread(strcat(dirGT,'gt',file_number,'.png'));
        gt_back = gt <= background;
        gt_fore = gt >= foreground;

        % compute detection using model
        detection(:,:,i) = abs(frame - mu_matrix) >= alpha_val.*(sigma_matrix+2);
        
        % adapt model using pixels belonging to the background
        % [mu_matrix, sigma_matrix] = adaptModel(mu_matrix, sigma_matrix, rho_val, detection, frame);
        [mu_matrix, sigma_matrix] = adaptModel(frame, detection(:,:,i), mu_matrix, sigma_matrix, rho_val);
    
    end

end


function [mean_matrix,variance_matrix] = adaptModel(frame, detection, mean_matrix, variance_matrix, rho)
    % background pixels: ~detection
    mean_matrix(~logical(detection))=rho*frame(~logical(detection)) + (1-rho)*mean_matrix(~logical(detection));
    variance_matrix(~logical(detection))=sqrt(rho*(frame(~logical(detection))-mean_matrix(~logical(detection))).^2 + (1-rho)*variance_matrix(~logical(detection)).^2);
end