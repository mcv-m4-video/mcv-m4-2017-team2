function task1

close all;

addpath('../datasets');
addpath('../utils');
addpath('../week2');

%Datasets to use 'highway' , 'fall' or 'traffic'
%Choose dataset images to work on from the above:
data = {'highway','traffic','fall'};

%Evaluating metrics
background = 50;
foreground = 255;

for d=1:size(data,2)
    [start_img, range_images, dirInputs, dirGT] = load_data(data{d});
    
    %open dataset
    input_files = list_files(dirInputs);

    [mu_matrix, sigma_matrix] = train_background(start_img, range_images, input_files, dirInputs);
%   %Create the mu and sigma matrices images:
%     filenameA = strcat(data{d},'_mu.png');
%     filenameB = strcat(data{d},'_sigma.png');
%     imwrite(mat2gray(mu_matrix),filenameA);
%     imwrite(mat2gray(sigma_matrix),filenameB);

    %Alpha parameter for sigma weight in background comparison (for frame by
    %frame plot set alpha to scalar, for threshold sweep set alpha to vector)
    alpha_vect = 0:0.25:5;
    % alpha_vect = 2;

    %Use when alpha_vect is a single value
    % single_alpha(alpha_vect, mu_matrix, sigma_matrix, range_images, start_img, dirInputs, input_files, background, foreground, dirGT);

    %Use when alpha_vect is a vector of thresholds
    [time, AUC, TP_, TN_, FP_, FN_, precision, recall, F1] = alpha_sweep(data, alpha_vect, mu_matrix, sigma_matrix, range_images, start_img, dirInputs, input_files, background, foreground, dirGT);

    TP(d,:)= TP_;
    TN(d,:)= TN_;
    FP(d,:)= FP_;
    FN(d,:)= FN_;
    precision_array(d,:)= precision;
    recall_array(d,:)= recall;
    F1_array(d,:)= F1;
    
end

figure(1)
plot(alpha_vect, transpose(precision_array));
title('Precision vs Threshold for dataset');
xlabel('Threshold');
ylabel('Measure');
legend('Highway','Traffic','Fall');

figure(2)
plot(alpha_vect, transpose(recall_array));
title('Recall vs Threshold for dataset');
xlabel('Threshold');
ylabel('Measure');
legend('Highway','Traffic','Fall');

figure(3)
plot(alpha_vect, transpose(F1_array));
title('F1 vs Threshold for dataset');
xlabel('Threshold');
ylabel('Measure');
legend('Highway','Traffic','Fall');


end