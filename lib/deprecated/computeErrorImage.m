function [ avg_err ] = computeErrorImage( depth_rec, depth_truth )
%computeErrorImage Compute average reconstruction error in milimeters
%   Detailed explanation goes here

vec_rec = depth_rec(:);
vec_truth = depth_truth(:);

vec_diff = removeNaN(vec_rec - vec_truth);
avg_err = norm(vec_diff, 1) / length(vec_diff) ;
end

