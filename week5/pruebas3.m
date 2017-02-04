clearvars
close all

addpath('../utils/adaptive_model');

videoname = 'highway';

if (strcmp(videoname, 'highway'))
    NumGaussians = 3;
    LearningRate = 0.0109;
    MinimumBackgroundRatio = 0.4;
    T1 = 1050;
    T2 = 1350;
    dirbase = '../datasets/cdvd/dataset/baseline/highway/';
elseif (strcmp(videoname, 'fall'))
    NumGaussians = 2;
    LearningRate = 0.0406;
    MinimumBackgroundRatio = 0.7;
    T1 = 1460;
    T2 = 1560;
    dirbase = '../datasets/cdvd/dataset/dynamicBackground/fall/';
elseif (strcmp(videoname, 'traffic'))
    NumGaussians = 3;
    LearningRate = 0.0406;
    MinimumBackgroundRatio = 0.6;
    T1 = 950;
    T2 = 1050;
    dirbase = '../datasets/cdvd/dataset/cameraJitter/traffic/';
else
    error('videoname not recognized.')
end

dirInputs = strcat(dirbase, 'input/');

nframes = int32(T2 - T1 + 1);

NumTrainingFrames = round(nframes/2);

% Detect:
detection = detectionPipeline_stgm(dirInputs, T1, T2, NumGaussians, NumTrainingFrames, ...
                            LearningRate, MinimumBackgroundRatio);

% Show detection
figure()
sequence = zeros(size(detection));
t = T1 - 1;
for i = 1:nframes
    % Read frame:
    t = t + 1;
    filenumber = sprintf('%06d', t);
    filename = strcat('in', filenumber, '.jpg');
    sequence(:,:,i) = double(rgb2gray(imread(strcat(dirInputs, filename))));
end
for i = 1:nframes
    subplot(1,2,1)
    imshow(sequence(:,:,i), [0 255])
    subplot(1,2,2)
    imshow(detection(:,:,i))
    title(num2str(i))
    pause(0.01)
end
