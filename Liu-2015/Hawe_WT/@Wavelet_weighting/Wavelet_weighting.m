% Set all appoximation coefficients to zero. Can be applied in like a
% matrix
% (c) Simon Hawe, Lehrstuhl fuer Datenverarbeitung Technische Universitaet
% Muenchen, 2011. Contact: simon.hawe@tum.de
% classdef Wavelet_weighting < BaseOperator
%     properties
%         %S
%         end_weight
%     end
%     methods
%         function obj = Wavelet_weighting(Image)
%             c=cd('C:\Users\Lester\Dropbox\L_SparseReconstructionPapers\Code\CurveLab-2.1.3\fdct_wrapping_matlab');
%             C = fdct_wrapping(double(Image),0);
%             cd(c);
%            coef =[];
%            for s=1:length(C)
%                for w=1:length(C{s})
%                     coef =[coef; C{s}{w}(:)];
%                     sz{s}{w}=size(C{s}{w});
%                end
%            end
% %             p = 0.3;
% %             coef_out = sort(coef);
% %             thres = coef_out(floor(p*length(coef_out)));
% %             aa=find(coef<thres);
% %             
% %             sz=size(C{1}{1});    
% %             obj.end_weight = [1:sz(1)*sz(2), aa' ];
%             
%             sz=size(C{1}{1});    
%             obj.end_weight = 1:sz(1)*sz(2);
%         end
%         
%         function res = mtimes(obj,b)
%             b(obj.end_weight) = 0;
%             res = b;
%         end
%     end
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef Wavelet_weighting < BaseOperator
    properties
        %S
        end_weight
    end
    methods
        function obj = Wavelet_weighting(Image, Type, Level)
            [~,S]           = wavedec2(Image, Level, Type);
            %obj.S           = s;
            obj.end_weight = 1:S(1,1)*S(1,2);
        end
        
        function res = mtimes(obj,b)
            b(obj.end_weight) = 0;
            res = b;
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% classdef Wavelet_weighting < BaseOperator
%     properties
%         %S
%         end_weight
%     end
%     methods
%         function obj = Wavelet_weighting(Image, nlev_SD, Pyr_mode, smooth_func, dfilt)
%            c=cd('C:\Users\Lester\Dropbox\L_SparseReconstructionPapers\Code\ContourletSD\Matlab');
%            % Contourlet transform
%            coeffs=ContourletSDDec(Image, nlev_SD, Pyr_mode, smooth_func, dfilt);
%            % Convert into the vector format
%            [CT_c CT_s] =  pdfb2vec(coeffs); 
%            cd(c);
%             
%             obj.end_weight = 1:CT_s(1,3)*CT_s(1,4);
%         end
%         
%         function res = mtimes(obj,b)
%             b(obj.end_weight) = 0;
%             res = b;
%         end
%     end
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%