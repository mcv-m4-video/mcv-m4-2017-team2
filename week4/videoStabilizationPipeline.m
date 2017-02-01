function videoStabilizationPipeline
    close all;

    addpath('../datasets');
    addpath('../utils');
    addpath('../week2');

    %% load data
    data = 'traffic';  % 'highway', 'fall', 'traffic', 'traffic_stabilized_target_tracking'
    [start_img, range_images, dirInputs, dirGT] = load_data(data);
    input_files = list_files(dirInputs);

    background = 55;
    foreground = 255;

    [mu_matrix, sigma_matrix] = train_background(start_img, range_images, input_files, dirInputs);

    look_best_alpha_rho = false;
    if look_best_alpha_rho
        alpha_vect = 1:0.25:5;
        rho_vect = 0.025:0.025:1;
        alpha_rho_sweep(data, alpha_vect, mu_matrix, sigma_matrix, range_images, start_img, dirInputs, input_files, background, foreground, dirGT, rho_vect);
    else
        switch data
            case 'highway'
                rho = 0.2;  % Best results adaptive: Alpha = 2.75, Rho = 0.2, F1 = 0.72946
            case 'fall'
                rho = 0.05;  % Best results adaptive: Alpha = 3.25, Rho = 0.05, F1 = 0.70262
            case 'traffic'
                rho = 0.225;  % Best results adaptive with morpho: Alpha = 2, Rho = 0.225, F1 = 0.8379, AUC = 0.63
            case 'traffic_stabilized_target_tracking'
                rho = 0.375;   % Best results adaptive with morpho: Alpha = 2.25, Rho = 0.375, F1 = 0.82869, AUC = 0.53
    end
        alpha_vect = 0:0.25:6;
        alpha_vect = [2];
        [time, AUC, TP_, TN_, FP_, FN_, precision, recall, F1] = alpha_sweep(data, alpha_vect, mu_matrix, sigma_matrix, range_images, start_img, dirInputs, input_files, background, foreground, dirGT, rho);
    end
    
end


function [time, AUC, TP_, TN_, FP_, FN_, precision, recall, F1] = alpha_sweep(data, alpha_vect, mu_matrix_original, sigma_matrix_original, range_images, start_img, dirInputs, input_files, background, foreground, dirGT, rho)
% sweep through several thresholds to compare performance

    tic

    plot_detection = true;
    plot_graphs = true;

    precision = zeros(1,size(alpha_vect,2));
    recall = zeros(1,size(alpha_vect,2));
    F1 = zeros(1,size(alpha_vect,2));

    TP_ = [];
    TN_ = [];
    FP_ = [];
    FN_ = [];

    max_f1 = 0;
    max_alpha = 0;
    max_rho = 0;

    for n=1:size(alpha_vect,2)
        alpha = alpha_vect(n);

        mu_matrix = mu_matrix_original;
        sigma_matrix = sigma_matrix_original;
    
        %Metrics for alpha sweep
        TP_global = 0;
        TN_global = 0;
        FP_global = 0;
        FN_global = 0;
        
        %detect foreground and compare results
        for i=1:(round(range_images/2))

            % read frame and ground truth
            index = round(i + (start_img + range_images/2) - 2);
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

            if plot_detection
                fig = figure(10);
                subplot(1,2,1); imshow(gt_fore); title('ground truth');
                subplot(1,2,2); imshow(detection(:,:,i)); title('detection');
                % outfile = strcat('task_2_2_TrafficDetection.gif');
                % fig_frame = getframe(fig);
                % im = frame2im(fig_frame);
                % if i == 1
                %     imwrite(rgb2gray(im),outfile,'gif','LoopCount',Inf,'DelayTime',0.1);
                % else
                %     imwrite(rgb2gray(im),outfile,'gif','WriteMode','append','DelayTime',0.1);
                % end
            end

            [TP, TN, FP, FN] = get_metrics_2val(gt_back, gt_fore, detection(:,:,i), data);

            %option of getting overall metrics
            TP_global = TP_global + TP;
            TN_global = TN_global + TN;
            FP_global = FP_global + FP;
            FN_global = FN_global + FN;

            % adapt model using pixels belonging to the background
            [mu_matrix, sigma_matrix] = adaptModel(test_backg_in(:,:,i), detection(:,:,i), mu_matrix, sigma_matrix, rho);

        end

        %global metrics for threshold sweep:
        [precision(n), recall(n), F1(n)] = evaluation_metrics(TP_global,TN_global,FP_global,FN_global);
        TP_(n) = TP_global;
        TN_(n) = TN_global;
        FP_(n) = FP_global;
        FN_(n) = FN_global;

        if F1(n) > max_f1
            max_f1 = F1(n);
            max_alpha = alpha;
            max_rho = rho;
        end
    end    

    time = toc;

    %AUC of Precision metrics
    AUC = trapz(precision,2)/size(TP_,2);

    if plot_graphs
        x = alpha_vect;
        figure(1)
        plot(x, transpose(precision), 'b', x, transpose(recall), 'r',  x, transpose(F1), 'k');
        title(strcat({'Precision, Recall & F1 vs Threshold for dataset '},data));
        xlabel('Threshold');
        ylabel('Measure');
        legend('Precision','Recall','F1');

        figure(2)
        plot(x, transpose(TP_),'b', x, transpose(TN_),'g', x, transpose(FP_),'r', x, transpose(FN_));
        title(strcat({'TP, TN, FP & FN vs Threshold for '},data));
        xlabel('Threshold');
        ylabel('Pixels');
        legend('TP','TN','FP','FN');

        figure(3)
        plot(recall, transpose(precision), 'g');
        title(strcat({'Recall vs Precision & AUC for dataset '},data));
        xlabel('Recall');
        ylabel('Precision');
        legend('Recall vs Precision','Area under the curve');
    end
end


function alpha_rho_sweep(data, alpha_vect, mu_matrix_original, sigma_matrix_original, range_images, start_img, dirInputs, input_files, background, foreground, dirGT, rho_vect)
% sweeps through several thresholds to compare performance

    plot_detection = false;

    precision = zeros(1,size(alpha_vect,2));
    recall = zeros(1,size(alpha_vect,2));
    F1 = zeros(1,size(alpha_vect,2));

    max_f1 = 0;
    max_alpha = 0;
    max_rho = 0;

    position = 1;
    
    for n=1:size(alpha_vect,2)
        alpha = alpha_vect(n);
        for rho = rho_vect
            
            fprintf(['trying alpha = ', num2str(alpha), ' and rho = ', num2str(rho), '\n']);
            
            mu_matrix = mu_matrix_original;
            sigma_matrix = sigma_matrix_original;

            %Metrics for alpha sweep
            TP_global = 0;
            TN_global = 0;
            FP_global = 0;
            FN_global = 0;
            
            %detect foreground and compare results
            for i=1:(round(range_images/2))

                % read frame and ground truth
                index = round(i + (start_img + range_images/2) - 2);
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

                if plot_detection
                    fig = figure(10);
                    subplot(1,2,1); imshow(gt_fore); title('ground truth');
                    subplot(1,2,2); imshow(detection(:,:,i)); title('detection');
                    % pause();
                end

                [TP, TN, FP, FN] = get_metrics_2val(gt_back, gt_fore, detection(:,:,i));

                %option of getting overall metrics
                TP_global = TP_global + TP;
                TN_global = TN_global + TN;
                FP_global = FP_global + FP;
                FN_global = FN_global + FN;

                % adapt model using pixels belonging to the background
                [mu_matrix, sigma_matrix] = adaptModel(test_backg_in(:,:,i), detection(:,:,i), mu_matrix, sigma_matrix, rho);

            end

            %global metrics for threshold sweep:
            [precision(position), recall(position), F1(position)] = evaluation_metrics(TP_global,TN_global,FP_global,FN_global);

            if F1(position) > max_f1
                max_f1 = F1(position);
                max_alpha = alpha;
                max_rho = rho;
                fprintf(['max f1 = \t', num2str(max_f1),'\n']);
                fprintf(['max alpha = \t', num2str(max_alpha),'\n']);
                fprintf(['max rho = \t', num2str(max_rho),'\n']);
            end
            position = position+1;
        end
    end    
end


function [mean_matrix,variance_matrix] = adaptModel(frame, detection, mean_matrix, variance_matrix, rho)
    % background pixels: ~detection
    mean_matrix(~logical(detection))=rho*frame(~logical(detection)) + (1-rho)*mean_matrix(~logical(detection));
    variance_matrix(~logical(detection))=sqrt(rho*(frame(~logical(detection))-mean_matrix(~logical(detection))).^2 + (1-rho)*variance_matrix(~logical(detection)).^2);
end
