function detection = detectionPipeline_adaptive(dirSequence, T1, T2, mu_matrix, sigma_matrix, alpha, rho)
    % Given a grayscale frame, detect with the adaptive gaussian model, and
    % apply filling holes morphological operators.
    
    % Fixed parameters:
    connectivity = 4;
    se = strel('square', 15);
%     se = strel('square', 3);
    
    % Number of frames to analyze:
    nframes = T2 - T1 + 1;
    
    % Initialize detection:
%     frame0 = double(rgb2gray(imread(strcat(dirSequence, 'in000001.jpg')))) / 255;
    frame0 = double(rgb2gray(imread(strcat(dirSequence, 'in000001.jpg'))));
    detection = zeros(size(frame0,1), size(frame0,2), nframes);
    
    t = T1 - 1;
    for i = 1:nframes
        % Read frame:
        t = t + 1;
        filenumber = sprintf('%06d', t);
        filename = strcat('in', filenumber, '.jpg');
%         grayframe = double(rgb2gray(imread(strcat(dirSequence, filename)))) / 255;
        grayframe = double(rgb2gray(imread(strcat(dirSequence, filename))));

        % Select pixels belonging to their gaussian models:
%         detection(:,:,i) = double(abs(grayframe - mu_matrix) >= (alpha * (sigma_matrix + 2.0/255)));
        detection(:,:,i) = double(abs(grayframe - mu_matrix) >= (alpha * (sigma_matrix + 2)));

        % Fill holes:
        detection(:,:,i) = imfill(detection(:,:,i), connectivity);

        % ??
%         detection(:,:,i) = bwareaopen(detection(:,:,i), 500);

        % Morphological operators:
%         detection(:,:,i) = imopen(detection(:,:,i), se);
%         detection(:,:,i) = imclose(detection(:,:,i), se);
        
        % Adapt model:
        [mu_matrix, sigma_matrix] = adaptModel(grayframe, detection(:,:,i), mu_matrix, sigma_matrix, rho);
    end
end



