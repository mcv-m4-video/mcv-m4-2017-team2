function [TP, TN, FP, FN] = get_metrics_2val (gt_back, gt_fore, img)
    %detected as foreground and gt_fore gives 1 (is foreground)
    TP = sum(sum((img>0 & gt_fore>0)));
    
    %detected as foreground and gt_back gives a 1(is background)
    FP = sum(sum((img>0 & gt_back>0)));
    
    %not detected as foreground and gt_fore gives 1(is foreground)
    FN = sum(sum((img==0 & gt_fore>0)));
    
    %not detected as foreground and gt_back gives a 1(is background)
    TN = sum(sum((img==0 & gt_back>0)));

end