clearvars
close all

addpath('../datasets');
addpath('../utils');


video = VideoReader('parc_nova_icaria.mp4');
frame = readFrame(video);
    
figure()
imshow(frame)

hold on
plot([0, 300], [230, 0], 'r')
plot([640, 315], [365, 0], 'r')
plot([0, 640], [50, 50], 'r')
plot([0, 640], [88, 88], 'y')
plot([0, 640], [137, 137], 'y')
plot([0, 640], [405, 405], 'y')




