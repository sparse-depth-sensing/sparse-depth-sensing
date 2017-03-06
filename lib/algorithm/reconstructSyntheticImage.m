function [ results ] = reconstructSyntheticImage( solver, settings, ...
    height, width, sampling_matrix, measured_vector, samples, initial_guess, ...
    depth, pc_truth, figHandle, subplot_id)
%reconstructDepthImage A wrapper for all solvers, to avoid repeated codes
%   Detailed explanation goes here

if settings.show_debug_info
    disp('************************************')
end

%% slope_cartesian_noDiag generates a list of x coordiantes
if strcmp(solver, 'slope_cartesian_noDiag')
    tic
    x_slope_cartesian = l1ReconstructionOnPointcloud( height, width, ...
            sampling_matrix, measured_vector, pc_truth.Location(:, [2, 3]), ...
            settings, samples, initial_guess);
    time = toc;
    solver_title = 'l1-cart-noDiag';
    
    % reconstruct the point cloud
    xyz_slope_cartesian = pc_truth.Location;
    xyz_slope_cartesian(:, 1) = x_slope_cartesian;
    pc_rec = pointCloud(xyz_slope_cartesian);
    depth_rec = [];

%% other methods generate a vectorized depth image
else
    tic
    switch solver
        case 'naive'
            x = linearInterpolationOnImage( depth, samples, measured_vector );
            solver_title = 'naive';
        case 'slope_perspective_diag'
            x = l1ReconstructionOnImage( height, width, ...
                sampling_matrix, measured_vector, settings, samples, initial_guess);
            solver_title = 'l1-pers-diag';
        case 'slope_perspective_noDiag'
            x = l1ReconstructionOnImage( height, width, ...
                sampling_matrix, measured_vector, settings, samples, initial_guess);
            solver_title = 'l1-pers-noDiag';
    end
    time = toc;
    
    % reshape the vectorized depth image into a image
    depth_rec = reshape(x, height, width);
    
    pc_rec = depth2pcOrthogonal( depth_rec );

end

error = computeErrorPointcloud(pc_rec.Location, pc_truth.Location, settings); 

if settings.show_debug_info
    disp([solver, ': time = ', num2str(time), 's'])
    disp([solver, ': error = ', sprintf('%.2f', error.euclidean), 'm'])
end

if settings.show_figures
    figure(figHandle);
    subplot(subplot_id);
    pcshow(pc_rec, 'MarkerSize', settings.markersize); xlabel('x'); ylabel('y'); zlabel('z'); 
    title({solver_title, ['(Error=', sprintf('%.2f', error.euclidean), 'm)']})
    drawnow;
end

results.error = error;
results.time = time;
results.pc_rec_noblack = pc_rec;
if exist('depth_rec', 'var')
    results.depth_rec = depth_rec;
end

end

