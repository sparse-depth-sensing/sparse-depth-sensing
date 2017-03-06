close all; clear; clc

%% Settings
doSave = 1;
doShow = 0;

%% Load ROS bag file
name = 'stata_floor1_g';    % '32_144', '34_floor3', '36_floor3', '38_floor3', '39_floor3', 'lids_floor7', 'stata_floor1'
bag = rosbag([name, '.bag']);
bagselectDepth = select(bag, 'Topic', '/kinect2/sd/image_depth_rect');
bagselectRGB = select(bag, 'Topic', '/kinect2/sd/image_color_rect');
bagselectOdom = select(bag, 'Topic', '/odom');

mkdir(name);

% start = bag.StartTime;

tf_count = 1;
tf_sec = 0;
tf_nsec = 0;
pos = [];

%% Loop over all image topics
for i = 1:bagselectDepth.NumMessages
    msgDepth = readMessages(bagselectDepth, i);
    depth = readImage(msgDepth{1});
    depth = fliplr(flipud(depth));
    depth_sec = msgDepth{1}.Header.Stamp.Sec;
    depth_nsec = msgDepth{1}.Header.Stamp.Nsec;

    msgRGB = readMessages(bagselectRGB, i);
    rgb = readImage(msgRGB{1});
    rgb = fliplr(flipud(rgb));
    rgb_sec = msgRGB{1}.Header.Stamp.Sec;
    rgb_nsec = msgRGB{1}.Header.Stamp.Nsec;
    
    %% Check synchronization of rgb and depth images
    if abs(depth_nsec - rgb_nsec) > 0
        warning('RGB and Depth images not synchronized');
    end
    % disp(['rgb_time - depth_time = ', num2str(rgb_time - depth_time) ]);
    
    %% find the corresponding tf
    while tf_sec < depth_sec || (tf_sec == depth_sec && tf_nsec < depth_nsec)
        tf_count = tf_count + 1;
        msgOdom = readMessages(bagselectOdom, tf_count);
        tf_sec = msgOdom{1}.Header.Stamp.Sec;
        tf_nsec = msgOdom{1}.Header.Stamp.Nsec;
        % disp(['tf_nsec = ', num2str(tf_nsec), ', depth_nsec = ', num2str(depth_nsec) ]);
     
    end
    Position = msgOdom{1}.Pose.Pose.Position;
    Orientation = msgOdom{1}.Pose.Pose.Orientation;
    Theta = 2 * acos(Orientation.W) * sign(Orientation.Z);  % Quaternion to angle (in radian)
    Theta = Theta * 180 / pi;   % convert from radian to degree
    disp(['tf_count = ', num2str(tf_count), ...
        '; X = ', num2str(Position.X), ...
        '; Y = ', num2str(Position.Y), ...
        '; Theta = ', num2str(Theta) ...
        ]);
    
    if doShow
        figure(1); 
        subplot(211); imshow(depth); title('depth')
        subplot(212); imshow(rgb); title('rgb')
        % suptitle(['image ', num2str(i), ', x = ', num2str(x), 'm'])

        pause;
    end
    
    if doSave
        filename = sprintf([name, '/%03d.mat'], i);
        save(filename, 'rgb', 'depth', 'Position', 'Orientation', 'Theta')
    end
end

