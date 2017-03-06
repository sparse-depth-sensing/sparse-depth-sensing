function [ x_naive ] = linearInterpolationOnPointcloud( query_points, measured_points, settings )
%linearInterpolationOnPointcloud Reconstruction based on naive linear interpolation of 
%   3D points.

Yq = query_points(:, 1);
Zq = query_points(:, 2);
Y_sample = measured_points(:, 2);
Z_sample = measured_points(:, 3);
Fun = scatteredInterpolant(Y_sample, Z_sample, measured_points(:, 1), 'linear');
x_naive = Fun(Yq, Zq);

end

