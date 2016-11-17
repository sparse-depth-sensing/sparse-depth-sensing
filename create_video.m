close all; clear; clc;
addpath('plotting');

results_folder = 'results/subSample=0.200000.sampleMode=grid.percSamples=0.010000';

%% Create the video
outputVideo = VideoWriter(fullfile('videos', 'output.avi'));
outputVideo.FrameRate = 8;
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
        
        % plot_4windows
        plot_3windows
        
        % write to the output video
        F = getframe(fig);
        writeVideo(outputVideo, F);
        
    else
        continue;
    end
end

%% Finish the video
close(outputVideo)
