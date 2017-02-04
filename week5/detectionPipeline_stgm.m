function detection = detectionPipeline_stgm(dirSequence, T1, T2, NumGaussians, ...
                            NumTrainingFrames, LearningRate, MinimumBackgroundRatio)
    % Given a grayscale frame, detect with the adaptive gaussian model, and
    % apply filling holes morphological operators.
    
    fprintf('Detecting with Stauffer & Grimson...\n')
    
    % Fixed parameters:
    connectivity = 4;
%     se = strel('square', 15);
    se = strel('square', 10);
    
    % Number of frames to analyze:
    nframes = T2 - T1 + 1;
    
    % Initialize detection:
    frame0 = double(rgb2gray(imread(strcat(dirSequence, 'in000001.jpg')))) / 255;
%     frame0 = double(rgb2gray(imread(strcat(dirSequence, 'in000001.jpg'))));
    detection = zeros(size(frame0,1), size(frame0,2), nframes);

    % Create detector object:
    foregroundDetector = vision.ForegroundDetector('NumGaussians', NumGaussians, ...
                'NumTrainingFrames', NumTrainingFrames, 'LearningRate', LearningRate, ...
                'MinimumBackgroundRatio', MinimumBackgroundRatio);
    
    t = T1 - 1;
    fprintf('0%%\n')
    progress = 10;
    for i = 1:nframes
        if(i / nframes * 100 > progress)
            fprintf('%i%%\n', progress)
            progress = progress + 10;
        end
        % Read frame:
        t = t + 1;
        filenumber = sprintf('%06d', t);
        filename = strcat('in', filenumber, '.jpg');
        grayframe = double(rgb2gray(imread(strcat(dirSequence, filename)))) / 255;
%         grayframe = double(rgb2gray(imread(strcat(dirSequence, filename))));

        % Stauffer & Grimson detection:
        detection(:,:,i) = double(step(foregroundDetector, grayframe));

        % Fill holes:
        detection(:,:,i) = imfill(detection(:,:,i), connectivity);

        % ??
%         detection(:,:,i) = bwareaopen(detection(:,:,i), 500);

        % Morphological operators:
        detection(:,:,i) = imopen(detection(:,:,i), se);
        detection(:,:,i) = imclose(detection(:,:,i), se);
    end
    fprintf('100%%\n')
end



