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
    settings.use_slope_perspective_noDiag = false;
    settings.use_slope_perspective_diag = true;
    settings.use_slope_cartesian_noDiag = false;
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

pc_truth_orig = depth2pc(depth_orig, rgb, odometry, settings, false);
pc_truth = depth2pc(depth, rgb, odometry, settings, false);
pc_truth_noblack = depth2pc(depth, rgb, odometry, settings, true);

if settings.show_figures
    fig1 = figure(1);
    
    subplot(221)
    pcshow(pc_truth_noblack, 'MarkerSize', settings.markersize); xlabel('x'); ylabel('y'); zlabel('z'); title('Ground Truth'); 
else, settings
    fig1 = [];
end

%% Create measurements
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
if settings.show_figures
    figure(fig1);
    subplot(222)
    pcshow(pc_samples, 'MarkerSize', settings.markersize); xlabel('x'); ylabel('y'); zlabel('z'); 
    title('Samples')
end

%% create (possibly noisy) measurements
if settings.addNoise    
    noise = settings.epsilon * (2*rand(K,1)-1);
else
    noise = zeros(K,1);
end
measured_vector = sampling_matrix * xGT + noise;    

% Naive_Perspective
if settings.use_naive
    results.naive = reconstructDepthImage( 'naive', settings, ...
        height, width, sampling_matrix, measured_vector, samples, [], ...
        depth, rgb, odometry, pc_truth_orig, fig1, 223);
end

% Slope_Perspective_noDiag 
if settings.use_slope_perspective_noDiag
    settings.useDiagonalTerm = false;
    results.slope_perspective_noDiag = reconstructDepthImage( 'slope_perspective_noDiag', settings, ...
        height, width, sampling_matrix, measured_vector, samples, results.naive.depth_rec(:), ...
        depth, rgb, odometry, pc_truth_orig, fig1, 224);
end

% Slope_Perspective_diag 
if settings.use_slope_perspective_diag
    settings.useDiagonalTerm = true;
    results.slope_perspective_diag = reconstructDepthImage( 'slope_perspective_diag', settings, ...
        height, width, sampling_matrix, measured_vector, samples, results.naive.depth_rec(:), ...
        depth, rgb, odometry, pc_truth_orig, fig1, 224);
end

% Slope_Cartesian_noDiag 
if settings.use_slope_cartesian_noDiag
    results.slope_cartesian_noDiag = reconstructDepthImage( 'slope_cartesian_noDiag', settings, ...
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

    subplot(221); 
    colormap('parula'); imagesc(depth); set(gca,'XTick',[]); set(gca,'YTick',[]); 
    title('Ground Truth Depth');
    
    
    subplot(222); 
    colormap('parula'); imagesc(img_sample); set(gca,'XTick',[]); set(gca,'YTick',[]); 
    title('Samples');
    
    if settings.use_naive  
        fig=subplot(223);
        colormap('parula'); imagesc(results.naive.depth_rec); set(gca,'XTick',[]); set(gca,'YTick',[]); 
        title({'Naive Interpolation', ['(Error=', sprintf('%.2g', 100*results.naive.error.euclidean), 'cm)']})
    end

    subplot(224); 
    colormap('parula');
    if settings.use_slope_perspective_diag
        imagesc(results.slope_perspective_diag.depth_rec); set(gca,'XTick',[]); set(gca,'YTick',[]); 
        title({'Slope Perspective', ['(Error=', sprintf('%.2g', 100*results.slope_perspective_diag.error.euclidean), 'cm)']})
    elseif settings.use_slope_perspective_noDiag
        imagesc(results.slope_perspective_noDiag.depth_rec); set(gca,'XTick',[]); set(gca,'YTick',[]); 
        title({'Slope Perspective', ['(Error=', sprintf('%.2g', 100*results.slope_perspective_noDiag.error.euclidean), 'cm)']})
    elseif settings.use_slope_cartesian_noDiag
        imagesc(results.slope_cartesian_noDiag.depth_rec); set(gca,'XTick',[]); set(gca,'YTick',[]); 
        title({'Slope Cartesian', ['(Error=', sprintf('%.2g', 100*results.slope_cartesian_noDiag.error.euclidean), 'cm)']})
    end
end
