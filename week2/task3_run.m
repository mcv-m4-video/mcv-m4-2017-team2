function task3_run(videoname, writevideo)

close all

addpath('../utils');

black_n_white = 1;

% Directory for writing results:
dirResults = './results';

if(exist(dirResults, 'dir') ~= 7)
    mkdir(dirResults)
end

if(strcmp(videoname, 'highway'))
    T1 = 1050;
    T2 = 1350;
    dirbase = '../datasets/cdvd/dataset/baseline/highway';
    NumGaussians = 3;
    LearningRate = 0.0109;
    MinimumBackgroundRatio = 0.4;
    
elseif(strcmp(videoname, 'fall'))
    T1 = 1460;
    T2 = 1560;
    dirbase = '../datasets/cdvd/dataset/dynamicBackground/fall';
    NumGaussians = 2;
    LearningRate = 0.0406;
    MinimumBackgroundRatio = 0.7;
    
elseif(strcmp(videoname, 'traffic'))
    T1 = 950;
    T2 = 1050;
    dirbase = '../datasets/cdvd/dataset/cameraJitter/traffic';
    NumGaussians = 3;
    LearningRate = 0.0406;
    MinimumBackgroundRatio = 0.6;
    
else
    error('Sequence not recognized.')
end

dirGT = strcat(dirbase, '/groundtruth/');
dirinput = strcat(dirbase, '/input/');

nframes = T2-T1+1;
frame = rgb2gray(imread(strcat(dirinput, 'in000001.jpg')));
sequence = zeros(size(frame,1), size(frame,2), nframes);

foregroundDetector = vision.ForegroundDetector('NumGaussians', NumGaussians, ...
            'NumTrainingFrames', round(nframes/2), 'LearningRate', LearningRate, ...
            'MinimumBackgroundRatio', MinimumBackgroundRatio);

fprintf(['Computing detection with Stauffer-Grimson for sequence ', videoname, '...\n'])
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
fprintf('Done!\n')

% Evaluate detection:
[precision, recall, F1] = test_sequence(sequence, videoname, T1, 0);
fprintf('Precision: %f\n', precision)
fprintf('Recall: %f\n', recall)
fprintf('F1: %f\n', F1)

% Write video:
if(writevideo == 1)
    motion = 170; %%%%%  OJO CON ESTO
    fig = figure();
    v = VideoWriter(strcat(dirResults, '/stgm_', videoname, '.avi'));
    v.FrameRate = 15;
    open(v)
    for i = 1:nframes
        file_number = sprintf('%06d', t);
        gt = imread(strcat(dirGT, 'gt', file_number, '.png'));  % Read the GT image
        test = sequence(:,:,i);  % Read the image
        gt = gt >= motion;  % binarize gt mask
        
        subplot(1,2,1)
        imshow(gt, [0 1])
        title(['gt',file_number,'.png'])
        subplot(1,2,2)
        imshow(test, [0 1])
        title(['sequence(:,:,', num2str(i),')'])
        pause(0.001)

        frame = getframe(fig);
        writeVideo(v,frame);
    end
    close(v)
end

end
