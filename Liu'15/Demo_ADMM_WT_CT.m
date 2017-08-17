%    
%     Demonstrating ADMM algorithm with combined WT and CT dictionary
%  
%     Lee-Kang (Lester) Liu and Stanley Chan
%     Copyright 2014
%     University of California, San Diego
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all
clear all
clc
sp=[ 0.05 0.10 0.15 0.2];

% access disparity data
c=cd('data');
gt_x0  = im2double(imread('Aloe_disp1_512.png'));
% downsample
% gt_x0 = imresize(gt_x0, 0.5);
x0 = gt_x0;
cd(c);

[rows cols] = size(x0);
% for itr = 1: length(sp)
for itr = 1
  
        figure(2);
        imshow(gt_x0)
    
        % Initialize parameters
        WTCTparam.wname            = 'db2';                % types of wavelet function
        WTCTparam.wlevel           = 2;                    % number of levels for wavelet transform
        WTCTparam.nlev_SD          = [5 6];                % directional filter partition numbers
        WTCTparam.smooth_func      = @rcos;                % smooth function for Lacian Pyramid
        WTCTparam.Pyr_mode         = 2;                    % reduneancy setting for the transformed coefficients
        WTCTparam.dfilt            = '9-7';                % 9-7 bior filter for directional filtering
        WTCTparam.lambda1          = 4e-5;                 % regularization parameter for L1_Wavelet term
        WTCTparam.lambda2          = 2e-4;                 % regularization parameter for L1_Contourlet term
        WTCTparam.beta             = 2e-3;                 % regularization parameter for totalvariation term
%         WTCTparam.max_itr          = 400;                  % maximum iteration for reconstruction
        WTCTparam.max_itr          = 100;                  % maximum iteration for reconstruction
        WTCTparam.tol              = 1e-5;                 % tolerance for stop condition
                
        % Set contourlet transform toolbox path
        addpath(genpath('ContourletSD\'));
         
        % uniformly random sampling map generation
        S        = (rand(rows, cols)<=sp(itr));
        b = S.*x0;
                
        % main algorithm for dense disparity reconstruction
        xout = ADMM_WT_CT(S,b,WTCTparam);
                
        eer = mean(((xout(:)-x0(:)).^2));
        MSE(itr)=eer;
                
end
MSE