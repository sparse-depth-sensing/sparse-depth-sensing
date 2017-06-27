close all; clear; clc
addpath(genpath('lib'))

%% Choose dataset
settings.dataset = 'ZED';   % choose either ZED or lids_floor6

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
settings.sampleMode = 'uniform';   % choose from 'uniform', 'harris-feature', 'regular-grid'
settings.doAddNeighbors = false;   % set to true, if we want to sample neighboring pixels

%% Start the loop
num_data = getNumberOfImages(settings);
for img_ID = 1 : 5 : num_data
  disp('****************************************************************')
  disp(sprintf('Image ID : %3d', img_ID))
  [results, ~] = reconstruct_single_frame(img_ID, settings);
  if settings.show_debug_info
    disp(sprintf(' --- samples (number=%3d, percentage=%.2g%%)', ...
      results.K, 100*results.K/length(results.depth(:))))
  end
end