function task4_non_adaptative
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
alpha = zeros(numel(colorspaces),numel(datasets));

for d=1:numel(datasets)
    data = datasets{d};
    [start_img, range_images, dirInputs, dirGT] = load_data(data);
    
    %open dataset
    input_files = list_files(dirInputs);
    for c=1:numel(colorspaces)
        colorspace=colorspaces{c};
        [mu_matrix, sigma_matrix] = train_background_color(start_img, range_images, input_files, dirInputs, colorspace);
        
        %Alpha parameter for sigma weight in background comparison (for frame by
        %frame plot set alpha to scalar, for threshold sweep set alpha to vector)
        alpha_vect = 0:0.25:5;
        %Use when alpha_vect is a vector of thresholds
        [alpha(c,d),f1(c,d)] = alpha_sweep_color(alpha_vect, mu_matrix, sigma_matrix, range_images, start_img, dirInputs, input_files, background, foreground, dirGT, colorspace)
        
    end
end

save('non_adaptative_color.mat','f1','alpha');
% load('non_adaptative.mat');
%visualization
figure;
rgb = f1(1,:); hsv = f1(2,:); yuv = f1(3,:);
Y=[rgb;hsv;yuv].';
h = bar(Y)
set(gca, 'XTick', 1:3, 'XTickLabel', datasets);
legend(colorspaces','location','northeast')
title('F1 measure per colorspace for non-recursive bg detection')
end