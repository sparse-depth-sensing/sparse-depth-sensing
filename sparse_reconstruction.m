% This is the main procedure for sparse depth reconstruction. We load depth
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
[ depth, rgb ] = load_image(img_ID);
if size(depth, 1) == 0  % file does not exist
    warning(['File ', num2str(img_ID), ' does not exist. Skipped.'])
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
Znaive = naive( depth, samples, y, settings );
naive_error = norm(vec(Znaive) - zGT, 1) / N / 255 * 10; % avg error in meters
disp(['naive: average error = ', num2str(naive_error)])

% our l1 reconstruction approach
z = l1_reconstruction( height, width, R, y, settings);
rec_depth = reshape(z, height, width);
rec_error = norm(z - zGT, 1) / N / 255 * 10;    % avg error in meters
disp(['l1 reconstruction: average error = ', num2str(rec_error)])

%% Visualization
sample_mask = zeros(size(depth));
sample_mask(samples) = ones(size(samples));
figure(1);
subplot(221); imshow(depth/255); title('original depth')
subplot(222); imshow(sample_mask); title('samples')
subplot(223); imshow(rec_depth/255); title(['rec (err=', num2str(sprintf('%.2f', rec_error)), 'm)'])
subplot(224); imshow(Znaive/255); title(['naive (err=', num2str(sprintf('%.2f', naive_error)), 'm)'])
drawnow