
clearvars
close all;

addpath('../datasets');
addpath('../utils');
addpath('../week2');

data = 'traffic';
[T1, nframes, dirInputs] = load_data(data);
input_files = list_files(dirInputs);
dirGT = strcat('../datasets/cdvd/dataset/cameraJitter/traffic/groundtruth/');

block_size = 5;
search_area = 20;

row1 = 150;
row2 = 200;
col1 = 40;
col2 = 90;

fid = figure();
flowx_old = 0;
flowy_old = 0;

gifname = 'task_2_1.gif';

t = T1;
% t=990;
for i = 1:(nframes-1)
    filenumber1 = sprintf('%06d', t);
    filepath1 = strcat(dirInputs, 'in', filenumber1, '.jpg');
    image1 = double(imread(filepath1)) / 255;
    
    filenumber2 = sprintf('%06d', t+1);
    filepath2 = strcat(dirInputs, 'in', filenumber2, '.jpg');
    image2 = double(imread(filepath2)) / 255;
    
    sub_image1 = image1(row1:row2,col1:col2);
    sub_image2 = image2(row1:row2,col1:col2);
    
    gradi1 = sub_image1 - image1((row1:row2)-1,col1:col2);
    gradj1 = sub_image1 - image1(row1:row2,(col1:col2)-1);
    maggrad1 = sqrt(gradi1.^2 + gradj1.^2);
    gradi2 = sub_image2 - image2((row1:row2)-1,col1:col2);
    gradj2 = sub_image2 - image2(row1:row2,(col1:col2)-1);
    maggrad2 = sqrt(gradi2.^2 + gradj2.^2);
    
%     [flow_estimation_x, flow_estimation_y]  = block_matching(maggrad1, maggrad2, block_size, search_area);
    [flow_estimation_x, flow_estimation_y]  = block_matching(sub_image1, sub_image2, block_size, search_area);
%     [flow_estimation_x, flow_estimation_y]  = block_matching(image1, image2, block_size, search_area);
    
    flowx_flat = flow_estimation_x(:);
    flowy_flat = flow_estimation_y(:);
%     X = [flowx_flat, flowy_flat];
%     histograma = hist3(X);
%     bar3(histograma)
    
%     nbins = 10;
%     histx = hist(flowx_flat, nbins);
%     [~, ix] = max(histx);
%     flowx = (ix - 1) / (nbins - 1) * 2 * search_area - search_area;
%     histy = hist(flowy_flat, nbins);
%     [~, iy] = max(histy);
%     flowy = (iy - 1) / (nbins - 1) * 2 * search_area - search_area;
    
%     flowx = mean(flowx_flat);
%     flowy = mean(flowy_flat);
    
    flowx = median(flowx_flat);
    flowy = median(flowy_flat);
    
    flow_estimation_x = ones(size(flow_estimation_x,1), size(flow_estimation_x,2)) * flowx;
    flow_estimation_y = ones(size(flow_estimation_y,1), size(flow_estimation_y,2)) * flowy;
    
    step = 5;
    r1_step = (row1:step:row2) - row1 + 1;
    r2_step = (col1:step:col2) - col1 + 1;
%     r1_step = (row1:step:row2);
%     r2_step = (col1:step:col2);
    flowx_step = flow_estimation_x(r1_step, r2_step);
    flowy_step = flow_estimation_y(r1_step, r2_step);

    flowx = flowx + flowx_old;
    flowy = flowy + flowy_old;
    
    subplot(1,2,1)
    imshow(image2)
    hold on
    plot([col1 col2], [row1 row1], 'b')
    plot([col1 col2], [row2 row2], 'b')
    plot([col1 col1], [row1 row2], 'b')
    plot([col2 col2], [row1 row2], 'b')
    quiver(r2_step+col1-1, r1_step+row1-1, flowx_step, flowy_step, 0)
%     quiver(r2_step, r1_step, flowx_step, flowy_step, 0)
    hold off
%     pause(0.1)
    
%     image_trans = imtranslate(image2, [flowy, flowx]);
    image_trans = imtranslate(image2, [-flowy, -flowx]);
    subplot(1,2,2)
    imshow(image_trans)
    pause(0.1)
    
%     subplot(2,2,1)
%     image_trans = imtranslate(image2, [flowy, flowx]);
%     imshow(image_trans)
%     subplot(2,2,2)
%     image_trans = imtranslate(image2, [-flowy, -flowx]);
%     imshow(image_trans)
%     subplot(2,2,3)
%     image_trans = imtranslate(image2, [-flowx, -flowy]);
%     imshow(image_trans)
%     subplot(2,2,4)
%     image_trans = imtranslate(image2, [-flowx, -flowy]);
%     imshow(image_trans)
%     pause(0.1)

    frame = getframe(fid);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if i == 1;
        imwrite(imind,cm,gifname,'gif', 'Loopcount',inf);
    else
        imwrite(imind,cm,gifname,'gif','WriteMode','append');
    end
    
    flowx_old = flowx;
    flowy_old = flowy;
    
    t = t + 1;
end
