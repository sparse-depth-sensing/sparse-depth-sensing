function [ x_b, y_b ] = transform2d_world2body( x_w, y_w, t_x, t_y, theta )
%TRANSFORM2D_WORLD2BODY This function does 2D geometric transformation of a point
%from the world frame to the body frame
%   x_b and y_b --- the coordinates of the point in the body frame
%   x_w and y_w --- the coordinates of the point in the world frame
%   t_x, t_y --- the translation of body frame, 
%   theta --- the clockwise rotation angle of the body frame

%% reshape the input vectors to be row vectors
L = length(x_w);
x_w = reshape(x_w, 1, L);
y_w = reshape(y_w, 1, L);

%% Construct the rotation matrix
R = [cos(theta), sin(theta), 0;
     -sin(theta), cos(theta), 0;
     0, 0, 1];

%% Apply the transformation
% translation first
vec_w = [x_w - t_x; y_w - t_y; ones(1, L)]; % this is actually a matrix

% then rotation
vec_b = R * vec_w;

%% Extract the results
x_b = vec_b(1, :);
y_b = vec_b(2, :);

%% Reshape the output as column vectors
x_b = reshape(x_b, L, 1);
y_b = reshape(y_b, L, 1);

end

