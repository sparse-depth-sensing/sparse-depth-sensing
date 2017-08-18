% Compute wavelet transformation. Currently implemented using Matlab
% wavelet toolbox.
% (c) Simon Hawe, Lehrstuhl fuer Datenverarbeitung Technische Universitaet
% Muenchen, 2011. Contact: simon.hawe@tum.de
% classdef Wavelet < BaseOperator
%     properties
%     %    S
%     %    Level
%     %    Type
%            SZ
%            imSZ
%     end
%     methods
% %         function obj = Wavelet(Image, Type, Level)
% %             [~,s]           = wavedec2(Image, Level, Type);
% %             obj.S           = s;
% %             obj.Level       = Level;
% %             obj.Type        = Type;
% %         end
% %----------------------Modified Code-------------------------------------
%        function obj = Wavelet(Image)
%            c=cd('C:\Users\Lester\Dropbox\L_SparseReconstructionPapers\Code\CurveLab-2.1.3\fdct_wrapping_matlab');
%            C = fdct_wrapping(double(Image),0);
%            cd(c);
%            
%            % Stack all coefficients from cells
%            % coef =[];
%            for s=1:length(C)
%                for w=1:length(C{s})
%                     %coef =[coef; C{s}{w}(:)];
%                     sz{s}{w}=size(C{s}{w});
%                end
%            end
%           obj.SZ= sz;
%           obj.imSZ=size(Image);
%        end
% %--------------------End of Modified Code-----------------------------
%         function res = mtimes(obj,coef)
%             if obj.adjoint
%                 % Make the wavelet reconstruction
%                 %res = waverec2(b, obj.S, obj.Type);
%                 %---------------------Modified Code------------------------
%                 % Do Curvelet reconstruction
%                  loc=1;
%                 for s=1:length(obj.SZ)
%                     for w=1:length(obj.SZ{s})
%                        r=obj.SZ{s}{w}(1);
%                        c=obj.SZ{s}{w}(2);
%                        vec = coef(loc:loc+(r*c)-1);
%                        loc = loc +(r*c);
%                        C{s}{w} = reshape(vec,[r c]);
%                     end
%                 end      
%                   c=cd('C:\Users\Lester\Dropbox\L_SparseReconstructionPapers\Code\CurveLab-2.1.3\fdct_wrapping_matlab');
%                 res = ifdct_wrapping(C,0);
%                 %res = res(:);
%                 cd(c);
%                 %--------------End of Modified Code---------------------
%             else
%                 % Make the wavelet decomposition
%                 % res = wavedec2(b, obj.Level, obj.Type)';
%                 %--------------------Modified Code-------------------------
%                 % Do Curvelet decomposition
%                 X = reshape(coef,obj.imSZ);
%                 c=cd('C:\Users\Lester\Dropbox\L_SparseReconstructionPapers\Code\CurveLab-2.1.3\fdct_wrapping_matlab');
%                 C = fdct_wrapping(double(X),0);
%                 cd(c);
%                 coef =[];
%                for s=1:length(C)
%                    for w=1:length(C{s})
%                     coef =[coef; C{s}{w}(:)];
%                     %sz{s}{w}=size(C{s}{w});
%                    end
%                end
%                res = coef;
%                 %-------------End of Modified Code-----------------------
%             end
%         end
%         
%         function res = eq(obj,b)
%             res = eq@BaseOperator(obj,b);
%             if res
%                % res = (obj.Level == b.Level)    && ... 
%                %        strcmp(obj.Type,b.Type)      && ... 
%                %       (obj.S(end,1) == b.S(end,1)) && (obj.S(end,2) == b.S(end,2));
%                    res = (obj.imSZ(1) == b.imSZ(1)) && (obj.imSZ(2) == b.imSZ(2));
%             end
%         end
%     end
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef Wavelet < BaseOperator
    properties
        S
        Level
        Type
    end
    methods
         function obj = Wavelet(Image, Type, Level)
             [~,s]           = wavedec2(Image, Level, Type);
             obj.S           = s;
             obj.Level       = Level;
             obj.Type        = Type;
         end
        function res = mtimes(obj,b)
            if obj.adjoint
                % Make the wavelet reconstruction
                res = waverec2(b, obj.S, obj.Type);
            else
                % Make the wavelet decomposition
                 res = wavedec2(b, obj.Level, obj.Type)'; 
            end
        end
        
        function res = eq(obj,b)
            res = eq@BaseOperator(obj,b);
            if res
               res = (obj.Level == b.Level)    && ... 
                      strcmp(obj.Type,b.Type)      && ... 
                     (obj.S(end,1) == b.S(end,1)) && (obj.S(end,2) == b.S(end,2));     
            end
        end
    end
end

% classdef Wavelet < BaseOperator
%     properties
%     %    S
%     %    Level
%     %    Type
%            SZ
%            imSZ
%            % Contourlet Parameters
%            nlev_SD
%            smooth_func
%            Pyr_mode
%            dfilt
%     end
%     methods
% %         function obj = Wavelet(Image, Type, Level)
% %             [~,s]           = wavedec2(Image, Level, Type);
% %             obj.S           = s;
% %             obj.Level       = Level;
% %             obj.Type        = Type;
% %         end
% %----------------------Modified Code for Contourlet-------------------------------------
%        function obj = Wavelet(Image,nlev_SD0 , smooth_func0 , Pyr_mode0,dfilt0)
%        % Contourlet Parameter Setting
%        obj.nlev_SD=nlev_SD0;
%        obj.smooth_func = smooth_func0;
%        obj.Pyr_mode = Pyr_mode0;
%        obj.dfilt = dfilt0;
%        
%        c=cd('C:\Users\Lester\Dropbox\L_SparseReconstructionPapers\Code\ContourletSD\Matlab');
%        % Contourlet transform
%        coeffs=ContourletSDDec(Image, nlev_SD0, Pyr_mode0, smooth_func0, dfilt0);
%        % Convert into the vector format
%        [CT_c CT_s] =  pdfb2vec(coeffs); 
%        cd(c);
%            
%        obj.SZ= CT_s;
%        obj.imSZ=size(Image);
%        end
% %--------------------End of Modified Code-----------------------------
%         function res = mtimes(obj,Y)
%             if obj.adjoint
%                 % Make the wavelet reconstruction
%                 %res = waverec2(b, obj.S, obj.Type);
%                 %---------------------Modified Code------------------------
%                 % Contourlet reconstruction
%                c=cd('C:\Users\Lester\Dropbox\L_SparseReconstructionPapers\Code\ContourletSD\Matlab');
%                coeffs = vec2pdfb(Y, obj.SZ);
%                % Reconstruct image
%                res=ContourletSDRec(coeffs, obj.Pyr_mode, obj.smooth_func, obj.dfilt);
%                 cd(c);
%                 %--------------End of Modified Code---------------------
%             else
%                 % Make the wavelet decomposition
%                 % res = wavedec2(b, obj.Level, obj.Type)';
%                 %--------------------Modified Code-------------------------
%                 % Contourlet decomposition
%                c=cd('C:\Users\Lester\Dropbox\L_SparseReconstructionPapers\Code\ContourletSD\Matlab');
%                % Contourlet transform
%                coeffs=ContourletSDDec(Y, obj.nlev_SD, obj.Pyr_mode, obj.smooth_func, obj.dfilt);
%                % Convert into the vector format
%                [CT_c CT_s] =  pdfb2vec(coeffs); 
%                cd(c);
%                res= CT_c;
%                 %-------------End of Modified Code-----------------------
%             end
%         end
%         
%         function res = eq(obj,b)
%             res = eq@BaseOperator(obj,b);
%             if res
%                % res = (obj.Level == b.Level)    && ... 
%                %        strcmp(obj.Type,b.Type)      && ... 
%                %       (obj.S(end,1) == b.S(end,1)) && (obj.S(end,2) == b.S(end,2));
%                    res = (obj.imSZ(1) == b.imSZ(1)) && (obj.imSZ(2) == b.imSZ(2));
%             end
%         end
%     end
% end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

