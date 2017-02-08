
%% Motion-Based Multiple Object Tracking

function task_1_1_tracker_kalman()

% Create system objects used for reading video, detecting moving objects,
% and displaying the results.
obj = setupSystemObjects();

tracks = initializeTracks(); % Create an empty array of tracks.

% >>>>>> xian
set_reliable_tracks = [];
vehicle_counter = 0;
frame_count = 0;
first_landmark = 116; %137;
second_landmark = 386; %405;
third_landmark
fps = 29;
% <<<<<<

nextId = 1; % ID of the next track

% Detect moving objects, and track them across video frames.
while ~isDone(obj.reader)
    frame_count = frame_count + 1; % xian
    
    frame = readFrame();
    [centroids, bboxes, mask] = detectObjects(frame);
    predictNewLocationsOfTracks();
    [assignments, unassignedTracks, unassignedDetections] = ...
        detectionToTrackAssignment();
    
    updateAssignedTracks();
    updateUnassignedTracks();
    deleteLostTracks();
    createNewTracks();
    computeVelocities();
    
    displayTrackingResults();
end


%% Create System Objects
% Create System objects used for reading the video frames, detecting
% foreground objects, and displaying results.

    function obj = setupSystemObjects()
 
        obj.reader = vision.VideoFileReader('parc_nova_icaria2.mp4');  % lpmayos
        
        % Create two video players, one to display the video,
        % and one to display the foreground mask.
        obj.videoPlayer = vision.VideoPlayer('Position', [20, 100, 700, 550]);
        obj.maskPlayer = vision.VideoPlayer('Position', [740, 100, 700, 550]);
        
        obj.detector = vision.ForegroundDetector('NumGaussians', 2, ...
            'NumTrainingFrames', 25, 'LearningRate', 0.0025, 'MinimumBackgroundRatio', 0.9);

        
        obj.blobAnalyser = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
            'AreaOutputPort', true, 'CentroidOutputPort', true, ...
            'MinimumBlobArea', 200);
%             'MinimumBlobArea', 300);
    end

%% Initialize Tracks

    function tracks = initializeTracks()
        % create an empty array of tracks
        tracks = struct(...
            'id', {}, ...
            'bbox', {}, ...
            'kalmanFilter', {}, ...
            'age', {}, ...
            'totalVisibleCount', {}, ...
            'consecutiveInvisibleCount', {}, ...
            'time_first_mark', -1, ... % xian
            'time_second_mark', -1, ... % xian
            'speed', -1); % xian
    end

%% Read a Video Frame
% Read the next video frame from the video file.
    function frame = readFrame()
        frame = obj.reader.step();
    end

%% Detect Objects

    function [centroids, bboxes, mask] = detectObjects(frame)
        
        % Detect foreground.
        mask = obj.detector.step(frame);

        % % lpmayos: last week we applied this operators
        index1 = round(size(mask,1)/3);
        index2 = round(2*(size(mask,1)/3));
        
        mask = imopen(mask, strel('square', 3));
        mask = imfill(mask, 4, 'holes');
        mask = imopen(mask, strel([0,0,1,0,0;0,0,1,0,0;0,1,1,1,0;0,0,1,0,0;0,0,1,0,0;0,0,1,0,0]));
        mask (index1:end,:) = imopen(mask(index1:end,:), strel('rectangle', [5,10]));
        mask = imclose(mask, strel('square', 10));
        mask = imfill(mask, 4, 'holes');
        
        mask1 = double(mask);
        
        mask1(index1:index2,:) = bwareaopen(mask1(index1:index2,:), 300);
        mask1(index2:end,:) = bwareaopen(mask1(index2:end,:), 900);
        
        mask=logical(mask1);
        
        % lpmayos: Leave out all the detections outside the Region Of Interest:
        roi = imread('mask_roi_parc_nova_icaria2.png');
        roi = double(roi(:,:,1) > 0.5);
        mask = logical(mask .* roi);

        % Perform blob analysis to find connected components.
        [~, centroids, bboxes] = obj.blobAnalyser.step(mask);
        
    end

%% Predict New Locations of Existing Tracks
% Use the Kalman filter to predict the centroid of each track in the
% current frame, and update its bounding box accordingly.

    function predictNewLocationsOfTracks()
        for i = 1:length(tracks)
            bbox = tracks(i).bbox;
            
            % Predict the current location of the track.
            predictedCentroid = predict(tracks(i).kalmanFilter);
            
            % Shift the bounding box so that its center is at 
            % the predicted location.
            predictedCentroid = int32(predictedCentroid) - bbox(3:4) / 2;
            tracks(i).bbox = [predictedCentroid, bbox(3:4)];
        end
    end

%% Assign Detections to Tracks

    function [assignments, unassignedTracks, unassignedDetections] = ...
            detectionToTrackAssignment()
        
        nTracks = length(tracks);
        nDetections = size(centroids, 1);
        
        % Compute the cost of assigning each detection to each track.
        cost = zeros(nTracks, nDetections);
        for i = 1:nTracks
            cost(i, :) = distance(tracks(i).kalmanFilter, centroids);
        end
        
        % Solve the assignment problem.
        costOfNonAssignment = 20;
        [assignments, unassignedTracks, unassignedDetections] = ...
            assignDetectionsToTracks(cost, costOfNonAssignment);
    end

%% Update Assigned Tracks
%
    function updateAssignedTracks()
        numAssignedTracks = size(assignments, 1);
        for i = 1:numAssignedTracks
            trackIdx = assignments(i, 1);
            detectionIdx = assignments(i, 2);
            centroid = centroids(detectionIdx, :);
            bbox = bboxes(detectionIdx, :);
            
            % Correct the estimate of the object's location
            % using the new detection.
            correct(tracks(trackIdx).kalmanFilter, centroid);
            
            % Replace predicted bounding box with detected
            % bounding box.
            tracks(trackIdx).bbox = bbox;
            
            % Update track's age.
            tracks(trackIdx).age = tracks(trackIdx).age + 1;
            
            % Update visibility.
            tracks(trackIdx).totalVisibleCount = ...
                tracks(trackIdx).totalVisibleCount + 1;
            tracks(trackIdx).consecutiveInvisibleCount = 0;
        end
    end

%% Update Unassigned Tracks
% Mark each unassigned track as invisible, and increase its age by 1.

    function updateUnassignedTracks()
        for i = 1:length(unassignedTracks)
            ind = unassignedTracks(i);
            tracks(ind).age = tracks(ind).age + 1;
            tracks(ind).consecutiveInvisibleCount = ...
                tracks(ind).consecutiveInvisibleCount + 1;
        end
    end

%% Delete Lost Tracks


    function deleteLostTracks()
        if isempty(tracks)
            return;
        end
        
        invisibleForTooLong = 2;
        ageThreshold = 8;
        visibilityThreshold = 0.6;
        
        % Compute the fraction of the track's age for which it was visible.
        ages = [tracks(:).age];
        totalVisibleCounts = [tracks(:).totalVisibleCount];
        visibility = totalVisibleCounts ./ ages;
        
        % Find the indices of 'lost' tracks.
        lostInds = (ages < ageThreshold & visibility < visibilityThreshold) | ...
            [tracks(:).consecutiveInvisibleCount] >= invisibleForTooLong;
        
        % Delete lost tracks.
        tracks = tracks(~lostInds);
    end

%% Create New Tracks

    function createNewTracks()
        centroids = centroids(unassignedDetections, :);
        bboxes = bboxes(unassignedDetections, :);
        
        for i = 1:size(centroids, 1)
            
            centroid = centroids(i,:);
            bbox = bboxes(i, :);
            
            % Create a Kalman filter object.
            kalmanFilter = configureKalmanFilter('ConstantVelocity', ...
                centroid, [200, 50], [100, 25], 100);
            
            % Create a new track.
            newTrack = struct(...
                'id', nextId, ...
                'bbox', bbox, ...
                'kalmanFilter', kalmanFilter, ...
                'age', 1, ...
                'totalVisibleCount', 1, ...
                'consecutiveInvisibleCount', 0, ...
                'time_first_mark', -1, ... % xian
                'time_second_mark', -1, ... % xian
                'speed', -1); % xian
            
            % Add it to the array of tracks.
            tracks(end + 1) = newTrack;
            
            % Increment the next id.
            nextId = nextId + 1;
        end
    end

%% Compute velocities
% We will annotate when a track reaches the first landmark, then when it
% reaches the second one, and with this two data we will compute a speed.
% xian

    function computeVelocities()
        if isempty(tracks)
            return;
        end
        
        for i = 1:length(tracks)
            bottom_row = tracks(i).bbox(2) + tracks(i).bbox(4);
            % Check first landmark:
            if(bottom_row >= first_landmark && tracks(i).time_first_mark == -1)
                % If the track appears after the first landmark, we do not
                % take this track into account.
                if(bottom_row <= first_landmark + 20)
                    tracks(i).time_first_mark = frame_count;
                end
            end
            % Check second landmark:
            if(bottom_row >= second_landmark && tracks(i).time_second_mark == -1)
                tracks(i).time_second_mark = frame_count;
            end
            % Compute velocity:
            if(tracks(i).time_first_mark ~= -1 && tracks(i).time_second_mark ~= -1 && ...
                    tracks(i).speed == -1)
                tracks(i).speed = fps / (tracks(i).time_second_mark - tracks(i).time_first_mark) ...
                                * 24 * 3.6;
            end
        end
    end

%% Display Tracking Results

    function displayTrackingResults()
        % Convert the frame and the mask to uint8 RGB.
        frame = im2uint8(frame);
        mask = uint8(repmat(mask, [1, 1, 3])) .* 255;
        
        minVisibleCount = 8;
        if ~isempty(tracks)
              
             reliableTrackInds = ...
                [tracks(:).totalVisibleCount] > minVisibleCount;
            reliableTracks = tracks(reliableTrackInds);
            
            % Display the objects. If an object has not been detected
            % in this frame, display its predicted bounding box.
            if ~isempty(reliableTracks)
                % >>>>>> xian
                if(isempty(set_reliable_tracks))
                    set_reliable_tracks = reliableTracks(:).id;
                else
                    for i = 1:length(reliableTracks)
                        found = 0;
                        for j = 1:length(set_reliable_tracks)
                            if(set_reliable_tracks(j) == reliableTracks(i).id)
                                found = 1;
                            end
                        end
                        if(found == 0)
                            set_reliable_tracks = [set_reliable_tracks, reliableTracks(i).id];
                        end
                    end
                end
                % <<<<<<
            
                % Get bounding boxes.
                bboxes = cat(1, reliableTracks.bbox);
                
                % Get ids.
                ids = int32([reliableTracks(:).id]);
                
                % >>>>>> xian
                % Change ids to make them consistent:
                new_ids = zeros(size(ids));
                for i = 1:length(ids)
                    aux = set_reliable_tracks == ids(i);
                    for j = 1:length(set_reliable_tracks)
                        if(aux(j))
                            new_ids(i) = j;
                            break
                        end
                    end
                end
                new_ids = int32(new_ids);
                vehicle_counter = new_ids(end);
                % <<<<<<
                
                labels = cellstr(int2str(new_ids')); % xian

                % >>>>>> xian
                % Add the speed to the label:
                for i = 1:length(reliableTracks)
%                     if(reliableTracks(i).speed ~= -1)
%                         labels(i) = strcat(labels(i), num2str(reliableTracks(i).speed));
%                     end
                    if(reliableTracks(i).speed ~= -1)
                    labels{i} = strcat(labels{i}, ' - ', ...
                                    num2str(round(reliableTracks(i).speed,2)), ' km/h');
                    end
                end
                % <<<<<<
                
                % Draw the objects on the frame.
                frame = insertObjectAnnotation(frame, 'rectangle', ...
                    bboxes, labels);
                
                % Insert speeds at top left corner:
                y = 1;
                w_box = 100;
                for i = 1:length(labels)
                    frame = insertObjectAnnotation(frame, 'rectangle', ...
                        [1, y, w_box, 1], labels{i}, ...
                        'TextBoxOpacity', 0.9, 'FontSize', 12);
                    y = y + 50;
                end
                
                % Draw the objects on the mask.
                mask = insertObjectAnnotation(mask, 'rectangle', ...
                    bboxes, labels);
            end
        end
        
        % Display the mask and the frame.
        obj.maskPlayer.step(mask);        
        obj.videoPlayer.step(frame);
        
        % Show total number of cars found:
        fprintf('Vehicle counter: %i.\n', vehicle_counter)
    end

%% Summary

displayEndOfDemoMessage(mfilename)
end