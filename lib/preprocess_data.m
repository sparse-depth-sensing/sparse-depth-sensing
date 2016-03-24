function [ depth, rgb ] = preprocess_data( settings, depth, rgb)
%PRE Summary of this function goes here
%   Detailed explanation goes here

%% If depth images have 3 duplicate channels, just use one of them.
depth = double(depth);
if size(depth,3) > 1
    depth = depth(:,:,1);
end

%% Pre-processing of NaN values (a hacky workaround, need a more solid fix)
% we scale all valid values to the range of (0,240]
valid_mask = depth > 0; 
depth(valid_mask) = depth(valid_mask) * 240/255;

% for simplicity, we make all invalid values 255
depth = 255 * (1-valid_mask) + depth .* valid_mask;

%% Down-sample images
depth = imresize(depth, settings.subSample, 'nearest'); % downsample image (before scaling)
rgb = imresize(rgb, settings.subSample, 'nearest');

%% Visualization
if settings.isDebug
    figure;
    imshow(depth/255,'InitialMagnification',300); 
    title('Pre-processed Depth Image');
end

end

