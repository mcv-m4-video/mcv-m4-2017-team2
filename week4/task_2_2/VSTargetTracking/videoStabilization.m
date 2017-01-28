% source: https://es.mathworks.com/help/vision/examples/video-stabilization.html

% Input video file which needs to be stabilized.
% filename = 'shaky_car.avi';
filename = 'traffic.avi';

hVideoSource = vision.VideoFileReader(filename, ...
                                      'ImageColorSpace', 'Intensity',...
                                      'VideoOutputDataType', 'double');

hTM = vision.TemplateMatcher('ROIInputPort', true, ...
                            'BestMatchNeighborhoodOutputPort', true);

hVideoOut = vision.VideoPlayer('Name', 'Video Stabilization');
hVideoOut.Position(1) = round(0.4*hVideoOut.Position(1));
hVideoOut.Position(2) = round(1.5*(hVideoOut.Position(2)));
hVideoOut.Position(3:4) = [650 350];

pos.template_orig = [60 150];  % [109 100]; % [x y] upper left corner
pos.template_size = [20 20];  % [22 18];   % [width height]
pos.search_border = [15 10];   % max horizontal and vertical displacement
pos.template_center = floor((pos.template_size-1)/2);
pos.template_center_pos = (pos.template_orig + pos.template_center - 1);
fileInfo = info(hVideoSource);
W = fileInfo.VideoSize(1); % Width in pixels
H = fileInfo.VideoSize(2); % Height in pixels
BorderCols = [1:pos.search_border(1)+4 W-pos.search_border(1)+4:W];
BorderRows = [1:pos.search_border(2)+4 H-pos.search_border(2)+4:H];
sz = fileInfo.VideoSize;
TargetRowIndices = ...
  pos.template_orig(2)-1:pos.template_orig(2)+pos.template_size(2)-2;
TargetColIndices = ...
  pos.template_orig(1)-1:pos.template_orig(1)+pos.template_size(1)-2;
SearchRegion = pos.template_orig - pos.search_border - 1;
Offset = [0 0];
Target = zeros(18,22);
firstTime = true;

i = 1;
j = 950;
save_stabilized_images = true;
save_stabilized_dual_images = true;

while ~isDone(hVideoSource)
    input = step(hVideoSource);

    % Find location of Target in the input video frame
    if firstTime
      Idx = int32(pos.template_center_pos);
      MotionVector = [0 0];
      firstTime = false;
    else
      IdxPrev = Idx;

      ROI = [SearchRegion, pos.template_size+2*pos.search_border];
      Idx = step(hTM, input, Target, ROI);

      MotionVector = double(Idx-IdxPrev);
    end

    [Offset, SearchRegion] = updatesearch(sz, MotionVector, ...
        SearchRegion, Offset, pos);

    % Translate video frame to offset the camera motion
    Stabilized = imtranslate(input, Offset, 'linear');

    Target = Stabilized(TargetRowIndices, TargetColIndices);

    % Add black border for display
    Stabilized(:, BorderCols) = 0;
    Stabilized(BorderRows, :) = 0;

    TargetRect = [pos.template_orig-Offset, pos.template_size];
    SearchRegionRect = [SearchRegion, pos.template_size + 2*pos.search_border];

    % Draw rectangles on input to show target and search region
    input = insertShape(input, 'Rectangle', [TargetRect; SearchRegionRect],...
                        'Color', 'white');
    % Display the offset (displacement) values on the input image
    txt = sprintf('(%+05.1f,%+05.1f)', Offset);
    input = insertText(input(:,:,1),[191 215],txt,'FontSize',16, ...
                'TextColor', 'white', 'BoxOpacity', 0);
    
    % Display video
    step(hVideoOut, [input(:,:,1) Stabilized]);

    % Save stabilized images to later creat eanimated gif (i.e. using http://gifmaker.me/)
    if save_stabilized_dual_images
      fig = figure(2);
      subplot(1,2,1); imshow(input(:,:,1)); title('original');
      subplot(1,2,2); imshow(Stabilized); title('stabilized');
      fig_frame = getframe(fig);
      im = frame2im(fig_frame);
      imwrite(im, strcat('stabilized_dual/image', num2str(i), '.jpg'));
      i = i + 1;
    end

    % Save stabilized images to later creat eanimated gif (i.e. using http://gifmaker.me/)
    if save_stabilized_images
      if j < 1000
          leading_zeros = '000';
      else
          leading_zeros = '00';
      end
      imwrite(Stabilized, strcat('stabilized/in', leading_zeros, num2str(j), '.jpg'));
      j = j + 1;
    end

end

release(hVideoSource);
