function parameters = affinePara(previousFrame,currentFrame,U,V)
%% function motionModel = affinePara(previousFrame,currentFrame,U,V)
%% Purpose : perform motion estimation using affine motion model on
%% motion vectors from block matching motion estimation
%% INPUT : previousFrame -- array [nRows x nCols]
%% currentFrame -- array [nRows x nCols]
%% U -- array [mRows x mCols]
%% V -- array [mRows x mCols]
%% OUTPUT : parameters -- array
%%
%% Author : T. Chen
%% Date : 03/03/2000
%%
%% Assign local variables
%%
[nRows,nCols] = size(previousFrame);
[mRows,mCols] = size(U);
blockSize = nRows/mRows;
offset = round(blockSize/2);
currentXYs = [];
Hxy = [];
for i = 2:mRows-1,
y = blockSize*(i-1)+offset;
for j = 2:mCols-1,
x = blockSize*(j-1)+offset;
Y = y + V(i,j);
X = x + U(i,j);
currentXYs = [currentXYs; X; Y];
Hxy = [Hxy; x -y 1 0; y x 0 1];
end
end
parameters = pinv(Hxy)*currentXYs;