function [ flag_pass ] = test_pc_and_image_projections( )
close all
tolerance = 1e-5;
flag_pass = true;

%% Settings
addpath('..')
settings.subSample = 1;
settings.show_debug_info = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Get First Data
settings.path = '../../data/lab1';            % test_data, lids_floor6, lab1, ZED
img_ID = 50;
addpath(settings.path)
[ depth, rgb, odometry ] = load_and_process_data( settings, img_ID );

if settings.show_debug_info
    figure(1);
    subplot(221); imshow(toRangeZeroOne(depth)); title('Depth Raw'); drawnow
    subplot(222); imshow(rgb); title('RGB Raw'); drawnow
end

%% Create Point Cloud
pc = depth2pc(depth, rgb, odometry, settings);
if settings.show_debug_info
    figure(2); pcshow(pc); drawnow
end

%% Perspective Projection
[ depth_proj, rgb_proj ] = pc2images( pc, odometry, settings );
if settings.show_debug_info
    figure(1);
    subplot(223); imshow(toRangeZeroOne(depth_proj)); title('Depth Projected'); drawnow
    subplot(224); imshow(rgb_proj); title('RGB Projected'); drawnow
end

%% Compute Error
error = compute_error_from_image(depth_proj, depth, settings)
if error > tolerance
    flag_pass = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Get Second Data
settings.path = '../../data/ZED';            % test_data, lids_floor6, lab1, ZED
img_ID = 10;
addpath(settings.path)
[ depth, rgb, odometry ] = load_and_process_data( settings, img_ID );

if settings.show_debug_info
    figure(3);
    subplot(221); imshow(toRangeZeroOne(depth)); title('Depth Raw'); drawnow
    subplot(222); imshow(rgb); title('RGB Raw'); drawnow
end

%% Create Point Cloud
pc = depth2pc(depth, rgb, odometry, settings);
if settings.show_debug_info
    figure(4); pcshow(pc); drawnow
end

%% Perspective Projection
[ depth_proj, rgb_proj ] = pc2images( pc, odometry, settings );
if settings.show_debug_info
    figure(3);
    subplot(223); imshow(toRangeZeroOne(depth_proj)); title('Depth Projected'); drawnow
    subplot(224); imshow(rgb_proj); title('RGB Projected'); drawnow
end

%% Compute Error
error = compute_error_from_image(depth_proj, depth, settings)
if error > tolerance
    flag_pass = false;
end