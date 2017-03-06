function [ pc ] = depth2pcOrthogonal( depth, scaleUpFactor )
%DEPTH2PCORTHOGONAL Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
    scaleUpFactor = 0.1;    % a constant scale up factor
end

[height, width] = size(depth);

X = depth(:);
nbPoints = length(X);
[Y, Z] = meshgrid(1:height, 1:width);

xyzPoints = zeros(nbPoints, 3);
xyzPoints(:, 1) = X;
xyzPoints(:, 2) = scaleUpFactor * Y(:) ;
xyzPoints(:, 3) = scaleUpFactor * Z(:);

pc = pointCloud(xyzPoints);
end

