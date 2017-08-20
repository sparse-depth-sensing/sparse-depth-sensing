close all; clear; clc
addpath(genpath('lib'))
addpath(genpath('Liu-2015'))

%% Create settings for the demo
createSettings

% settings for solver
settings.solver = 'nesta';         % choose either 'cvx' or 'nesta'
settings.mu = 0.1;
settings.useDiagonalTerm = true;

% settings for sampling
settings.subSample = 0.5;          % subsample original image to reduce its size
settings.percSamples = 5 / 100;       % perceptage of samples relative to image size
settings.sampleMode = 'uniform';   % choose from 'uniform', 'harris-feature', 'regular-grid'

output_folder = fullfile(getPath('results'), 'middlebury');
output_folder = fullfile(output_folder, ...
  sprintf('mu=%.subSample=%g.percSamples=%g.sampleMode=%s', ...
    settings.mu, settings.subSample, settings.percSamples, settings.sampleMode) ...
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
  height = size(disparityImage,1);
  width = size(disparityImage,2);
  
  xGT = disparityImage(:);
  
  S = ( rand(height, width) <= settings.percSamples );
  b = S .* disparityImage;
  
  samples = find(S > 0);
%   samples = createSamples( disparityImage, [], settings );
  N = length(xGT);    % total number of valid 3D points
  K = length(samples);    % total number of measurements
  
  % create sparse sampling matrix
  Rfull = speye(N);
  sampling_matrix = Rfull(samples, :);
  img_sample = zeros(size(disparityImage));
  img_sample(samples) = xGT(samples);
  measured_vector = sampling_matrix * xGT;
  disp(sprintf(' --- samples (number=%3d, percentage=%.2g%%)', K, 100*K/N));
   
%   % Liu'2015 uses a different format
%   S = zeros(size(disparityImage));
%   S(samples) = 1;
%   b = S .* disparityImage;
  
  %% algorithm: Hawe'11
  [Hawe.reconstruction, Hawe.time] = CS_SparseReconstruction(b, disparityImage, S);
  Hawe.error.psnr = psnr(disparityImage, Hawe.reconstruction);
  disp(sprintf(' --- %8s: time=%.5gms, psnr=%.3gdB (high is good)', ...
    'Hawe-11', 1000*Hawe.time, Hawe.error.psnr))
  
  %% algorithm: Liu'15
  [Liu.reconstruction, Liu.time] = ADMM_WT_CT(S,b,WTCTparam);
  Liu.error.psnr = psnr(disparityImage, Liu.reconstruction);
  disp(sprintf(' --- %8s: time=%.5gms, psnr=%.3gdB (high is good)', ...
    'Liu-15', 1000*Liu.time, Liu.error.psnr))
  
  %% algorithm: naive
  tic
  naive.reconstruction = linearInterpolationOnImage( height, width, samples, measured_vector );
  naive.time = toc;
  naive.error.psnr = psnr(disparityImage, naive.reconstruction);
  disp(sprintf(' --- %8s: time=%.5gms, psnr=%.3gdB (high is good)', ...
    'naive', 1000*naive.time, naive.error.psnr))
  
  %% algorithm: L1-diag
  initial_guess = img_sample(:);
  [x_L1_diag, L1_diag.time] = l1ReconstructionOnImage( height, width, sampling_matrix, ...
    measured_vector, settings, samples, initial_guess(:));
  L1_diag.reconstruction = reshape(x_L1_diag, height, width);
  L1_diag.error.psnr = psnr(disparityImage, L1_diag.reconstruction);
  disp(sprintf(' --- %8s: time=%.5gms, psnr=%.3gdB (high is good)', ...
    'L1-diag', 1000*L1_diag.time, L1_diag.error.psnr))
  
  %% visualization
  figure(i);
  set(gcf, 'Color', 'White')   % set white background
  set(gcf, 'Position', [0 0 1280 960]); %<- Set size
  set(gca, 'fontsize', 15)
  
  subplot(231); 
  imshow(disparityImage); 
  title('ground truth disparity');
  
  subplot(232); 
  img_sample(samples) = 255;
  imshow(img_sample); 
  titleString = sprintf('%.3g%% samples', 100*settings.percSamples);
  title(titleString);

  subplot(233); 
  imshow(naive.reconstruction);
  titleString = {'naive', ...
      ['psnr=', sprintf('%.3g db', naive.error.psnr)]};
  title(titleString);

  subplot(234); 
  imshow(Hawe.reconstruction);
  titleString = {'Hawe-2011', ...
      ['psnr=', sprintf('%.3g db', Hawe.error.psnr)]};
  title(titleString);
  
  subplot(235); 
  imshow(Liu.reconstruction);
  titleString = {'Liu-2015', ...
      ['psnr=', sprintf('%.3g db', Liu.error.psnr)]};
  title(titleString);
  
  
  subplot(236); 
  imshow( L1_diag.reconstruction);
  titleString = {'L1-diag', ...
      ['psnr=', sprintf('%.3g db', L1_diag.error.psnr)]};
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