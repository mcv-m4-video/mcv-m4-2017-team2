% Make a video with the sequence to analize.

clearvars
close all

% videoName = 'highway.avi';
% dirinput = '../datasets/cdvd/dataset/baseline/highway/input/';

videoName = 'traffic.avi';
dirinput = '../datasets/cdvd/dataset/cameraJitter/traffic/input/';

files = list_files(dirinput);

outputVideo = VideoWriter(fullfile(videoName));
open(outputVideo)

for ii = 1:length(files)
   filename = files(ii).name;
   img = imread(strcat(dirinput,filename));
   writeVideo(outputVideo,img)
end

close(outputVideo)