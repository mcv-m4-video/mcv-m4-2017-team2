function [precision, recall, F1] = test_sequence(sequence, videoname, T1, show_plot)

if (strcmp(videoname, 'highway'))
    dirGT = '../datasets/cdvd/dataset/baseline/highway/groundtruth/';
    
elseif (strcmp(videoname, 'fall'))
    dirGT = '../datasets/cdvd/dataset/dynamicBackground/fall/groundtruth/';
    
elseif (strcmp(videoname, 'traffic'))
    dirGT = '../datasets/cdvd/dataset/cameraJitter/traffic/groundtruth/';
    
else
    error('videoname not recognized.')
end

nfiles = size(sequence,3);

TP = 0; FP = 0; FN = 0; TN = 0;

motion = 170; %%%%%  OJO CON ESTO

t = T1;
for i = 1:nfiles
    file_number = sprintf('%06d', t);
    gt = imread(strcat(dirGT, 'gt', file_number, '.png'));  % Read the GT image
    test = sequence(:,:,i);  % Read the image
    gt = gt >= motion;  % binarize gt mask
    [TP_frame, TN_frame, FP_frame, FN_frame] = get_metrics(gt, test);
    TP = TP + TP_frame;
    FP = FP + FP_frame;
    FN = FN + FN_frame;
    TN = TN + TN_frame;
    
    if(show_plot == 1)
        subplot(1,2,1)
        imshow(gt, [0 1])
        title(['gt',file_number,'.png'])
        subplot(1,2,2)
        imshow(test, [0 1])
        title(['sequence(:,:,', num2str(i),')'])
        pause(0.001)
    end
    
    t = t + 1;
end

% Compute evaluation metrics
[precision, recall, F1] = evaluation_metrics(TP, TN, FP, FN);

return

end