function [ depth, rgb ] = load_image(DATASET, ID)
%LOAD_IMAGE Load images from our dataset

if strcmp(DATASET, 'zed')
    msg = sprintf('%04d', ID);
    depthName = ['data/zed/depth_scaled/depth_scaled_', msg, '.png'];
    rgbName = ['data/zed/rgb/rgb_', msg, '.png'];
elseif strcmp(DATASET, 'gazebo')
    msg = sprintf('%03d', ID);
    depthName = ['data/gazebo/depth/depth', msg, '.png'];
    rgbName = ['data/gazebo/rgb/rgb', msg, '.png'];
else
    error(['Incorrect dataset: ', DATASET]);
end

try
    depth = imread(depthName);
    rgb = imread(rgbName);
catch
    % warning(['File ', rgbName, ' does not exist.'])
    depth = [];
    rgb = [];
end

