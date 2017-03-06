close all; clear; clc;
addpath('..')
settings.path = '../../data/lab1';            % test_data, lids_floor6, lab1, ZED
addpath(settings.path)
img_ID = 310;

settings.subSample = 0.2;               % subsample original image, to reduce its size
settings.chopImage = false;
settings.min_depth = 0;  
settings.max_depth = 8;  

%% Load Data
[ depth, rgb, odometry, invalid_data ] = load_and_process_data( settings, img_ID );
odometry.Position.X = 0;
odometry.Position.Y = 0;
odometry.Theta = 0;    
pc_truth = depth2pc(depth, rgb, odometry, settings);

figure;
subplot(121); imshow(rgb)
subplot(122); imshow(toRangeZeroOne(depth))

% [ Y_stretched, Z_stretched ] = stretch( height, width, Y, Z, settings )

%% Stretching
[height, width] = size(depth);
Y = pc_truth.Location(:, 2);
Z = pc_truth.Location(:, 3);

settings.stretch.delta_y = 0;
settings.stretch.delta_z = settings.stretch.delta_y;
[ Y_stretched, Z_stretched ] = stretch( height, width, Y, Z, settings );
xyz_stretched = pc_truth.Location;
xyz_stretched(:, [2,3]) = [ Y_stretched, Z_stretched ];
pc_stretched = pointCloud(xyz_stretched, 'Color', pc_truth.Color);

figure;
subplot(121); pcshow(pc_truth); xlabel('x'); ylabel('y'); zlabel('z');
subplot(122); pcshow(pc_stretched); xlabel('x'); ylabel('y'); zlabel('z');