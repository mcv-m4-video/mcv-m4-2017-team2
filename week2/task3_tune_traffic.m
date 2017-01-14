clearvars
close all

addpath('../utils');

% Compute in black and white?
black_n_white = 1;

% Select video sequence:
videoname = 'traffic';

% Sizes of grid:
n_LearningRate = 21;
n_MinimumBackgroundRatio = 11;

% Compute over grid:
tune_st_gm(videoname, black_n_white, n_LearningRate, n_MinimumBackgroundRatio)

% Search results:
% posttuning_st_gm(videoname)

