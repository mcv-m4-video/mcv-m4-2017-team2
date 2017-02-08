
A=rgb2gray(imread('sequence_parc_nova_icaria/in001174.jpg'));

figure(1)
imshow(A);
hold on
%line([383 383],[0,65], 'Color','r');
line([383,611],[65,386],'Color','b');
%line([419 419],[0,116], 'Color','r');
%line([611,611],[0,386],'Color','r');
line([260,383],[65,65],'Color','y');
line([230,419],[116,116],'Color','y');
line([20,611],[386,386],'Color','y');
%half1x = round(sqrt((419-383)^2 + ))
line([401 401],[0,120], 'Color','b');
line([515 515],[0,340], 'Color','b');
line([260 401],[90,90], 'Color','g');
line([515 515],[0,340], 'Color','g');