function [precision,recall, F1] = evaluation_metrics(TP,TN,FP,FN)

	precision=TP/(TP+FP);
	recall=TP/(TP+FN);
	F1=2*precision*recall/(precision+recall);

end