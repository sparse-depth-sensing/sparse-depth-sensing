function xout = ADMM_outer(S0,b0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   xout = ADMM_outer(S0,b0)
%   reconstruct dense disparity map, xout, from initial observation, b0,
%   and sampling map, S0. The reconstruction process solves the following
%   convex problem :
%
%          min (1/2) || S*r - b ||_2^2 + lambda1*||W1*u1||_1 + lambda2*||W2*u2||_1  + beta*||v||_1
%            x
%
%          subject to :       r  = x
%                             u1 = B1*x
%                             u2 = B2*x
%                             v  = D*x
%    Inputs:
%          S             - sampling matrix
%          b             - observation matrix, gray scale, double format, range [0 ~ 1]
%          B1            - wavelet transformation matrix {Wavelet}
%          B1_size       - size information for  wavelet transform
%          B2            - contourlet transformation matrix {Contourlet}
%          B2_size       - size information for contourlet transform
%          W1            - diagonal matrix with zeros at approximation coefficients and ones at detail coefficients,  for Wavelet transformation
%          W2            - diagonal matrix with zeros at approximation coefficients and ones at detail coefficients,  for Contourlet transformation
%
%     param.wname        - types of wavelet function {db2}
%     param.wlevel       - number of levels for wavelet transform {2}
%     param.nlev_SD      - directional filter partition numbers { [5 6] }
%     param.smooth_func  - smooth function for Lacian Pyramid {@rcos}
%     param.Pyr_mode     - reduneancy setting for the transformed coefficients {2}
%     param.dfilt        - filter used for directional filtering {'9-7'}
%     param.lambda1      - regulization parameter for L1_Wavelet term
%     param.lambda2      - regulization parameter for L1_Contourlet term
%     param.gamma        - regulizer parameter for totalvariation term
%     param.tol          - tolerance for stop condition
%     param.max_itr      - maximum iteration for reconstruction
%
%     Lee-Kang (Lester) Liu and Stanley Chan
%     Copyright 2013
%     University of California, San Diego
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Initialize parameters
        param.wname            = 'db2';                % types of wavelet function
        param.wlevel           = 2;                    % number of levels for wavelet transform
        param.nlev_SD          = [5 6];                % directional filter partition numbers
        param.smooth_func      = @rcos;                % smooth function for Lacian Pyramid
        param.Pyr_mode         = 2;                    % reduneancy setting for the transformed coefficients
        param.dfilt            = '9-7';                % 9-7 bior filter for directional filtering
        param.lambda1          = 4e-5;                 % regulizer parameter for L1_Wavelet term 
        param.lambda2          = 2e-4;                 % regulizer parameter for L1_Contourlet term 
        param.beta             = 2e-3;                 % regulizer parameter for totalvariation term 
        param.max_itr          = 150;                  % maximum iteration for reconstruction
        param.tol              = 1e-5;                 % tolerance for stop condition
    
        [D, ~]            = defDDt;
    
    % add contourlet toolbox
    addpath(genpath('ContourletSD\'));
    
for ilevel = 2:-1:0
    b = imresize(b0,2^(-ilevel),'nearest');
    S = imresize(S0,2^(-ilevel),'nearest');

%    initialization
    if ilevel==2
        x = b;
    else
        x = imresize(xout,2);
    end
    
    r                  = x;
    [u1 B1_size]       = wavedec2(x,param.wlevel,param.wname);
    B2_Coeff           = ContourletSDDec(x, param.nlev_SD, param.Pyr_mode, param.smooth_func, param.dfilt);
    [u2, B2_size]      = pdfb2vec(B2_Coeff);
    v                  = D(x);
    
    W1 = ones(size(u1));
    W2 = ones(size(u2));
    W1(1:B1_size(1,1)*B1_size(1,2)) = 0;
    W2(1:B2_size(1,3)*B2_size(1,4)) = 0;
    
    w  = zeros(size(r));
    y1 = zeros(size(u1));
    y2 = zeros(size(u2));
    z  = zeros(size(v));
    
    xout = ADMM_inner(S,b,x,r,u1,u2,v,w,y1,y2,z,W1,W2,B1_size,B2_size,param);
    
end
