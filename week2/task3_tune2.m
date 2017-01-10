clearvars
close all

addpath('../datasets');
addpath('../utils');
addpath('../utils/StGm');
addpath('../week2');

% Evaluating data and metrics
dirGT = '../datasets/cdvd/dataset/baseline/highway/groundtruth/';
background = 55;
foreground = 250;

% Directory for writing results:
dirResults = './results/';


videoname = 'highway';
T1 = 1050;
T2 = 1350;


Threshold = 1;
K = 6;
Rho = 0.5;
THFG = 0.5;


theta0 = [Threshold, Rho, THFG];
gamma = 0.3;
delta = 0.001;
maxiter = 100;
theta = St_Gm_gradient_ascent(theta0, delta, gamma, maxiter, K, videoname, T1, T2);



