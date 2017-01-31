function [mu_matrix, sigma_matrix] = train_background(start_img, range_images, input_files, dirInputs, cropImage, cropSize)
%Get the training data for background:
for i=1:(1 + round(range_images/2))
    index = i + start_img - 1;
    file_number = input_files(index).name(3:8);  % example: take '001050' from 'im001050.png'
    try
        img = double(rgb2gray(imread(strcat(dirInputs,'in',file_number,'.jpg'))));
    catch
        img = double(imread(strcat(dirInputs,'in',file_number,'.jpg')));
    end

    % when we work with stabilized images, the margins need to be cut out
    if cropImage
        img = img(20:size(img,1)-20,20:size(img,2)-20,:);
    end

    train_backg_in(:,:,i) = img;

end

mu_matrix = mean(train_backg_in,3);
sigma_matrix = std(train_backg_in, 1, 3);