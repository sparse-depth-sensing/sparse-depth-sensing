close all; clear; clc
addpath(genpath('lib'))

%% Choose dataset
settings.dataset = 'lids_floor6';   % only lids_floor6 contains odometry information

%% Create settings for the demo
createSettings

% settings for solver
settings.solver = 'nesta';         % choose either 'cvx' or 'nesta'

% settings for objective functions (algorithms)
settings.use_L1 = false;
settings.use_L1_diag = true;
settings.use_L1_cart = false;

% settings for sampling
settings.subSample = 0.2;          % subsample original image to reduce its size
settings.percSamples = 0.01;       % perceptage of samples relative to image size
settings.sampleMode = 'regular-grid';   % choose from 'uniform', 'harris-feature', 'regular-grid'
settings.doAddNeighbors = false;   % set to true, if we want to sample neighboring pixels
settings.window_size = 5;          % size of the temporal window

%% Start the loop
num_data = getNumberOfImages(settings);
for img_ID = 1 : 5 : num_data-settings.window_size+1
    disp('****************************************************************')
    indices = img_ID : img_ID+settings.window_size-1;
    disp(sprintf('Temporal Window : %d to %d', img_ID, img_ID+settings.window_size-1))
    results = reconstruct_multi_frame(indices, settings);
    if settings.show_debug_info
        disp(sprintf(' across %d frames: samples (number=%3d, percentage=%.2g%%)', ...
            settings.window_size, results.K, 100*results.K/length(results.depth(:))))
    end
end