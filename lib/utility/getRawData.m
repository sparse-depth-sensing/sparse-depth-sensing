function [ depth, rgb, odom, depth_orig ] = getRawData( settings, id )
%getRawData Load .mat files that contain rgb and depth images, as welll as odometry information
%   Detailed explanation goes here
filename = fullfile(getPath('data'), settings.dataset, sprintf('%03d.mat', id));
load(filename)

%% Metrics conversion
% convert from milimeters to meters
depth = double(depth) / 1000.0;

%% Remove invalid depth measurements
% this depends on the sensors (Kinect vs. Stereo)
mask_invalid = find(depth <= settings.min_depth | depth >= settings.max_depth);
if strcmp(settings.dataset, 'ZED')
  % too many NaN measurements from ZED, make them all equal to 10m for
  % simplicity
  depth(mask_invalid) = 10 * ones(length(mask_invalid), 1);
else
  depth(mask_invalid) = nan * ones(length(mask_invalid), 1);
end
depth_orig = depth;

%% cropBorder (for Kinect data only)
% the rgb images have two empty borders on the top and bottom
if settings.cropBorder
  % disp('cropping image.')
  depth = imageCropBorder( depth, settings, 'original' );
  depth_orig = imageCropBorder( depth_orig, settings, 'original' );
end

%% Downsampling the images
if settings.subSample < 1
  depth_orig = imresize(depth_orig, settings.subSample, 'nearest') ;
  depth = imresize(depth, settings.subSample, 'nearest') ;
  if exist('rgb', 'var')
    rgb = imresize(rgb, settings.subSample, 'nearest');
  else
    rgb = [];
  end
end

%% Odometry
if exist('Position', 'var') && exist('Theta', 'var')
  odom.Position = Position;
  % odom.Orientation = Orientation; % in quaternion representation
  
  % Theta is extracted from Orientation, for ease of use in 2D motion
  odom.Theta = Theta;
else
  odom.Position = [];
  odom.Theta = 0;
end


end