% Base class for solving optimization problems of the form
% minimize f(x) + lambda g(x)
% (c) Simon Hawe, Lehrstuhl fuer Datenverarbeitung Technische Universitaet
% Muenchen, 2011. Contact: simon.hawe@tum.de
classdef Optimizationbase < handle & hgsetget
    %% Accessible from outside
    properties
        t                   = 1;    % Stepsize
        alpha               = 1e-5; % First linesearch parameter
        beta                = .8;   % Second linesearch parameter
        maxLineSearchSteps  = 100;
        p_norm              = 1;    % That�s currently just for testing
        delta_conv          = 1e-8; % Parameter for stopping iterations
        max_iterations      = 500;  % Maximum number of iterations
        verbose             = 1;    % If == 0 no output, otherwise every veboseth frame 1 output
        side_eval_function  = {};   % If this is a function handle, this function will be evaluate when verbose is true
        lambda              = 1;    % Lagrange Multiplier
        lambda_min                  % Minimum Lagrange Multiplier if continuation
        lambda_st           = 1;
        l1Smooth                    % l1-norm smoothing term
    end
    
    properties (SetAccess = protected)
        %% Variable Required for the optimization
        k = 0;          % Current iteration
        f0              % Last value ob objective function
        max_cont        %
        
        %% Vectors used throughout the optimization
        x           % Variable to be optimized
        dx          % Stepdirection
        y           % Measured Data
        g           % Previous Gradient
        c_y         % Store A*x-y = c_y
        c_dy        % Store A*dx  = c_dy
        sp_x        % Store W*x   = sp_x
        sp_dx       % Store W*dx  = sp_dx
          
        %% Things to control the stopping
        gx_old = zeros(11,1);
    end
    
    methods
        %% This function evalutes the total cost function to be minimized.
        %  As we are dealing with unconstrainted lagrange functions, this
        %  always has the form objective + lambda* regularizer
        function obj = Evalute(obj)
            gx = g_x(obj);
            fx = f_x(obj);
            %fprintf('Value of Inf Norm: %f\n',obj.lambda_st);
            %obj.lambda = min(1,min(obj.lambda,obj.lambda_st));
            % Required for the stopping criterion
            obj.gx_old = [obj.gx_old(2:end);gx];
            obj.f0 = fx + obj.lambda*gx;
        end
        
        %% linesearch updating the direction
        function [obj,worked] = linesearch(obj)
            ls_iter     = 0;
            t0          = obj.t;
            f_c         = obj.f0;
            worked      = 1;
            val = obj.alpha * ((obj.g(:)'*obj.dx(:)));
            %Performing the linesearch
            while (ls_iter == 0) || ... % Quasi Do while loop
                    (obj.f0 > f_c + obj.t *val) && ... % Check Wolfe Condition
                    (ls_iter < obj.maxLineSearchSteps) % Check Maximum number of Iterations
                
                
                % Evalute the Objective Function at the taken step
                Evalute(obj);
                % Increase the number of linesearch iterates as we only
                % allow a certain amount of steps
                ls_iter = ls_iter + 1;
                % Update the step size
                obj.t  = obj.t*obj.beta;

            end
            
            if ls_iter >= obj.maxLineSearchSteps
                worked = 0;
                return;
            end
            
            update_variables(obj);
            
            obj.t  =  obj.t/obj.beta;
            if ls_iter == 1
                obj.t  =  t0;
            end
            
        end
        
        
        %% Update everything for the next iteration
        function [obj, stop] = next_iteration(obj, cg_beta, g_new)
            stop = 0;
            
            if obj.k >= numel(obj.gx_old)
                mean_gx = mean(obj.gx_old(1:end-1));
                delta_gx = abs(obj.gx_old(end)-mean_gx)/mean_gx;
%                 fprintf('delta_gx: %f\n',delta_gx);
                if delta_gx <= obj.delta_conv
                    stop = 1; return;
                end
            end
            
            % Update the iteration counter
            obj.k  = obj.k  + 1;
            
            if obj.k > obj.max_iterations
                stop = 1; return;
            end
            
            if obj.verbose && ~mod(obj.k,obj.verbose)
                for func_id = 1:numel(obj.side_eval_function)
                    if isa(obj.side_eval_function{func_id},'function_handle')
                        obj.side_eval_function{func_id}(obj.x);
                    end
                end
            end
            % Update the step direction with current gradient and computed
            % CG value
            obj.dx = -g_new + cg_beta*obj.dx;
            % Store the Gradient
            obj.g  = g_new;
            preobjective(obj);
        end
        
        %% This function must be overloaded if other variable are added
        %  that should be updated
        function obj = update_variables(obj)
            obj.x    = obj.x     + obj.t * obj.dx;
            obj.c_y  = obj.c_y   + obj.t * obj.c_dy;
            obj.sp_x = obj.sp_x  + obj.t * obj.sp_dx;
        end
        
    end
    
    methods (Static)
        %% Gradient of the l1-norm Term
        function grad_g = dg_x(W, sp_x, l1Smooth, p_norm)
            if l1Smooth == 0 && p_norm == 1
                grad_g = W' * sign(sp_x);
            else
                %grad_g = W' * (sp_x./sqrt(sp_x.*conj(sp_x)+ l1Smooth));
                grad_g = p_norm * (W' * (sp_x.*(sp_x.*conj(sp_x)+ l1Smooth).^(p_norm/2-1)));
            end
        end
    end
    
    %% Abstract methods that must be reimplemented by inheriting classes
    methods (Abstract)
        val = f_x(obj)    % Objective   Function
        val = g_x(obj)    % Regularizer Function
        obj = preobjective(obj)
    end
    
end


