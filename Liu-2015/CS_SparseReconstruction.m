function [output, time] = CS_SparseReconstruction(Signal, Ground_Truth,SignalSampleMap)

addpath(genpath('Hawe_WT'));
% Percentage = 0.2; % will not be used.
iccv_setup

tic
for lev = 1:1
    % Select conjugate gradient methd
    CG_method   = 'HS';
    % Set convergence threshold
    l1min.delta_conv = 1e-6;
    
    for i = 1 % 1:2
         %  l1min.lambda  =0.01;
        conjugate_gradient(l1min, CG_method, Disp_mat, Ground_Truth);
        l1min.lambda    = l1min.lambda*.01;
        l1min.tvSmooth  = l1min.tvSmooth*.01;
        l1min.tv_method = 'iso';
    end
end

X = (real(Disp_mat*l1min.x));

output=double((X));
time = toc;