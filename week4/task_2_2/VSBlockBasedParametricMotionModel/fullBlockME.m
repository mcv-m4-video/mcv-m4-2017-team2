function [u,v] = fullBlockME(i,j,blk_length,search_range,f1_Y,f2_Y)
%% function [u,v] = fullBlockME(i,j,blk_length,search_range,f1_Y,f2_Y)
%% Purpose : returns the motion vector for block i-j using MSE
%% criterion
%% INPUT : i,j -- block index
%% blk_length -- size of block
%% search_range -- [-search_range search_range]
%% f1_Y -- previous frame
%% f2_Y -- current frame
%% OUTPUT : [u, v] -- motion displacements in horizontal and vertical
%% direction, respectively
%% Author : T. Chen
%% Date : 02/24/2000
%%
sqrtMSEs = [];
%% store the target block into a 16x16 matrix block2
%%
block2 = f2_Y(blk_length*(i-1)+1:blk_length*i,....
blk_length*(j-1)+1:blk_length*j);
vector2 = reshape(block2,1,blk_length^2); % reshape to 1-D array
%% search and calculate MSE and store MSE results into MSEs
%%
for y_offset = -search_range:search_range,
for x_offset = -search_range:search_range,
block1 = f1_Y(blk_length*(i-1)+1+y_offset:blk_length*i+y_offset,....
blk_length*(j-1)+1+x_offset:blk_length*j+x_offset);
vector1 = reshape(block1,1,blk_length^2);
sqrtMSEs = [sqrtMSEs norm(vector2-vector1)];
end
end
[temp, index] = min(sqrtMSEs);
%% calculate motion vector
v = -search_range + floor((index(1)-1)/(2*search_range+1));
u = -search_range + rem(index(1)-1, 2*search_range+1);
