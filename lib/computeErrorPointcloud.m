function [ error_struct ] = computeErrorPointcloud( xyz_rec, xyz_ref, settings )
%computeErrorPointcloud evaluate reconstruction error in milimeters
% There are 5 error metrics: 
%   1. MAE (mean absolute error) on image plane
%   2. MSE (mean squared error) on image plane
%   3. RMSE (root mean squared error) on image plane
%   4. PSNR (peak signal-to-noise ratio) on image plane
%   5. normalized L2 norm of euclidean error in cartesian space

mat_diff = removeNaN(xyz_rec - xyz_ref);
X_diff = mat_diff(:,1);
Y_diff = mat_diff(:,2);
Z_diff = mat_diff(:,3);

count = length(X_diff);

%% 1. Mean Absolute Error
error_struct.mae = norm(X_diff, 1) / count ;

%% 2. Mean Square Error
squared_error = sum(X_diff.^2);
error_struct.mse = squared_error / count;

%% 3. Root Mean Square Error
error_struct.rmse = sqrt(error_struct.mse);

%% 4. Peak Signal-to-Noise Ratio
max_depth_gt = max(xyz_ref(:,1));
error_struct.psnr = 20*log10(max_depth_gt) - 10*log10(error_struct.mse);

%% 5. normalized L2 norm of error
euclidean_dist = sqrt(X_diff.^2 + Y_diff.^2 + Z_diff.^2);
error_struct.euclidean = sum(euclidean_dist) / count ;

end