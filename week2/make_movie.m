% Make a video with the sequence to analize.

clearvars
close all

videoname = 'traffic';

if (strcmp(videoname, 'highway'))
    T1 = 1050;
    T2 = 1350;
    dirGT = '../datasets/cdvd/dataset/baseline/highway/groundtruth/';
    dirinput = '../datasets/cdvd/dataset/baseline/highway/input/';
    
elseif (strcmp(videoname, 'fall'))
    T1 = 1460;
    T2 = 1560;
    dirGT = '../datasets/cdvd/dataset/dynamicBackground/fall/groundtruth/';
    dirinput = '../datasets/cdvd/dataset/dynamicBackground/fall/input/';
    
elseif (strcmp(videoname, 'traffic'))
    T1 = 950;
    T2 = 1050;
    dirGT = '../datasets/cdvd/dataset/cameraJitter/traffic/groundtruth/';
    dirinput = '../datasets/cdvd/dataset/cameraJitter/traffic/input/';
else
    error('videoname not recognized.')
end

nframes = T2 - T1 + 1;

% Prepare the video object:
v = VideoWriter([videoname, '_video.avi']);
open(v);

fig = figure();

t = T1;
for i = 1:nframes
    file_number = sprintf('%06d', t);

    input_image = imread(strcat(dirinput,'in',file_number,'.jpg')); % Read the input image
    gt_image = imread(strcat(dirGT,'gt',file_number,'.png'));  % Read the ground truth image

    subplot(1,2,1)
    imshow(input_image)
    title(['in',file_number,'.jpg'])
    subplot(1,2,2)
    imshow(gt_image)
    title('Ground Truth')

    frame = getframe(fig);
    writeVideo(v,frame);
    
    t = t + 1;
end

close(v);
        