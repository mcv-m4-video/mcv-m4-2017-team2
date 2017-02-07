function detection = detectionPipeline(grayframe, mu_matrix, sigma_matrix)
    % Given a grayscale frame, detect with the adaptive gaussian model, and
    % apply filling holes morphological operators.
    
    % Fixed parameters:
    connectivity = 4;
    se = strel('square',15);

    % Select pixels belonging to their gaussian models:
    detection = double(abs(grayframe - mu_matrix) >= (alpha * (sigma_matrix + 2)));

    % Fill holes:
    detection = imfill(detection, connectivity);
    
    % ??
    detection = bwareaopen(detection, 25);
    
    % Morphological operators:
    detection = imopen(detection, se);
    detection = imclose(detection, se);
end