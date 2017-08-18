close all; clear; clc
addpath(genpath('lib'))
addpath(genpath('Liu-2015'))

%% Create settings for the demo
createSettings

% settings for solver
settings.solver = 'nesta';         % choose either 'cvx' or 'nesta'

% settings for sampling
settings.subSample = 1;          % subsample original image to reduce its size
settings.percSamples = 0.05;       % perceptage of samples relative to image size
settings.sampleMode = 'regular-grid';   % choose from 'uniform', 'harris-feature', 'regular-grid'
settings.doAddNeighbors = false;   % set to true, if we want to sample neighboring pixels

output_folder = fullfile(getPath('results'), 'middlebury');
output_folder = fullfile(output_folder, ...
  sprintf('subSample=%g.percSamples=%g.sampleMode=%s', ...
    settings.subSample, settings.percSamples, settings.sampleMode) ...
  );
mkdir(output_folder)

%% Create settings for Liu'2015
WTCTparam.wname            = 'db2';                % types of wavelet function
WTCTparam.wlevel           = 2;                    % number of levels for wavelet transform
WTCTparam.nlev_SD          = [5 6];                % directional filter partition numbers
WTCTparam.smooth_func      = @rcos;                % smooth function for Lacian Pyramid
WTCTparam.Pyr_mode         = 2;                    % reduneancy setting for the transformed coefficients
WTCTparam.dfilt            = '9-7';                % 9-7 bior filter for directional filtering
WTCTparam.lambda1          = 4e-5;                 % regularization parameter for L1_Wavelet term
WTCTparam.lambda2          = 2e-4;                 % regularization parameter for L1_Contourlet term
WTCTparam.beta             = 2e-3;                 % regularization parameter for totalvariation term
%　WTCTparam.max_itr          = 400;                  % maximum iteration for reconstruction
WTCTparam.max_itr          = 100;                  % maximum iteration for reconstruction
WTCTparam.tol              = 1e-5;                 % tolerance for stop condition
WTCTparam.verbose          = false;

%% Start the loop
middleburyDatasetPath = fullfile(getPath('data'), 'middlebury');
listing = dir(middleburyDatasetPath);
for i = 1 : length(listing)
  if strcmp(listing(i).name,'.') || strcmp(listing(i).name,'..')
    continue;
  end
  
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
  img_sample = zeros(size(disparityImage));
  img_sample(samples) = 255 * xGT(samples);
  measured_vector = sampling_matrix * xGT;
  disp(sprintf(' --- samples (number=%3d, percentage=%.2g%%)', K, 100*K/N));
  
  % Liu'2015 uses a different format
  S = zeros(size(disparityImage));
  S(samples) = 1;
  b = S .* disparityImage;
  
  %% algorithm: naive
  tic
  naive.reconstruction = linearInterpolationOnImage( height, width, samples, measured_vector );
  naive.time = toc;
  naive.error = computeErrorImage(naive.reconstruction, disparityImage);
  disp(sprintf(' --- %8s: time=%.5gms, mae=%.3g, rmse=%.3g, mse=%.3g, psnr=%.3gdB (high is good)', ...
    'naive', 1000*naive.time, naive.error.mae, naive.error.rmse, naive.error.mse, naive.error.psnr))
  
  %% algorithm: Hawe'11
  [Hawe.reconstruction, Hawe.time] = CS_SparseReconstruction(b, disparityImage, S);
  Hawe.error = computeErrorImage(Hawe.reconstruction, disparityImage);
  disp(sprintf(' --- %8s: time=%.5gms, mae=%.3g, rmse=%.3g, mse=%.3g, psnr=%.3gdB (high is good)', ...
    'Hawe-11', 1000*Hawe.time, Hawe.error.mae, Hawe.error.rmse, Hawe.error.mse, Hawe.error.psnr))
  
  %% algorithm: L1-diag
  settings.useDiagonalTerm = true;
  initial_guess = naive.reconstruction;
  [x_L1_diag, L1_diag.time] = l1ReconstructionOnImage( height, width, sampling_matrix, ...
    measured_vector, settings, samples, initial_guess(:));
  L1_diag.reconstruction = reshape(x_L1_diag, height, width);
  L1_diag.error = computeErrorImage(L1_diag.reconstruction, disparityImage);
  disp(sprintf(' --- %8s: time=%.5gms, mae=%.3g, rmse=%.3g, mse=%.3g, psnr=%.3gdB (high is good)', ...
    'L1-diag', 1000*L1_diag.time, L1_diag.error.mae, L1_diag.error.rmse, L1_diag.error.mse, L1_diag.error.psnr))
  
  %% algorithm: Liu'15
  [Liu.reconstruction, Liu.time] = ADMM_WT_CT(S,b,WTCTparam);
  Liu.error = computeErrorImage(Liu.reconstruction, disparityImage);
  disp(sprintf(' --- %8s: time=%.5gms, mae=%.3g, rmse=%.3g, mse=%.3g, psnr=%.3gdB (high is good)', ...
    'Liu-15', 1000*Liu.time, Liu.error.mae, Liu.error.rmse, Liu.error.mse, Liu.error.psnr))
  
  %% visualization
  figure(i);
  set(gcf, 'Color', 'White')   % set white background
  set(gcf, 'Position', [0 0 1280 960]); %<- Set size
  set(gca, 'fontsize', 15)
  
  subplot(231); 
  imshow(disparityImage); 
  title('ground truth disparity');
  
  subplot(232); 
  imshow(img_sample); 
  titleString = sprintf('%.3g%% samples', 100*settings.percSamples);
  title(titleString);

  subplot(233); 
  imshow(naive.reconstruction);
  titleString = {'naive', ...
      ['mae=', sprintf('%.3gpixel', naive.error.mae)], ...
      ['rmse=', sprintf('%.3gpixel', naive.error.rmse)]};
  title(titleString);

  subplot(234); 
  imshow(Hawe.reconstruction);
  titleString = {'Hawe-2011', ...
      ['mae=', sprintf('%.3gpixel', naive.error.mae)], ...
      ['rmse=', sprintf('%.3gpixel', naive.error.rmse)]};
  title(titleString);
  
  subplot(235); 
  imshow(Liu.reconstruction);
  titleString = {'Liu-2015', ...
      ['mae=', sprintf('%.3gpixel', Liu.error.mae)], ...
      ['rmse=', sprintf('%.3gpixel', Liu.error.rmse)]};
  title(titleString);
  
  
  subplot(236); 
  imshow( L1_diag.reconstruction);
  titleString = {'L1-diag', ...
      ['mae=', sprintf('%.3gpixel', L1_diag.error.mae)], ...
      ['rmse=', sprintf('%.3gpixel', L1_diag.error.rmse)]};
  title(titleString);
  
  drawnow;
  
  %% Saving to result folder
  img_folder = fullfile(output_folder, disparityName(1:end-14));
  mkdir(img_folder)
  imwrite(Liu.reconstruction, fullfile(img_folder, 'Liu.png'))
  imwrite(Hawe.reconstruction, fullfile(img_folder, 'Hawe.png'))
  imwrite(naive.reconstruction, fullfile(img_folder, 'naive.png'))
  imwrite(L1_diag.reconstruction, fullfile(img_folder, 'L1_diag.png'))
  imwrite(img_sample, fullfile(img_folder, 'samples.png'))
  save(fullfile(img_folder, 'results.mat'), 'settings', ...
    'L1_diag', 'Hawe', 'naive', 'Liu', 'K', 'samples', 'N', 'WTCTparam');
end