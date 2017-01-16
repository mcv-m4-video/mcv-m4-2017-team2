function task3_run(videoname, show_video, write_video)

close all

addpath('../utils');

% Compute detection with Stauffer and Grimson:
sequence = detection_st_gm(videoname);

% Evaluate detection:
filename = strcat('st_gm_', videoname);
[precision, recall, F1] = test_sequence(sequence, videoname, show_video, write_video, filename);
fprintf('Precision: %f\n', precision)
fprintf('Recall: %f\n', recall)
fprintf('F1: %f\n', F1)

end
