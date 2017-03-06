function [ depth_out, depth_cut ] = imageCropBorder( depth, settings, flag )
%imageCropBorder Summary of this function goes here
%   Detailed explanation goes here

    depth_out = depth;

    if strcmp(flag, 'original')
        depth_out(settings.crop.bottom:end,:) = nan * ones(size(depth(settings.crop.bottom:end,:)));
        depth_out(1:settings.crop.top,:) = nan * ones(size(depth(1:settings.crop.top,:)));
        depth_cut = depth(settings.crop.top+1 : settings.crop.bottom-1, :);
    elseif strcmp(flag, 'resized')
        depth_out(settings.crop.bottom * settings.subSample:end,:) ...
            = nan * ones(size(depth(settings.crop.bottom * settings.subSample:end,:)));
        depth_out(1:settings.crop.top * settings.subSample,:) ...
            = nan * ones(size(depth(1:settings.crop.top * settings.subSample,:)));
        depth_cut = depth(settings.crop.top * settings.subSample + 1 : ...
            settings.crop.bottom * settings.subSample - 1, :);
    end

end