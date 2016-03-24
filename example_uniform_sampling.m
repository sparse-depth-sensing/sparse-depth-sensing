close all; clear; clc;
addpath('lib')

%% Settings
settings.subSample = 0.2;         % subsample original image, to reduce its size
settings.isDebug = false;         % show debug information if true

settings.sampleMode = 'uniform';  % uniform, rgb_edges
settings.percSamples = 0.02;      % percentage of uniform random samples used, if sampleMode == uniform

settings.doAddNeighbors = true;   % set to true if neighbors of samples are also included
settings.useDiagonalTerm = true;  % minimize the diagonal 2nd-derivative term

settings.addNoise = false;        % set to true if you want to add noise into the measurements
settings.epsilon = 0.1;           % epsilon is the standard deviation of the random noise

settings.isBounded = true;        % set to true if bound the range of reconstruction (10 meters max)
settings.maxValue = 255;          % 10 meters correspond to value 255 in the scaled depth images.

% uses Mosek solver if installed with academic license in CVX
try
    cvx_solver mosek 
    cvx_save_prefs
end

%% Loop over all data
for img_ID = 375 : 10: 1400
    disp('========================')
    disp(['Image ID: ', num2str(img_ID)]);
    
    sparse_reconstruction
end
