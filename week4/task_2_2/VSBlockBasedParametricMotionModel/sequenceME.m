function estimatedMotion = sequenceME(sequence)
%% function estimatedMotion = sequenceME(sequence)
%% Purpose : perform motion estimation using appropriate motion
%% estimation methods
%% INPUT : sequence -- structure
%% OUTPUT : estimatedMotion -- structure
%% Author : T. Chen
%% Date : 02/24/2000
%%
%% Assign local variables :
%%
%% Perform motion estimation on Y plane only
%%
originalFrames = sequence.originalYPlane;
nFrames = size(originalFrames,3);
%% Motion Estimation between adjacent frames
%%
estimatedMotion = [];
for i = 2:nFrames,
previousFrame = originalFrames(:,:,i-1);
currentFrame = originalFrames(:,:,i);
fprintf('Motion Estimation for frame %d and %d\n', i-1,i);
currentEstimatedMotion = ...
motionEstimation(previousFrame,currentFrame,sequence);
estimatedMotion = [estimatedMotion currentEstimatedMotion];
end