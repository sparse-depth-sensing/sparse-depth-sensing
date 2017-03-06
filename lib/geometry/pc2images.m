function [ depth, rgb, varargout ] = pc2images( pc, odom, settings, varargin )
%PC2DEPTH Create a depth image as the perspective projection of a point cloud to the image plane 
%   The transformations by order is:
%       world frame -> vehicle frame (using odometry information)
%       vehicle frame -> camera frame (calibration for tilting of Kinect camera, if any)
%       camera frame -> image plane
%
% Following conventions in ROS, the axes in a coordinate frame is defined
% as follows:
%   x: pointing forward
%   z: pointing upward
%   y: pointing to the left
%
% mat_id indicates the source frame of data of each pixel (to reflect the level of uncertainty)

%% Load intrinsic parameters of the camera
parametersFileName = sprintf('%s/intrinsic_parameters.mat', getPath('data', settings));
load(parametersFileName)
width = ceil(W * settings.subSample);
height = ceil(H * settings.subSample);
% if isfield(settings, 'noImageChopping') 
%     height = ceil(H * settings.subSample);
% else
%     bottom_row = 400;
%     top_row = 40;
%     height = ceil((bottom_row - top_row + 1) * settings.subSample);
% end

fu = fu * settings.subSample; % (640 / 2) * cot(fov / 2)
fv = fv * settings.subSample; % (480 / 2) * cot(fov / 2) 
center_u = center_u * settings.subSample;
center_v = center_v * settings.subSample;

%% Vectorize all computation
x_world = pc.Location(:, 1);
y_world = pc.Location(:, 2);
z_world = pc.Location(:, 3);

%% world frame -> vehicle frame
t_x = odom.Position.X;
t_y = odom.Position.Y;
Theta = odom.Theta * pi / 180;  % convert from degree to radian
z_vehicle = z_world;
[x_vehicle, y_vehicle] = transform2d_world2body( x_world, y_world, t_x, t_y, Theta );

%% vehicle frame -> camera frame (calibrate for the tilting angle)
% tilting angle is positive when the camera looks down
tilting = tilting * pi / 180;

y_cam = y_vehicle;
x_cam = -z_vehicle * sin(tilting) + x_vehicle * cos(tilting);
z_cam = z_vehicle * cos(tilting) + x_vehicle * sin(tilting);

%% camera frame -> image plane
V = int32(- fv * z_cam ./ x_cam + center_v);
U = int32(- fu * y_cam ./ x_cam + center_u);

%% truncatation of values
% idx_exceeding_v = find(V > height);
% V(idx_exceeding_v) = height * ones(size(idx_exceeding_v));
% idx_exceeding_u = find(U > width);
% U(idx_exceeding_u) = width * ones(size(idx_exceeding_u));
% idx_below_v = find(V < 1);
% V(idx_below_v) = ones(size(idx_below_v));
% idx_below_u = find(U < 1);
% U(idx_below_u) = ones(size(idx_below_u));
% 
% idx_exceeding_v = find(V > height);
% V(idx_exceeding_v) = [];
% U(idx_exceeding_v) = [];
% 
% idx_exceeding_u = find(U > width);
% V(idx_exceeding_u) = [];
% U(idx_exceeding_u) = [];
% 
% idx_below_v = find(V < 1);
% V(idx_below_v) = [];
% U(idx_below_v) = [];
% 
% idx_below_u = find(U < 1);
% V(idx_below_u) = [];
% U(idx_below_u) = [];

mask_valid = find(V <= height & V > 0 & U <= width & U > 0);
V = V(mask_valid);
U = U(mask_valid);

%% Assigning values to depth 
depth = -ones(height, width);
idx = sub2ind(size(depth), V, U);
depth(idx) = x_cam(mask_valid);

%% Assigning values to rgb 
rgb = -ones(height, width, 3);
% Question: how do we get the linear indices for a 3-dim tensor?
idx_1 = sub2ind(size(rgb), V, U, ones(size(V)));
idx_2 = sub2ind(size(rgb), V, U, 2 * ones(size(V)));
idx_3 = sub2ind(size(rgb), V, U, 3 * ones(size(V)));
rgb(idx_1) = pc.Color(mask_valid, 1);
rgb(idx_2) = pc.Color(mask_valid, 2);
rgb(idx_3) = pc.Color(mask_valid, 3);
rgb = uint8(rgb);

%% Assigning values to matrix ID
% TODO: update for the new algorithm?
nout = max(nargout,1) - 2;
if length(varargin) == 1 && nout == 1
    frameID = varargin{1};
    mat_id = zeros(height, width);
    mat_id(idx) = frameID(mask_valid);
    varargout{1} = mat_id;
end

end

