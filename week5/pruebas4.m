clearvars
close all

addpath('../utils/adaptive_model');

NumGaussians = 5;
LearningRate = 0.0109;
MinimumBackgroundRatio = 0.4;
T1 = 500;
T2 = 1000;

dirInputs = './sequence_parc_nova_icaria/';

nframes = int32(T2 - T1 + 1);

NumTrainingFrames = 100;

% Detect:
detection = detectionPipeline_stgm(dirInputs, T1, T2, NumGaussians, NumTrainingFrames, ...
                            LearningRate, MinimumBackgroundRatio);
                        
% Leave out all the detections outside the Region Of Interes:
mask = imread('mask_roi_parc_nova_icaria.png');
mask = double(mask(:,:,1) > 0.5);
for i = 1:nframes
    detection(:,:,i) = detection(:,:,i) .* mask;
end

% Show detection
figure()
t = T1 - 1;
for i = 1:nframes
    subplot(1,2,1)
    t = t + 1;
    filenumber = sprintf('%06d', t);
    filename = strcat('in', filenumber, '.jpg');
    frame = double(rgb2gray(imread(strcat(dirInputs, filename))));
    imshow(frame, [0 255])
    subplot(1,2,2)
    imshow(detection(:,:,i))
    title(num2str(i))
    pause(0.01)
end
