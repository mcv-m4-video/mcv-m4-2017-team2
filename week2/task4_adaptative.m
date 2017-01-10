function task4_adaptative
close all;

addpath('../datasets');
addpath('../utils');
addpath('../week2');
%Datasets to use 'highway' , 'fall' or 'traffic'
%Choose dataset images to work on from the above:
datasets = {'fall','highway','traffic'};

%Evaluating metrics
background = 50;
foreground = 255;

%color space
colorspaces = {'RGB','HSV','YUV'};

%mat for save the values of f1 and alpha for each dataset in relation to
%color space
f1 = zeros(numel(colorspaces),numel(datasets));

%Those values came from the results of task 2 grid search
alpha_x_dataset = [4.5, 2.4, 5.9];
rho_x_dataset = [0.35, 0.32, 0.41];

for d=1:numel(datasets)
    data = datasets{d};
    [start_img, range_images, dirInputs, dirGT] = load_data(data);
    
    %open dataset
    input_files = list_files(dirInputs);
    for c=1:numel(colorspaces)
        colorspace=colorspaces{c};
        alpha = alpha_x_dataset(d);
        rho = rho_x_dataset(d);
        f1(c,d) = adaptive_model_color(alpha,rho,start_img, range_images, dirInputs, input_files, dirGT, background, foreground, colorspace);

    end
end
save('non_adaptative.mat','alpha','f1');
%visualization
figure;
rgb = f1(1,:); hsv = f1(2,:); yuv = f1(3,:);
Y=[rgb;hsv;yuv].';
h = bar(Y)
set(gca, 'XTick', 1:3, 'XTickLabel', datasets);
% color_space_test=num2str([1:3].','Job %d');
legend(colorspaces','location','northeast')
title('F1 measure per colorspace for recursive bg detection')
end


function f1 = adaptive_model_color(alpha_val, rho_val, start_img, range_images, dirInputs, input_files, dirGT, background, foreground, colorspace)
[mu_matrix, sigma_matrix] = train_background_color(start_img, range_images, input_files, dirInputs, colorspace);
[precision, recall, F1] = single_alpha_adaptive_color(alpha_val, rho_val, mu_matrix, sigma_matrix, range_images, start_img, dirInputs, input_files, background, foreground, dirGT, colorspace);
f1 = mean(F1);
% Show results in tabular format
fprintf('\tWEEK 2 TASK 4 RESULTS\n');
fprintf('--------------------------------------------------\n');
fprintf(['ColorSpace = \t', colorspace,'\n']);
fprintf(['Alpha = \t', num2str(alpha_val),'\n']);
fprintf(['Rho = \t\t', num2str(rho_val),'\n']);
fprintf(['Precision = \t', num2str(mean(precision)),'\n']);
fprintf(['Recall = \t', num2str(mean(recall)),'\n']);
fprintf(['F1 = \t\t', num2str(f1),'\n']);

end

function [precision, recall, F1] = single_alpha_adaptive_color(alpha_val, rho_val, mu_matrix, sigma_matrix, range_images, start_img, dirInputs, input_files, background, foreground, dirGT, colorspace)

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
        frame(:,:,:,i) = 255.*frame(:,:,:,i);
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
