% function task2_1_videostsabilization_bm()
close all;

addpath('../datasets');
addpath('../utils');
addpath('../week2');

data = 'traffic';
[T1, nframes, dirInputs] = load_data(data);
input_files = list_files(dirInputs);
dirGT = strcat('../datasets/cdvd/dataset/cameraJitter/traffic/groundtruth/');

block_size = 15;
search_area = 20;

t = 1000
% 
% t = T1;
% for i = 1:nframes-1
    filenumber1 = sprintf('%06d', t);
    filepath1 = strcat(dirInputs, 'in', filenumber1, '.jpg');
    image1 = imread(filepath1);
    
    filenumber2 = sprintf('%06d', t+1);
    filepath2 = strcat(dirInputs, 'in', filenumber2, '.jpg');
    image2 = imread(filepath2);
    
    sub_image1 = image1(150:210,40:100);
    
    sub_image2 = image2(150:210,40:100);
    [flow_estimation_x, flow_estimation_y]  = block_matching(sub_image1, sub_image2, block_size, search_area);
    
    step = 5;
    visualize_optical_flow(sub_image1, flow_estimation_x, flow_estimation_y, step)
    figure()
    imshow(sub_image2)
    
    flow_x_flat = flow_estimation_x(:);
    flow_y_flat = flow_estimation_y(:);
    
    meanx = ones(size(flow_estimation_x,1), size(flow_estimation_x,2)) * mean(flow_x_flat);
    meany = ones(size(flow_estimation_x,1), size(flow_estimation_x,2)) * mean(flow_y_flat);
    
    step = 5;
    visualize_optical_flow(sub_image1, meanx, meany, step)
    figure()
    imshow(sub_image2)
    
    X = [flow_x_flat, flow_y_flat];
    
    histograma = hist3(X, [10, 10]);
    bar3(histograma)
    
%     t = t + 1;
% end
