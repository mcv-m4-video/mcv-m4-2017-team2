function [precision, recall, F1] = test_sequence(dirResults, videoname)

if (strcmp(videoname, 'highway'))
    dirGT = '../datasets/cdvd/dataset/baseline/highway/groundtruth/';
    
elseif (strcmp(videoname, 'fall'))
    dirGT = '';
    
elseif (strcmp(videoname, 'traffic'))
    dirGT = '';
    
else
    error('videoname not recognized.')
end

results_files = list_files(dirResults);
files_number = size(results_files,1);

TP = 0; FP = 0; FN = 0; TN = 0;

motion = 170; %%%%%  OJO CON ESTO

for i=1:files_number
    file_number = results_files(i).name(5:10);  % example: take '001201' from 'res_001201.png'
    gt = imread(strcat(dirGT, 'gt', file_number, '.png'));  % Read the GT image
    test = imread(strcat(dirResults,'res_',file_number,'.png'));  % Read the image
    gt = gt >= motion;  % binarize gt mask
    [TP, TN, FP, FN] = get_metrics(gt, test);
    TP = TP + TP;
    FP = FP + FP;
    FN = FN + FN;
    TN = TN + TN;
end

% Compute evaluation metrics
[precision, recall, F1] = evaluation_metrics(TP, TN, FP, FN);

return

end