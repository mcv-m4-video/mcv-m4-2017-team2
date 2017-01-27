function estimatedB = affineRec(matAtoB_inv,affAtoB_inv,A,B);
%% function estimatedB = affineRec(paraAtoB,A,B);
%% calculate the predicted B image from image A and affine
%% model parameters
%%
[nRows,nCols] = size(A);
estimatedB = B;
for i = 1:nRows,
for j = 1:nCols,
xy = matAtoB_inv*[i;j] + affAtoB_inv;
xy = round(xy);
%% take care of points outside the image boundary
if xy(1) <= nRows & xy(2) <= nCols & min(xy) > 0,
estimatedB(i,j) = A(xy(1),xy(2));
end
end
end