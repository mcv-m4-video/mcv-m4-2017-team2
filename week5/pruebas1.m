clearvars
close all

addpath('../datasets');
addpath('../utils');


video = VideoReader('parc_nova_icaria.mp4');

figure()

t = 0;
while hasFrame(video)
    t = t + 1;
    frame = readFrame(video);
    
    imshow(frame)
    title(strcat('frame ', num2str(t)))
    pause(0.01)
end

whos frame

