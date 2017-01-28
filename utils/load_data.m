function [start_img, range_images, dirInputs, dirGT] = load_data(data)

%First image from each set:
start_highway = 1050;
start_fall    = 1460;
start_traffic = 950;

%Range of each dataset:
range_highway = 1350 - 1050;
range_fall    = 1560 - 1460;
range_traffic = 1050 - 950;

%setting paths and dependant variables
switch data
    case 'highway'
        %First image to use from set:
        start_img = start_highway;
        %Amount of images to use from set:
        range_images = range_highway;
        %Write the dataset option from the 3 above:
        dirInputs = '../datasets/cdvd/dataset/baseline/highway/input/';
        dirGT = '../datasets/cdvd/dataset/baseline/highway/groundtruth/';
        
    case 'fall'
        %First image to use from set:
        start_img = start_fall;
        %Amount of images to use from set:
        range_images = range_fall;
        %Write the dataset option from the 3 above:
        dirInputs = '../datasets/cdvd/dataset/dynamicBackground/fall/input/';
        dirGT = '../datasets/cdvd/dataset/dynamicBackground/fall/groundtruth/';
        
    case 'traffic'
        %First image to use from set:
        start_img = start_traffic;
        %Amount of images to use from set:
        range_images = range_traffic;
        %Write the dataset option from the 3 above:
        dirInputs = '../datasets/cdvd/dataset/cameraJitter/traffic/input/';
        dirGT = '../datasets/cdvd/dataset/cameraJitter/traffic/groundtruth/';

    case 'traffic_stabilized_target_tracking'
        %First image to use from set:
        start_img = start_traffic;
        %Amount of images to use from set:
        range_images = range_traffic;
        %Write the dataset option from the 3 above:
        dirInputs = '../week4/task_2_2/VSTargetTracking/stabilized/';
        dirGT = '../datasets/cdvd/dataset/cameraJitter/traffic/groundtruth/';
end

end