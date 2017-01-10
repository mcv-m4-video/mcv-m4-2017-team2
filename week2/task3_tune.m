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

% Number of Gaussians (fixed):
K = 5;

Threshold_vec = [1, 1.25, 1.5, 1.75, 2, 2.5, 3];
Rho_vec = [0.1, 0.15, 0.2, 0.25, 0.3, 0.4];
THFG_vec = [0.1, 0.15, 0.2, 0.25, 0.3, 0.4];

% Threshold_vec = [1, 1.5];
% Rho_vec = [0.1, 0.2];
% THFG_vec = [0.1, 0.15];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Compute over grid:
F1_array = zeros(length(Threshold_vec), length(Rho_vec), length(THFG_vec));
progress = 10;
fprintf('Completed 0%%\n')
for idx1 = 1:length(Threshold_vec)
    if(idx1 > progress / 100 * length(Threshold_vec))
        fprintf('Completed %i%%\n', progress)
        progress = progress + 10;
    end
    Threshold = Threshold_vec(idx1);
    for idx2 = 1:length(Rho_vec)
        Rho = Rho_vec(idx2);
        for idx3 = 1:length(THFG_vec)
            THFG = THFG_vec(idx3);
            % Compute detection:
            sequence = MultG_fun(Threshold, T1, T2, K, Rho, THFG, videoname);
            % Evaluate detection:
            [~, ~, F1_array(idx1, idx2, idx3)] = test_sequence(sequence, videoname, T1);
        end
    end
end
fprintf('Completed 100%%\n')

% Search over grid:
idx1max = 0;
idx2max = 0;
idx3max = 0;
F1max = 0;
for idx1 = 1:length(Threshold_vec)
    for idx2 = 1:length(Rho_vec)
        for idx3 = 1:length(THFG_vec)
            if(F1max < F1_array(idx1, idx2, idx3))
                idx1max = idx1;
                idx2max = idx2;
                idx3max = idx3;
                F1max = F1_array(idx1, idx2, idx3);
            end
        end
    end
end

Threshold = Threshold_vec(idx1max);
Rho = Rho_vec(idx2max);
THFG = THFG_vec(idx3max);

fprintf('Best values found for K = %i Gaussians: %f\n', K, F1max)
fprintf('Threshold = %f\n', Threshold)
fprintf('Rho = %f\n', Rho)
fprintf('THFG = %f\n\n', THFG)





