function createVideo( dataset, settings )
%CREATEVIDEO Summary of this function goes here
%   Detailed explanation goes here

%% Load data
settings.dataset = dataset;
output_folder = getPath('results', settings);
if ~exist(output_folder, 'dir')
  error(sprintf('output folder %s does not exist.\n', output_folder))
end
pc_folder = fullfile(output_folder, 'pointclouds');
if ~exist(pc_folder, 'dir')
  error(sprintf('point cloud folder %s does not exist.\n', pc_folder))
end
settings_filename = fullfile(output_folder, 'settings.mat');
if ~exist(settings_filename, 'file')
  error(sprintf('setting file %s does not exist.\n', settings_filename))
end
stats_filename = fullfile(output_folder, 'stats.mat');
if ~exist(stats_filename, 'file')
  error(sprintf('stats file %s does not exist.\n', stats_filename))
else
  fprintf(' --> loading stats file.\n');
end

%% Video settings
subfigureBottomMargin = 0.002;
subfigureSideMargin = 0.008;

outputVideo = VideoWriter(fullfile(output_folder, 'video.avi'));
outputVideo.FrameRate = 5;
open(outputVideo);

%% Loop through the frames
num_data = getNumberOfImages(settings);
for i = 1 : num_data
  fprintf('frame:%d\n', i)
  pc_filename = fullfile(pc_folder, sprintf('%03d.mat', i));
  if exist(pc_filename, 'file') == 0
    continue;
  end
  load(pc_filename);
  
  if ~isfield(results, 'K')
    continue;
  end

  h=subplot(221); 
  display_depth_image(results.depth, settings, 'Ground Truth'); 
%     set(h, 'pos', [subfigureSideMargin, subfigureBottomMargin, ...
%         1/3-2*subfigureSideMargin, 1-2*subfigureBottomMargin]);

  h=subplot(222); 
  percentage = 100 * results.K / prod(size(results.depth));
  display_depth_image(results.img_sample, settings, sprintf('Measurements (%.2f%%)', percentage)); 
%     set(h, 'pos', [1/3+subfigureSideMargin, subfigureBottomMargin, ...
%         1/3-2*subfigureSideMargin, 1-2*subfigureBottomMargin]);

  h = subplot(223); 
  titleString = {'L1-diag', ...
      ['mae=', sprintf('%.3g', 100*results.L1_diag.error.mae), 'cm'], ...
      ['rmse=', sprintf('%.3g', 100*results.L1_diag.error.rmse), 'cm']...
      };
  display_depth_image(results.L1_diag.depth_rec, settings, titleString);
%     set(h, 'pos', [2/3+subfigureSideMargin, subfigureBottomMargin, ...
%         1/3-2*subfigureSideMargin, 1-2*subfigureBottomMargin]);

  h = subplot(224); 
  titleString = {'L1-inv-diag', ...
      ['mae=', sprintf('%.3g', 100*results.L1_inv_diag.error.mae), 'cm'], ...
      ['rmse=', sprintf('%.3g', 100*results.L1_inv_diag.error.rmse), 'cm']...
      };
  display_depth_image(results.L1_inv_diag.depth_rec, settings, titleString);
%     set(h, 'pos', [2/3+subfigureSideMargin, subfigureBottomMargin, ...
%         1/3-2*subfigureSideMargin, 1-2*subfigureBottomMargin]);

  F = getframe(gcf);
  writeVideo(outputVideo, F);
%   pause(0.1);
end

%% Finish the video
close(outputVideo)

end

