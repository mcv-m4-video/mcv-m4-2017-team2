function estimatedMotion = motionEstimation(previousFrame,currentFrame,sequence)
%% function estimatedMotion = motionEstimation(previousFrame,currentFrame,sequence)
%% Purpose : perform motion estimation using appropriate motion
%% estimation methods
%% INPUT : previousFrame -- array [nRows x nCols]
%% currentFrame -- array [nRows x nCols]
%% sequence -- structure
%% OUTPUT : estimatedMotion -- structure
%% fields : method -- string
%% relevantInfo -- array
%% motionVector -- array [u v];
%% MVmap -- structure with fields U and V
%% Author : T. Chen
%% Date : 02/24/2000
%%
%% Need to decide whether the motion fits in translational model or not
%%
motionModel = selectMotionModel(previousFrame,currentFrame,sequence);
%% Assign local variables
%%
U = motionModel.MVmap.U;
V = motionModel.MVmap.V;
blockSize = 16; % block size in block-matching ME
searchRange = 15; % search range
searchType = 1; % '1' == full search
%% Remove the MVs for the blocks on the frame boundary (they are all
%% pre-set to zero)
%%
[s1,s2] = size(U);
temp = U(2:s1-1,2:s2-1);
Us = reshape(temp,prod(size(temp)),1);
temp = V(2:s1-1,2:s2-1);
Vs = reshape(temp,prod(size(temp)),1);
%% Generate appropriate output structure
%%
switch motionModel.method
case 'block',
%% Obtain the appropriate global motion transformation parameters
%%
u = round(median(Us));
v = round(median(Vs));
%% Generate the estimatedMotion structure
%%
estimatedMotion.method = 'block';
estimatedMotion.relevantInfo = [blockSize searchRange 1];
estimatedMotion.motionVector = [u v];
estimatedMotion.MVmap.U = U;
estimatedMotion.MVmap.V = V;
case 'affine',
%% Obtain the appropriate global motion transformation parameters
%%
parameters = affinePara(previousFrame,currentFrame,U,V);
u = round(median(Us));
v = round(median(Vs));
%% Generate the estimatedMotion structure
%%
estimatedMotion.method = 'affine';
estimatedMotion.relevantInfo = parameters;
estimatedMotion.motionVector = [u v]; % Not required,
% but included anyway
estimatedMotion.MVmap.U = U;
estimatedMotion.MVmap.V = V;
otherwise,
error('Unsupported Motion Estimation Model!');
end