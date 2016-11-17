close all; clear; clc;

addpath('../results')

%% Settings
settings.subSample = 0.2;         % subsample original image, to reduce its size
settings.sampleMode = 'depth_edges';  % uniform, rgb_edges, depth_edges
settings.percEdges = 1;           % percentage of edge samples used, if sampleMode == rgb_edges

img_ID = 750;

%% Load result folder
result_folder = sprintf('../results/subSample=%f.sampleMode=%s.percSamples=%f', ...
    settings.subSample, settings.sampleMode, settings.percEdges);
addpath(result_folder);

results_filename = [result_folder, '/', num2str(img_ID), '.mat'];

if exist(results_filename, 'file') == 2
    load(results_filename);

    % the case where raw file not exists
    if size(results, 1) < 1
        disp('Not Valid. Please use some other image ID.');
    else
        fig1=figure(1);
        imshow(results.rgb);
        set(gca, 'position', [0 0 1 1], 'units', 'normalized')
        saveas(fig1, 'figures/edge_example_rgb.jpg')
        
        fig2=figure(2);
        cMap = colormap('parula');
        X8 = uint16(1000 * results.sample_mask);
        colormap(cMap)
        imagesc(X8);
        axis off
        set(gca, 'position', [0 0 1 1], 'units', 'normalized')
        saveas(fig2, 'figures/edge_example_samples.jpg')
        
        fig3=figure(3);
        X8 = uint16(1000 * results.depth);
        colormap(cMap)
        imagesc(X8);
        axis off
        set(gca, 'position', [0 0 1 1], 'units', 'normalized')
        saveas(fig3, 'figures/edge_example_depth.jpg')
        
    end
    
end