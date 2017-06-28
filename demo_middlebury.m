close all; clear; clc
addpath(genpath('lib'))

%% Create settings for the demo
createSettings

% settings for solver
settings.solver = 'nesta';         % choose either 'cvx' or 'nesta'

% settings for sampling
settings.subSample = 0.5;          % subsample original image to reduce its size
settings.percSamples = 0.02;       % perceptage of samples relative to image size
settings.sampleMode = 'uniform';   % choose from 'uniform', 'harris-feature', 'regular-grid'
settings.doAddNeighbors = false;   % set to true, if we want to sample neighboring pixels

%% Start the loop
middleburyDatasetPath = fullfile(getPath('data'), 'middlebury');
listing = dir(middleburyDatasetPath);
for i = 3 : length(listing)
  %% Load the images
  % Modify this part for your own depth/disparity images
  disparityName = listing(i).name;
  disparityPath = fullfile(middleburyDatasetPath, disparityName);
  disparityImage = imread(disparityPath);
  disparityImage = im2double(disparityImage);
  
  disp('****************************************************************')
  disp(disparityName)
  
  %% Downsampling the images
  if settings.subSample < 1
    disparityImage = imresize(disparityImage, settings.subSample, 'nearest') ;
  end
  
  %% Create measurements
  xGT = disparityImage(:);
  samples = createSamples( disparityImage, [], settings );
  N = length(xGT);    % total number of valid 3D points
  K = length(samples);    % total number of measurements
  
  height = size(disparityImage,1);
  width = size(disparityImage,2);
  
  % create sparse sampling matrix
  Rfull = speye(N);
  sampling_matrix = Rfull(samples, :);
  img_sample = nan * ones(size(disparityImage));
  img_sample(samples) = 255 * xGT(samples);
  measured_vector = sampling_matrix * xGT;
  disp(sprintf(' --- samples (number=%3d, percentage=%.2g%%)', K, 100*K/N));
  
  %% algorithm: naive
  tic
  naive.reconstruction = linearInterpolationOnImage( height, width, samples, measured_vector );
  naive.time = toc;
  naive.error = computeErrorImage(naive.reconstruction, disparityImage);
  disp(sprintf(' --- %8s: time=%.5gms, mae=%.3g, rmse=%.3g, mse=%.3g, psnr=%.3gdB (high is good)', ...
    'naive', 1000*naive.time, naive.error.mae, naive.error.rmse, naive.error.mse, naive.error.psnr))
  
  %% algorithm: L1-diag
  settings.useDiagonalTerm = true;
  initial_guess = naive.reconstruction;
  tic
  x_L1_diag = l1ReconstructionOnImage( height, width, sampling_matrix, ...
    measured_vector, settings, samples, initial_guess(:));
  L1_diag.time = toc;
  L1_diag.reconstruction = reshape(x_L1_diag, height, width);
  L1_diag.error = computeErrorImage(L1_diag.reconstruction, disparityImage);
  disp(sprintf(' --- %8s: time=%.5gms, mae=%.3g, rmse=%.3g, mse=%.3g, psnr=%.3gdB (high is good)', ...
    'L1-diag', 1000*L1_diag.time, L1_diag.error.mae, L1_diag.error.rmse, L1_diag.error.mse, L1_diag.error.psnr))
  
  %% visualization
  figure(i);
  subplot(221); imshow(disparityImage); title('ground truth disparity');
  
  subplot(222); 
  imshow(img_sample); 
  titleString = sprintf('%.3g%% samples', 100*settings.percSamples);
  title(titleString);
  
  subplot(223); 
  imshow(naive.reconstruction);
  titleString = {'naive', ...
      ['mae=', sprintf('%.3gpixel', naive.error.mae)], ...
      ['rmse=', sprintf('%.3gpixel', naive.error.rmse)]};
  title(titleString);
  
  subplot(224); 
  imshow( L1_diag.reconstruction);
  titleString = {'L1-diag', ...
      ['mae=', sprintf('%.3gpixel', L1_diag.error.mae)], ...
      ['rmse=', sprintf('%.3gpixel', L1_diag.error.rmse)]};
  title(titleString);
  
  drawnow;
  
end