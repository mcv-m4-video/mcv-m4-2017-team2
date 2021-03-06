function sequence = detection_st_gm(videoname)

black_n_white = 1;

if(strcmp(videoname, 'highway'))
    T1 = 1050;
    T2 = 1350;
    dirinput = '../datasets/cdvd/dataset/baseline/highway/input/';
    NumGaussians = 3;
    LearningRate = 0.0109;
    MinimumBackgroundRatio = 0.4;
    
elseif(strcmp(videoname, 'fall'))
    T1 = 1460;
    T2 = 1560;
    dirinput = '../datasets/cdvd/dataset/dynamicBackground/fall/input/';
    NumGaussians = 2;
    LearningRate = 0.0406;
    MinimumBackgroundRatio = 0.7;
    
elseif(strcmp(videoname, 'traffic'))
    T1 = 950;
    T2 = 1050;
    dirinput = '../datasets/cdvd/dataset/cameraJitter/traffic/input/';
    NumGaussians = 3;
    LearningRate = 0.0406;
    MinimumBackgroundRatio = 0.6;
    
else
    error('Sequence not recognized.')
end

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

end