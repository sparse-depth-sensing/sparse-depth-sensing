warning('off','all')

%% Settings
if ~isfield(settings, 'show_figures')
    settings.show_figures = true; 
end

if ~isfield(settings, 'show_pointcloud')
    settings.show_pointcloud = false; 
end

if ~isfield(settings, 'show_debug_info')
    settings.show_debug_info = true;       
end

%% Dataset
if ~isfield(settings, 'dataset')
    settings.dataset = 'lids_floor6';   % test_data, lids_floor6, lab1, ZED, pwlinear_nbCorners=10
end
% addpath(sprintf('%s/%s', getPath('data'), settings.dataset));
    
if ~isKinectDataset( settings )
    settings.cropBorder = false;    % no cropping of images since we are not using Kinect data 
    settings.min_depth = 0;        % a large min_depth leads to most of the depth values being NaN  
    settings.max_depth = inf;  
else
    settings.cropBorder = true;    % cropping of images since we are using Kinect data 
    settings.crop.top = 40;    
    settings.crop.bottom = 400;

    % sensing range - 
    % The Kinect v2 can physically sense depth at 8 meters. So you can sense 
    % objects at 5M. However 4.5M  is where you can reliably track body joints. 
    % Anything beyond 4.5 meters your body tracking yields inconsistent results.
    settings.min_depth = 0;  
    settings.max_depth = 8;  
end

% do stretching for the new reconstruction algorithm
if ~isfield(settings, 'stretch')
    settings.stretch.flag = false;
    settings.stretch.delta_y = 0;
    settings.stretch.delta_z = settings.stretch.delta_y;
end
    
%% Sampling
if ~isfield(settings, 'subSample')
    settings.subSample = 0.1;
end

if ~isfield(settings, 'percSamples')
    settings.percSamples = 0.01;
end

if ~isfield(settings, 'doAddNeighbors')
    settings.doAddNeighbors = false;
end

if ~isfield(settings, 'sampleMode')
    settings.sampleMode = 'regular-grid';        % 'uniform', 'regular-grid', 'rgb-edges', 'depth-edges'
end

if ~isfield(settings, 'addNoise')
    settings.addNoise = false;              % set to true if you want to add noise into the measurements
end

%% Solver
if ~isfield(settings, 'solver')
    settings.solver = 'nesta';              % 'cvx', 'nesta'
end

if ~isfield(settings, 'mu')
    settings.mu = 1e-3;
end

if ~isfield(settings, 'epsilon')
    settings.epsilon = 0;
end


% whether the point cloud is processed in the world frame or in the body
% frame
settings.pc_frame = 'body';

%% Metrics
if ~isfield(settings, 'use_naive')
    settings.use_naive = true;
end

if ~isfield(settings, 'use_L1')
    settings.use_L1 = true;
end

if ~isfield(settings, 'use_L1_diag')
    settings.use_L1_diag = true;
end

if ~isfield(settings, 'use_L1_cart')
    settings.use_L1_cart = true;
end


% uses Mosek solver if installed with academic license in CVX
try
    cvx_solver mosek 
    % cvx_save_prefs
end

if ~isfield(settings, 'markersize')
    settings.markersize = 200;
end