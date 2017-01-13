clearvars
close all

addpath('../datasets');
addpath('../utils');
addpath('../utils/StGm');

% Evaluating data and metrics
background = 55;
foreground = 250;

% Directory for writing results:
dirResults = './results/';

% Compute in black and white?
black_n_white = 1;

% Select video sequence:
videoname = 'traffic';

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

% Number of Gaussians (fixed):
K = 6;

% Parameters to search:
LearningRate_vec = linspace(0.001, 0.05, 10);
MinimumBackgroundRatio_vec = linspace(0.1, 0.9, 5);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Compute over grid:
F1_array = zeros(length(LearningRate_vec), length(MinimumBackgroundRatio_vec));
progress = 10;
fprintf('Completed 0%%\n')
for idx1 = 1:length(LearningRate_vec)
    if(idx1 > progress / 100 * length(LearningRate_vec))
        fprintf('Completed %i%%\n', progress)
        progress = progress + 10;
    end
    LearningRate = LearningRate_vec(idx1);
    for idx2 = 1:length(MinimumBackgroundRatio_vec)
        MinimumBackgroundRatio = MinimumBackgroundRatio_vec(idx2);
        % Initialize sequence:
        sequence = zeros(height, width, nframes);
        % Create detector:
        foregroundDetector = vision.ForegroundDetector('NumGaussians', K, ...
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
        [~, ~, F1_array(idx1, idx2)] = test_sequence(sequence, videoname, T1, 0);
    end
end
fprintf('Completed 100%%\n')

% Search over grid:
idx1max = 0;
idx2max = 0;
F1max = 0;
for idx1 = 1:length(LearningRate_vec)
    for idx2 = 1:length(MinimumBackgroundRatio_vec)
        if(F1max < F1_array(idx1, idx2))
            idx1max = idx1;
            idx2max = idx2;
            F1max = F1_array(idx1, idx2);
        end
    end
end

LearningRate = LearningRate_vec(idx1max);
MinimumBackgroundRatio = MinimumBackgroundRatio_vec(idx2max);

fprintf('Best values found for K = %i Gaussians: %f\n', K, F1max)
fprintf('LearningRate = %f\n', LearningRate)
fprintf('MinimumBackgroundRatio = %f\n', MinimumBackgroundRatio)





