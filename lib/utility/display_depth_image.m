function display_depth_image( depth, titleString )
%SHOWDEPTHIMAGE Summary of this function goes here
%   Detailed explanation goes here

    colormap('parula'); 
    imagesc(depth); 
    set(gca,'XTick',[]); 
    set(gca,'YTick',[]); 
    
    if nargin>1
        title(titleString);
    end
end

