function [ smoothed ] = smoothing( depth, settings )
%SMOOTHING Summary of this function goes here
%   Detailed explanation goes here

smoothed = depth;

%% replace invalid data with statistical mean
mask_invalid = find(depth <= settings.min_depth | depth >= settings.max_depth);
mask_valid = setdiff([1:length(depth(:))], mask_invalid);
smoothed(mask_invalid) = mean(depth(mask_valid)) * ones(length(mask_invalid), 1);
% smoothed(mask_invalid) = big_M * ones(length(mask_invalid), 1);

figure;
subplot(131);imshow(toRangeZeroOne(depth));title('GT')
subplot(132);imshow(toRangeZeroOne(smoothed));title('Replacing Invalid Points')
% 
%     sigma = 0.5;
%     smoothed = imgaussfilt(depth, sigma);

smoothed = medfilt2(smoothed);


subplot(133);imshow(toRangeZeroOne(smoothed));title('Median Filtered')

end

