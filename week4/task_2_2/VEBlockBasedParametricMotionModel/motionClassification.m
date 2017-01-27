function sequence = motionClassification(sequence)
%% function sequence = motionClassification(sequence)
%% Purpose : determine whether the motion is intentional and
%% smooth out/remove unwanted motion (vectors)
%% INPUT : sequence -- structure
%% OUTPUT : sequence -- structure
%%
%% Author : T. Chen
%% Date : 02/24/2000
%%
%% Assign local variables
%%
estimatedMotion = sequence.estimatedMotion;
[nRows,nCols,nFrames] = size(sequence.originalYPlane);
kernelLength = 5; % 5 for 'flower'
MAFilter = ones(1,kernelLength)/kernelLength;
%% Assume the entire sequence can be described by the same
%% type of motion model. In reality, we can always segment
%% the sequence so that each segment of sequences only describes
%% one type of motion.
%%
switch estimatedMotion(1).method
case 'block',
%% Examine the estimated motion vectors
%%
u = [];
v = [];
for i = 1:nFrames-1,
    u = [u estimatedMotion(i).motionVector(1)];
    v = [v estimatedMotion(i).motionVector(2)];
end
%% Smooth out the motion vectors
%% For now, use a Moving Average (MA) filter
%%
us = conv(u,MAFilter);
vs = conv(v,MAFilter);
if rem(kernelLength,2) == 1,
    us = us((kernelLength+1)/2:(length(us)-(kernelLength-1)/2));
    vs = vs((kernelLength+1)/2:(length(vs)-(kernelLength-1)/2));
else
    us = us(kernelLength/2+1:(length(us)-(kernelLength/2-1)));
    vs = vs(kernelLength/2+1:(length(vs)-(kernelLength/2-1)));
end
%% Only integer pixel movement is allowed
%%
us = round(us);
vs = round(vs);
figure;
subplot(211); plot(u,'-o'); hold on; plot(us,'r-s'); hold off
subplot(212); plot(v,'-o'); hold on; plot(vs,'r-s'); hold off
%% Add new fields to sequence
sequence.smoothedMVs = [us' vs'];
case 'affine',
%% Examine the estimated motion vectors
%%
alpha = [];
beta = [];
xoffset = [];
yoffset = [];
theta = [];
for i = 1:nFrames-1,
    alpha = [alpha estimatedMotion(i).relevantInfo(1)];
    beta = [beta estimatedMotion(i).relevantInfo(2)];
    theta = [theta atan(beta(i)/alpha(i))];
    xoffset = [xoffset estimatedMotion(i).relevantInfo(3)];
    yoffset = [yoffset estimatedMotion(i).relevantInfo(4)];
end
%% Smooth out the rotation (angle) and translation (offsets)
%% For now, use a Moving Average (MA) filter
%%
thetas = conv(theta,MAFilter);
xoffsets = round(conv(xoffset,MAFilter));
yoffsets = round(conv(yoffset,MAFilter));
if rem(kernelLength,2) == 1,
    thetas = ...
    thetas((kernelLength+1)/2:(length(thetas)-(kernelLength-1)/2));
    xoffsets = ...
    xoffsets((kernelLength+1)/2:(length(xoffsets)-(kernelLength-1)/2));
    yoffsets = ...
    yoffsets((kernelLength+1)/2:(length(yoffsets)-(kernelLength-1)/2));
else
    thetas = thetas(kernelLength/2+1:(length(thetas)-(kernelLength/2-1)));
    xoffsets = ...
    xoffsets(kernelLength/2+1:(length(xoffsets)-(kernelLength/2-1)));
    yoffsets = ...
    yoffsets(kernelLength/2+1:(length(yoffsets)-(kernelLength/2-1)));
end
%% Only integer pixel movement is allowed
%%
figure;
subplot(311); plot(theta/pi*180,'-o');
hold on; plot(thetas/pi*180,'r-s'); ylabel('Angle of rotation (^o)');
legend('original','smoothed');
hold off
subplot(312); plot(xoffset,'-o');
hold on; plot(xoffsets,'r-s'); ylabel('x_{offset}');
legend('original','smoothed');
hold off
subplot(313); plot(yoffset,'-o');
hold on; plot(yoffsets,'r-s'); ylabel('y_{offset}');
legend('original','smoothed');
hold off
%% Add new fields to sequence
smoothedAlpha = cos(thetas).*sqrt(alpha.^2+beta.^2);
smoothedBeta = sin(thetas).*sqrt(alpha.^2+beta.^2);
smoothedXoffset = xoffsets;
smoothedYoffset = yoffsets;
sequence.smoothedPara = ...
[smoothedAlpha' smoothedBeta' smoothedXoffset' smoothedYoffset'];
otherwise
    error('Motion Model Not supported');
end