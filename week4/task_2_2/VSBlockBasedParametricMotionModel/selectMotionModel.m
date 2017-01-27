function motionModel = selectMotionModel(previousFrame,currentFrame,sequence)
%% function motionModel = selectMotionModel(previousFrame,currentFrame,sequence)
%% Purpose : distinguish rotation from translation (for now)
%% INPUT : previousFrame -- array [nRows x nCols]
%% currentFrame -- array [nRows x nCols]
%% sequence -- structure
%% OUTPUT : motionModel -- structure
%%
%% Author : T. Chen
%% Date : 03/07/2000
%%
%% Assign local variables
%%
[nRows,nCols] = size(previousFrame);
varThreshold = 5;
searchRange = 15;
%% First need to obtain local optical flow information.
%% by default use the standard block-matching, full search and MSE criterion
%%
blockSize = 16;
searchRange = 15;
searchType = 1; % '1' == full search
U = zeros(nRows/blockSize,nCols/blockSize);
V = U;
%% Need to speed up considerably :
%%
for i=2:nRows/blockSize-1,
for j=2:nCols/blockSize-1,
%% fprintf('\nME for block %d-%d\n',i,j);
[u,v] = fullBlockME(i,j,blockSize,searchRange,previousFrame,currentFrame);
U(i,j) = u;
V(i,j) = v;
end
end
%% Testing scripts :
%% display the motion field
%%
X = 1:blockSize:nCols; % horizontal direction
Y = 1:blockSize:nRows; % vertical direction
figure(1); quiver(X,Y,U,V); title('Motion Vector Field');
axis ij; axis equal; axis tight
%% display histogram of the motion vectors
%%
%% First remove the MVs on the frame boundary
%%
[s1,s2] = size(U);
temp = U(2:s1-1,2:s2-1);
Us = reshape(temp,prod(size(temp)),1);
temp = V(2:s1-1,2:s2-1);
Vs = reshape(temp,prod(size(temp)),1);
figure(2);
subplot(211); hist(Us,-searchRange:searchRange);
xlabel('Frame'); ylabel('u (horizontal direction)');
subplot(212); hist(Vs,-searchRange:searchRange);
ylabel('Frame'); ylabel('v (vertical direction)');
%% Determine the appropriate motion model :
%% pre-processing to filter out the extreme outliners
%% Here assume the extreme outliners are the ones with less than
%% certain percentage of probability
%%
prefilterThreshold = 0.02;
Us_median = median(Us);
Vs_median = median(Vs);
num = length(Us);
for i = -searchRange:searchRange,
index = find(Us==i);
if length(index)/num < prefilterThreshold,
Us(index) = Us_median;
end
index = find(Vs==i);
if length(index)/num < prefilterThreshold,
Vs(index) = Vs_median;
end
end
%% create structure motionModel
%% Notice right now this decision making process only works well when
%% the frames are not motion blurred so the MEs are accurate.
%% So ideally there should be a motion-deblurring routine before the
%% block-matching motion estimation
%% However, since I do not have a chance to implement such a function
%% right now, and I did not hand edit the video sequence and threw out
%% the blurred frames, I will cheat a little bit here.
%% Actually, what I really want to do here is to come up an algorithm
%% that can be "smart" enough to detect the blurred frames and
%% consequently remove their effects. Also the case where occasionally
%% the wrong motion type is mistakenly determined should be able to
%% be corrected somehow by exploiting the motion characteristics of
%% the overall video sequence. For this to work, we still assume that
%% the same type of motions is always associated with a cluster of frames
%%
%%
if strcmp(sequence.name,'lamp') | strcmp(sequence.name,'car') | ...
strcmp(sequence.name,'kids'),
motionModel.method = 'block';
elseif var(Us) <= varThreshold & var(Vs) <= varThreshold,
motionModel.method = 'block';
else
motionModel.method = 'affine';
%% regenerate U and V by applying weighted MSE
%%
U = zeros(nRows/blockSize,nCols/blockSize);
V = U;
for i=2:nRows/blockSize-1,
for j=2:nCols/blockSize-1,
[u,v] = ...
fullBlockME_weighted(i,j,blockSize,searchRange,previousFrame,currentFrame);
U(i,j) = u;
V(i,j) = v;
end
end
end
motionModel.MVmap.U = U;
motionModel.MVmap.V = V;