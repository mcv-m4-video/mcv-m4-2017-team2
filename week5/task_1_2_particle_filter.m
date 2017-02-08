function task_1_2_particle_filter()

addpath('./particle_filter/')

% Parameters

F_update = [1 0 1 0; 0 1 0 1; 0 0 1 0; 0 0 0 1];

Npop_particles = 4000;

Xstd_rgb = 50;
Xstd_pos = 250;
Xstd_vec = 5;

Xrgb_trgt = [255; 255; 255];
sequence = 'nova_icaria';

if(strcmp(sequence,'highway'))
    
    T1 = 950;
    T2 = 1050;
    dirInputs = '..\datasets\cdvd\dataset\baseline\highway\input\';
    path_gt = '..\datasets\cdvd\dataset\baseline\highway\groundtruth\';
    preffix = 'gt';
    suffix = '.png';
elseif (strcmp(sequence,'nova_icaria'))
    T1 = 1174;
    T2 = 2004;
    dirInputs = './sequence_parc_nova_icaria/';
    path_gt = './sequence_parc_nova_icaria_stg_foreground/';
    preffix = 'in';
    suffix = '.jpg';
end


Npix_resolution = [320 240];

% Object Tracking by Particle Filter

X = create_particles(Npix_resolution, Npop_particles);
%f = getforeground(path_highway);

nframes = int32(T2 - T1 + 1);
t = T1 - 1;
for idx = 1:nframes
    
    % Read frame:
    t = t + 1;
    filenumber = sprintf('%06d', t);
    filename = strcat('in', filenumber, '.jpg');
    filegt = strcat(preffix, filenumber, suffix);
    %         grayframe = double(rgb2gray(imread(strcat(dirSequence, filename)))) / 255;
    Y_k1 = imread(strcat(dirInputs, filename));
    
    gts = imread(strcat(path_gt ,filegt));
    %gts = activecontour(rgb2gray(Y_k1), mask, maxIterations, 'Chan-Vese');
    
    Y_k = bsxfun(@times,Y_k1,gts);
    
    % Forecasting
    X = update_particles(F_update, Xstd_pos, Xstd_vec, X);
    
    % Calculating Log Likelihood
    L = calc_log_likelihood(Xstd_rgb, Xrgb_trgt, X(1:2, :), Y_k);
    
    % Resampling
    X = resample_particles(X, L);
    
    % Showing Image
    show_particles(X, Y_k1);
    %show_state_estimated(X, Y_k);
    
end