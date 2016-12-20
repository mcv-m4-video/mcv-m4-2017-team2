function [TP, TN, FP, FN] = get_metrics (gt, img)

TP = sum(sum(img>0 & gt>0));
FP = sum(sum(img>0 & gt==0));
FN = sum(sum(img==0 & gt>0));
TN = sum(sum(img==0 & gt==0));

end