close all; clear; clc
addpath(genpath(fullfile('..', 'lib')))

%% Create settings
createSettings

% settings for solver
settings.solver = 'cvx';         % choose either 'cvx' or 'nesta'
if strcmp(settings.solver, 'cvx')
    cvx_solver mosek
    cvx_save_prefs
end

% settings for objective functions (algorithms)
settings.use_naive = true;
settings.use_L1 = true;
settings.use_L1_diag = true;
settings.use_L1_cart = true;
settings.use_L1_inv = true;
settings.use_L1_inv_diag = true;

% settings for sampling
settings.sampleMode = 'uniform';   % choose from 'uniform', 'harris-feature', 'regular-grid'
settings.doAddNeighbors = false;   % set to true, if we want to sample neighboring pixels

DATASETS = {'ZED', 'lids_floor6', 'lids_floor7', '38_floor3', ...
    '39_floor3', '34_floor3', '36_floor3', 'stata_floor1', '32_144'};
num_datasets = length(DATASETS);

%% Run on all datasets
settings.subSample = 0.1;          % subsample original image to reduce its size
settings.percSamples = 0.05;       % perceptage of samples relative to image size
for dataset_ID = 1 : num_datasets
  run_dataset(DATASETS{dataset_ID}, settings);
end

%% Run on all datasets
settings.subSample = 0.1;          % subsample original image to reduce its size
settings.percSamples = 0.1;       % perceptage of samples relative to image size
for dataset_ID = 1 : num_datasets
  run_dataset(DATASETS{dataset_ID}, settings);
end

%% Run on all datasets
settings.subSample = 0.1;          % subsample original image to reduce its size
settings.percSamples = 0.02;       % perceptage of samples relative to image size
for dataset_ID = 1 : num_datasets
  run_dataset(DATASETS{dataset_ID}, settings);
end

%% Run on all datasets
settings.subSample = 0.2;          % subsample original image to reduce its size
settings.percSamples = 0.02;       % perceptage of samples relative to image size
for dataset_ID = 1 : num_datasets
  run_dataset(DATASETS{dataset_ID}, settings);
end
