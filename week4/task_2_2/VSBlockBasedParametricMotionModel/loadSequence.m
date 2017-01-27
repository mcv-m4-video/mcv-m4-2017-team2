function sequence = loadSequence(sequence)
%% function sequence = loadSequence(sequence
%% Purpose : load original video sequence
%% INPUT : sequence -- structure
%% OUTPUT : sequence -- structure
%% Author : T. Chen
%% Date : 02/24/2000
%%
%% Assign local variables
name = sequence.name;
filepath = strcat('../data/',name,'/',name,'00');
switch name
case 'lamp',
    frameindex = [0:17 24:28 39:49]; % hand edited lamp sequence
case 'kids',
    frameindex = [12:59];
case 'car',
    frameindex = [0:44];
case 'flower',
%frameindex = [33:51]; % flowerFile_step2new.mat
frameindex = [33:2:51 50:-2:34]; % flowerFile_step2.mat
otherwise
    error('Unrecognized sequence name');
end
originalYPlane = repmat(0,[240 320 length(frameindex)]);
originalIPlane = originalYPlane;
originalQPlane = originalYPlane;
for i = 1:length(frameindex),
    if frameindex(i) < 10,
        filename = strcat(filepath,'0',num2str(frameindex(i)),'.raw');
    else
        filename = strcat(filepath,num2str(frameindex(i)),'.raw');
    end
    currentFrame = readDatafile(filename);
    currentY = 0.3*currentFrame(:,:,1) + ...
    0.59*currentFrame(:,:,2) + 0.11*currentFrame(:,:,3);
    currentI = 0.6*currentFrame(:,:,1) - ...
    0.28*currentFrame(:,:,2) - 0.32*currentFrame(:,:,3);
    currentQ = 0.21*currentFrame(:,:,1) - ...
    0.52*currentFrame(:,:,2) + 0.31*currentFrame(:,:,3);
    originalYPlane(:,:,i) = currentY;
    originalIPlane(:,:,i) = currentI;
    originalQPlane(:,:,i) = currentQ;
end
sequence.originalYPlane = originalYPlane;
sequence.originalIPlane = originalIPlane;
sequence.originalQPlane = originalQPlane;