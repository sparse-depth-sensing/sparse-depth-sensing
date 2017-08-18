% minimize f(x) + lambda*g(x)
% f(x) = 1/2||M'*PHI'*x - y ||_2^2 with PHI being an orthonormal basis
% g(x) = || x ||_1 + gamma*|| PHI'*x ||_TV
% (c) Simon Hawe, Lehrstuhl fuer Datenverarbeitung Technische Universitaet
% Muenchen, 2011. Contact: simon.hawe@tum.de
classdef CSTVWav < Optimizationbase
    properties
        TVM
        W2
        tvSmooth
        gamma
        tv_x
        tv_dx
        PSI    = 1; % Measurement Basis
        PHI    = 1; % Densifying transformation
        W      = 1;  % Sparsifying transformation
        Weight = 1; % Weighting Matrix
        M           % This extracts the required points
        tv_method = 'aniso'
    end
    methods
        %% Constructor
        function obj   = CSTVWav(y, PHI_in, PSI_in, M_in, W_in, Weight_in, TVM_in, W2_in, l1Smooth, tvSmooth)
            
            if exist('PHI_in','var') && ~isempty(PHI_in)
                obj.PHI    = PHI_in;
            end
            
            if exist('PSI_in','var') && ~isempty(PSI_in)
                obj.PSI    = PSI_in;
            end
            
            if exist('W_in','var') && ~isempty(W_in)
                obj.W      = W_in;
            end
            
            if exist('M_in','var') && ~isempty(M_in)
                obj.M      = M_in;
            end
            
            if exist('Weight_in','var') && ~isempty(Weight_in)
                obj.Weight = Weight_in;
            end
            
            % Creating Measurements
            obj.y      = y;
            
            % Computing Inital Guess of the reconstructed signal
            obj.x      = obj.PSI'*(obj.PHI'*(obj.M'*obj.y));
            
            % Setting the smoothing value for the derivative
            obj.l1Smooth    =  l1Smooth;
            
            obj.max_cont = 1e-7*max(abs(obj.x(:)));
            
            
            obj.TVM         = TVM_in;
            obj.W2          = W2_in;
            obj.tvSmooth    = tvSmooth;
            obj.gamma       = 10;
            obj.lambda      = .01;
        end
        
        %% Init function for CG method or even GD method
        function obj = init(obj)
            % First we set t = 0 to evalute this function at the current
            % poistion
            obj.t   = 0;
            
            % If obj.W == 1 this mean x is in the sparse version, and it
            % has to be retranslated into a dense version
            
            xx        = obj.W2 * obj.x;    % L: Transform it back to spatial domain
            obj.tv_x  = obj.TVM * xx;      % L: Find the total variation of the spatial domain
            obj.c_y   = obj.M*(obj.PHI*(xx)) - obj.y; % L: cost comparing with the measurement
            
            obj.sp_x  = obj.W * obj.x;     %L : W=1
            
            
            % Computing the gradient
            obj.g   = gradient(obj);
            %Setting the descent direction
            obj.dx  = -obj.g;
            preobjective(obj);   % calculate c_dy, tv_dx, sp_dx
            Evalute(obj);            % update cost fun
            % Set it back to the inital values
            obj.t   = 1;
            obj.k   = 0;
            %obj.lambda = obj.lambda_st;
            
        end
        
        %% Gradient of the objective function
        function grad_f = df_x(obj)    % Objective   Function
            % We store this, because this values is always needed for
            % evaluating the objective function.  In this way it is
            % computed only once
            grad_f          = obj.PSI'*( obj.PHI'* (obj.M'* obj.c_y));
            obj.lambda_st   = max(obj.max_cont,0.05*max(abs(grad_f(:))));   % not yet checked
            % fprintf('Infnorm: %.4f\n',max(grad_f(:)));
        end
        
        %% Objective Function
        function val = f_x(obj)
            val = obj.c_y + obj.t*obj.c_dy;
            val = 0.5*val(:)'*val(:);
        end
        
        
        
        %% Computing the entire gradient
        function grad = gradient(obj)
            grad_f = df_x(obj);
            grad_g1 = obj.dg_x(obj.W, obj.Weight*obj.sp_x, obj.l1Smooth,1);
            
            
            %            grad_g2 = obj.W2'*(obj.dg_x(obj.TVM, obj.tv_x, obj.tvSmooth,1));
            if strcmp(obj.tv_method,'iso')
                %% Isotropic Huber
                denom          = sqrt((sum(obj.tv_x.^2,3)));
                sel            = denom<obj.tvSmooth;
                sel            = cat(3,sel,sel);
                grad_g2        = bsxfun(@times,obj.tv_x,1./denom);  % 
                grad_g2(sel)   = obj.tv_x(sel)/obj.tvSmooth;
                
            else
                %% anisotropic Huber
                denom          = abs(obj.tv_x);
                sel            = denom<obj.tvSmooth;
                grad_g2        = sign(obj.tv_x);
                grad_g2(sel)   = obj.tv_x(sel)/obj.tvSmooth;
            end
            grad_g2        = obj.W2'*(obj.TVM'*grad_g2);
            
            
            %%
            if obj.l1Smooth == 0
                grad            = (grad_f + grad_g2*obj.gamma*obj.lambda)/obj.lambda;
                % Finding the zeros in the subgradient of the l1 term
                SEL             = (grad_g1 == 0);
                Comp            = grad(SEL);
                SEL2            = abs(Comp)>=1;
                Comp(SEL2)      = sign(Comp(SEL2));
                % Setting the zeros to the respective values either -sign or -value
                grad_g1(SEL)    = -Comp;
                grad            = (grad + grad_g1)*obj.lambda;
            else
                grad = (grad_f + grad_g2*obj.gamma*obj.lambda + obj.lambda*grad_g1);
            end
            
        end
        
        %% Preobjective function required for accelerating the algorithmn
        function obj = preobjective(obj)
            
            xx        = obj.W2 * obj.dx;
            obj.tv_dx  = obj.TVM * xx;
            obj.c_dy   = obj.M*(obj.PHI*(xx));
            
            obj.sp_dx  = obj.dx;
            
        end
        
        function obj = update_variables(obj)
            obj = update_variables@Optimizationbase(obj);
            obj.tv_x = obj.tv_x  + obj.t * obj.tv_dx;
        end
        
        %% Regularizer Function
        function val = g_x(obj)
            val = obj.Weight*(obj.sp_x + obj.t * obj.sp_dx);
            if obj.l1Smooth == 0
                val = sum(abs(val(:)));
            else
                val = sqrt(val.*conj(val)+obj.l1Smooth);
                val = sum(val(:));
            end
            
            val2 = obj.tv_x + obj.t * obj.tv_dx;
            
            %% Non Isotropic Smoothing
            %            val2 = sqrt(val2.*conj(val2)+obj.tvSmooth);
            
            if strcmp(obj.tv_method,'iso')
                %% Isotropic Huber
                val2       = sqrt(sum(val2.^2,3));
            else
                %% Non Isotropic Huber
                val2       =abs(val2);
            end
            sel        = val2<obj.tvSmooth;
            val2(~sel) = val2(~sel)-obj.tvSmooth/2;
            val2(sel)  = val2(sel).^2./(obj.tvSmooth*2);
            
            
            val2 = sum(val2(:));
            
            val = val + val2*obj.gamma;
        end
        
    end
end