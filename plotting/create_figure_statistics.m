close all; clear; clc;

addpath('../results')

%% Settings
settings.subSample = 0.2;         % subsample original image, to reduce its size
settings.sampleMode = 'depth_edges';  % uniform, rgb_edges, depth_edges
settings.percEdges = 1;           % percentage of edge samples used, if sampleMode == rgb_edges

%% Plot settings
figure_position = [50, 50, 900, 700];
dim = 24;
linewidth = 3;

%% Load result folder
result_folder = sprintf('../results/subSample=%f.sampleMode=%s.percSamples=%f', ...
    settings.subSample, settings.sampleMode, settings.percEdges);
addpath(result_folder);

%% Create data holder
ID_array = 375 : 1: 1400;
N = length(ID_array);
l1_error_array = zeros(N, 1);
naive_error_array = zeros(N, 1);
time_array = zeros(N, 1);
samples_array = zeros(N, 1);
original_size = 0;

%% Loop over all data
count = 0;
for img_ID = ID_array
    disp('========================')
    disp(['Image ID: ', num2str(img_ID)]);
    
    results_filename = [result_folder, '/', num2str(img_ID), '.mat'];
    if exist(results_filename, 'file') == 2
        load(results_filename);
        
        % the case where raw file not exists
        if size(results, 1) < 1
            continue;
        end
    
        count = count+1;
        original_size = prod(size(results.depth));
        naive_error_array(count) = results.naive_error;
        l1_error_array(count) = results.rec_error;
        samples_array(count) = length(results.samples);
        time_array(count) = results.time_l1;
        % disp(sprintf('Percentage of Samples: %f', length(results.samples) / prod(size(results.depth))));
    end
end

%% Create figure
fig1 = figure(1);
set(fig1, 'Position', figure_position);

plot(1:count, naive_error_array(1:count), ':r', 'LineWidth', linewidth);
hold on
plot(1:count, l1_error_array(1:count), 'b-', 'LineWidth', linewidth);

xlabel('image sequence')
ylabel('error [m]')
legend('naive', 'L1-diag')
xlim([0, count])
grid on
set(gca, 'FontSize', dim)
set(gca, 'box', 'off');
ylabh=get(gca,'ylabel'); set(ylabh, 'FontSize', dim);
xlabh=get(gca,'xlabel'); set(xlabh, 'FontSize', dim);

output_name_error = 'figures/error_vs_time.eps';
saveas(fig1, output_name_error, 'epsc')

%%%%%%%%%%%%%%%%%%%
fig2 = figure(2);
set(fig2, 'Position', figure_position);

plot(1:count, 4*original_size/1000*ones(1, count), 'r:', 'LineWidth', linewidth);
hold on
plot(1:count, 4*samples_array(1:count)/1000, 'b-', 'LineWidth', linewidth);
xlabel('image sequence')
ylabel('bandwidth [KB]')
legend('original bandwidth', 'edges only')
xlim([0, count])
grid on
set(gca, 'FontSize', dim)
set(gca, 'box', 'off');
ylabh=get(gca,'ylabel'); set(ylabh, 'FontSize', dim);
xlabh=get(gca,'xlabel'); set(xlabh, 'FontSize', dim);

output_name_bandwidth = 'figures/bandwidth.eps';
saveas(fig2, output_name_bandwidth, 'epsc')