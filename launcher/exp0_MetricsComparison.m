addpath(genpath(fullfile('..', 'lib')))

%% Create settings for the demo
createSettings

% settings for solver
settings.solver = 'cvx';         % choose either 'cvx' or 'nesta'
if strcmp(settings.solver, 'cvx')
    cvx_solver mosek
    cvx_save_prefs
end

% settings for objective functions (algorithms)
settings.use_naive = true;
settings.use_L1 = true;
settings.use_L1_diag = true;
settings.use_L1_cart = true;
settings.use_L1_inv_diag = true;

% settings for sampling
settings.subSample = 0.2;          % subsample original image to reduce its size
settings.percSamples = 0.01;       % perceptage of samples relative to image size
settings.sampleMode = 'regular-grid';   % choose from 'uniform', 'harris-feature', 'regular-grid'
settings.doAddNeighbors = false;   % set to true, if we want to sample neighboring pixels

%% Run on all datasets
run_dataset('ZED', settings);
run_dataset('lids_floor6', settings );
run_dataset('lids_floor7', settings );
run_dataset('38_floor3', settings );
run_dataset('39_floor3', settings );
run_dataset('34_floor3', settings );
run_dataset('36_floor3', settings );
run_dataset('stata_floor1', settings );
run_dataset('32_144', settings );