% Base operator for performing Operations on arrays, vectors, an matrices without
% actually computing matrix vector or matrix matrix multiplications.
% However, the syntax is the same as computing matrix vector products.
% (c) Simon Hawe, Lehrstuhl fuer Datenverarbeitung Technische Universitaet
% Muenchen, 2011. Contact: simon.hawe@tum.de
classdef BaseOperator
    properties
        adjoint = 0;
    end
    methods        
        function res = eq(obj,b)
            res = false;
            if strcmp(class(obj),class(b)) && (obj.adjoint == b.adjoint)
                res = true;
            end
        end
        
        function obj = ctranspose(obj)
            obj.adjoint = ~obj.adjoint;
        end
        
        function res = times(obj,b)
            res = mtimes(obj,b);
        end

    end
    
    methods (Abstract)
        res = mtimes(obj,b)
    end
    
    
end