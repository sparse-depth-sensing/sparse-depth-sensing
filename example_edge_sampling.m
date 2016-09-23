close all; clear; clc;
addpath('lib')

%% Settings
settings.subSample = 0.2;         % subsample original image, to reduce its size
settings.isDebug = false;         % show debug information if true

settings.sampleMode = 'rgb_edges';  % uniform, rgb_edges
settings.percEdges = 1;           % percentage of edge samples used, if sampleMode == rgb_edges

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

%% Create folder for saving results
output_folder = sprintf('results/subSample=%f.sampleMode=%s.percSamples=%f', ...
    settings.subSample, settings.sampleMode, settings.percEdges);
mkdir(output_folder);

%% Loop over all data
for img_ID = 375 : 10: 1400
    disp('========================')
    disp(['Image ID: ', num2str(img_ID)]);
    
    results_filename = [output_folder, '/', num2str(img_ID), '.mat'];
    if exist(results_filename, 'file') == 2
        disp('File already exists. Skip this one.')
        continue;
    else
        results = sparse_reconstruction(img_ID, settings);
        save(results_filename, 'results');
    end
end
