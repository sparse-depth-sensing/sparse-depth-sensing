function [ pc, depth ] = getSyntheticData( settings, id )
%getRawData Load .mat files that contain rgb and depth images, as welll as odometry information
%   Detailed explanation goes here

filename = sprintf('%s/%s/%03d.mat', getPath('data'), settings.dataset, id);
load(filename)

%% Metrics conversion
% convert from milimeters to meters
depth = double(depth) / 1000;   

%% Downsampling the images
if settings.subSample < 1
    depth = imresize(depth, settings.subSample, 'bilinear') ;
end

%% Construct the point cloud
scaleUpFactor = 0.1;

pc = depth2pcOrthogonal( depth, scaleUpFactor );

end

