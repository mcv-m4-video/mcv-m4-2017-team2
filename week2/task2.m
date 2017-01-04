% Week 2 task 2
% Task 2.1: Adaptive modelling
% Task 2.2: Comparison adaptive vs non

function task2
    close all;

    addpath('../datasets');
    addpath('../utils');
    addpath('../week2');

    % Datasets to use 'highway', 'fall' or 'traffic'
    % Choose dataset images to work on from the above:
    data = 'highway';

    [start_img, range_images, dirInputs] = load_data(data);

    % open dataset
    input_files = list_files(dirInputs);

    % Evaluating data and metrics
    dirGT = '../datasets/cdvd/dataset/baseline/highway/groundtruth/';
    background = 55;
    foreground = 250;

    [mu_matrix, sigma_matrix] = train_background(start_img, range_images, input_files, dirInputs);

    alpha_val = 0.5;


    single_alpha_adaptive(alpha_val, mu_matrix, sigma_matrix, range_images, start_img, dirInputs, input_files, background, foreground, dirGT);
end


function single_alpha_adaptive(alpha, mu_matrix, sigma_matrix, range_images, start_img, dirInputs, input_files, background, foreground, dirGT)

    v = VideoWriter('single_alpha_adaptive.avi','Grayscale AVI');
    v.FrameRate = 15;

    for i=1:(round(range_images/2))
        index = i + (start_img + range_images/2) - 1;
        file_number = input_files(index).name(3:8);
        test_backg_in(:,:,i) = double(rgb2gray(imread(strcat(dirInputs,'in',file_number,'.jpg'))));
        detection(:,:,i) = abs(mu_matrix-test_backg_in(:,:,i)) >= (alpha * (sigma_matrix + 2));
        gt = imread(strcat(dirGT,'gt',file_number,'.png'));
        
        gt_fore = gt >= foreground;
        [TP, TN, FP, FN] = get_metrics( gt_fore, detection(:,:,i));
        frame(:,:,i) = mat2gray(detection(:,:,i));
        
        % adapt model 
        gt_back = gt <= background;
        rho = 0.5;
        [mu_matrix, sigma_matrix] = adaptModel(mu_matrix, sigma_matrix, gt_back, test_backg_in, rho);

        % option of getting frame by frame metrics
        TPvector(i) = TP;
        TNvector(i) = TN;
        FPvector(i) = FP;
        FNvector(i) = FN;
        [precision(i), recall(i), F1(i)] = evaluation_metrics(TP,TN,FP,FN);
    
    end
    
    open(v)
        writeVideo(v,frame)
        close(v)
    
       
    % Frame by frame plotting
    x= 1:range_images/2;
    figure(1)
    plot(x, transpose(precision), x, transpose(recall), x, transpose(F1));
    title('Metrics')
    xlabel('Frame')
    ylabel('Measure')
    legend('Precision','Recall','F1');
end


function [adaptedMean, adaptedVariance] = adaptModel(mean, variance, background, image, rho)

    adaptedMean = mean;
    adaptedVariance = variance;

    adaptedMean(background) = rho * image(background) + (1 - rho) * mean(background);
    adaptedVariance(background) = rho * (image(background) - adaptedMean(background)).^2 + (1 - rho) * variance(background);

end
