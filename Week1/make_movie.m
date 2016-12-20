% Make a video with the sequence to analize.

clearvars
close all

dirinput = '../datasets/cdvd/dataset/baseline/highway/input/';
dirGT = '../datasets/cdvd/dataset/baseline/highway/groundtruth/';
dirResults = '../datasets/cdvd/dataset/baseline/highway/results/';

results_files = list_files(dirResults);
nfiles = size(results_files,1);

% Prepare the video object:
v = VideoWriter('highway_video.avi');
open(v);

fig = figure();

for i = 1:nfiles
    
    file_class  = results_files(i).name(6);
    file_number = results_files(i).name(8:13);  % example: take '001201' from 'test_A_001201.png'
    
    input_image = imread(strcat(dirinput,'in',file_number,'.jpg')); % Read the input image
    gt_image = imread(strcat(dirGT,'gt',file_number,'.png'));  % Read the ground truth image
    test_A = imread(strcat(dirResults,'test_A_',file_number,'.png'));  % Read the A image
    test_B = imread(strcat(dirResults,'test_B_',file_number,'.png'));  % Read the B image
    
    subplot(2,2,1)
    imshow(input_image)
    title(['in',file_number,'.jpg'])
    subplot(2,2,2)
    imshow(gt_image)
    title('Ground Truth')
    subplot(2,2,3)
    imshow(test_A, [0 1])
    title('Test A')
    subplot(2,2,4)
    imshow(test_B, [0 1])
    title('Test B')
        
    frame = getframe(fig);
    writeVideo(v,frame);
end

close(v);
        