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



% p0 = [1, 0, 0, 1, 0, 0]';
% p0 = [0.9351   0.0051  -0.0197   0.9761   0.0609   0.0646]';
p0 = [0.9590   0.0107  -0.0033   0.9968   0.0628   0.0691]';
% p0 = [0.9601   0.0112  -0.0040   0.9957   0.0634   0.0735]';
maxiter = 20;
dt = 0.01;
delta = 0.000001;

% Compute the model parameters:
mask = ones(size(img1,1), size(img1,2));
p = affine_gradient_descent(img2, img1, p0, dt, maxiter, delta, mask);

fprintf('\n\n computing mask...\n\n')

dfd = affine_dfd(img2, img1, p);
x = dfd(:);
x = x.^2;
percentile90 = prctile(x, 90);
mask = dfd.^2 < percentile90;

maxiter = 100;
dt = 0.1;
p0 = p;
p = affine_gradient_descent(img2, img1, p0, dt, maxiter, delta, mask);

fprintf('\n\n computing mask...\n\n')

dfd = affine_dfd(img2, img1, p);
x = dfd(:);
x = x.^2;
percentile90 = prctile(x, 90);
mask = dfd.^2 < percentile90;

maxiter = 200;
dt = 0.01;
p0 = p;
p = affine_gradient_descent(img2, img1, p0, dt, maxiter, delta, mask);

fprintf('\n\n computing mask...\n\n')

dfd = affine_dfd(img2, img1, p);
x = dfd(:);
x = x.^2;
percentile95 = prctile(x, 95);
mask = dfd.^2 < percentile95;

maxiter = 200;
dt = 0.001;
p0 = p;
p = affine_gradient_descent(img2, img1, p0, dt, maxiter, delta, mask);



% Visualize:
step = 20;
nrow = size(img1, 1);
ncol = size(img1, 2);
[r2, r1] = meshgrid(1:step:ncol, 1:step:nrow);
[D1, D2] = affine_transform(r1, r2, p);
figure()
imshow(img1)
hold on
quiver(r2, r1, D2, D1)
figure()
imshow(img2)

