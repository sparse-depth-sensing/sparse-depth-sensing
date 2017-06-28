function [ results ] = reconstructDepthImage( solver, settings, ...
  height, width, sampling_matrix, measured_vector, samples, initial_guess, ...
  depth, rgb, odometry, pc_truth, figHandle, subplot_id)
%reconstructDepthImage A wrapper for all solvers, to avoid repeated codes
%   Detailed explanation goes here

% if settings.show_debug_info
%     disp('')
% end

%% slope_cartesian_noDiag generates a list of x coordiantes
if strcmp(solver, 'L1-cart')
  tic
  x_slope_cartesian = l1ReconstructionOnPointcloud( height, width, ...
    sampling_matrix, measured_vector, pc_truth.Location(:, [2, 3]), ...
    settings, samples, initial_guess);
  time = toc;
  
  % reconstruct the point cloud
  xyz_slope_cartesian = pc_truth.Location;
  xyz_slope_cartesian(:, 1) = x_slope_cartesian;
  pc_rec = pointCloud(xyz_slope_cartesian, 'Color', pc_truth.Color);
  
  % reconstruct the point cloud with only valid colors
  color_idx = find(ismember(pc_truth.Color, [0 0 0], 'rows') == 0);
  pc_rec_noblack = pointCloud(xyz_slope_cartesian(color_idx,:), 'Color', pc_truth.Color(color_idx,:));
  
  % reconstruct projected depth image
  [ depth_rec, rgb_rec ] = pc2images( pc_rec, odometry, settings );
  
  %% other methods generate a vectorized depth image
else
  tic
  switch solver
    case 'naive'
      x = linearInterpolationOnImage( height, width, samples, measured_vector );
    case 'L1-diag'
      x = l1ReconstructionOnImage( height, width, ...
        sampling_matrix, measured_vector, settings, samples, initial_guess);
    case 'L1'
      x = l1ReconstructionOnImage( height, width, ...
        sampling_matrix, measured_vector, settings, samples, initial_guess);
  end
  time = toc;
  
  % reshape the vectorized depth image into a image
  depth_rec = reshape(x, height, width);
  
  % reconstruct the point cloud
  pc_rec = depth2pc(depth_rec, rgb, odometry, settings, false);
  
  % reconstruct the point cloud with only valid colors
  pc_rec_noblack = depth2pc(depth_rec, rgb, odometry, settings, true);
end

error = computeErrorPointcloud(pc_rec.Location, pc_truth.Location, settings);

if settings.show_debug_info
  disp(sprintf(' --- %8s: time=%.5gms, mae=%.3gcm, rmse=%.3gcm, psnr=%.3gdB (high is good)', ...
    solver, 1000*time, 100*error.mae, 100*error.rmse, error.psnr))
%   disp(sprintf(' --- %8s: time=%.5gms, mae=%.3gcm', solver, 1000*time, 100*error.euclidean))
end

if settings.show_pointcloud
  figure(figHandle);
  subplot(subplot_id);
  pcshow(pc_rec_noblack, 'MarkerSize', settings.markersize); xlabel('x'); ylabel('y'); zlabel('z');
  title({solver, ['(avg error=', sprintf('%.3g', 100*error.euclidean), 'cm)']})
  drawnow;
end

results.error = error;
results.time = time;
results.pc_rec_noblack = pc_rec_noblack;
results.depth_rec = depth_rec;

end

