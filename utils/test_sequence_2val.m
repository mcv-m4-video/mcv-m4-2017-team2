%test sequence version for 2 groundtruth values, uses metrics vectors
%instead of cumulative numbers
function [precision, recall, F1, AUC] = test_sequence_2val(sequence, videoname, show_video, write_video, filename)

if(write_video && ~show_video)
    error('Not possible to write video and not show it.')
end

% Directory for writing results:
dirResults = './results/';
if(exist(dirResults, 'dir') ~= 7)
    mkdir(dirResults)
end

if (strcmp(videoname, 'highway'))
    T1 = 1050;
    dirGT = '../datasets/cdvd/dataset/baseline/highway/groundtruth/';
    
elseif (strcmp(videoname, 'fall'))
    T1 = 1460;
    dirGT = '../datasets/cdvd/dataset/dynamicBackground/fall/groundtruth/';
    
elseif (strcmp(videoname, 'traffic'))
    T1 = 950;
    dirGT = '../datasets/cdvd/dataset/cameraJitter/traffic/groundtruth/';
    
else
    error('videoname not recognized.')
end

nfiles = size(sequence,3);

TP = []; FP = []; FN = []; TN = [];

background = 50; %%%%%  OJO CON ESTO
foreground = 255;

if(show_video)
    fig = figure();
    if(write_video)
        v = VideoWriter(strcat(dirResults, filename, '.avi'));
        v.FrameRate = 15;
        open(v)
    end
end

t = T1;
for i = 1:nfiles
    file_number = sprintf('%06d', t);
    gt = imread(strcat(dirGT, 'gt', file_number, '.png'));  % Read the GT image
    test = sequence(:,:,i);  % Read the image
    gt_back = gt <= background;
    gt_fore = gt >= foreground;
    [TP_frame, TN_frame, FP_frame, FN_frame] = get_metrics_2val(gt_back, gt_fore, test);
    TP(i) = TP_frame;
    FP(i) = FP_frame;
    FN(i) = FN_frame;
    TN(i) = TN_frame;
    
    if(show_video)
        subplot(1,2,1)
        imshow(gt, [0 1])
        title(['gt',file_number,'.png'])
        subplot(1,2,2)
        imshow(test, [0 1])
        title(['sequence(:,:,', num2str(i),')'])
        pause(0.001)
        if(write_video)
            frame = getframe(fig);
            writeVideo(v,frame);
        end
    end
    
    t = t + 1;
end

if(write_video)
    close(v)
end

% Compute evaluation metrics
[precision, recall, F1] = evaluation_metrics(TP, TN, FP, FN);
[AUC] = area_under_curve(TP, FP, FN, TN, precision, recall, F1,'precision');
return

end