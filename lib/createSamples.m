function [ samples ] = createSamples( depth, rgb, settings )
%createSamples Sample randomly from a depth image
%   Detailed explanation goes here

height = size(depth, 1);
width = size(depth, 2);
N = height * width; % total number of pixels
K = round(N * settings.percSamples); % number of measurements
samples = [];

%% settings for image dilation and edge detection
if strcmp(settings.sampleMode, 'rgb-edges') || strcmp(settings.sampleMode, 'depth-edges')
    kernel_size = 0;
    se = offsetstrel('ball', kernel_size, kernel_size);
end

%% Main
switch settings.sampleMode
    case 'uniform'
        samples = [randperm(N, K)]';  
    case 'regular-grid'
        % colSub = 1 : floor(width / sqrt(K)) : width;
        % rowSub = 1 : floor(height / sqrt(K)) : height;
        colStep = floor(1 / sqrt(settings.percSamples));
        rowStep = floor(1 / sqrt(settings.percSamples));
        colSub = floor(colStep/2) : colStep : width;
        rowSub = floor(rowStep/2) : rowStep : height;
        idxSub = combvec(rowSub, colSub);
        samples = [uint32(sub2ind(size(depth), idxSub(1,:), idxSub(2,:)))]';
    case 'rgb-edges'
        Igray = rgb2gray(rgb);

        % note that Kinect images have two empty strips on the top and the bottom
        % here we fill the two strips to get rid of any edges detected
        if isKinectDataset( settings )
            top_row = ceil(settings.crop.top * settings.subSample) + 1;
            bottom_row = floor(settings.crop.bottom * settings.subSample);
            Igray(1:top_row, :) = repmat(Igray(top_row,:), top_row, 1 );
            Igray(bottom_row:end, :) = repmat(Igray(bottom_row,:), size(depth,1)-bottom_row+1, 1);
        end

        [~, threshOut] = edge(Igray, 'canny');
        Iedge = im2uint8(edge(Igray, 'canny', threshOut * 0.8));

        % dilate the edges
        dilatedI = imdilate(Iedge, se);

        % get sample ID
        dilatedI = dilatedI(:);
        samples = find(dilatedI > 0);
    case 'depth-edges'
        depth_preprocessed = depth;

        % note that Kinect images have two empty strips on the top and the bottom
        % here we fill the two strips to get rid of any edges detected
        if isKinectDataset( settings )
            top_row = ceil(settings.crop.top * settings.subSample) + 1;
            bottom_row = floor(settings.crop.bottom * settings.subSample);
            depth_preprocessed(1:top_row, :) = repmat(depth(top_row,:), top_row, 1 );
            depth_preprocessed(bottom_row:end, :) = repmat(depth(bottom_row,:), size(depth,1)-bottom_row+1, 1);
        end

        % fill in NaN values (either too far or no measurement)
        indices_nan = find(isnan(depth_preprocessed) > 0);
        indices_nan = indices_nan(:);
        depth_preprocessed(indices_nan) = 0 * ones(size(indices_nan));
    
        % detect edges using Canny edge detector
        Iedge = im2uint8(edge(depth_preprocessed, 'canny', 0));

        % dilate the edges
        dilatedI = imdilate(Iedge, se);

        % get sample ID
        dilatedI = dilatedI(:);
        samples = find(dilatedI > 0);

        % remove samples at NaN measurements from Kinect data
        if isKinectDataset( settings )
            mask_valid = find(depth(samples) ~= 0);
            samples = samples(mask_valid);
        end
    case 'harris-feature'
        Igray = rgb2gray(rgb);
        
        % note that Kinect imasamplesges have two empty strips on the top and the bottom
        % here we fill the two strips to get rid of any edges detected
        if isKinectDataset( settings )
            top_row = ceil(settings.crop.top * settings.subSample) + 1;
            bottom_row = floor(settings.crop.bottom * settings.subSample);
            Igray(1:top_row, :) = repmat(Igray(top_row,:), top_row, 1 );
            Igray(bottom_row:end, :) = repmat(Igray(bottom_row,:), size(depth,1)-bottom_row+1, 1);
        end
        
        corners = detectHarrisFeatures(Igray, 'MinQuality', 1e-6);
        Locations = corners.selectStrongest(K).Location;
        colIdx = round(Locations(:,1));
        rowIdx = round(Locations(:,2));
        samples = [uint32(sub2ind(size(depth), rowIdx, colIdx))];
    case 'surf-feature'
        Igray = rgb2gray(rgb);
        
        % note that Kinect imasamplesges have two empty strips on the top and the bottom
        % here we fill the two strips to get rid of any edges detected
        if isKinectDataset( settings )
            top_row = ceil(settings.crop.top * settings.subSample) + 1;
            bottom_row = floor(settings.crop.bottom * settings.subSample);
            Igray(1:top_row, :) = repmat(Igray(top_row,:), top_row, 1 );
            Igray(bottom_row:end, :) = repmat(Igray(bottom_row,:), size(depth,1)-bottom_row+1, 1);
        end
        
        corners = detectSURFFeatures(Igray, 'MetricThreshold', 1);
        Locations = corners.selectStrongest(K).Location;
        colIdx = round(Locations(:,1));
        rowIdx = round(Locations(:,2));
        samples = [uint32(sub2ind(size(depth), rowIdx, colIdx))];
        
    otherwise
        error('incorrect settings for settings.sampleMode')
end

if(settings.doAddNeighbors) 
    samples = addNeighbors(samples, height, width); 
end

% make sure that all measurements are valid
mask_valid = find(~isnan(depth(samples)));
samples = samples(mask_valid);
K = length(samples);

img_samples = zeros(size(depth));
img_samples(samples) = 255 * ones(length(samples), 1);

if false
% if settings.show_figures
    figure(3); 
    subplot(221); imshow(rgb); title('RGB'); 
    subplot(222); imshow(toRangeZeroOne(depth)); title('depth'); 
    % subplot(223); imshow(rgb2gray(rgb)); title('gray-scale'); 
    subplot(224); imshow(toRangeZeroOne(img_samples)); title('edges'); 
    drawnow
end

end

