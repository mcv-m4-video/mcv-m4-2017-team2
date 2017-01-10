figure(1)
plot(alpha_vect, transpose(F1_fall), 'g', alpha_vect, transpose(F1_traffic),'r',alpha_vect, transpose(F1_highway));
title('F1 for the 3 datasets');
xlabel('alpha');
ylabel('F1 measure');
legend('fall','traffic','highway');