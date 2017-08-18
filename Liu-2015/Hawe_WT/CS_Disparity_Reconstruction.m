% (c) Simon Hawe, Lehrstuhl fuer Datenverarbeitung Technische Universitaet
% Muenchen, 2011. Contact: simon.hawe@tum.de
% This is a modification for disparity map reconstruction from sparse
% samples.
%
% by Lee-Kang Lester Liu 04/19/2013
%

function output=CS_Disparity_Reconstruction(Signal,SignalSampleMap)

        Percentage  = 0.07;
        
        % In this file all parameters specific for this kind of CG reconstruction
        % are initialized. It's not in the main file just for readabilty. It's not
        % a function for simply hacky debugging :)

        iccv_setup;
        
        for lev = 1:1
            % Select conjugate gradient methd
            CG_method   = 'HS';
            % Set convergence threshold
            l1min.delta_conv = 1e-6;
            
            for i = 1:2
                l1min.lambda  =0.05;
                conjugate_gradient(l1min, CG_method,Disp_mat, Signal);
                l1min.lambda    = l1min.lambda*.01;
                l1min.tvSmooth  = l1min.tvSmooth*.01;
                l1min.tv_method = 'iso';
            end
        end
        
      
    X = (real(Disp_mat*l1min.x));XX=double((abs(X)));
    output=uint8(XX);
  
