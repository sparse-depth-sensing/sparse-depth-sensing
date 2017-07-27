close all; clear; clc
addpath(genpath(fullfile('..', 'lib')))

%% Create settings 
createSettings

settings.solver = 'cvx'; 

% settings for objective functions (algorithms)
% settings.use_naive = true;
% settings.use_L1 = true;
% settings.use_L1_diag = true;
% settings.use_L1_cart = true;
% settings.use_L1_inv = true;
% settings.use_L1_inv_diag = true;

% settings for sampling
settings.subSample = 0.1;          % subsample original image to reduce its size
settings.percSamples = 0.05;       % perceptage of samples relative to image size
settings.sampleMode = 'uniform';   % choose from 'uniform', 'harris-feature', 'regular-grid'
settings.doAddNeighbors = false;   % set to true, if we want to sample neighboring pixels

DATASETS = {'ZED', 'lids_floor6', 'lids_floor7', '38_floor3', ...
    '39_floor3', '34_floor3', '36_floor3', 'stata_floor1', '32_144'};
datasetLabels = {'ZED', 'K1', 'K2', 'K3', ...
    'K4', 'K5', 'K6', 'K7', 'K8'};
num_datasets = length(DATASETS);

%% Loop over all results
for dataset_ID = 1 : 7
  fprintf('ID=%d, Dataset=%s\n', dataset_ID, DATASETS{dataset_ID})
  stats = load_result_stats(DATASETS{dataset_ID}, settings);
%   pause;
end