function st_gm_precision_recall(videoname, K, LearningRate)

addpath('../utils');

if(strcmp(videoname, 'highway'))
    T1 = 1050;
    T2 = 1350;
    dirinput = '../datasets/cdvd/dataset/baseline/highway/input/';
elseif(strcmp(videoname, 'fall'))
    T1 = 1460;
    T2 = 1560;
    dirinput = '../datasets/cdvd/dataset/dynamicBackground/fall/input/';
elseif(strcmp(videoname, 'traffic'))
    T1 = 950;
    T2 = 1050;
    dirinput = '../datasets/cdvd/dataset/cameraJitter/traffic/input/';
else
    error('Sequence not recognized.')
end

nframes = T2-T1+1;
frame = rgb2gray(imread(strcat(dirinput, 'in000001.jpg')));

MinimumBackgroundRatio_vec = linspace(0, 1, 21);

precision = zeros(1,length(MinimumBackgroundRatio_vec));
recall = zeros(1,length(MinimumBackgroundRatio_vec));

progress = 10;
fprintf('Completed 0%%\n')
for j = 1:length(MinimumBackgroundRatio_vec)
    if(j > progress / 100 * length(MinimumBackgroundRatio_vec))
        fprintf('Completed %i%%\n', progress)
        progress = progress + 10;
    end
    
    MinimumBackgroundRatio = MinimumBackgroundRatio_vec(j);
    
    sequence = zeros(size(frame,1), size(frame,2), nframes);

    foregroundDetector = vision.ForegroundDetector('NumGaussians', K, ...
                'NumTrainingFrames', round(nframes/2), 'LearningRate', LearningRate, ...
                'MinimumBackgroundRatio', MinimumBackgroundRatio);

    % Compute detection:
    t = T1;
    for i = 1:nframes
        file_number = sprintf('%06d', t);
        frame = rgb2gray(imread(strcat(dirinput, 'in', file_number, '.jpg')));  % Read the frame
        sequence(:,:,i) = step(foregroundDetector, frame);
        t = t + 1;
    end

    % Evaluate detection:
    [precision(j), recall(j), ~] = test_sequence(sequence, videoname, T1, 0);
end
fprintf('Completed 100%%\n')

plot(recall, precision)
