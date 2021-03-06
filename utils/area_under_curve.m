%This functions calculates the area under the curve for different cases, it
%enters with the vectors containing the metrics of the run. Input 'choice'
%decides which AUC will be calculated.
function [AUC] = area_under_curve(TP ,FP ,FN ,TN ,precision,recall,F1,choice)

switch choice
    case 'precision'
        AUC = trapz(precision,2)/size(TP,2);
    case 'ROC'
        AUC = trapz((TP./(TP + FN)),2)/size(TP,2);
end

end