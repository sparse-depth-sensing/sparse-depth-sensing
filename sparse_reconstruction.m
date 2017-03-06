function results = sparse_reconstruction(DATASET, img_ID, settings);
% This is the main procedure for sparse depth reconstruction. We  depth
% images from the data folder, create random depth measurements (depending on 
% the "settings" structure array), reconstruct the depth images and
% visualize the results

%% The settings structure array
% settings.subSample = 0.2;         % subsample original image, to reduce its size
% settings.isDebug = false;         % show debug information if true
%
% settings.sampleMode = 'uniform';  % uniform, rgb_edges
% settings.percSamples = 0.02;      % percentage of uniform random samples used, if sampleMode == uniform
% settings.percEdges = 1;           % percentage of edge samples used, if sampleMode == rgb_edges
% settings.doAddNeighbors = true;   % set to true if neighbors of samples are also included
% settings.useDiagonalTerm = true;  % minimize the diagonal 2nd-derivative term
% 
% settings.addNoise = false;        % set to true if you want to add noise into the measurements
% settings.epsilon = 0.1;           % epsilon is the standard deviation of the random noise
% 
% settings.isBounded = true;        % set to true if bound the range of reconstruction (10 meters max)
% settings.maxValue = 255;          % 10 meters correspond to value 255 in the scaled depth images.

%% Load images and preprocessing of data
disp('Loading data..')
% the depth images are mapped from [0-10m] to [0, 255]
[ depth, rgb ] = load_image(DATASET, img_ID);
if size(depth, 1) == 0  % file does not exist
    warning(['File ', num2str(img_ID), ' does not exist. Skipped.'])
    results = [];
    return
end

% Downsampling and Pre-processing
[ depth, rgb ] = preprocess_data( settings, depth, rgb);

%% Create random samples
disp('Creating sparse measurements..')
zGT = vec(depth); % vectorized version of the ground truth
[ samples ] = create_samples( settings, depth, rgb );
N = length(zGT);    % total number of pixels
K = length(samples);    % total number of measurements
height = size(depth,1);
width = size(depth,2);
% create sparse sampling matrix
Rfull = speye(N);
R = Rfull(samples, :);

%% create (possibly noisy) measurements
if settings.addNoise
    noise = settings.epsilon * (2*rand(K,1)-1);
else
    noise = zeros(K,1);
end
y = R * zGT + noise;    % measurement vector

%% Reconstruction
% naive linear interpolation
tic
Znaive = naive( depth, samples, y, settings );
time_naive = toc;
naive_error = norm(vec(Znaive) - zGT, 1) / N / 255 * 10; % avg error in meters
disp(sprintf('naive interpolation: average error = %.2gcm', 100*naive_error))

% our l1 reconstruction approach
tic
z = l1_reconstruction( height, width, R, y, settings);
time_l1 = toc;
rec_depth = reshape(z, height, width);
rec_error = norm(z - zGT, 1) / N / 255 * 10;    % avg error in meters
disp(sprintf('l1 reconstruction: average error = %.2gcm', 100*rec_error))

%% Visualization
sample_mask = zeros(size(depth));
sample_mask(samples) = ones(size(samples));
figure(1);
subplot(221); 
cMap=colormap('parula'); imagesc(uint8(depth)); 
axis image; axis off;
title('original depth')

subplot(222); 
colormap(cMap); imagesc(uint8(sample_mask)); 
axis image; axis off;
title('samples')

subplot(223); 
colormap(cMap);imagesc(uint8(rec_depth)); 
axis image; axis off;
title(['rec (err=', num2str(sprintf('%.2f', rec_error)), 'm)'])

subplot(224); 
colormap(cMap); imagesc(uint8(Znaive)); 
axis image; axis off;
title(['naive (err=', num2str(sprintf('%.2f', naive_error)), 'm)'])
drawnow

% figure(2);

%% Saving results
results.depth = depth;
results.rgb = rgb;
results.img_ID = img_ID;

results.samples = samples;
results.sample_mask = sample_mask;

results.rec_depth = rec_depth;
results.rec_error = rec_error;

results.Znaive = Znaive;
results.naive_error = naive_error;

results.time_l1 = time_l1;
results.time_naive = time_naive;


end