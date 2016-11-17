function samples = sampleDepthedge( depth, settings )
%SAMPLE_EDGE Summary of this function goes here
% Detailed explanation goes here

%% Get edges from gray scale image
Iedge = im2uint8(edge(depth,'canny', 0));

Iedge = (Iedge > 0) * 255;
% se = strel('square',2);
% Iedge = imdilate(Iedge,se);
indices = find(vec(Iedge) > 0);

if settings.isDebug
    edge_mask = (Iedge == 0);
    figure;
    subplot(221); imshow(depth,'InitialMagnification',300); title('Original Depth');
    subplot(222); imshow(rgb,'InitialMagnification',300); title('Original RGB');
    % subplot(223); imshow(Igray,'InitialMagnification',300); title('Channel');
    % subplot(224); imshow(edge_mask,'InitialMagnification',300); title('Masked out values');
    subplot(223); imshow(edge_mask,'InitialMagnification',300); title('Masked out values');
    rgb_masked = rgb;
    for i = 1:size(rgb,1)
        for j = 1:size(rgb,2)
            if edge_mask(i, j) == 1
                rgb_masked(i,j,1) = 0;
                rgb_masked(i,j,2) = 0;
                rgb_masked(i,j,3) = 0;
            end
        end
    end
    subplot(224); imshow(rgb_masked,'InitialMagnification',300); title('Masked out values');
end

%% Get samples around edges
samples = indices';
num_edge_pixel = length(samples);
K = ceil(num_edge_pixel * settings.percEdges);
samples = samples(randperm(num_edge_pixel, K));

end

