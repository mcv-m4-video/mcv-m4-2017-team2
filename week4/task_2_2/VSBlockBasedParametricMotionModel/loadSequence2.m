function sequence = loadSequence2(sequence)
%% function sequence = loadSequence(sequence
%% Purpose : load original video sequence
%% INPUT : sequence -- structure
%% OUTPUT : sequence -- structure
%% Author : T. Chen
%% Date : 02/24/2000
%%
%% Assign local variables
seq = sequence.name;
files = ListFiles(seq);
NumFrames = size(files,1);
NumFramesH = floor(NumFrames/2);

for i=1:NumFramesH
    frame = imread(strcat(seq,'/',files(i).name));
    frame = rgb2ntsc(frame);  % Convert RGB color values to NTSC color space
    originalYPlane(:,:,i) = frame(:,:,1);
    originalIPlane(:,:,i) = frame(:,:,2);
    originalQPlane(:,:,i) = frame(:,:,3);
end

sequence.originalYPlane = originalYPlane;
sequence.originalIPlane = originalIPlane;
sequence.originalQPlane = originalQPlane;
