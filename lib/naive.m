function [ Znaive ] = naive( depth, samples, y, settings )
%NAIVE Niave linear interpolation of depth samples
%   Detailed explanation goes here

[Xq, Yq] = meshgrid(1:size(depth,2), 1:size(depth,1));
X_sample = Xq(samples)';
Y_sample = Yq(samples)';
Fun = scatteredInterpolant(X_sample, Y_sample, y, 'linear');
Znaive = Fun(Xq, Yq);

if settings.isBounded
    valid_mask = (Znaive >=0) .* (Znaive <= 255); 
    Znaive = Znaive .* valid_mask + 255 .* (Znaive > 255);
end

end

