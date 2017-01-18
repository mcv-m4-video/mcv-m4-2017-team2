function task4

    close all;

    addpath('../utils');

    % videonames = {'highway','traffic','fall'};
    videonames = {'highway'};
    for v=1:numel(videonames)
        
        %% load data
        % Datasets to use 'highway', 'fall' or 'traffic'
        % Choose dataset images to work on from the above:
        dataset = videonames{v};
        [start_img, range_images, dirInputs] = load_data(dataset);
        input_files = list_files(dirInputs);

        % get model background
        [background_rgb] = get_background_rgb(start_img, range_images, input_files, dirInputs);
        


        %Best Sequence
        % Compute detection with Stauffer and Grimson:
        dir_seq = strcat('task3_results/',dataset,'/');
        sequence = read_sequence(dir_seq);
        technique = 'chromaticity';  % 'chromaticity' or 'texture';
        f1 = remove_shadows(sequence, dataset, start_img, background_rgb, dirInputs, technique);

        % Evaluate detection:
        fprintf(dataset);
        fprintf(' F1: %f\n', f1);
        
        %result_file = strcat('best_shadow_',dataset,'.mat');
        %save(result_file,'auc');
    end
end


function F1 = remove_shadows(sequence, dataset, start_img, background_rgb, dirInputs, method)

    seq_size = size(sequence,3);
    sequence_without_shadows = sequence;
    for i=1:seq_size
        if(strcmp(method,'chromaticity'))
            frame_rgb = imread(strcat(dirInputs,'in',sprintf('%06d',i + start_img - 1),'.jpg'));
            sequence_without_shadows(:,:,i) = removeShadowsChromaticity(frame_rgb, sequence(:,:,i), background_rgb);
            
        elseif(strcmp(method,'texture'))
            frame_rgb = imread(strcat(dirInputs,'in',sprintf('%06d',i + start_img - 1),'.jpg'));
            sequence_without_shadows(:,:,i) = removeShadowsTexture(frame_rgb, background_rgb);
        end
    end
    [precision, recall, F1, AUC] = test_sequence_2val(sequence_without_shadows, dataset, false, false, '',true);
    %     fprintf('Precision: %f\n', precision)
    %     fprintf('Recall: %f\n', recall)
    %     fprintf('F1: %f\n', F1)
end


function [foreground_without_shadows] = removeShadowsChromaticity(frame, foreground, background)
% Shadow removal alogrithm: Chromacity-based method

    % best results with parameters search:
%     beta1 = 1;
%     beta2 = 1;
%     ts = 0.5;
%     th = 0.1;
    % best results according to paper:
    beta1 = 0.4;
    beta2 = 0.6;
    ts = 0.5;
    th = 0.1;

    % convert images to HSV colorspace
    frame_hsv = rgb2hsv(frame);
    background_hsv = rgb2hsv(background);
    
    % a pixel p is considered to be part of a shadow if the following three conditions are satisfied
    cond1_value = frame_hsv(:,:,3)./background_hsv(:,:,3);
    cond1 = (cond1_value>=beta1) & (cond1_value<=beta2);
    cond2 = abs(frame_hsv(:,:,2)-background_hsv(:,:,2)) <= ts;
    cond3 = abs(frame_hsv(:,:,1)-background_hsv(:,:,1)) <= th;

    % apply conditions to remove shadows form foreground
    shadows = foreground&cond1&cond2&cond3;
    foreground_without_shadows = (~shadows)&foreground;
    foreground_without_shadows = imfill(foreground_without_shadows, 4);
    
    fig = figure(1);
    subplot(2,2,1); imshow(frame); title('original');
    subplot(2,2,2); imshow(foreground); title('foreground with shadows');
    subplot(2,2,3); imshow(shadows); title('shadows');
    subplot(2,2,4); imshow(foreground_without_shadows); title('foreground without shadows');
    outfile = strcat('task4_shadow_detection.gif');
    fig_frame = getframe(fig);
    im = frame2im(fig_frame);
    if i == 1
        imwrite(rgb2gray(im),outfile,'gif','LoopCount',Inf,'DelayTime',0.1);
    else
        imwrite(rgb2gray(im),outfile,'gif','WriteMode','append','DelayTime',0.1);
    end
end


function [im] = removeShadowsTexture(foreground, background)
% based on: https://es.mathworks.com/matlabcentral/answers/183169-how-to-eliminate-shadow-from-the-foreground-image

  a=foreground;
  b=background;
  da=double(a);
  db=double(b);
  D=imabsdiff(a,b);
  r=zeros(240,320);
  h=a;
  for ix=1:240
      for iy=1:320
          if D(ix,iy)>20
              if da(ix,iy,1)~=0&da(ix,iy,2)~=0&da(ix,iy,3)~=0
                  if (db(ix,iy,1)/da(ix,iy,1)<4)&(db(ix,iy,1)/da(ix,iy,1)>1.5)
                      if (db(ix,iy,2)/da(ix,iy,2)<2.8)&(db(ix,iy,2)/da(ix,iy,2)>1.3)
                          if (db(ix,iy,3)/da(ix,iy,3)<2.05)&(db(ix,iy,3)/da(ix,iy,3)>1.14)
                              if (db(ix,iy,3)/da(ix,iy,3)<db(ix,iy,1)/da(ix,iy,1))&(db(ix,iy,3)/da(ix,iy,3)<db(ix,iy,2)/da(ix,iy,2))&(db(ix,iy,2)/da(ix,iy,2)<db(ix,iy,1)/da(ix,iy,1))
                                  if abs(da(ix,iy,1)/(da(ix,iy,1)+da(ix,iy,2)+da(ix,iy,3))-db(ix,iy,1)/(db(ix,iy,1)+db(ix,iy,2)+db(ix,iy,3)))<0.129
                                      if abs(da(ix,iy,2)/(da(ix,iy,1)+da(ix,iy,2)+da(ix,iy,3))-db(ix,iy,2)/(db(ix,iy,1)+db(ix,iy,2)+db(ix,iy,3)))<0.028
                                          if abs(da(ix,iy,3)/(da(ix,iy,1)+da(ix,iy,2)+da(ix,iy,3))-db(ix,iy,3)/(db(ix,iy,1)+db(ix,iy,2)+db(ix,iy,3)))<0.143
                                              r(ix,iy)=0;
                                              h(ix,iy,1)=255;
                                              h(ix,iy,2)=255;
                                              h(ix,iy,3)=255;
                                          end
                                      end
                                  end
                              end
                          end
                      end
                  end                    
              end
          end
      end
  end
  im=h-a;

  fig = figure(2);
  subplot(1,3,1); imshow(h); title('h');
  subplot(1,3,2); imshow(a); title('a');
  subplot(1,3,3); imshow(im); title('h-a');
  
end

function [background_rgb] = get_background_rgb(start_img, range_images, input_files, dirInputs)
% models the rgb background image using the first 50% of the frames 

    mean_rgb_image = zeros();
    
    for i=1:(1 + round(range_images/2))
        index = i + start_img - 1;
        file_number = input_files(index).name(3:8);  % example: take '001050' from 'im001050.png'
        rgb_image = imread(strcat(dirInputs,'in',file_number,'.jpg'));
        if exist('mean_rgb_image','var')
            mean_rgb_image = mean_rgb_image + double(rgb_image);
        else
            mean_rgb_image = double(rgb_image);
        end
    end

    background_rgb = uint8(mean_rgb_image / (1 + round(range_images/2)));
end
