function [precision,recall, F1] = evaluation_metrics(TP,TN,FP,FN)

precision=TP/(TP+FN);
recall=TP/(TP+FP);
F1=2*precision*recall/(precision+recall);

end