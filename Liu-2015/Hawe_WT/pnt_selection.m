% This functionselect n=total sample positions for the input image Img. The
% points are selected to lie around the input images edges, and are quasi
% equaly spaced over the entire image. For an input image Img of size (n x
% m), the output Sel is of equal size where the sampling positions are
% marked as ones, and all other entries are zero.
% (c) Simon Hawe, Lehrstuhl fuer Datenverarbeitung Technische Universitaet
% Muenchen, 2011. Contact: simon.hawe@tum.de
function Sel = pnt_selection(Img, canny_th, total)
% Finding the edges
D_canny             = edge(Img,'canny',[],canny_th);
[Y_start,X_start]   = find(D_canny);
% Adding ones to the Selection array.
Sel                 = zeros(size(Img,1),size(Img,2));
Sel(sub2ind(size(Sel), Y_start, X_start))      = 1;
% Rest is the rest of points to be equally spaced
Rest = total - sum(Sel(:));

if Rest > 0
    % Currently a test function, additionally to the images lying at the
    % edges we add the ones lying in the direction of the gradient.
    [~, ~, gv, gh]      = edge(Img,'sobel');
    % Computing the angles
    Dir                 = atan2(gh,gv);
    % Only those where edges have been found by the canny filter
    Dir                 = Dir(D_canny);
    X_new               = X_start - round(cos(Dir));
    Y_new               = Y_start - round(sin(Dir));
    % Getting the indices
    Inds = sub2ind(size(Sel), Y_new,     X_new);
    % Only using about half of the remaing points to be placed
    Inds = Inds(get_rand(numel(Inds),floor(Rest*.5)));
    
    Sel(Inds)      = 1;
    Rest = total - sum(Sel(:));
    
    % Exclusion region to have minimal distance between 2 samples
    Pixel_per_sample = numel(Img)/Rest;
    MinDist = floor(ceil(sqrt(Pixel_per_sample))/2)+0;
    [X,Y]=meshgrid(-MinDist:MinDist,[-MinDist:-1,0:MinDist]);
    Cake = sqrt(X.^2+Y.^2)>MinDist;
    

    Add   = ones(size(Img,1)+size(Cake,1),size(Img,2)+size(Cake,2));
    Add(MinDist+1:end-MinDist-1,MinDist+1:end-MinDist-1)=Sel;
    posis = find(Add==0);
    Cntr  = randperm(numel(posis));
    %Add(posis(Cntr(1:Rest)))=1;
    
    Lookup = ~Add;
    
    cntr=0;
    
    Cntr = posis(Cntr);
    
    for crnt = 1:numel(Cntr);
        if Lookup(Cntr(crnt)) == 0
            continue
        end
        Add(Cntr(crnt)) = 1;
        [x_c,y_c]=ind2sub(size(Add),Cntr(crnt));
        Lookup(x_c-MinDist:x_c+MinDist,y_c-MinDist:y_c+MinDist) = Lookup(x_c-MinDist:x_c+MinDist,y_c-MinDist:y_c+MinDist).*Cake;
        cntr = cntr + 1;
         if cntr == Rest
             break;
         end
    end
    
    % Final selection array
    Sel = Add(MinDist+1:end-MinDist-1,MinDist+1:end-MinDist-1);
end

