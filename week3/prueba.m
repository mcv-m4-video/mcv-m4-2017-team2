clearvars
close all

addpath('../utils');

videoname = 'fall';
show_video = 1;
write_video = 0;
filename = 'prueba';

useTrain = 0;

dirinput = strcat('./task3_results/', videoname, '/');
sequence = double(read_sequence(dirinput));


% Evaluate detection:
[precision, recall, F1] = test_sequence_2val(sequence, videoname, show_video, write_video, filename, useTrain);
fprintf('Precision: %f\n', precision)
fprintf('Recall: %f\n', recall)
fprintf('F1: %f\n', F1)

