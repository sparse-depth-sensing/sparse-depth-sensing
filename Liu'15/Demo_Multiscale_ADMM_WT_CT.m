%    
%     Demonstrating multiscale ADMM algorithm with combined WT and CT dictionaries
%  
%     Lee-Kang (Lester) Liu and Stanley Chan
%     Copyright 2014
%     University of California, San Diego
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


close all
clear all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sp=[ 0.05 0.10 0.15 0.2];

PSNR = zeros(size(sp));
P_Bad_Pixel = zeros(size(sp));

% access disparity data
gt_x0  = im2double(imread(fullfile('..', 'data', 'middlebury', 'Aloe_disp1_512.png')));
x0 = gt_x0;
[rows cols] = size(x0);

for itr=1:length(sp)
    
    % uniformly random sampling map generation
    S = (rand(rows, cols)<=sp(itr));
    b = S.*x0;
    
    % main algorithm for dense disparity reconstruction
    xout = ADMM_outer(S,b);
 
    eer = mean(((xout(:)-x0(:)).^2));
    MSE(itr)=eer;

end
