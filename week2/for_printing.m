figure(1)
plot(alpha_vect, transpose(F1_fall), 'g', alpha_vect, transpose(F1_traffic),'r',alpha_vect, transpose(F1_highway));
title('F1 for the 3 datasets');
xlabel('alpha');
ylabel('F1 measure');
legend('fall','traffic','highway');

indexmaxfall = find(max(F1_fall) == F1_fall);
xmaxfall = alpha_vect(indexmaxfall);
ymaxfall = F1_fall(indexmaxfall);
strmaxf = ['Max alpha = ',num2str(xmaxfall)];
text(xmaxfall,ymaxfall,strmaxf,'HorizontalAlignment','left');

indexmaxtraf = find(max(F1_traffic) == F1_traffic);
xmaxtraf = alpha_vect(indexmaxtraf);
ymaxtraf = F1_traffic(indexmaxtraf);
strmaxt = ['Max alpha = ',num2str(xmaxtraf)];
text(xmaxtraf,ymaxtraf,strmaxt,'HorizontalAlignment','left');

indexmaxh = find(max(F1_highway) == F1_highway);
xmaxh = alpha_vect(indexmaxh);
ymaxh = F1_highway(indexmaxh);
strmaxh = ['Max alpha = ',num2str(xmaxh)];
text(xmaxh,ymaxh,strmaxh,'HorizontalAlignment','left');