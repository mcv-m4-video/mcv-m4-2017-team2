
clearvars
close all;

addpath('../datasets');
addpath('../utils');
addpath('../week2');
addpath('./translation_model');
addpath('./affine_model');

data = 'traffic';
[T1, nframes, dirInputs] = load_data(data);
input_files = list_files(dirInputs);
dirGT = strcat('../datasets/cdvd/dataset/cameraJitter/traffic/groundtruth/');

block_size = 10;
search_area = 20;

row1 = 150;
row2 = 200;
col1 = 40;
col2 = 90;
figure()
t = T1;
for i = 1:(nframes-1)
% for i = 1:3
    filenumber1 = sprintf('%06d', t);
    filepath1 = strcat(dirInputs, 'in', filenumber1, '.jpg');
    image1 = double(imread(filepath1)) / 255;
    
    filenumber2 = sprintf('%06d', t+1);
    filepath2 = strcat(dirInputs, 'in', filenumber2, '.jpg');
    image2 = double(imread(filepath2)) / 255;
    
    sub_image1 = image1(row1:row2,col1:col2);
    sub_image2 = image2(row1:row2,col1:col2);
    
    [subr2, subr1] = meshgrid(1:(col2-col1+1), 1:(row2-row1+1));
    
%     p0 = [0 0];
%     dt = 0.1;
%     delta = 0.000001;
%     maxiter = 1000;
%     p = translation_gradient_descent(sub_image2, sub_image1, p0, dt, maxiter, delta);
%     [flow_estimation_y, flow_estimation_x] = translation_transform(subr1, subr2, p);
    
    p0 = [1 0 0 1 0 0];
    dt = 0.01;
    delta = 0.000001;
    maxiter = 1000;
    p = affine_gradient_descent(sub_image2, sub_image1, p0, dt, maxiter, delta);
    [flow_estimation_y, flow_estimation_x] = affine_transform(subr1, subr2, p);
    
    step = 10;
    r1_step = (row1:step:row2) - row1 + 1;
    r2_step = (col1:step:col2) - col1 + 1;
%     r1_step = (row1:step:row2);
%     r2_step = (col1:step:col2);
    flowx_step = flow_estimation_x(r1_step, r2_step);
    flowy_step = flow_estimation_y(r1_step, r2_step);
    
    
    imshow(image1)
    hold on
    plot([col1 col2], [row1 row1], 'b')
    plot([col1 col2], [row2 row2], 'b')
    plot([col1 col1], [row1 row2], 'b')
    plot([col2 col2], [row1 row2], 'b')
    quiver(r2_step+col1-1, r1_step+row1-1, flowx_step, flowy_step, 0)
%     quiver(r2_step, r1_step, flowx_step, flowy_step, 0)
    hold off
    pause(0.1)
    
    t = t + 1;
end
