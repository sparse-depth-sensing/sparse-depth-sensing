function [ depth, rgb ] = load_image(ID)
%LOAD_IMAGE Load images from our dataset

msg = sprintf('%04d', ID);
depthName = ['data/depth_scaled/depth_scaled_', msg, '.png'];
rgbName = ['data/rgb/rgb_', msg, '.png'];

try
    depth = imread(depthName);
    rgb = imread(rgbName);
catch
    % warning(['File ', rgbName, ' does not exist.'])
    depth = [];
    rgb = [];
end

