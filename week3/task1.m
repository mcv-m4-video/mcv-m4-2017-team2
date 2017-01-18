function task1(videoname, connectivity, method, show_video, write_video)

% connectivity can be either 4 or 8.

close all

addpath('../utils');

% Get the detection sequence:
switch (method)
    case('st_gm')
        % Compute detection with Stauffer and Grimson:
        sequence = detection_st_gm(videoname);
        % Name of the file for writing results:
        filename = strcat('st_gm_filled', int2str(connectivity), '_', videoname);
        % Use all the sequence for evaluation:
        useTrain = 1;
        
    case('adaptive')
        % Read detection of adaptive method:
        dirsequence = strcat('./adaptativeModel_sequences/', videoname, '/');
        sequence = double(read_sequence(dirsequence));
        % Name of the file for writing results:
        filename = strcat('adaptive_filled', int2str(connectivity), '_', videoname);
        % Use second half of the sequence for evaluation:
        useTrain = 0;
        
    otherwise
        error('Detection method not recognized.')
end

% Fill holes:
sequence = fill_holes(sequence, connectivity);

% Evaluate detection:
[precision, recall, F1] = test_sequence_2val(sequence, videoname, show_video, write_video, filename, useTrain, size(sequence,3));
fprintf('Precision: %f\n', precision)
fprintf('Recall: %f\n', recall)
fprintf('F1: %f\n', F1)

end