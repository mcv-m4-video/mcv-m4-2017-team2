function task4_adaptative
close all;

addpath('../datasets');
addpath('../utils');
addpath('../week2');

%% load data
% Datasets to use 'highway', 'fall' or 'traffic'
% Choose dataset images to work on from the above:
data = 'fall';
[start_img, range_images, dirInputs] = load_data(data);
input_files = list_files(dirInputs);

% dirGT = strcat('../datasets/cdvd/dataset/baseline/highway/groundtruth/');
dirGT = strcat('../datasets/cdvd/dataset/dynamicBackground/fall/groundtruth/');
background = 55;
foreground = 250;
%color space
colorspace = 'YUV'; % 'YUV' 'HSV' 'RGB'
% Either perform an exhaustive grid search to find the best alpha and rho,
% or just use the adaptive model if they are already computed.
exhaustive_search = true;
if exhaustive_search
    exhaustive_grid_search_color(start_img, range_images, dirInputs, input_files, dirGT, background, foreground, colorspace);
else
    adaptive_model_color(start_img, range_images, dirInputs, input_files, dirGT, background, foreground, colorspace);
end

end


function adaptive_model_color(start_img, range_images, dirInputs, input_files, dirGT, background, foreground, colorspace)
[mu_matrix, sigma_matrix] = train_background_color(start_img, range_images, input_files, dirInputs, colorspace);
alpha_val = 4.5;
rho_val = 0.35;
create_animated_gif = true;
[precision, recall, F1] = single_alpha_adaptive_color(alpha_val, rho_val, mu_matrix, sigma_matrix, range_images, start_img, dirInputs, input_files, background, foreground, dirGT, create_animated_gif, colorspace);

% Show results in tabular format
fprintf('\tWEEK 2 TASK 4 RESULTS\n');
fprintf('--------------------------------------------------\n');
fprintf(['Alpha = \t', colorspace,'\n']);
fprintf(['Alpha = \t', num2str(alpha_val),'\n']);
fprintf(['Rho = \t\t', num2str(rho_val),'\n']);
fprintf(['Precision = \t', num2str(mean(precision)),'\n']);
fprintf(['Recall = \t', num2str(mean(recall)),'\n']);
fprintf(['F1 = \t\t', num2str(mean(F1)),'\n']);
end


function exhaustive_grid_search_color(start_img, range_images, dirInputs, input_files, dirGT, background, foreground, colorspace)
%% train model with the first 50% of the images
[mu_matrix, sigma_matrix] = train_background_color(start_img, range_images, input_files, dirInputs, colorspace);

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
        [precision, recall, F1] = single_alpha_adaptive_color(alpha_val, rho_val, mu_matrix, sigma_matrix, range_images, start_img, dirInputs, input_files, background, foreground, dirGT, create_animated_gif, colorspace);
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
fprintf('\tWEEK 2 TASK 4 RESULTS\n');
fprintf('--------------------------------------------------\n');
fprintf(['Alpha = \t', num2str(max_alpha),'\n']);
fprintf(['Rho = \t\t', num2str(max_rho),'\n']);
fprintf(['F1 = \t\t', num2str(mean(max_f1)),'\n']);

%% plot results
figure;
surf(alpha_vals, rho_vals, results_f1);
end

function [precision, recall, F1] = single_alpha_adaptive_color(alpha_val, rho_val, mu_matrix, sigma_matrix, range_images, start_img, dirInputs, input_files, background, foreground, dirGT, create_animated_gif, colorspace)

for i=1:(round(range_images/2))
    
    % read frame and ground truth
    index = i + (start_img + range_images/2) - 1;
    file_number = input_files(index).name(3:8);
    
    if strcmp(colorspace,'RGB')
        frame(:,:,:,i) = double(imread(strcat(dirInputs,'in',file_number,'.jpg')));
    elseif strcmp(colorspace,'YUV')
        
        frame(:,:,:,i) = double(imread(strcat(dirInputs,'in',file_number,'.jpg')));
        frame(:,:,:,i) = rgb2yuv(frame(:,:,:,i));
    elseif strcmp(colorspace,'HSV')
        frame(:,:,:,i) = double(rgb2hsv(imread(strcat(dirInputs,'in',file_number,'.jpg'))));
    else
        error('colorspace not recognized');
    end
    gt = imread(strcat(dirGT,'gt',file_number,'.png'));
    gt_back = gt <= background;
    gt_fore = gt >= foreground;
    
    % compute detection using model
    detection(:,:,i) = abs(frame(:,:,1,i)-mu_matrix(:,:,1)) >= (alpha_val * (sigma_matrix(:,:,1) + 2)) | ...
        abs(frame(:,:,2,i)-mu_matrix(:,:,2)) >= (alpha_val * (sigma_matrix(:,:,2) + 2)) | ...
        abs(frame(:,:,3,i)-mu_matrix(:,:,3)) >= (alpha_val * (sigma_matrix(:,:,3) + 2)) ;
    % adapt model using pixels belonging to the background
    [mu_matrix, sigma_matrix] = adaptModel_color(mu_matrix, sigma_matrix, rho_val, detection(:,:,i), frame(:,:,:,i));
    
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


function [mean_matrix, variance_matrix] = adaptModel_color(mean_matrix, variance_matrix, rho, detection, frame)
% background pixels: ~detection
channels = size(frame,3);
for i=1:channels
    mean_matrix_temp = mean_matrix(:,:,i);
    variance_matrix_temp = variance_matrix(:,:,i);
    frame_temp = frame(:,:,i);
    mean_matrix_temp(~detection) = rho.*frame_temp(~detection) + (1-rho).*mean_matrix_temp(~detection);
    variance_matrix_temp(~detection) = rho.*(frame_temp(~detection) - mean_matrix_temp(~detection)).^2 + (1 - rho).*variance_matrix_temp(~detection);
    mean_matrix(:,:,i) = mean_matrix_temp;
    variance_matrix(:,:,i) = variance_matrix_temp;
    frame(:,:,i) = frame_temp;
end
end
