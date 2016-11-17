%% Plot settings
width = 900;     % Width in inches
height = 200;    % Height in inches
fontsize = 15;
subfigure_expansion = 0.06;


fig = figure(1);
set(gca, 'FontSize', fontsize)
set(gcf, 'Position', [0 0 width, height]); %<- Set size
set(gcf, 'Color', 'White')   % set white background

h = subplot(131); 
p = get(h, 'pos');
p(1:2) = p(1:2) - subfigure_expansion;
p(3:4) = p(3:4) + subfigure_expansion;
set(h, 'pos', p);
imshow(results.rgb); 
title('Environment')

h = subplot(132); 
p = get(h, 'pos');
p(1:2) = p(1:2) - subfigure_expansion;
p(3:4) = p(3:4) + subfigure_expansion;
set(h, 'pos', p);

[Xq, Yq] = meshgrid(1:size(results.depth,2), 1:size(results.depth,1));
X_sample = Xq(results.samples)';
Y_sample = Yq(results.samples)';
depth_sampled = nan*ones(size(results.depth));
depth_sampled(results.samples) = results.depth(results.samples);
cMap=colormap('parula'); 
% imagesc(uint8(depth_sampled)); 

scatter3(X_sample, Y_sample, results.depth(results.samples), 2, results.depth(results.samples));
view(0,-90)
% axis image; 
axis off; 
title('Sparse Depth Measurements')

h=subplot(133); 
p = get(h, 'pos');
p(1:2) = p(1:2) - subfigure_expansion;
p(3:4) = p(3:4) + subfigure_expansion;
set(h, 'pos', p);
colormap(cMap);imagesc(uint8(results.rec_depth)); 
axis image; axis off;
title(['Reconstruction (err=', num2str(sprintf('%.2f', results.rec_error)), 'm)'])

drawnow