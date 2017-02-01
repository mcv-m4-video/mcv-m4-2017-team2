% function task2_1_videostsabilization_bm()
close all;

addpath('../datasets');
addpath('../utils');
addpath('../week2');

data = 'traffic';
[T1, nframes, dirInputs] = load_data(data);
input_files = list_files(dirInputs);
dirGT = strcat('../datasets/cdvd/dataset/cameraJitter/traffic/groundtruth/');

block_size = 20;
search_area = 40;

t = T1;

%For gif
filenumber1 = sprintf('%06d', t);
filepath1 = strcat(dirInputs, 'in', filenumber1, '.jpg');
previous_image = rgb2gray(imread(filepath1));
gif_subplots=cell(1,2);
titles={'Original','Stabilized'};
gif_subplots{1}=previous_image;
gif_subplots{2}=previous_image;
gif_horizontal_plots_t5('results/','video_stable_sinROI.gif',gif_subplots,titles,1);
    
%for i = 2:nframes-1
for i = 2:nframes-1    
%     filenumber1 = sprintf('%06d', t);
%     filepath1 = strcat(dirInputs, 'in', filenumber1, '.jpg');
%     image1 = imread(filepath1);
    
    
    t = t + 1;
    filenumber2 = sprintf('%06d', t+1);
    filepath2 = strcat(dirInputs, 'in', filenumber2, '.jpg');
    current_image = rgb2gray(imread(filepath2));
    
    %sub_prev_img = previous_image(150:240,30:120);
    
    %sub_cur_img = current_image(150:240,30:120);
    
    %backward bw
    %[flow_estimation_x, flow_estimation_y]  = block_matching(sub_prev_img, sub_cur_img,  block_size, search_area);
    
    [flow_estimation_x, flow_estimation_y]  = block_matching( current_image, previous_image, block_size, search_area);
    
    flow_x_flat = flow_estimation_x(:);
    flow_y_flat = flow_estimation_y(:);
    
    meanx = int8(mean(flow_x_flat))
    meany = int8(mean(flow_y_flat))
    meanx_mat = ones(size(flow_estimation_x,1), size(flow_estimation_x,2)) * mean(flow_x_flat);
    meany_mat = ones(size(flow_estimation_x,1), size(flow_estimation_x,2)) * mean(flow_y_flat);
%     
%     figure()
%     imshow(previous_image)
%     title('pasada');
%     figure()
%     imshow(current_image)
%     title('current');
%     step = 5;
%     visualize_optical_flow(sub_cur_img, meanx_mat, meany_mat, step)
%     figure()
%     hold on;
    image_stabilized = imtranslate(current_image, [meanx, meany]);
    gif_subplots{1}=current_image;
    gif_subplots{2}=image_stabilized;
    gif_horizontal_plots_t5('results/','video_stable_sinROI.gif',gif_subplots,titles,i);
    
    previous_image = image_stabilized;
    %X = [flow_x_flat, flow_y_flat];
    
    %histograma = hist3(X, [10, 10]);
    %bar3(histograma)
end
