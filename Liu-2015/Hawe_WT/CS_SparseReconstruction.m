function output=CS_SparseReconstruction(Signal, Ground_Truth,SignalSampleMap)

   c=cd('C:\Users\Lester\Dropbox\L_SparseReconstructionPapers\Code\Sparse Reconstruction-Code');
    
   iccv_setup
            
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
            
            X = (real(Disp_mat*l1min.x));
            XX=double((abs(X)));
            output=double(uint8(XX));
            cd(c);