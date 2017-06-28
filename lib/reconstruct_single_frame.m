function [results, settings] = reconstruct_single_frame(img_ID, settings)
addpath(genpath('lib'))
% addpath('plots');

%% settings for the default test example
if nargin < 2
  close all; clear; clc;
  settings.dataset = 'ZED';   % test_data, lids_floor6, lab1, ZED, pwlinear_nbCorners=10
  img_ID = 76;
  
  createSettings
  
  settings.solver = 'nesta';
  settings.use_L1 = false;
  settings.use_L1_diag = true;
  settings.use_L1_cart = false;
  settings.subSample = 0.2;               % subsample original image, to reduce its size
  settings.percSamples = 0.01;
  settings.sampleMode = 'uniform';   % 'uniform', 'harris-feature', 'regular-grid'
  settings.doAddNeighbors = true;
  settings.stretch.flag = false;
  settings.stretch.delta_y = 0; %1e-5;
  settings.stretch.delta_z = settings.stretch.delta_y;
end

%% Load Data
[ depth, rgb, odometry, depth_orig ] = getRawData( settings, img_ID );

% rgb may be not available
if isKinectDataset(settings) && sum(rgb(:)) == 0
  results.rgb = [];
  return
end

% convert raw data to point cloud
if strcmp(settings.pc_frame, 'body')
  % create null odometry information
  odometry.Position.X = 0;
  odometry.Position.Y = 0;
  odometry.Theta = 0;
end

% create point clouds
pc_truth_orig = depth2pc(depth_orig, rgb, odometry, settings, false);
pc_truth = depth2pc(depth, rgb, odometry, settings, false);
pc_truth_noblack = depth2pc(depth, rgb, odometry, settings, true);  % only points with rgb colors

if settings.show_pointcloud
  fig1 = figure(1);
  
  subplot(221)
  pcshow(pc_truth_noblack, 'MarkerSize', settings.markersize); xlabel('x'); ylabel('y'); zlabel('z'); title('Ground Truth');
else
  fig1 = [];
end

%% Create random samples
samples = createSamples( depth, rgb, settings );

% if samples are not created properly
if size(samples, 1) == 0
  results = [];
  return;
end
xGT = depth(:);
N = length(xGT);    % total number of valid 3D points
K = length(samples);    % total number of measurements

height = size(depth,1);
width = size(depth,2);

% create sparse sampling matrix
Rfull = speye(N);
sampling_matrix = Rfull(samples, :);
img_sample = nan * ones(size(depth));
img_sample(samples) = 255 * xGT(samples);

% create point cloud
[pc_samples] = depth2pc(img_sample, rgb, odometry, settings, false);

% visualization
if settings.show_pointcloud
  figure(fig1);
  subplot(222)
  pcshow(pc_samples, 'MarkerSize', settings.markersize); xlabel('x'); ylabel('y'); zlabel('z');
  title('Input (Samples)')
end

%% create (possibly noisy) measurements
if settings.addNoise
  noise = settings.epsilon * (2*rand(K,1)-1);
else
  noise = zeros(K,1);
end
measured_vector = sampling_matrix * xGT + noise;

%% algorithm: naive
if settings.use_naive
  results.naive = reconstructDepthImage( 'naive', settings, ...
    height, width, sampling_matrix, measured_vector, samples, [], ...
    depth, rgb, odometry, pc_truth_orig, fig1, 223);
end

%% algorithm: L1
if settings.use_L1
  settings.useDiagonalTerm = false;
  results.L1 = reconstructDepthImage( 'L1', settings, ...
    height, width, sampling_matrix, measured_vector, samples, results.naive.depth_rec(:), ...
    depth, rgb, odometry, pc_truth_orig, fig1, 224);
end

%% algorithm: L1-diag
if settings.use_L1_diag
  settings.useDiagonalTerm = true;
  results.L1_diag = reconstructDepthImage( 'L1-diag', settings, ...
    height, width, sampling_matrix, measured_vector, samples, results.naive.depth_rec(:), ...
    depth, rgb, odometry, pc_truth_orig, fig1, 224);
end

%% algorithm: L1-cart
if settings.use_L1_cart
  results.L1_cart = reconstructDepthImage( 'L1-cart', settings, ...
    height, width, sampling_matrix, measured_vector, samples, results.naive.depth_rec(:), ...
    depth, rgb, odometry, pc_truth_orig, fig1, 224);
end

%% Save results
results.pc_truth_noblack = pc_truth_noblack;
results.pc_truth = pc_truth;
results.pc_truth_orig = pc_truth_orig;
results.pc_samples = pc_samples;
results.img_sample = img_sample;

results.rgb = rgb;
results.depth = depth;
results.K = K;

%% Perspective projection to images (for visualization)
if settings.show_debug_info
  figure(2);
  
  subplot(231); imshow(rgb); title('RGB');
  subplot(232); display_depth_image( depth, settings, 'Ground Truth Depth' )
  subplot(234); display_depth_image( img_sample, settings, 'Input (Samples)' );
  
  if settings.use_naive
    subplot(235);
    titleString = {'naive', ...
      ['mae=', sprintf('%.3g', 100*results.naive.error.mae), 'cm'], ...
      ['rmse=', sprintf('%.3g', 100*results.naive.error.rmse), 'cm']...
      };
    display_depth_image( results.naive.depth_rec, settings, titleString );
  end
  
  subplot(236);
  if settings.use_L1_diag
    titleString = {'L1-diag', ...
      ['mae=', sprintf('%.3g', 100*results.L1_diag.error.mae), 'cm'], ...
      ['rmse=', sprintf('%.3g', 100*results.L1_diag.error.rmse), 'cm']...
      };
    display_depth_image( results.L1_diag.depth_rec, settings, titleString );
  elseif settings.use_L1
    titleString = {'L1', ...
      ['mae=', sprintf('%.3g', 100*results.L1.error.mae), 'cm'], ...
      ['rmse=', sprintf('%.3g', 100*results.L1.error.rmse), 'cm']...
      };
    display_depth_image( results.L1.depth_rec, settings, titleString );
  elseif settings.use_L1_cart
    titleString = {'L1-cart', ...
      ['mae=', sprintf('%.3g', 100*results.L1_cart.error.mae), 'cm'], ...
      ['rmse=', sprintf('%.3g', 100*results.L1_cart.error.rmse), 'cm']...
      };
    display_depth_image( results.L1_cart.depth_rec, settings, titleString );
  end
  drawnow
end
