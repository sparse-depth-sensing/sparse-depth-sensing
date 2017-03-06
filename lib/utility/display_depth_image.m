function display_depth_image( depth, settings, titleString )
%SHOWDEPTHIMAGE Summary of this function goes here
%   Detailed explanation goes here

    colormap('parula'); 
    caxis(1000*[settings.min_depth, settings.max_depth])
    
    imagesc(depth); 
    axis image;
    set(gca,'XTick',[]); 
    set(gca,'YTick',[]); 
    
    if nargin>2
        title(titleString);
    end
end

