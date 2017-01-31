%%% pruebas

clearvars
close all




addpath('../utils');

% Compute in black and white?
black_n_white = 1;

% Select video sequence:
videoname = 'traffic';



% Select directories and times depending on video sequence:
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

dirinput = strcat(dirbase, '/input/');

nframes = T2-T1+1;
frame = rgb2gray(imread(strcat(dirinput, 'in000001.jpg')));
[height, width] = size(frame);



t = 1000;
file_number = sprintf('%06d', t);
img1 = imread(strcat(dirinput, 'in', file_number, '.jpg'));

t = 1001;
file_number = sprintf('%06d', t);
img2 = imread(strcat(dirinput, 'in', file_number, '.jpg'));






