%    
%     Demonstrating ADMM algorithm with single WT dictionary
%  
%     Lee-Kang (Lester) Liu and Stanley Chan
%     Copyright 2014
%     University of California, San Diego
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all
clear all
clc
sp=[0.2];

% access disparity data
gt_x0  = im2double(imread(fullfile('..', 'data', 'middlebury', 'Aloe_disp1_512.png')));
x0 = gt_x0;
[rows cols] = size(x0);
for itr = 1:length(sp)
    % Initialize parameters
    param.wname            = 'db2';       % types of wavelet function
    param.wlevel           = 2;           % number of levels for wavelet transform
    param.lambda1          = 4e-5;        % regulization parameter for L1_Wavelet term
    param.beta             = 2e-3;        % regulization parameter for totalvariation term
    param.max_itr          = 400;         % maximum iteration for reconstruction
    param.tol              = 1e-5;        % tolerance for stop condition
    
    % uniformly random sampling map generation
    S = (rand(rows, cols)<=sp(itr));
    b = S.*x0;
    
    % ADMM using wavelet dictionary
    xout = ADMM_WT(S,b,param);
    
    eer = mean(((xout(:)-x0(:)).^2))
    MSE(itr)=eer;
end
