function task2(videoname, connectivity, show_video, write_video)

addpath('../utils');

%show_video = 0; write_video = 0;

%videoname = {'fall','highway','traffic'}; 
%connectivity = 4;

% Compute detection with Stauffer and Grimson:
filename = strcat('st_gm_filled_', int2str(connectivity), '_', videoname);

sequence = detection_st_gm(videoname);
sequence = fill_holes(sequence, connectivity);

for p=0:50:1000
    p_index = 1 + (p/50);
    P_number(p_index)= p;
    for i=1:size(sequence,3)
        seq_opened(:,:,i) = bwareaopen(sequence(:,:,i),p);
        [precision(p_index,:), recall(p_index,:), F1(p_index,:), AUC(p_index)] = test_sequence_2val(sequence, videoname, show_video, write_video, filename);
    end
end

figure(1)
plot(P_number, AUC);
title('AUC vs Pixels');
xlabel('Pixels');
ylabel('AUC');

end