function M = sequenceDisplay2(sequence)
%% function M = sequenceDisplay(sequence)
%% Purpose : Display the original and smoothed video sequence
%% INPUT : sequence -- structure
%% OUTPUT : M -- array representing the video sequences
%% Author : T. Chen
%% Date : 03/08/2000
%%
rgb2yiq = [0.3 0.59 0.11; 0.6 -0.28 -0.32; 0.21 -0.52 0.31];
yiq2rgb = inv(rgb2yiq);
[nRows,nCols,nFrames] = size(sequence.originalYPlane);
figure;
M = [];
M = moviein(nFrames);
if strcmp(sequence.displayOption,'color'),
    for i = 1:nFrames,
        originalYPlane = sequence.originalYPlane(:,:,i);
        originalIPlane = sequence.originalIPlane(:,:,i);
        originalQPlane = sequence.originalQPlane(:,:,i);
        originalFrame(:,:,1) = yiq2rgb(1,1)*originalYPlane + ...
        yiq2rgb(1,2)*originalIPlane + ...
        yiq2rgb(1,3)*originalQPlane;
        originalFrame(:,:,2) = yiq2rgb(2,1)*originalYPlane + ...
        yiq2rgb(2,2)*originalIPlane + ...
        yiq2rgb(2,3)*originalQPlane;
        originalFrame(:,:,3) = yiq2rgb(3,1)*originalYPlane + ...
        yiq2rgb(3,2)*originalIPlane + ...
        yiq2rgb(3,3)*originalQPlane;
        originalFrame = max(originalFrame,0);
        originalFrame = originalFrame/max(originalFrame(:));
        stabilizedYPlane = sequence.stabilizedYPlane(:,:,i);
        stabilizedIPlane = sequence.stabilizedIPlane(:,:,i);
        stabilizedQPlane = sequence.stabilizedQPlane(:,:,i);
        stabilizedFrame(:,:,1) = yiq2rgb(1,1)*stabilizedYPlane + ...
        yiq2rgb(1,2)*stabilizedIPlane + ...
        yiq2rgb(1,3)*stabilizedQPlane;
        stabilizedFrame(:,:,2) = yiq2rgb(2,1)*stabilizedYPlane + ...
        yiq2rgb(2,2)*stabilizedIPlane + ...
        yiq2rgb(2,3)*stabilizedQPlane;
        stabilizedFrame(:,:,3) = yiq2rgb(3,1)*stabilizedYPlane + ...
        yiq2rgb(3,2)*stabilizedIPlane + ...
        yiq2rgb(3,3)*stabilizedQPlane;
        stabilizedFrame = max(stabilizedFrame,0);
        stabilizedFrame = stabilizedFrame/max(stabilizedFrame(:));
        compareFrame = [originalFrame stabilizedFrame];
        imshow(compareFrame); axis image; truesize;
        M(:,i) = getframe;

        % Save animated gif
        fig = figure();
        imshow(compareFrame); axis image; truesize;
        outfile = strcat('task_2_2_BlockBasedParamMotionModelVideoStabilization.gif');
        fig_frame = getframe(fig);
        im = frame2im(fig_frame);
        if i == 1
            imwrite(rgb2gray(im),outfile,'gif','LoopCount',Inf,'DelayTime',0.1);
        else
            imwrite(rgb2gray(im),outfile,'gif','WriteMode','append','DelayTime',0.1);
        end

    end
else
    for i = 1:nFrames,
        originalFrame = sequence.originalYPlane(:,:,i);
        stabilizedFrame = sequence.stabilizedYPlane(:,:,i);
        compareFrame = [originalFrame stabilizedFrame];
        colormap(gray(256)); imagesc(compareFrame); axis image; truesize;
        M(:,i) = getframe;
    end

    % Save animated gif
    fig = figure();
    for i = 1:nFrames,
        imshow(M(:, i).cdata);
        outfile = strcat('task_2_2_BlockBasedParamMotionModelVideoStabilization.gif');
        fig_frame = getframe(fig);
        im = frame2im(fig_frame);
        if i == 1
            imwrite(rgb2gray(im),outfile,'gif','LoopCount',Inf,'DelayTime',0.1);
        else
            imwrite(rgb2gray(im),outfile,'gif','WriteMode','append','DelayTime',0.1);
        end
    end
    
end