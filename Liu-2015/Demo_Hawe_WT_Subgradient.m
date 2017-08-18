% This code is for testing running time of sub_gradient algorithm
% for single wavelet dictionary
%
%    
%     Lee-Kang (Lester) Liu and Stanley Chan
%     Copyright 2014
%     University of California, San Diego
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all
clear all
clc
sp=[ 0.05 ];

% access disparity data
gt_x0  = im2double(imread(fullfile('..', 'data', 'middlebury', 'Aloe_disp1_512.png')));
x0 = gt_x0;
[rows cols] = size(x0);

for spID=1:length(sp)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    clearvars -except MSE x0  spID rows cols sp;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % uniformly random sampling map generation
    S = (rand(rows, cols)<=sp(spID));
    b = S.*x0;
    
    % main algorithm
    xout = CS_SparseReconstruction(b, x0,S);
    eer = mean((xout(:)-x0(:)).^2);
    MSE(spID) = 10*log10(255^2/eer);
    
    imshow(xout);
    
end
