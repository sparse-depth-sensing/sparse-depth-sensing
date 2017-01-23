function [ samples ] = create_samples( settings, depth, rgb )
%CREATE_SAMPLES create sample set of a depth image
%   Detailed explanation goes here

height = size(depth, 1);
width = size(depth, 2);
N = height * width; % total number of pixels

switch settings.sampleMode
    case 'rgb_edges'
        samples = sampleRGBedge( depth, rgb, settings );
    case 'depth_edges'
        samples = sampleDepthedge( depth, settings );
    case 'uniform'
        K = round(N * settings.percSamples); % number of measurements
        samples = randperm(N, K);
    case 'grid'
        colStep = floor(1 / sqrt(settings.percSamples));
        rowStep = floor(1 / sqrt(settings.percSamples));
        colSub = floor(colStep/2) : colStep : width;
        rowSub = floor(rowStep/2) : rowStep : height;
        idxSub = combvec(rowSub, colSub);
        samples = [uint32(sub2ind(size(depth), idxSub(1,:), idxSub(2,:)))]';
    otherwise
        error('sampleMode selection incorrect.')
end

if(settings.doAddNeighbors==1) 
    samples = addNeighbors(samples, height, width); 
end

samples = unique(samples);
samples = sort(samples); % for debugging


end

