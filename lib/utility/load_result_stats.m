function [ stats ] = load_result_stats( dataset, settings )
%LOAD_DATASET_STATS Summary of this function goes here
%   Detailed explanation goes here  
  
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

curr_settings = settings;
load(stats_filename)
settings = curr_settings;

%% extract data out of the array of structs
fprintf(' --> extracting data.\n');
error_naive = [array_naive.error]; 
mae_naive = [error_naive.mae];
rmse_naive = [error_naive.rmse];
psnr_naive = [error_naive.psnr];
euclidean_naive = [error_naive.euclidean];

error_L1 = [array_L1.error]; 
mae_L1 = [error_L1.mae];
rmse_L1 = [error_L1.rmse];
psnr_L1 = [error_L1.psnr];
euclidean_L1 = [error_L1.euclidean];

error_L1_diag = [array_L1_diag.error]; 
mae_L1_diag = [error_L1_diag.mae];
rmse_L1_diag = [error_L1_diag.rmse];
psnr_L1_diag = [error_L1_diag.psnr];
euclidean_L1_diag = [error_L1_diag.euclidean];

error_L1_cart = [array_L1_cart.error]; 
mae_L1_cart = [error_L1_cart.mae];
rmse_L1_cart = [error_L1_cart.rmse];
psnr_L1_cart = [error_L1_cart.psnr];
euclidean_L1_cart = [error_L1_cart.euclidean];

error_L1_inv = [array_L1_inv.error]; 
mae_L1_inv = [error_L1_inv.mae];
rmse_L1_inv = [error_L1_inv.rmse];
psnr_L1_inv = [error_L1_inv.psnr];
euclidean_L1_inv = [error_L1_inv.euclidean];

error_L1_inv_diag = [array_L1_inv_diag.error]; 
mae_L1_inv_diag = [error_L1_inv_diag.mae];
rmse_L1_inv_diag = [error_L1_inv_diag.rmse];
psnr_L1_inv_diag = [error_L1_inv_diag.psnr];
euclidean_L1_inv_diag = [error_L1_inv_diag.euclidean];

%% Saving stats
stats.mae_naive = mae_naive;
stats.rmse_naive = rmse_naive;
stats.psnr_naive = psnr_naive;
stats.euclidean_naive = euclidean_naive;

stats.mae_L1 = mae_L1;
stats.rmse_L1 = rmse_L1;
stats.psnr_L1 = psnr_L1;
stats.euclidean_L1 = euclidean_L1;

stats.mae_L1_diag = mae_L1_diag;
stats.rmse_L1_diag = rmse_L1_diag;
stats.psnr_L1_diag = psnr_L1_diag;
stats.euclidean_L1_diag = euclidean_L1_diag;

stats.mae_L1_cart = mae_L1_cart;
stats.rmse_L1_cart = rmse_L1_cart;
stats.psnr_L1_cart = psnr_L1_cart;
stats.euclidean_L1_cart = euclidean_L1_cart;

stats.mae_L1_inv = mae_L1_inv;
stats.rmse_L1_inv = rmse_L1_inv;
stats.psnr_L1_inv = psnr_L1_inv;
stats.euclidean_L1_inv = euclidean_L1_inv;

stats.mae_L1_inv_diag = mae_L1_inv_diag;
stats.rmse_L1_inv_diag = rmse_L1_inv_diag;
stats.psnr_L1_inv_diag = psnr_L1_inv_diag;
stats.euclidean_L1_inv_diag = euclidean_L1_inv_diag;

%% Figure settings
subfigure_expansion = 0.01;
figure_position = [50, 50, 900, 700];
dim = 16;
linewidth = 1;
barwidth = 0.8;

z_mark = 'b'; % o
z_diag_mark = 'b'; % d
zFast_mark = 'c'; % o
zFast_diag_mark = 'c' ; % d
naive_mark = 'r'; % s

%% Mean error bar plot
fig = figure(1);
set(fig, 'Position', figure_position);
euclidean_means = [];
mae_means = [];
rmse_means = [];
approachLabels = {};
if settings.use_naive 
  euclidean_means = [euclidean_means, mean(euclidean_naive)];
  mae_means = [mae_means, mean(mae_naive)];
  rmse_means = [rmse_means, mean(rmse_naive)];
  approachLabels = [approachLabels; 'naive'];
end
if settings.use_L1
  euclidean_means = [euclidean_means, mean(euclidean_L1)];
  mae_means = [mae_means, mean(mae_L1)];
  rmse_means = [rmse_means, mean(rmse_L1)];
  approachLabels = [approachLabels; 'l1'];
end
if settings.use_L1_diag
  euclidean_means = [euclidean_means, mean(euclidean_L1_diag)];
  mae_means = [mae_means, mean(mae_L1_diag)];
  rmse_means = [rmse_means, mean(rmse_L1_diag)];
  approachLabels = [approachLabels; 'l1-diag'];
end
if settings.use_L1_cart
  euclidean_means = [euclidean_means, mean(euclidean_L1_cart)];
  mae_means = [mae_means, mean(mae_L1_cart)];
  rmse_means = [rmse_means, mean(rmse_L1_cart)];
  approachLabels = [approachLabels; 'l1-cart'];
end
if settings.use_L1_inv
  euclidean_means = [euclidean_means, mean(euclidean_L1_inv)];
  mae_means = [mae_means, mean(mae_L1_inv)];
  rmse_means = [rmse_means, mean(rmse_L1_inv)];
  approachLabels = [approachLabels; 'l1-inv'];
end
if settings.use_L1_inv_diag
  euclidean_means = [euclidean_means, mean(euclidean_L1_inv_diag)];
  mae_means = [mae_means, mean(mae_L1_inv_diag)];
  rmse_means = [rmse_means, mean(rmse_L1_inv_diag)];
  approachLabels = [approachLabels; 'l1-inv-diag'];
end

b = bar(7*[1:length(euclidean_means)], [euclidean_means', mae_means', rmse_means'], barwidth); 
legend('euclidean error', 'mean absolute error', 'RMSE', 'Location', 'NorthWest')
set(gca,'xticklabel', approachLabels);
title(sprintf('dataset: %s', dataset), 'interpreter','none');
ylabel('error[m]')
set(gca,'FontSize',dim); 
ylabh=get(gca,'ylabel'); set(ylabh, 'FontSize', dim); 
xlabh=get(gca,'ylabel'); set(xlabh, 'FontSize', dim);

%% Saving figures
eps_figure_name = fullfile(output_folder, 'errors.eps');
fprintf(' --> saving figure to %s\n', eps_figure_name);
saveas(fig, eps_figure_name, 'epsc'); 

png_figure_name = fullfile(output_folder, 'errors.png');
fprintf(' --> saving figure to %s\n', png_figure_name);
saveas(fig, png_figure_name, 'png'); 

end

