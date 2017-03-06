function [ Xnaive ] = linearInterpolationOnImage( depth, samples, measured_vector )
%linearInterpolationOnImage Reconstruction based on naive linear interpolation of 
%   depth image.

[Yq, Zq] = meshgrid(1:size(depth,2), 1:size(depth,1));
Y_sample = Yq(samples);
Z_sample = Zq(samples);
Fun = scatteredInterpolant(Y_sample, Z_sample, measured_vector, 'linear');
Xnaive = Fun(Yq, Zq);

end

