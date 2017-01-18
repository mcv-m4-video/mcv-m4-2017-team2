function task1(videoname, connectivity, show_video, write_video)

% connectivity can be either 4 or 8.

close all

addpath('../utils');

% % Compute detection with Stauffer and Grimson:
% sequence = detection_st_gm(videoname);

% Read detection of adaptive method:
dirsequence = strcat('./adaptativeModel_sequences/', videoname, '/');
sequence = read_sequence(dirsequence);

% Fill holes:
% sequence = fill_holes(sequence, connectivity);

% Evaluate detection:
% filename = strcat('st_gm_filled', int2str(connectivity), '_', videoname);
filename = strcat('adaptive_filled', int2str(connectivity), '_', videoname);
[precision, recall, F1] = test_sequence(sequence, videoname, show_video, write_video, filename);
fprintf('Precision: %f\n', precision)
fprintf('Recall: %f\n', recall)
fprintf('F1: %f\n', F1)

end