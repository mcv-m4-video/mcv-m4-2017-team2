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
    frame = double(imread(strcat(seq,'/',files(i).name)));
    originalYPlane(:,:,i) = frame(:,:,1);
    originalIPlane(:,:,i) = frame(:,:,2);
    originalQPlane(:,:,i) = frame(:,:,3);
end

sequence.originalYPlane = originalYPlane;
sequence.originalIPlane = originalIPlane;
sequence.originalQPlane = originalQPlane;


% function sequence = loadSequence2(sequence)
% %% function sequence = loadSequence(sequence
% %% Purpose : load original video sequence
% %% INPUT : sequence -- structure
% %% OUTPUT : sequence -- structure
% %% Author : T. Chen
% %% Date : 02/24/2000
% %%
% %% Assign local variables
% name = sequence.name;
% filepath = strcat(name,'/');
% switch name
%     case 'traffic',
%         % frameindex = [950:1050]; % hand edited lamp sequence
%         frameindex = [950:960]; % hand edited lamp sequence
% otherwise
%     error('Unrecognized sequence name');
% end

% originalYPlane = repmat(0,[240 320 length(frameindex)]);
% originalIPlane = originalYPlane;
% originalQPlane = originalYPlane;

% for i = 1:length(frameindex),
%     if frameindex(i) < 1000,
%         filename = strcat(filepath,'in000',num2str(frameindex(i)),'.jpg');
%     else
%         filename = strcat(filepath,'in00',num2str(frameindex(i)),'.jpg');
%     end
%     currentFrame = readDatafile2(filename);
%     currentY = 0.3*currentFrame(:,:,1) + ...
%     0.59*currentFrame(:,:,2) + 0.11*currentFrame(:,:,3);
%     currentI = 0.6*currentFrame(:,:,1) - ...
%     0.28*currentFrame(:,:,2) - 0.32*currentFrame(:,:,3);
%     currentQ = 0.21*currentFrame(:,:,1) - ...
%     0.52*currentFrame(:,:,2) + 0.31*currentFrame(:,:,3);
%     originalYPlane(:,:,i) = currentY;
%     originalIPlane(:,:,i) = currentI;
%     originalQPlane(:,:,i) = currentQ;
% end

% sequence.originalYPlane = originalYPlane;
% sequence.originalIPlane = originalIPlane;
% sequence.originalQPlane = originalQPlane;
