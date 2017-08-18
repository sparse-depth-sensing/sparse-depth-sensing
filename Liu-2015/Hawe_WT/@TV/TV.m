% Currently uses mex file implementation. If you don't want the mex file
% implementation  just use the part that is commented.
% (c) Simon Hawe, Lehrstuhl fuer Datenverarbeitung Technische Universitaet
% Muenchen, 2011. Contact: simon.hawe@tum.de
classdef TV < BaseOperator
    properties
	
    end
    methods
        function obj = TV
        end
        function res = mtimes(obj,b)
            res = totalvariation(b);
            %% Plain Matlab TV implementation. For very large matrices this is a bit slower compared to the c implementation
%             if obj.adjoint
%                 div = sqrt(2);
%                 if obj.version == 1
%                     res1         =   b(:,[1,1:end-1],1)/div - b(:,:,1)/div;
%                     res1(:,1)    =   -b(:,1,1)/div;
% 
%                     res         =    b([1,1:end-1],:,2)/div - b(:,:,2)/div;
%                     res(1,:)    =   -b(1,:,2)/div;
%                 else
%                     res1         =   b(:,:,1)/div - b(:,[1,1:end-1],1)/div;
%                     res1(:,1)    =   b(:,1,1)/div;
%                     res1(:,end)  =   -b(:,end-1,1)/div;
% 
%                     res         = b(:,:,2)/div-b([1,1:end-1],:,2)/div;
%                     res(1,:)    = b(1,:,2)/div;
%                     res(end,:)  = -b(end-1,:,2)/div;
%                 end
%                 
% 
%                 res = res1 +  res;
% 
%             else
%                 div = sqrt(2);
%                 if obj.version == 1
%                     Dx = b(:,[2:end,end])/div - b/div;
%                     Dx(:,end) = -b(:,end)/div;
%                     Dy = b([2:end,end],:)/div - b/div;
%                     Dy(end,:) = -b(end,:)/div;
%                 else
%                     Dx = b(:,[2:end,end])/div - b/div;
%                     Dy = b([2:end,end],:)/div - b/div;
%                 end
% 
%                 res = cat(3,Dx,Dy);
%             end
        end
    end
    
    
end