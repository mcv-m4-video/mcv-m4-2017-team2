clearvars
close all

dirinput = '..\datasets\data_stereo_flow\training\image_0\';

im_number = 45;
% im_number = 157;

filename_old = strcat(sprintf('%06d', im_number), '_10.png');
filename_curr = strcat(sprintf('%06d', im_number), '_11.png');

I_old = double(imread(strcat(dirinput, filename_old))) / 255;
I_curr = double(imread(strcat(dirinput, filename_curr))) / 255;

% I_old = imresize(I_old, [100, 400]);
% I_curr = imresize(I_curr, [100, 400]);

% I_old = imresize(I_old, [10, 20]);
% I_curr = imresize(I_curr, [10, 20]);

I_old(1:5,:) = 0;
I_old(end-5:end,:) = 0;
I_old(:,1:5) = 0;
I_old(:,end-5:end) = 0;
I_curr(1:5,:) = 0;
I_curr(end-5:end,:) = 0;
I_curr(:,1:5) = 0;
I_curr(:,end-5:end) = 0;

p0 = [1, 0, 0, 1, 0, 0]';
maxiter = 1000;
dt = 0.01;
delta = 0.000001;




fprintf('Computing global affine model by gradient descent...\n')

pold = p0; % Introduce the initial condition.

iterate = 1; % Flag to decide when to stop iterating.
iter = 0; % Number of iterations counter.

p1 = p0;
p2 = p0;
p3 = p0;
p4 = p0;
p5 = p0;
p6 = p0;

epsilon = 0.01;

p1(1) = p0(1) + epsilon;
p2(2) = p0(2) + epsilon;
p3(3) = p0(3) + epsilon;
p4(4) = p0(4) + epsilon;
p5(5) = p0(5) + epsilon;
p6(6) = p0(6) + epsilon;

[gradient0, error0] = compute_gradient_error(I_curr, I_old, p0);
[~, error1] = compute_gradient_error(I_curr, I_old, p1);
[~, error2] = compute_gradient_error(I_curr, I_old, p2);
[~, error3] = compute_gradient_error(I_curr, I_old, p3);
[~, error4] = compute_gradient_error(I_curr, I_old, p4);
[~, error5] = compute_gradient_error(I_curr, I_old, p5);
[~, error6] = compute_gradient_error(I_curr, I_old, p6);

partial1 = (error1 - error0) / epsilon;
partial2 = (error2 - error0) / epsilon;
partial3 = (error3 - error0) / epsilon;
partial4 = (error4 - error0) / epsilon;
partial5 = (error5 - error0) / epsilon;
partial6 = (error6 - error0) / epsilon;

gradient0
[partial1, partial2, partial3, partial4, partial5, partial6]






