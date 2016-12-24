function [TP, TN, FP, FN] = get_metrics_2val (gt_back, gt_fore, img)
    %detected as foreground and gt_fore gives 1 or not detected as
    %foreground and gt_back gives a 1(is background)
    TP = sum(sum((img>0 & gt_fore>0) | (img==0 & gt_back>0)));
    
    %detected as foreground and gt_fore gives 0 or not detected as
    %foreground and gt_back gives a 0(is not background)
    FP = sum(sum((img>0 & gt_fore==0) | (img==0 & gt_back==0)));
    
    %not detected as foreground and gt_fore gives 1 or detected as
    %foreground and gt_back gives a 1(is background)
    FN = sum(sum((img==0 & gt_fore>0) | (img>0 & gt_back>0)));
    
    %not detected as foreground and gt_fore gives 0 or not detected as
    %foreground and gt_back gives a 1(is background)
    TN = sum(sum((img==0 & gt_fore==0) | (img==0 & gt_back>0)));

end