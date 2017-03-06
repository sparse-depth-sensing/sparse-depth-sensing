close all; clear; clc

%% Settings
doSave = 1;
% doShow = 0;

depth_path = 'ZED/depth_scaled';
rgb_path = 'ZED/rgb';
out_path = 'ZED/output'

%% Iteration
count = 0;
for img_ID = 1 : 1400
    if count > 1000
        break;
    end
    
    depth_filename = sprintf('%s/depth_scaled_%s.png', depth_path, sprintf('%04d', img_ID));
    rgb_filename = sprintf('%s/rgb_%s.png', rgb_path, sprintf('%04d', img_ID));

    if (exist(depth_filename, 'file') == 2) && (exist(rgb_filename, 'file') == 2)
        count = count + 1;
        
        msg = sprintf('Both depth and rgb files exist for image %d', img_ID);
        output_filename = sprintf('%s/%s.mat', out_path, sprintf('%03d', count))
        
        rgb=imread(rgb_filename);
        depth=double(imread(depth_filename));
        % convert depth images to millimeters. Originally the maximum is
        % 255, which corresponds to roughly 10 meters
        depth = uint16(depth / 255 * 10 * 1e3);
        
        % null data
        Position = rosmessage(rostype.geometry_msgs_Point);
        Theta = 0;
        
        if doSave
            save(output_filename, 'depth', 'rgb', 'Position', 'Theta');
        end
    end
end