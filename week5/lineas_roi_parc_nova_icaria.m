clearvars
close all

addpath('../datasets');
addpath('../utils');

video = VideoReader('parc_nova_icaria.mp4');
frame = double(readFrame(video)) / 255;

[nrow, ncol, nc] = size(frame);
[x, y] = meshgrid(1:ncol, 1:nrow);

% Recta izquierda:
x1 = 0;
x2 = 300;
y1 = 230;
y2 = 0;
a = (y2 - y1) / (x2 - x1);
b = y1 - a * x1;
mask_izq = y > a * x + b;
% imshow(mask_izq)

% Recta derecha:
x1 = 640;
x2 = 315;
y1 = 365;
y2 = 0;
a = (y2 - y1) / (x2 - x1);
b = y1 - a * x1;
mask_der = y > a * x + b;
% imshow(mask_der)

% Recta superior:
x1 = 0;
x2 = 640;
y1 = 50;
y2 = 50;
a = (y2 - y1) / (x2 - x1);
b = y1 - a * x1;
mask_sup = y > a * x + b;
% imshow(mask_sup)

% Máscara final:
mask = zeros(nrow, ncol, 3);
mask(:,:,1) = mask_izq .* mask_der .* mask_sup;
mask(:,:,2) = mask(:,:,1);
mask(:,:,3) = mask(:,:,1);
% imshow(mask)
imwrite(mask, 'mask_roi_parc_nova_icaria.png')

% Figura:
figure()
imshow(frame .* mask)
hold on
plot([0, 300], [230, 0], 'r')
plot([640, 315], [365, 0], 'r')
plot([0, 640], [50, 50], 'r')
plot([0, 640], [88, 88], 'y')
plot([0, 640], [137, 137], 'y')
plot([0, 640], [405, 405], 'y')

