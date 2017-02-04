function [mu_matrix, sigma_matrix] = train_background(T1train, T2train, dirInputs)
% Get the training data for background:

nframes = T2train - T1train + 1;

t = T1train - 1;
for i = 1:nframes
    t = t + 1;
    filenumber = sprintf('%06d', t);
    filename = strcat('in', filenumber, '.jpg');
%     train_background(:,:,i) = double(rgb2gray(imread(strcat(dirInputs, filename)))) / 255;
    train_background(:,:,i) = double(rgb2gray(imread(strcat(dirInputs, filename))));
end

mu_matrix = mean(train_background, 3);
sigma_matrix = std(train_background, 1, 3);