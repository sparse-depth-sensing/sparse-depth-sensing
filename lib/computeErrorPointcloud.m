function [ error_cartesian ] = computeErrorPointcloud( xyz_rec, xyz_ref, settings )
%computeErrorPointcloud Compute average reconstruction error in milimeters
%   There are two error metrics: the first one computes the error along x
%   only; the second one computes the euclidean distances 

mat_diff = removeNaN(xyz_rec - xyz_ref);
X_diff = mat_diff(:,1);
Y_diff = mat_diff(:,2);
Z_diff = mat_diff(:,3);

count = length(X_diff);
error_cartesian.depth_only = norm(X_diff, 1) / count ;

euclidean_dist = sqrt(X_diff.^2 + Y_diff.^2 + Z_diff.^2);
error_cartesian.euclidean = norm(euclidean_dist, 1) / count ;
% disp(sprintf('The number of valid reconstruction is %d, while the original N = %d', ...
%     count, pc_ref.Count))
end