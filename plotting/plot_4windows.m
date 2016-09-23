figure(1);
subplot(221); 
cMap=colormap('parula'); imagesc(uint8(results.depth)); 
axis image; axis off;
title('original depth')

subplot(222); 
colormap(cMap); imagesc(uint8(results.sample_mask)); 
axis image; axis off;
title('samples')

subplot(223); 
colormap(cMap);imagesc(uint8(results.rec_depth)); 
axis image; axis off;
title(['rec (err=', num2str(sprintf('%.2f', results.rec_error)), 'm)'])

subplot(224); 
colormap(cMap); imagesc(uint8(results.Znaive)); 
axis image; axis off;
title(['naive (err=', num2str(sprintf('%.2f', results.naive_error)), 'm)'])
drawnow