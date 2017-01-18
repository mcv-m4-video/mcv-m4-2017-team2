clearvars
close all

addpath('../utils');

videoname = 'traffic';
show_video = 1;
write_video = 0;
filename = 'prueba';

useTrain = 1;

dirinput = strcat('./task3_results/', videoname, '/');
sequence = double(read_sequence(dirinput));


% Evaluate detection:
[precision, recall, F1] = test_sequence_2val(sequence, videoname, show_video, write_video, filename, useTrain, size(sequence,3));
fprintf('Precision: %f\n', precision)
fprintf('Recall: %f\n', recall)
fprintf('F1: %f\n', F1)

