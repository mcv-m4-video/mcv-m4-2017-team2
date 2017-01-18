function task1_comparacion(videoname, connectivity, method)

% connectivity can be either 4 or 8.

close all

addpath('../utils');

% Get the detection sequence:
switch (method)
    case('st_gm')
        % Compute detection with Stauffer and Grimson:
        sequence = detection_st_gm(videoname);
        % Use all the sequence for evaluation:
        useTrain = 0;
        
    case('adaptive')
        % Read detection of adaptive method:
        dirsequence = strcat('./adaptativeModel_sequences/', videoname, '/');
        sequence = double(read_sequence(dirsequence));
        % Use second half of the sequence for evaluation:
        useTrain = 1;
        
    otherwise
        error('Detection method not recognized.')
end

% Fill holes:
sequence_filled = fill_holes(sequence, connectivity);

% Evaluate detection:
[precision, recall, F1] = test_sequence_2val(sequence_filled, videoname, 0, 0, 'prueba', useTrain);
fprintf('Precision: %f\n', precision)
fprintf('Recall: %f\n', recall)
fprintf('F1: %f\n', F1)


%%%%%%%%%%%%%%%%%%
%%%%% Comparacion

if (strcmp(videoname, 'highway'))
    T1 = 1050;
elseif (strcmp(videoname, 'fall'))
    T1 = 1460;
elseif (strcmp(videoname, 'traffic'))
    T1 = 950;
else
    error('videoname not recognized.')
end

if (useTrain)
    t = T1 + nfiles - 1;
else
    t = T1;
end

for i = 1:size(sequence,3)
    file_number = sprintf('%06d', t);
    
    subplot(1,2,1)
    imshow(sequence(:,:,i), [0 1])
    title(['original ',file_number])
    subplot(1,2,2)
    imshow(sequence_filled(:,:,i), [0 1])
    title(['filled ',file_number])
    pause(0.001)
    
    t = t + 1;
end

end