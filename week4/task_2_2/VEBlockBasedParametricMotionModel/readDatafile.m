function outImage = readDatafile(filename);
% function outImage = readDatafile(filename)
% Purpose : loads the image specified by filename into matrix outImage
%
% Argument : INPUT : filename -- string
% OUTPUT: outImage -- matrix of size NxMx3 in RGB color space

x = [];
fid = fopen(filename,'r');
x = fread(fid);
fclose(fid);
x = reshape(x,3,320,240);
xs = zeros(240,320,3);
xs(:,:,1) = squeeze(x(1,:,:))';
xs(:,:,2) = squeeze(x(2,:,:))';
xs(:,:,3) = squeeze(x(3,:,:))';
outImage = xs;
