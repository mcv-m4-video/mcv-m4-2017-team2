% [16:45, 1/27/2017] Gonzalo m2: Est?? dentro de alpha_sweep                        
% [16:46, 1/27/2017]??Gonzalo m2:??La figure(3) que est?? comentada es la que grafica precisi??n vs recall                        
% [16:47, 1/27/2017]??Laura P??rez Mayos:??perfecto! pues voy a montar en un archivo el pipeline entero: adaptive + fill holes + remove noise + morphological ops

% morpho operator para traffic: opening+closening utilizando un SE de 'square' size 15

% based on week2 > task2.m
    % Week 2 task 2
    % Task 2.1: Adaptive modelling
    % Task 2.2: Comparison adaptive vs non
            % Highway best results:     Alpha = 2.75, Rho = 0.2,  F1 = 0.72946
            % Fall best results:        Alpha = 3.25, Rho = 0.05, F1 = 0.70262
            % Traffic best results:     Alpha = 3.25, Rho = 0.15, F1 = 0.66755

function videoStabilizationPipeline
    close all;

    addpath('../datasets');
    addpath('../utils');
    addpath('../week2');

    %% load data
    % Datasets to use: 'highway', 'fall', 'traffic', 'traffic_stabilized_target_tracking'
    % Choose dataset images to work on from the above:
    data = 'traffic';
    [start_img, range_images, dirInputs, dirGT] = load_data(data);
    input_files = list_files(dirInputs);

    switch data
        case 'highway'
            % Best results adaptive: Alpha = 2.75, Rho = 0.2, F1 = 0.72946
            rho_val = 0.2;
        case 'fall'
            % Best results adaptive: Alpha = 3.25, Rho = 0.05, F1 = 0.70262
            rho_val = 0.05;
        case 'traffic'
            % Best results adaptive: Alpha = 3.25, Rho = 0.15, F1 = 0.66755
            rho_val = 0.15; 
        case 'traffic_stabilized_target_tracking'
            % Best results adaptive: Alpha = 3.25, Rho = 0.15, F1 = 0.66755
            rho_val = 0.15; 
    end

    background = 55;
    foreground = 250;

    alpha_vect = 0.25:0.25:10;
    % alpha_vect = [2.5];

    [mu_matrix, sigma_matrix] = train_background(start_img, range_images, input_files, dirInputs);

    [time, AUC, TP_, TN_, FP_, FN_, precision, recall, F1] = alpha_sweep(data, alpha_vect, mu_matrix, sigma_matrix, range_images, start_img, dirInputs, input_files, background, foreground, dirGT, rho_val)
end


function [time, AUC, TP_, TN_, FP_, FN_, precision, recall, F1] = alpha_sweep(data, alpha_vect, mu_matrix, sigma_matrix, range_images, start_img, dirInputs, input_files, background, foreground, dirGT, rho_val)
%function for sweeping through several thresholds to compare performance

    tic

    precision = zeros(1,size(alpha_vect,2));
    recall = zeros(1,size(alpha_vect,2));
    F1 = zeros(1,size(alpha_vect,2));

    TP_ = [];
    TN_ = [];
    FP_ = [];
    FN_ = [];

    for n=1:size(alpha_vect,2)
        
        alpha = alpha_vect(n);
        
        %Metrics for alpha sweep
        TP_global = 0;
        TN_global = 0;
        FP_global = 0;
        FN_global = 0;
        
        %detect foreground and compare results
        for i=1:(round(range_images/2)+1)
            index = i + (start_img + range_images/2) - 1;
            file_number = input_files(index).name(3:8);
            try
                img = double(rgb2gray(imread(strcat(dirInputs,'in',file_number,'.jpg'))));
            catch
                img = double(imread(strcat(dirInputs,'in',file_number,'.jpg')));
            end

            test_backg_in(:,:,i) = img;

            detection(:,:,i) = double((abs(test_backg_in(:,:,i)-mu_matrix) >= (alpha * (sigma_matrix + 2))));

            % fill holes (week 3 task 1)
            connectivity = 4;  % can be either 4 or 8
            detection(:,:,i) = imfill(detection(:,:,i), connectivity);

            % remove noise (week 3 task 2)
            % not applied because we said it does not change the results for traffic sequence
            detection(:,:,i) = bwareaopen(detection(:,:,i),500);

            % apply morphological operators  (week 3 task 3)
            se = strel('square',15);
            detection(:,:,i) = imopen(detection(:,:,i),se);
            detection(:,:,i) = imclose(detection(:,:,i),se);


            gt = imread(strcat(dirGT,'gt',file_number,'.png'));
            gt_back = gt <= background;
            gt_fore = gt >= foreground;

            [TP, TN, FP, FN] = get_metrics_2val(gt_back, gt_fore, detection(:,:,i), data);

            %option of getting overall metrics
            TP_global = TP_global + TP;
            TN_global = TN_global + TN;
            FP_global = FP_global + FP;
            FN_global = FN_global + FN;

            % adapt model using pixels belonging to the background
            [mu_matrix, sigma_matrix] = adaptModel(test_backg_in(:,:,i), detection(:,:,i), mu_matrix, sigma_matrix, rho_val);

        end

        %global metrics for threshold sweep:
        [precision(n), recall(n), F1(n)] = evaluation_metrics(TP_global,TN_global,FP_global,FN_global);
        TP_(n) = TP_global;
        TN_(n) = TN_global;
        FP_(n) = FP_global;
        FN_(n) = FN_global;

    end    

    time = toc;

    %AUC of Precision metrics
    AUC = trapz(precision,2)/size(TP_,2);

    % x = alpha_vect;
    % figure(1)
    % plot(x, transpose(precision), 'b', x, transpose(recall), 'r',  x, transpose(F1), 'k');
    % title(strcat({'Precision, Recall & F1 vs Threshold for dataset '},data));
    % xlabel('Threshold');
    % ylabel('Measure');
    % legend('Precision','Recall','F1');

    % figure(2)
    % plot(x, transpose(TP_),'b', x, transpose(TN_),'g', x, transpose(FP_),'r', x, transpose(FN_));
    % title(strcat({'TP, TN, FP & FN vs Threshold for '},data));
    % xlabel('Threshold');
    % ylabel('Pixels');
    % legend('TP','TN','FP','FN');

    figure(3)
    plot(recall, transpose(precision), 'g');
    title(strcat({'Recall vs Precision & AUC for dataset '},data));
    xlabel('Recall');
    ylabel('Precision');
    legend('Recall vs Precision','Area under the curve');
end


function [mean_matrix,variance_matrix] = adaptModel(frame, detection, mean_matrix, variance_matrix, rho)
    % background pixels: ~detection
    mean_matrix(~logical(detection))=rho*frame(~logical(detection)) + (1-rho)*mean_matrix(~logical(detection));
    variance_matrix(~logical(detection))=sqrt(rho*(frame(~logical(detection))-mean_matrix(~logical(detection))).^2 + (1-rho)*variance_matrix(~logical(detection)).^2);
end
