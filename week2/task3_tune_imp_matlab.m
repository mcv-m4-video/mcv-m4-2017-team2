clearvars
close all

addpath('../utils');

% Evaluating data and metrics
background = 55;
foreground = 250;

% Directory for writing results:
dirResults = './results/';

% Compute in black and white?
black_n_white = 1;

% Select video sequence:
videoname = 'highway';

if(strcmp(videoname, 'highway'))
    T1 = 1050;
    T2 = 1350;
    dirbase = '../datasets/cdvd/dataset/baseline/highway';
elseif(strcmp(videoname, 'fall'))
    T1 = 1460;
    T2 = 1560;
    dirbase = '../datasets/cdvd/dataset/dynamicBackground/fall';
elseif(strcmp(videoname, 'traffic'))
    T1 = 950;
    T2 = 1050;
    dirbase = '../datasets/cdvd/dataset/cameraJitter/traffic';
else
    error('Sequence not recognized.')
end

dirGT = strcat(dirbase, '/groundtruth/');
dirinput = strcat(dirbase, '/input/');

nframes = T2-T1+1;
frame = rgb2gray(imread(strcat(dirinput, 'in000001.jpg')));
[height, width] = size(frame);

% Parameters to search:
NumGaussians_vec = [1, 2, 3, 4, 5, 6];
LearningRate_vec = linspace(0.001, 0.1, 10);
MinimumBackgroundRatio_vec = linspace(0, 1, 6);

% NumGaussians_vec = [3, 5];
% LearningRate_vec = linspace(0.001, 0.1, 3);
% MinimumBackgroundRatio_vec = linspace(0, 1, 2);

% Initialize arrays to store the results:
precision_array = zeros(length(NumGaussians_vec), ...
        length(LearningRate_vec), length(MinimumBackgroundRatio_vec));
recall_array = zeros(length(NumGaussians_vec), ...
        length(LearningRate_vec), length(MinimumBackgroundRatio_vec));
F1_array = zeros(length(NumGaussians_vec), ...
        length(LearningRate_vec), length(MinimumBackgroundRatio_vec));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Compute over grid:
progress = 10;
fprintf('Completed 0%%\n')
for idx1 = 1:length(NumGaussians_vec)
    if(idx1 > progress / 100 * length(NumGaussians_vec))
        fprintf('Completed %i%%\n', progress)
        progress = progress + 10;
    end
    NumGaussians = NumGaussians_vec(idx1);
    for idx2 = 1:length(LearningRate_vec)
        LearningRate = LearningRate_vec(idx2);
        for idx3 = 1:length(MinimumBackgroundRatio_vec)
            MinimumBackgroundRatio = MinimumBackgroundRatio_vec(idx3);
            % Initialize sequence:
            sequence = zeros(height, width, nframes);
            % Create detector:
            foregroundDetector = vision.ForegroundDetector('NumGaussians', NumGaussians, ...
                'NumTrainingFrames', round(nframes/2), 'LearningRate', LearningRate, ...
                'MinimumBackgroundRatio', MinimumBackgroundRatio);
            % Compute detection:
            t = T1;
            for i = 1:nframes
                file_number = sprintf('%06d', t);
                frame = imread(strcat(dirinput, 'in', file_number, '.jpg'));  % Read the frame
                if(black_n_white == 1) % Turn to black and white.
                    frame = rgb2gray(frame);
                end
                sequence(:,:,i) = step(foregroundDetector, frame);
                t = t + 1;
            end
            % Evaluate detection:
            [precision_array(idx1, idx2, idx3), recall_array(idx1, idx2, idx3), ...
                    F1_array(idx1, idx2, idx3)] = test_sequence(sequence, videoname, T1, 0);
        end
    end
end
fprintf('Completed 100%%\n')

% Search for maximum F1:
fprintf('Searching for maximum F1... ')
idx1maxF1 = 0;
idx2maxF1 = 0;
idx3maxF1 = 0;
F1max = 0;
for idx1 = 1:length(NumGaussians_vec)
    for idx2 = 1:length(LearningRate_vec)
        for idx3 = 1:length(MinimumBackgroundRatio_vec)
            if(F1max < F1_array(idx1, idx2, idx3))
                idx1maxF1 = idx1;
                idx2maxF1 = idx2;
                idx3maxF1 = idx3;
                F1max = F1_array(idx1, idx2, idx3);
                prec_F1max = precision_array(idx1, idx2, idx3); % Precision, where F1 is maximum.
                rec_F1max = recall_array(idx1, idx2, idx3); % Recall, where F1 is maximum.
            end
        end
    end
end
F1max_results = [prec_F1max, rec_F1max, F1max; ...
    NumGaussians_vec(idx1maxF1), LearningRate_vec(idx2maxF1), MinimumBackgroundRatio_vec(idx3maxF1)];
fprintf('Done!\n')

% Search for maximum precision, given recall:
fprintf('Searching for maximum precision, given recall... ')
recall_axis = linspace(0, 1, 20);
pr_curve_results = zeros(length(recall_axis), 5);
pr_curve_results(:,1) = recall_axis;
for i = 1:length(recall_axis)
    minrecall = recall_axis(i);
    idx1max = 0;
    idx2max = 0;
    idx3max = 0;
    precisionmax = 0;
    for idx1 = 1:length(NumGaussians_vec)
        for idx2 = 1:length(LearningRate_vec)
            for idx3 = 1:length(MinimumBackgroundRatio_vec)
                if(recall_array(idx1, idx2, idx3) >= minrecall)
                    if(precisionmax < precision_array(idx1, idx2, idx3))
                        idx1max = idx1;
                        idx2max = idx2;
                        idx3max = idx3;
                        precisionmax = precision_array(idx1, idx2, idx3);
                    end
                end
            end
        end
    end
    pr_curve_results(i, 2) = precisionmax;
    pr_curve_results(i, 3) = idx1max;
    pr_curve_results(i, 4) = idx2max;
    pr_curve_results(i, 5) = idx3max;
end
fprintf('Done!\n')

% Write results:
dlmwrite(strcat('pr_curve_results_', videoname, '.txt'), pr_curve_results)
dlmwrite(strcat('maxF1_', videoname, '.txt'), F1max_results)


NumGaussians = NumGaussians_vec(idx1maxF1);
LearningRate = LearningRate_vec(idx2maxF1);
MinimumBackgroundRatio = MinimumBackgroundRatio_vec(idx3maxF1);

fprintf('Precision: %f,   recall: %f,   F1: %f\n', prec_F1max, rec_F1max, F1max)
fprintf('NumGaussians = %f\n', NumGaussians)
fprintf('LearningRate = %f\n', LearningRate)
fprintf('MinimumBackgroundRatio = %f\n', MinimumBackgroundRatio)

% Plot precision - recall curve:
precision = pr_curve_results(:,2);
recall = pr_curve_results(:,1);
plot(recall, precision, 'LineWidth', 2)
ylabel('Precision')
xlabel('Recall')
axis([0 1 0 1])
title('Precision - Recall curve')
auc_pr = trapz(precision) / length(precision);



