function [ x_w, y_w ] = transform2d_body2world( x_b, y_b, t_x, t_y, theta )
%TRANSFORM_B2W This function does 2D geometric transformation of a point
%from the body frame to the world frame
%   x_b and y_b --- the coordinates of the point in the body frame
%   x_w and y_w --- the coordinates of the point in the world frame
%   t_x, t_y --- the translation of body frame, 
%   theta --- the counter-clockwise rotation angle of the body frame

%% reshape the input vectors to be row vectors
L = length(x_b);
x_b = reshape(x_b, 1, L);
y_b = reshape(y_b, 1, L);

%% Construct the transformation matrix
M = [cos(theta), -sin(theta), t_x;
    sin(theta), cos(theta), t_y;
    0, 0, 1];

%% Apply the transformation
vec_b = [x_b; y_b; ones(1, L)]; % this is actually a matrix
vec_w = M * vec_b;

%% Extract the results
x_w = vec_w(1, :);
y_w = vec_w(2, :);

%% Reshape the output as column vectors
x_w = reshape(x_w, L, 1);
y_w = reshape(y_w, L, 1);

end

