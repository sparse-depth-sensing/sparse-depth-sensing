close all; clear; clc
addpath(genpath('lib'))

%% Choose dataset
settings.dataset = 'ZED';   % choose either ZED or lids_floor6

%% Create settings for the demo
createSettings

% settings for solver
settings.solver = 'nesta';         % choose either 'cvx' or 'nesta'

% settings for objective functions (algorithms)
settings.use_slope_perspective_noDiag = false;
settings.use_slope_perspective_diag = true;
settings.use_slope_cartesian_noDiag = false;

% settings for sampling
settings.subSample = 0.2;          % subsample original image to reduce its size
settings.percSamples = 0.01;       % perceptage of samples relative to image size
settings.sampleMode = 'uniform';   % choose from 'uniform', 'harris-feature', 'regular-grid'
settings.doAddNeighbors = true;    % sample neighboring pixels

%% Start the loop
num_data = getNumberOfImages(settings);
for img_ID = 1 : 5 : num_data
    [results, settings] = reconstruct_single_frame(img_ID, settings);
end