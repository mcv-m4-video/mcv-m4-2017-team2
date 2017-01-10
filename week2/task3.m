clearvars
close all

addpath('../datasets');
addpath('../utils');
addpath('../utils/StGm');
addpath('../week2');

% Evaluating data and metrics
dirGT = '../datasets/cdvd/dataset/baseline/highway/groundtruth/';
background = 55;
foreground = 250;

% Directory for writing results:
dirResults = './results/';


videoname = 'fall';

if(strcmp(videoname, 'highway'))
    T1 = 1050;
    T2 = 1350;
elseif(strcmp(videoname, 'fall'))
    T1 = 1460;
    T2 = 1560;
elseif(strcmp(videoname, 'traffic'))
    T1 = 950;
    T2 = 1050;
else
    error('Sequence not recognized.')
end

Threshold = 2;
K = 3;
Rho = 0.1;
THFG = 0.1;


% Compute detection:
[Sequence] = MultG_fun(Threshold, T1, T2, K, Rho, THFG, videoname);

% Write detection:
write_sequence(Sequence, dirResults, T1);

% Evaluate detection:
[precision, recall, F1] = test_written_sequence(dirResults, videoname);

% Write video:
v = VideoWriter('stgm.avi','Grayscale AVI');
v.FrameRate = 15;
open(v)
for i = 1:size(Sequence,3)
    frame = mat2gray(Sequence(:,:,i));
    writeVideo(v,frame)
end
close(v)



