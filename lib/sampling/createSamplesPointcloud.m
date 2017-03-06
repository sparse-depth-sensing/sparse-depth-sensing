function [ samples,  pc_samples] = createSamplesPointcloud( depth, rgb, odom, settings )
%GET_SAMPLE_POINTCLOUDS Summary of this function goes here
%   Detailed explanation goes here

%% Create random samples
samples = createSamples( depth, rgb, settings );
xGT = depth(:);  
N = length(xGT);    % total number of valid 3D points
K = length(samples);    % total number of measurements

height = size(depth,1);
width = size(depth,2);

% create sparse sampling matrix
Rfull = speye(N);
% sampling_matrix = Rfull(samples, :);
img_sample = nan * ones(size(depth));
img_sample(samples) = xGT(samples);

% create point cloud
[pc_samples] = depth2pc(img_sample, rgb, odom, settings, false);


end

