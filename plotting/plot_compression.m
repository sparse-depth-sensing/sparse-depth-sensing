
if ~exist('figureInitialized')
    figureInitialized = true;
    
    width = 1100;     % Width in inches
    height = 900;    % Height in inches
    fontsize = 10;
    subfigureBottomMargin = 0.01;

    fig = figure(1);
    set(gca, 'FontSize', fontsize)
    set(gcf, 'Position', [0 0 width, height]); %<- Set size
    set(gcf, 'Color', 'White')   % set white background
end


h=subplot(221); 
imshow(uint8(results.rgb)); 
axis image; axis off;
title(['environment ', '(rgb images not used)'])
set(h, 'pos', [0, 0.5+subfigureBottomMargin, 0.5, 0.5-4*subfigureBottomMargin]);  % [left bottom width height]


h=subplot(222); 
cMap=colormap('parula'); imagesc(uint8(results.depth)); 
axis image; axis off;
title('ground truth depth image')
set(h, 'pos', [0.5, 0.5+subfigureBottomMargin, 0.5, 0.5-4*subfigureBottomMargin]);  % [left bottom width height]


h=subplot(223); 
[Xq, Yq] = meshgrid(1:size(results.depth,2), 1:size(results.depth,1));
X_sample = Xq(results.samples)';
Y_sample = Yq(results.samples)';
depth_sampled = nan*ones(size(results.depth));
depth_sampled(results.samples) = results.depth(results.samples);
colormap(cMap); imagesc(uint8(depth_sampled)); 
axis image; axis off;
title(['compressed data ', ...
    sprintf('(only edges are preserved, compression ratio=%.1f)', prod(size(results.depth))/length(results.samples))...
    ])
set(h, 'pos', [0, subfigureBottomMargin, 0.5, 0.5-4*subfigureBottomMargin]);  % [left bottom width height]


h=subplot(224); 
imagesc(uint8(results.rec_depth)); 
colormap(cMap);
axis image; axis off;
title(['decompressed data ', ...
    sprintf('(average error=%.1fcm)', 100*results.rec_error) ...
    ])
set(h, 'pos', [0.5, subfigureBottomMargin, 0.5, 0.5-4*subfigureBottomMargin]);  % [left bottom width height]


% subplot(224); 
% colormap(cMap); imagesc(uint8(results.Znaive)); 
% axis image; axis off;
% title(['naive (err=', num2str(sprintf('%.2f', results.naive_error)), 'm)'])

drawnow