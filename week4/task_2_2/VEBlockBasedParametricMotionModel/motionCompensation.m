function outFrame = motionCompensation(inFrame1, inFrame2, MVr, MVs)
%% function outFrame = motionCompensation(inFrame, MV)
%% Purpose : Motion compensation on current frame using given MVs
%% INPUT : inFrame -- [nRows x nCols]
%% MV -- [u v]
%% OUTPUT : outFrame -- motion compensated frame
%%
%% Author : T. Chen
%% Date : 02/29/2000
%%
nRows = size(inFrame1,1);
nCols = size(inFrame1,2);
u = MVs(1);
v = MVs(2);
ur = MVr(1);
vr = MVr(2);
uf = u - ur;
vf = v - vr;
outFrame = inFrame2;
%outFrame = inFrame1;
if uf >= 0 & vf >= 0,
outFrame(1:nRows-vf,1:nCols-uf) = inFrame2(1+vf:nRows,1+uf:nCols);
elseif uf >=0 & vf < 0,
outFrame(1-vf:nRows,1:nCols-uf) = inFrame2(1:nRows+vf,1+uf:nCols);
elseif uf < 0 & vf >= 0,
outFrame(1:nRows-vf,1-uf:nCols) = inFrame2(1+vf:nRows,1:nCols+uf);
else
outFrame(1-vf:nRows,1-uf:nCols) = inFrame2(1:nRows+vf,1:nCols+uf);
end
if u >= 0 & v >= 0,
outFrame(1:nRows-v,1:nCols-u) = inFrame1(1+v:nRows,1+u:nCols);
elseif u >=0 & v < 0,
outFrame(1-v:nRows,1:nCols-u) = inFrame1(1:nRows+v,1+u:nCols);
elseif u < 0 & v >= 0,
outFrame(1:nRows-v,1-u:nCols) = inFrame1(1+v:nRows,1:nCols+u);
else
outFrame(1-v:nRows,1-u:nCols) = inFrame1(1:nRows+v,1:nCols+u);
end