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



t = 1000;
file_number = sprintf('%06d', t);
img1 = double(rgb2gray(imread(strcat(dirinput, 'in', file_number, '.jpg')))) / 255;

t = 1001;
file_number = sprintf('%06d', t);
img2 = double(rgb2gray(imread(strcat(dirinput, 'in', file_number, '.jpg')))) / 255;



p0 = [0, 0]';
maxiter = 1000;
dt = 0.1;
delta = -1;

% Compute the model parameters:
mask = ones(size(img1,1), size(img1,2));
p = translation_gradient_descent(img2, img1, p0, dt, maxiter, delta, mask);



% Visualize:
step = 20;
nrow = size(img1, 1);
ncol = size(img1, 2);
[r2, r1] = meshgrid(1:step:ncol, 1:step:nrow);
[D1, D2] = translation_transform(r1, r2, p);
figure()
imshow(img1)
hold on
quiver(r2, r1, D2, D1)
figure()
imshow(img2)

