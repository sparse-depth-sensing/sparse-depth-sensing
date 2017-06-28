function [ error_struct ] = computeErrorImage( img_rec, img_ref, settings )
%computeErrorImage evaluate reconstruction error in milimeters
% There are 4 error metrics: 
%   1. MAE (mean absolute error) on image plane
%   2. MSE (mean squared error) on image plane
%   3. RMSE (root mean squared error) on image plane
%   4. PSNR (peak signal-to-noise ratio) on image plane

count = prod(size(img_rec));
diff = img_rec(:) - img_ref(:);

%% 1. Mean Absolute Error
error_struct.mae = norm(diff, 1) / count ;

%% 2. Mean Square Error
error_struct.mse = mean(diff.^2);

%% 3. Root Mean Square Error
error_struct.rmse = sqrt(error_struct.mse);

%% 4. Peak Signal-to-Noise Ratio
max_depth_gt = max(img_ref(:));
error_struct.psnr = 20*log10(max_depth_gt) - 10*log10(error_struct.mse);

end