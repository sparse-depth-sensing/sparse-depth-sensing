% Extracted the indices given by M. Applied as a Matrix Vector
% Multiplication. When numel(M)==m and Input size == n this can be thought
% of as a multiplication by an (m x n) matrix.
% (c) Simon Hawe, Lehrstuhl fuer Datenverarbeitung Technische Universitaet
% Muenchen, 2011. Contact: simon.hawe@tum.de
classdef Extraction < BaseOperator
    properties
        M
        sz
    end
    methods
        function obj = Extraction(M,sz)
            obj.M = unique(M);
            obj.sz = sz;
        end
        function res = mtimes(obj,b)
            if obj.adjoint
                res = zeros(obj.sz);
                res(obj.M) = b;
            else
                res = b(obj.M);
            end
        end
    end
end


