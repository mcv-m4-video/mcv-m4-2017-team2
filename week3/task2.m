function [AUC,precision,recall,F1]= task2(connectivity, show_video, write_video)

addpath('../utils');
datapath = 'st_gm_sequences/';

%show_video = 0; write_video = 0;

videoname = {'fall','highway','traffic'}; 
%connectivity = 4;
tic;

for v=1:size(videoname,2)
    sequence=[];
    seq_opened =[];
    % Compute detection with Stauffer and Grimson:
    filename = strcat('st_gm_filled_area_', int2str(connectivity), '_', videoname{v});

    [start_img, range_images, dirInputs, dirGT] = load_data(videoname{v});

    t = start_img; 
    for i=1:range_images
        sequence(:,:,i)= imread(strcat(datapath,videoname{v},'/','res_',sprintf('%06d', t),'.png'));
        t=t+1;
    end
    sequence = fill_holes(sequence, connectivity);

    pace=50;

    for p=0:pace:1000
        p_index = 1 + (p/pace);
        P_number(p_index)= p;
        for i=1:size(sequence,3)
            seq_opened(:,:,i) = bwareaopen(sequence(:,:,i),p);
        end
        [precision(v,p_index), recall(v,p_index), F1(v,p_index), AUC(v,p_index)] = test_sequence_2val(seq_opened, videoname{v}, show_video, write_video, filename);
    end

end
toc

indexmaxfall = find(max(AUC(1,:))==AUC(1,:));
indexmaxhigh = find(max(AUC(2,:))==AUC(2,:));
indexmaxtraf = find(max(AUC(3,:))==AUC(3,:));

AUCmax_fall = AUC(1,indexmaxfall);
AUCmax_high = AUC(2,indexmaxhigh);
AUCmax_traf = AUC(3,indexmaxtraf);

label_1 = strcat({'Fall max AUC = '},num2str(AUCmax_fall));
label_2 = strcat({'Highway max AUC = '},num2str(AUCmax_high));
label_3 = strcat({'Traffic max AUC = '},num2str(AUCmax_traf));

p_str_fall = strcat({'P = '},num2str(P_number(indexmaxfall)));
p_str_high = strcat({'P = '},num2str(P_number(indexmaxhigh)));
p_str_traf = strcat({'P = '},num2str(P_number(indexmaxtraf)));

figure(1)
plot(P_number, AUC(1,:),'g',P_number, AUC(2,:),'b', P_number, AUC(3,:),'r'); 
legend([label_1, label_2, label_3]);
title('AUC vs Pixels');
xlabel('Pixels');
ylabel('AUC');

text(P_number(indexmaxfall),0.82,p_str_fall,'HorizontalAlignment','left');
text(P_number(indexmaxhigh),0.87,p_str_high,'HorizontalAlignment','left');
text(P_number(indexmaxtraf),0.59,p_str_traf,'HorizontalAlignment','left');

hold on;
plot(P_number(indexmaxfall), AUC(1,indexmaxfall), 'o', P_number(indexmaxhigh), AUC(2,indexmaxhigh), 'o', P_number(indexmaxtraf), AUC(3,indexmaxtraf), 'o');

end