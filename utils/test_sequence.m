function [precision, recall, F1] = test_sequence(sequence, videoname, T1)

if (strcmp(videoname, 'highway'))
    dirGT = '../datasets/cdvd/dataset/baseline/highway/groundtruth/';
    
elseif (strcmp(videoname, 'fall'))
    dirGT = '';
    
elseif (strcmp(videoname, 'traffic'))
    dirGT = '';
    
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
    [TP, TN, FP, FN] = get_metrics(gt, test);
    TP = TP + TP;
    FP = FP + FP;
    FN = FN + FN;
    TN = TN + TN;
    t = t + 1;
end

% Compute evaluation metrics
[precision, recall, F1] = evaluation_metrics(TP, TN, FP, FN);

return

end