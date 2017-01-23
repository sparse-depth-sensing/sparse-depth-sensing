close all; clear; clc;
addpath('plotting');

target = 'sparseReconstruction';    % sparseReconstruction, compression

switch target
    case 'compression'
        results_folder = 'results/zed/subSample=0.200000.sampleMode=depth_edges.percSamples=1.000000';
        % results_folder = 'results/zed/subSample=0.200000.sampleMode=depth_edges.percSamples=1.000000';
    case 'sparseReconstruction'
%         results_folder = 'results/zed/subSample=0.200000.sampleMode=grid.percSamples=0.010000';
        results_folder = 'results/zed/subSample=0.400000.sampleMode=uniform.percSamples=0.005000';
    otherwise
        error('incorrect settings.')
end



%% Create the video
% outputVideo = VideoWriter(fullfile('videos', [target, '.avi']), 'Uncompressed AVI');
outputVideo = VideoWriter(fullfile('videos', [target, '.avi']));
% outputVideo.Quality = 75;
outputVideo.FrameRate = 6;
open(outputVideo);

%% Loop over all data
for img_ID = 375 : 5: 1400
    disp('========================')
    disp(['Image ID: ', num2str(img_ID)]);
    
    results_filename = [results_folder, '/', num2str(img_ID), '.mat'];
    if exist(results_filename, 'file') == 2
        load(results_filename);
        
        % the case where raw file not exists
        if size(results, 1) < 1
            continue;
        end
        
        switch target
            case 'compression'
                plot_compression
            case 'sparseReconstruction'
                plot_sparseReconstruction
            otherwise
                % plot_3windows
                error('incorrect settings.')
        end  
        
        % write to the output video
        F = getframe(fig);
        writeVideo(outputVideo, F);
        % pause
        
    else
        continue;
    end
end

%% Finish the video
close(outputVideo)
