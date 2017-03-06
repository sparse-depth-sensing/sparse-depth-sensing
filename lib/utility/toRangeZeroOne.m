function [ mat_out ] = toRangeZeroOne(mat_in, settings)
%TORANGEZEROONE Summary of this function goes here
%   Detailed explanation goes here

% minVal = min(mat_in(:));
% maxVal = max(mat_in(:));

mat_out = (mat_in - settings.min_depth) / (settings.max_depth - settings.min_depth);

end

