figure(1)
plot(alpha_vect, transpose(F1_fall), 'g', alpha_vect, transpose(F1_traffic),'r',alpha_vect, transpose(F1_highway));
title('F1 for the 3 datasets');
xlabel('alpha');
ylabel('F1 measure');
legend('fall','traffic','highway');

indexmaxfall = find(max(F1_fall) == F1_fall);
xmaxfall = alpha_vect(indexmaxfall);
ymaxfall = F1_fall(indexmaxfall);
strmaxf = ['Alpha = ',num2str(xmaxfall), ' / max F1 = ', num2str(ymaxfall)];
text(xmaxfall,ymaxfall,strmaxf,'HorizontalAlignment','left');

indexmaxtraf = find(max(F1_traffic) == F1_traffic);
xmaxtraf = alpha_vect(indexmaxtraf);
ymaxtraf = F1_traffic(indexmaxtraf);
strmaxt = ['Alpha = ',num2str(xmaxtraf), ' / max F1 = ', num2str(ymaxtraf)];
text(xmaxtraf,ymaxtraf,strmaxt,'HorizontalAlignment','left');

indexmaxh = find(max(F1_highway) == F1_highway);
xmaxh = alpha_vect(indexmaxh);
ymaxh = F1_highway(indexmaxh);
strmaxh = ['Alpha = ',num2str(xmaxh), ' / max F1 = ', num2str(ymaxh)];
text(xmaxh,ymaxh,strmaxh,'HorizontalAlignment','left');

fall=[xmaxfall,ymaxfall]

highway=[xmaxh,ymaxh]

traffic=[xmaxtraf,ymaxtraf]


TP_h= TP_;
FP_h=FP_;
FN_h=FN_;
TN_h=TN_;

TP_t= TP_;
FP_t=FP_;
FN_t=FN_;
TN_t=TN_;

TP_f= TP_;
FP_f=FP_;
FN_f=FN_;
TN_f=TN_;

figure(3)
plot((FP_h./(FP_h +TN_h)),TP_h./(TP_h+FN_h),'b',(FP_t./(FP_t +TN_t)),TP_t./(TP_t+FN_t),'r',(FP_f./(FP_f +TN_f)),TP_f./(TP_f+FN_f),'g')
title 'ROC curve'
xlabel('FP ratio')
ylabel('TP ratio')
legend('highway','traffic', 'fall');

figure(3)
plot(recall_h,pres_h,'b',recall_t,pres_t,'r',recall_f,pres_f,'g')
title 'P/R curve'
xlabel('Recall')
ylabel('Precision')
legend('highway','traffic', 'fall');
