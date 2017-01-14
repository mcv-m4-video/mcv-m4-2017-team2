function posttuning_st_gm(videoname)

% Load results:
pr_curve_results = load(strcat('pr_curve_results_', videoname, '.txt'));
F1max_results = load(strcat('maxF1_', videoname, '.txt'));

% Values at maximum F1:
prec_F1max = F1max_results(1,1);
rec_F1max = F1max_results(1,2);
F1max = F1max_results(1,3);
NumGaussians_maxF1 = F1max_results(2,1);
LearningRate_maxF1 = F1max_results(2,2);
MinimumBackgroundRatio_maxF1 = F1max_results(2,3);

fprintf('Precision: %f,   recall: %f,   F1: %f\n', prec_F1max, rec_F1max, F1max)
fprintf('NumGaussians = %f\n', NumGaussians_maxF1)
fprintf('LearningRate = %f\n', LearningRate_maxF1)
fprintf('MinimumBackgroundRatio = %f\n', MinimumBackgroundRatio_maxF1)

% Plot precision - recall curve:
precision = pr_curve_results(:,2);
recall = pr_curve_results(:,1);
plot(recall, precision, 'LineWidth', 2)
ylabel('Precision')
xlabel('Recall')
axis([0 1 0 1])
title('Precision - Recall curve')
auc_pr = trapz(precision) / length(precision);
fprintf('Area Under Curve P-R: %f\n', auc_pr)


end
