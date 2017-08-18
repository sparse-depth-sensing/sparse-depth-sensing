% C implementation for computing finite differences or the total variation
% D*s and its transposed. If the input is an (n x m) Matrix/Image the output is a
% (n x m x 2) matrix with dx in (:,:,1) and dy in (:,:,2). If the input is
% a (n x m x 2) matrix the output is a n x m matrix.
% (c) Simon Hawe, Lehrstuhl fuer Datenverarbeitung Technische Universitaet
% Muenchen, 2011. Contact: simon.hawe@tum.de