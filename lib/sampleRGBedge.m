function samples = sampleRGBedge( depth, rgb, settings )
%SAMPLE_EDGE Summary of this function goes here
% Detailed explanation goes here

useGrayIm = 1;   
if useGrayIm
    %% Get edges from gray scale image
    Igray = rgb2gray(rgb);
    Iedge = im2uint8(edge(Igray,'canny'));
else
    %% Channel-wise
    Igray1 = rgb(:,:,1);
    Iedge1 = im2uint8(edge(Igray1,'canny'));
    Igray2 = rgb(:,:,2);
    Iedge2 = im2uint8(edge(Igray2,'canny'));
    Igray3 = rgb(:,:,3);
    Iedge3 = im2uint8(edge(Igray3,'canny'));
    Iedge = Iedge1 + Iedge2 + Iedge3;
end
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

