function sequence = motionCorrection(sequence)
%% function sequence = motionCorrection(sequence)
%% Purpose : determine whether the motion is intentional and
%% smooth out/remove unwanted motion (vectors)
%% INPUT : sequence -- structure
%% OUTPUT : sequence -- structure
%%
%% Author : T. Chen
%% Date : 02/29/2000
%%
%% Assign local variables
%%
[nRows,nCols,nFrames] = size(sequence.originalYPlane);
originalYPlane = sequence.originalYPlane;
originalIPlane = sequence.originalIPlane;
originalQPlane = sequence.originalQPlane;
stabilizedYPlane = originalYPlane;
stabilizedIPlane = originalIPlane;
stabilizedQPlane = originalQPlane;
switch sequence.estimatedMotion(1).method,
case 'block',
    smoothedMVs = sequence.smoothedMVs;
    originalMVs = smoothedMVs;
    for i = 1:nFrames-1,
        originalMVs(i,:) = sequence.estimatedMotion(i).motionVector;
    end
%% Motion Correction
%%
threshold = sequence.MCpara.dThreshold; % threshold for synchronization
resetLength = sequence.MCpara.resetLength; % make sure synchronization
% occurs at least
% every resetLength frames
count = 0;
finalMVs = smoothedMVs; % resulting MVs with the effect of
% synchronization included, it should be
% approximately the same as smoothedMVs
for i = 1:nFrames-1,
    blockSize = sequence.estimatedMotion(i).relevantInfo(1);
%% calculate the motion vectors difference
%%
if i > 1,
    MVsDifference = ...
    sum(abs(sum(originalMVs(1:i-1,:))-sum(finalMVs(1:i-1,:))).^2);
end
%% determine whether synchronization should take place
%%
if (i == 1) | (MVsDifference > threshold^2 & count < resetLength),
% if no
stabilizedYPlane(:,:,i+1) = ...
motionCompensation(stabilizedYPlane(:,:,i),...
    originalYPlane(:,:,i+1),...
    originalMVs(i,:),smoothedMVs(i,:));
stabilizedIPlane(:,:,i+1) = ...
motionCompensation(stabilizedIPlane(:,:,i),...
    originalIPlane(:,:,i+1),...
    originalMVs(i,:),smoothedMVs(i,:));
stabilizedQPlane(:,:,i+1) = ...
motionCompensation(stabilizedQPlane(:,:,i),...
    originalQPlane(:,:,i+1),...
    originalMVs(i,:),smoothedMVs(i,:));
count = count + 1;
else % if yes
    fprintf('synchronization occurs at frame %d\n',i);
    stabilizedYPlane(:,:,i+1) = ...
    motionCompensation(originalYPlane(:,:,i),...
        originalYPlane(:,:,i+1),...
        originalMVs(i,:),smoothedMVs(i,:));
    stabilizedIPlane(:,:,i+1) = ...
    motionCompensation(originalIPlane(:,:,i),...
        originalIPlane(:,:,i+1),...
        originalMVs(i,:),smoothedMVs(i,:));
    stabilizedQPlane(:,:,i+1) = ...
    motionCompensation(originalQPlane(:,:,i),...
        originalQPlane(:,:,i+1),...
        originalMVs(i,:),smoothedMVs(i,:));
    count = 0;
    finalMVs(i,:) = smoothedMVs(i,:) + ...
    sum(originalMVs(1:i-1,:)) - ...
    sum(smoothedMVs(1:i-1,:));
end
end
%% Add new fields to sequence
%%
sequence.stabilizedYPlane = stabilizedYPlane;
sequence.stabilizedIPlane = stabilizedIPlane;
sequence.stabilizedQPlane = stabilizedQPlane;
sequence.finalMVs = finalMVs;
%% Compare the three different motion vectors
%%
figure;
subplot(211);
plot(originalMVs(:,1),'-o'); hold on;
plot(smoothedMVs(:,1),'r-s'); hold on;
plot(finalMVs(:,1),'g-^'); hold off;
temp = axis; axis([temp(1:2) -15 15]);
xlabel('Frames'); ylabel('u (horizontal direction)');
legend('original MV','smoothed MV','smoothed MV w/ error control');
subplot(212);
plot(originalMVs(:,2),'-o'); hold on;
plot(smoothedMVs(:,2),'r-s'); hold on;
plot(finalMVs(:,2),'g-^'); hold off;
temp = axis; axis([temp(1:2) -15 15]);
xlabel('Frames'); ylabel('v (vertical direction)');
legend('original MV','smoothed MV','smoothed MV w/ error control ');
%% End of case 'block'
case 'affine',
    smoothedAngles = ...
    atan(sequence.smoothedPara(:,2)./sequence.smoothedPara(:,1))/pi*180;
    originalAngles = smoothedAngles;
    smoothedOffsets = sequence.smoothedPara(:,3:4);
    originalOffsets = smoothedOffsets;
    for i = 1:nFrames-1,
        originalAngles(i) = ...
        atan(sequence.estimatedMotion(i).relevantInfo(2)/...
            sequence.estimatedMotion(i).relevantInfo(1))/pi*180;
        originalOffsets(i,:) = ...
        sequence.estimatedMotion(i).relevantInfo(3:4)';
    end
%% Motion Correction
%%
aThreshold = sequence.MCpara.aThreshold;
dThreshold = sequence.MCpara.dThreshold;
resetLength = sequence.MCpara.resetLength;
count = 0;
finalAngles = smoothedAngles;
finalOffsets = smoothedOffsets;
%temp = [];
%temp1 = [];
for i = 1:nFrames-1,
    para = sequence.estimatedMotion(i).relevantInfo;
    matAtoB = [para(1) -para(2); para(2) para(1)];
    matAtoB_inv = inv(matAtoB);
    affAtoB = [para(3); para(4)];
    affAtoB_inv = -matAtoB_inv*affAtoB;
    if i > 1,
        OffsetDifference = ...
        sum(abs(sum(originalOffsets(1:i-1,:))-sum(finalOffsets(1:i-1,:))).^2);
        AngleDifference = ...
        abs(sum(originalAngles(1:i-1)) - sum(finalAngles(1:i-1)));
% temp = [temp OffsetDifference];
% temp1 = [temp1 AngleDifference];
end
if i == 1 | (AngleDifference < aThreshold & OffsetDifference ...
    < dThreshold^2 & count >= 3) | count >= resetLength ,
fprintf('synchronization occurs at frame %d\n',i);
stabilizedYPlane(:,:,i+1) = ...
affineRec(matAtoB_inv, affAtoB_inv, ...
    originalYPlane(:,:,i),originalYPlane(:,:,i+1));
stabilizedIPlane(:,:,i+1) = ...
affineRec(matAtoB_inv, affAtoB_inv, ...
    originalIPlane(:,:,i),originalIPlane(:,:,i+1));
stabilizedQPlane(:,:,i+1) = ...
affineRec(matAtoB_inv, affAtoB_inv, ...
    originalQPlane(:,:,i),originalQPlane(:,:,i+1));
count = 0;
finalAngles(i) = smoothedAngles(i) + ...
sum(originalAngles(1:i-1)) - ...
sum(smoothedAngles(1:i-1));
finalOffsets(i,:) = smoothedOffsets(i,:) + ...
sum(originalOffsets(1:i-1,:)) - ...
sum(smoothedOffsets(1:i-1,:));
else
    stabilizedYPlane(:,:,i+1) = ...
    affineRec(matAtoB_inv, affAtoB_inv, ...
        stabilizedYPlane(:,:,i),originalYPlane(:,:,i+1));
    stabilizedIPlane(:,:,i+1) = ...
    affineRec(matAtoB_inv, affAtoB_inv, ...
        stabilizedIPlane(:,:,i),originalIPlane(:,:,i+1));
    stabilizedQPlane(:,:,i+1) = ...
    affineRec(matAtoB_inv, affAtoB_inv, ...
        stabilizedQPlane(:,:,i),originalQPlane(:,:,i+1));
    count = count + 1;
end %% End of 'if' statement
end %% End of 'for' statement
%figure;
%subplot(211); plot(temp1,'-o');
%subplot(212); plot(temp,'-o');
%% Add new fields to sequence
%%
sequence.stabilizedYPlane = stabilizedYPlane;
sequence.stabilizedIPlane = stabilizedIPlane;
sequence.stabilizedQPlane = stabilizedQPlane;
%% Compare the different motion parameters
%%
figure;
subplot(311);
plot(originalAngles,'-o'); hold on;
plot(smoothedAngles,'r-s'); hold on;
plot(finalAngles,'g-^'); hold off;
xlabel('Frames'); ylabel('\theta');
legend('original','smoothed','smoothed w/ error control');
subplot(312);
plot(originalOffsets(:,1),'-o'); hold on;
plot(smoothedOffsets(:,1),'r-s'); hold on;
plot(finalOffsets(:,1),'g-^'); hold off;
xlabel('Frames'); ylabel('x_{offset}');
legend('original','smoothed','smoothed w/ error control');
subplot(313);
plot(originalOffsets(:,2),'-o'); hold on;
plot(smoothedOffsets(:,2),'r-s'); hold on;
plot(finalOffsets(:,2),'g-^'); hold off;
xlabel('Frames'); ylabel('y_{offset}');
legend('original','smoothed','smoothed w/ error control');
%% End of case 'affine'
otherwise
    error('Not supported');
end %% End of 'switch' statement