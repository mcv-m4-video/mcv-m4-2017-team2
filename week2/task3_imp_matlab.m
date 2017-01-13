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
sequence = zeros(size(frame,1), size(frame,2), nframes);

foregroundDetector = vision.ForegroundDetector('NumGaussians', 3, ...
    'NumTrainingFrames', round(nframes/2), 'LearningRate', 0.005, ...
    'MinimumBackgroundRatio', 0.7);

t = T1;
for i = 1:nframes
    file_number = sprintf('%06d', t);
    frame = rgb2gray(imread(strcat(dirinput, 'in', file_number, '.jpg')));  % Read the frame
    sequence(:,:,i) = step(foregroundDetector, frame);
    t = t + 1;
end

% Evaluate detection:
[precision, recall, F1] = test_sequence(sequence, videoname, T1, 1);

% % Write video:
% v = VideoWriter('stgm.avi','Grayscale AVI');
% v.FrameRate = 15;
% open(v)
% for i = 1:size(sequence,3)
%     frame = mat2gray(sequence(:,:,i));
%     writeVideo(v,frame)
% end
% close(v)



