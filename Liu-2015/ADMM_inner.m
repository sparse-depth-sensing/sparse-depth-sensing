function xout = ADMM_inner(S,b,x,r,u1,u2,v,w,y1,y2,z,W1,W2,B1_size,B2_size,param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   xout = ADMM_inner(S,b,x,u1,u2,u3,u4,y1,y2,y3,y4,W1,W2,B1_size,B2_size,param)
%   reconstruct dense disparity map, xout, from initial observation, b,
%   and sampling map, S. The reconstruction process solves the following
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
%   Internal parameters :
%      rho1      :   internal half quadratic penalty for Wavelet {0.001}
%      rho2      :   internal half quadratic penalty for Contourlet {0.001}
%      mu        :   internal half quadratic penalty for r = x {0.01}        
%      gamma     :   internal half quadratic penalty for v = Dx {0.1}
%
%    Lagrange multipliers :
%      w         :   Lagrange multilpier for (r-x)
%      y1        :   Lagrange multiplier for (u1-B1*x) 
%      y2        :   Lagrange multiplier for (u2-B2*x)
%      z         :   Lagrange multiplier for (v-D*x)
%
%
%     Lee-Kang (Lester) Liu and Stanley Chan
%     Copyright 2013
%     University of California, San Diego
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



[rows cols] = size(b);
[D, Dt]     = defDDt;

% check whether input parameters exist or not
if ~isfield(param,'wname')
    param.wname = 'db2';          % types of wavelet function
end

if ~isfield(param,'wlevel')
    param.wlevel = 2;             % number of levels for wavelet transform
end

if ~isfield(param,'nlev_SD')
    param.nlev_SD = [5 6];        % directional filter partition numbers
end

if ~isfield(param,'smooth_func')
    param.smooth_func = @rcos;    % smooth function for Lacian Pyramid
end

if ~isfield(param,'Pyr_mode')
    param.Pyr_mode = 2;           % reduneancy setting for the transformed coefficients
end

if ~isfield(param,'dfilt')
    param.dfilt   = '9-7';        % 9-7 bior filter for directional filtering
end

if ~isfield(param,'lambda1')
    param.lambda1 = 4e-5;          % regulization parameter for L1_Wavelet term
end

if ~isfield(param,'lambda2')
    param.lambda2 = 2e-4;          % regulization parameter for L1_Contourlet term
end

if ~isfield(param,'beta')
    param.beta  = 2e-3;           % regulization parameter for totalvariation term
end

if ~isfield(param,'max_itr')
    param.max_itr = 400;           % maximum iteration for reconstruction
end

if ~isfield(param,'tol')
    param.tol = 1e-5;              % tolerance for stop condition
end




cost1 = norm(r-x,'fro');
cost2 = norm(u1-wavedec2(x,param.wlevel,param.wname),'fro');
tmp_Coeff = ContourletSDDec(x, param.nlev_SD, param.Pyr_mode, param.smooth_func, param.dfilt);
[tmp_u2, B2_size] = pdfb2vec(tmp_Coeff);
cost3 =  norm(u2-tmp_u2,'fro');
cost4 = sqrt(sum(sum(sum((v - D(x)).^2, 3))));


% initialize fixed internal parameters mu, rho1, rho2, gamma
rho1 = 0.001;
rho2 = 0.001;
mu   = 0.01;
gamma= 0.1;

% regularization parameters 
lambda1  = param.lambda1;
lambda2  = param.lambda2;
beta     = param.beta;
alpha    = 1.2;
zeta     = 0.95;

% pre-calculated fourier term
eigDtD = abs(fftn([1 -1],  [rows cols])).^2 + abs(fftn([1 -1]', [rows cols])).^2;

max_itr  = param.max_itr;
tol      = param.tol;

fprintf('Itr     relchg     \n');
for itr=1:max_itr
    xold = x;
    
    % solve the x-subproblem
    tmp_u2_c      = vec2pdfb(u2, B2_size);
    rec_u2        = ContourletSDRec(tmp_u2_c, param.Pyr_mode, param.smooth_func, param.dfilt);
    tmp_y2_c      = vec2pdfb(y2, B2_size);
    rec_y2        = ContourletSDRec(tmp_y2_c, param.Pyr_mode, param.smooth_func, param.dfilt);
    rhs           =   mu*r ...
                     + rho1*waverec2(u1,  B1_size, param.wname) ...
                     + rho2*rec_u2 ...
                     + gamma*Dt(v) ...
                     - w - waverec2(y1,  B1_size,param.wname) - rec_y2 - Dt(z);
    x             = real( ifft2( fft2(rhs)./((rho1+rho2+mu)+ gamma.*eigDtD)) );
    
    % solve the u-subproblem
    tmpz1       = wavedec2(x,param.wlevel,param.wname);
    tmpu1       = tmpz1+(y1./rho1);
    u1          = max(abs(tmpu1)-(lambda1.*W1./rho1),0).*sign(tmpu1);
    
    tmpz2             =  ContourletSDDec(x, param.nlev_SD, param.Pyr_mode, param.smooth_func, param.dfilt);
    [tmp_u2, B2_size] = pdfb2vec(tmpz2);
    tmpu2             = tmp_u2 + (y2./rho2);
    u2                = max(abs(tmpu2)-(lambda2.*W2./rho2),0).*sign(tmpu2);
    
    % solve the r-subproblem    
    r              = (1./(S+mu)) .*(S.*b + w + mu.*x);
    
    % solve the v-subproblem
    tmpz3       = D(x);
    tmpu3       = tmpz3+(z./gamma);
    v           = max(abs(tmpu3)-(beta/gamma),0).*sign(tmpu3);
    
    % update Lagrange multipliers
    w          = w  - mu*(r - x);
    y1         = y1 - rho1*(u1 - tmpz1);
    y2         = y2 - rho2*(u2 - tmp_u2);
    z          = z  - gamma*(v - tmpz3);
    
    
    % update penalty parameter
        new_cost1 = norm(r-x,'fro');
        new_cost2 = norm(u1-tmpz1,'fro');
        new_cost3 = norm(u2-tmp_u2,'fro');
        new_cost4 = (sum(sum(sum((v - tmpz3).^2, 3))));
    
        if(new_cost1 >= alpha*cost1)
            mu = mu*zeta;
        end
        if(new_cost2 >= alpha*cost2)
            rho1 = rho1*zeta;
        end
        if(new_cost3 >= alpha*cost3)
            rho2 = rho2*zeta;
        end
        if(new_cost4 >= alpha*cost4)
            gamma = gamma*zeta;
        end
        cost1 =new_cost1;
        cost2 =new_cost2;
        cost3 =new_cost3;
        cost4 =new_cost4;
    
    relchg = norm(x - xold)/norm(x);
    
    fprintf('%3g \t %3.5e \n', itr, relchg);
    
    if (relchg<=tol)&&(itr>1)
        break;
    end
    
    figure(1); imshow(x);
   
    xout  = x;
end

