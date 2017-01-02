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

Threshold_vec = [1, 1.25, 1.5, 1.75, 2, 2.5, 3, 3.5, 4];
K_vec = [2, 5, 6, 7, 8, 9, 10, 11, 12];
Rho_vec = [0.1, 0.15, 0.2, 0.25, 0.3, 0.4];
THFG_vec = [0.1, 0.2, 0.225, 0.25, 0.275, 0.3, 0.4];

% Threshold
K = 8;
Rho = 0.25;
THFG = 0.25;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Threshold:
F1_vec = zeros(1,length(Threshold_vec));
for i = 1:length(Threshold_vec)
    Threshold = Threshold_vec(i);
    % Compute detection:
    [Sequence] = MultG_fun(Threshold, T1, T2, K, Rho, THFG, videoname);
    % Write detection:
    write_sequence(Sequence, dirResults, T1);
    % Evaluate detection:
    [~, ~, F1_vec(i)] = test_sequence(dirResults, videoname);
end
[~, imax] = max(F1_vec);
Threshold = Threshold_vec(imax);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% K:
F1_vec = zeros(1,length(K_vec));
for i = 1:length(K_vec)
    K = K_vec(i);
    % Compute detection:
    [Sequence] = MultG_fun(Threshold, T1, T2, K, Rho, THFG, videoname);
    % Write detection:
    write_sequence(Sequence, dirResults, T1);
    % Evaluate detection:
    [~, ~, F1_vec(i)] = test_sequence(dirResults, videoname);
end
[~, imax] = max(F1_vec);
K = K_vec(imax);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Rho:
F1_vec = zeros(1,length(Rho_vec));
for i = 1:length(Rho_vec)
    Rho = Rho_vec(i);
    % Compute detection:
    [Sequence] = MultG_fun(Threshold, T1, T2, K, Rho, THFG, videoname);
    % Write detection:
    write_sequence(Sequence, dirResults, T1);
    % Evaluate detection:
    [~, ~, F1_vec(i)] = test_sequence(dirResults, videoname);
end
[~, imax] = max(F1_vec);
Rho = Rho_vec(imax);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% THFG:
F1_vec = zeros(1,length(THFG_vec));
for i = 1:length(THFG_vec)
    THFG = THFG_vec(i);
    % Compute detection:
    [Sequence] = MultG_fun(Threshold, T1, T2, K, Rho, THFG, videoname);
    % Write detection:
    write_sequence(Sequence, dirResults, T1);
    % Evaluate detection:
    [~, ~, F1_vec(i)] = test_sequence(dirResults, videoname);
end
[~, imax] = max(F1_vec);
THFG = THFG_vec(imax);




