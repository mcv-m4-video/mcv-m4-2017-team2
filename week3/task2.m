%This function returns the Area Under the Curve for Precision vs Recall
%sweep through frames, given a further sweep between the size of the area
%for an opening applied. 
%Input parameters are:
%   'connectivity'  =   can be either 4 or 8 and corresponds to the
%                                   connectivity used in the imfill.
%   
%   'show_video'    =   set to '1' if want to display detection video.
%   'write_video'   =   set to '1' if show_video is enabled, saves said
%                       video.
%   'choice'        =   set to '1' for using Stauffer Grimson detection
%                       sequence, set to '2' for using Adaptative Model 
%                       detection.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [AUC,precision,recall,F1]= task2(connectivity, show_video, write_video, choice)


addpath('../utils');
if (choice==1)
    datapath = 'st_gm_sequences/';
    typo ='st_gm' ;
    pronoun ='res_';
    offset = 0;
    useTrain= true;
elseif (choice==2)
    datapath = 'adaptativeModel_sequences/';
    typo ='adaptativeModel' ;
    pronoun = 'in';
    offset = 1;
    useTrain= false;
else
    'Invalid data sequence...'
end

videoname = {'fall','highway','traffic'}; 

tic;

for v=1:size(videoname,2)
    sequence=[];
    seq_opened =[];

    filename = strcat(typo,'_filled_area_', int2str(connectivity), '_', videoname{v});

    [start_img, range_images, dirInputs, dirGT] = load_data(videoname{v});
    
    
    t = start_img + offset * (round(range_images/2));
    range_images = range_images - offset * (round(range_images/2));
    
    for i=1:range_images
        sequence(:,:,i)= double(imread(strcat(datapath,videoname{v},'/',pronoun,sprintf('%06d', t),'.png')));
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
        [precision(v,p_index), recall(v,p_index), F1(v,p_index), AUC(v,p_index)] = ...
            test_sequence_2val(seq_opened, videoname{v}, show_video, write_video, ...
            filename, useTrain, range_images);
    end

end
toc

indexmaxfall = find(max(AUC(1,:))==AUC(1,:),1,'first');
indexmaxhigh = find(max(AUC(2,:))==AUC(2,:),1,'first');
indexmaxtraf = find(max(AUC(3,:))==AUC(3,:),1,'first');

AUCmax_fall = AUC(1,indexmaxfall);
AUCmax_high = AUC(2,indexmaxhigh);
AUCmax_traf = AUC(3,indexmaxtraf);

label_1 = strcat({'Fall max AUC = '},num2str(AUCmax_fall),{' ('},num2str(P_number(indexmaxfall)),')');
label_2 = strcat({'Highway max AUC = '},num2str(AUCmax_high),{' ('},num2str(P_number(indexmaxhigh)),')');
label_3 = strcat({'Traffic max AUC = '},num2str(AUCmax_traf),{' ('},num2str(P_number(indexmaxtraf)),')');

p_str_fall = strcat({'P = '},num2str(P_number(indexmaxfall)));
p_str_high = strcat({'P = '},num2str(P_number(indexmaxhigh)));
p_str_traf = strcat({'P = '},num2str(P_number(indexmaxtraf)));

figure(1)
plot(P_number, AUC(1,:),'g',P_number, AUC(2,:),'b', P_number, AUC(3,:),'r'); 
legend([label_1, label_2, label_3]);
title('AUC vs Pixels for Stauffer & Grimson');
xlabel('Pixels');
ylabel('AUC');

text(P_number(indexmaxfall),(AUC(1,indexmaxfall)+0.02),p_str_fall,'HorizontalAlignment','left');
text(P_number(indexmaxhigh),(AUC(2,indexmaxfall)+0.08),p_str_high,'HorizontalAlignment','left');
text(P_number(indexmaxtraf),(AUC(3,indexmaxfall)+0.02),p_str_traf,'HorizontalAlignment','left');

hold on;
plot(P_number(indexmaxfall), AUC(1,indexmaxfall), 'o', P_number(indexmaxhigh), AUC(2,indexmaxhigh), 'o', P_number(indexmaxtraf), AUC(3,indexmaxtraf), 'o');

%P for max average AUC
indexmaxcomb = find(max(sum(AUC,1))==sum(AUC,1),1,'first');
bestP = P_number(indexmaxcomb);
AUC_mean_max = mean([AUC(1,indexmaxcomb),AUC(2,indexmaxcomb),AUC(3,indexmaxcomb)]);

end
