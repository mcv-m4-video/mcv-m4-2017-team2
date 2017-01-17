function task2(videoname, connectivity, show_video, write_video)

addpath('../utils');

%show_video = 0; write_video = 0;

%videoname = {'fall','highway','traffic'}; 
%connectivity = 4;

% Compute detection with Stauffer and Grimson:
filename = strcat('st_gm_filled_area_', int2str(connectivity), '_', videoname);

sequence = detection_st_gm(videoname);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [start_img, range_images, dirInputs, dirGT] = load_data(videoname);
%     
% %open dataset
% input_files = list_files(dirInputs);
% 
% [mu_matrix, sigma_matrix] = train_background(start_img, range_images, input_files, dirInputs);
% sequence = single_alpha(2, mu_matrix, sigma_matrix, range_images, start_img, dirInputs, input_files, 50, 255, dirGT);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sequence2 = fill_holes(sequence, connectivity);

pace=10;

[precision, recall, F1, AUC] = test_sequence_2val(sequence, videoname, show_video, write_video, filename);

% for p=0:pace:200
%     p_index = 1 + (p/pace);
%     P_number(p_index)= p;
%     for i=1:size(sequence,3)
%         seq_opened(:,:,i) = bwareaopen(sequence(:,:,i),p);
%     end
%     [precision(p_index,:), recall(p_index,:), F1(p_index,:), AUC(p_index)] = test_sequence_2val(sequence, videoname, show_video, write_video, filename);
% end

figure(1)
plot(P_number, AUC);
title('AUC vs Pixels');
xlabel('Pixels');
ylabel('AUC');

end