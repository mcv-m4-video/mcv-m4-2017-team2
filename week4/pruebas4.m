function task2_1_videostabilization_bm()
close all;

addpath('../datasets');
addpath('../utils');
addpath('../week2');

data = 'traffic';
[T1, nframes, dirInputs] = load_data(data);
input_files = list_files(dirInputs);
dirGT = strcat('../datasets/cdvd/dataset/cameraJitter/traffic/groundtruth/');

row1 = 160
row2 = 200;
col1 = 50
col2 = 90
figure()
t = T1;
for i = 1:nframes
    filenumber1 = sprintf('%06d', t);
    filepath1 = strcat(dirInputs, 'in', filenumber1, '.jpg');
    image1 = imread(filepath1);
    
    
    imshow(image1)
    hold on
    plot([col1 col2], [row1 row1], 'b')
    plot([col1 col2], [row2 row2], 'b')
    plot([col1 col1], [row1 row2], 'b')
    plot([col2 col2], [row1 row2], 'b')
    pause(0.1)
    
    t = t + 1;
end
