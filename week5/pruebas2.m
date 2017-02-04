clearvars
close all

addpath('../utils/adaptive_model');

videoname = 'highway';

if (strcmp(videoname, 'highway'))
    alpha = 2.75;
    rho = 0.2;
    T1 = 1050;
    T2 = 1350;
    dirbase = '../datasets/cdvd/dataset/baseline/highway/';
elseif (strcmp(videoname, 'fall'))
    alpha = 3.25;
    rho = 0.05;
    T1 = 1460;
    T2 = 1560;
    dirbase = '../datasets/cdvd/dataset/dynamicBackground/fall/';
elseif (strcmp(videoname, 'traffic'))
    alpha = 2;
    rho = 0.225;
    T1 = 950;
    T2 = 1050;
    dirbase = '../datasets/cdvd/dataset/cameraJitter/traffic/';
else
    error('videoname not recognized.')
end

dirInputs = strcat(dirbase, 'input/');

nframes = int32(T2 - T1 + 1);

% Train adaptive model:
T1train = T1;
T2train = T1 + nframes / 2;
[mu_matrix, sigma_matrix] = train_background(T1train, T2train, dirInputs);

% Detect:
T1detect = T2train + 1;
T2detect = T2;
detection = detectionPipeline_adaptive(dirInputs, T1detect, T2detect, mu_matrix, sigma_matrix, alpha, rho);

% Show detection
figure()
sequence = zeros(size(detection));
t = T1detect - 1;
for i = 1:(T2detect-T1detect+1)
    % Read frame:
    t = t + 1;
    filenumber = sprintf('%06d', t);
    filename = strcat('in', filenumber, '.jpg');
    sequence(:,:,i) = double(rgb2gray(imread(strcat(dirInputs, filename))));
end
for i = 1:(T2detect-T1detect+1)
    subplot(1,2,1)
    imshow(sequence(:,:,i), [0 255])
    subplot(1,2,2)
    imshow(detection(:,:,i))
    title(num2str(i))
    pause(0.01)
end
