function [mu_matrix, sigma_matrix] = train_background_color(start_img, range_images, input_files, dirInputs, colorspace)
%Get the training data for background:
for i=1:(1 + round(range_images/2))
    index = i + start_img - 1;
    file_number = input_files(index).name(3:8);  % example: take '001050' from 'im001050.png'
    if strcmp(colorspace,'RGB')
        train_backg_in(:,:,:,i) = double(imread(strcat(dirInputs,'in',file_number,'.jpg')));
    elseif strcmp(colorspace,'YUV')
        train_backg_in(:,:,:,i) = double(imread(strcat(dirInputs,'in',file_number,'.jpg')));
        train_backg_in(:,:,:,i) = rgb2yuv(train_backg_in(:,:,:,i));
    elseif strcmp(colorspace,'HSV')
        train_backg_in(:,:,:,i) = double(rgb2hsv(imread(strcat(dirInputs,'in',file_number,'.jpg'))));
        train_backg_in(:,:,:,i) = 255.* train_backg_in(:,:,:,i); 
    else 
        error('colorspace not recognized');
    end
end

mu_matrix = mean(train_backg_in,4);
sigma_matrix = std(train_backg_in, 1, 4);