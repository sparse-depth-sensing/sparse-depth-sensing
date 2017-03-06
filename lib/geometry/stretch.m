function [ Y_stretched, Z_stretched ] = stretch( height, width, Y, Z, settings )
%STRETCH Stretch the y and z coordinates
%   Detailed explanation goes here

% [colSub, rowSub] = meshgrid(1:width, 1:height);
Y = reshape(Y, height, width);
Z = reshape(Z, height, width);

% compute the 1st-order differences
Y_delta = diff(Y, 1, 2);    % 1st-order difference along the horizontal direction
Z_delta = diff(Z, 1, 1);    % 1st-order difference along the vertical direction
Y_delta(isnan(Y_delta)) = 0;
Z_delta(isnan(Z_delta)) = 0;

% add a small delta to the differences
% Y_delta = Y_delta + settings.stretch.delta_y * ones(size(Y_delta));
% Z_delta = Z_delta + settings.stretch.delta_z * ones(size(Z_delta));
Y_delta = abs(Y_delta) + settings.stretch.delta_y * ones(size(Y_delta));
Z_delta = abs(Z_delta) + settings.stretch.delta_z * ones(size(Z_delta));

% stretching along y,z directions
% Y_stretched = cumsum( [Y(:,1), -Y_delta], 2 );
% Z_stretched = cumsum( [Z(1,:); -Z_delta], 1 );
Y_stretched = cumsum( [zeros(height, 1), -Y_delta], 2 );
Z_stretched = cumsum( [zeros(1, width); -Z_delta], 1 );

% putting things together
Y_stretched = Y_stretched(:);
Z_stretched = Z_stretched(:);

end

