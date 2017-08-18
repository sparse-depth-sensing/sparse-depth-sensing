function xout=ADMM_WT(S,b,param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   xout = ADMM_WT(S,b,param)
%   reconstruct dense disparity map, xout, from initial observation, b,
%   and sampling map, S. The reconstruction process solves the following
%   convex problem :
%
%          min (1/2) || S*r - b ||_2^2 + lambda1*||W1*u1||_1 +  beta*||v||_1
%            x
%
%          subject to :       r = x
%                             u1 = B1*x
%                             v = D*x
%    Inputs:
%              S           - sampling matrix
%              b           - observation matrix, gray scale, double format, range [0 ~ 1]
%              B1          - wavelet transformation matrix {Wavelet}
%         B1_size          - size information for  wavelet transform
%              W1          - diagonal matrix with zeros at approximation coefficients and ones at detail coefficients,  for Wavelet transformation
%     param.wname          - types of wavelet function {db2}
%     param.wlevel         - number of levels for wavelet transform {2}
%     param.lambda1        - regularization parameter for Wavelet sparsity term {4e-5}
%     param.beta           - regularization parameter for total variation term {2e-3}
%     param.tol            - tolerance for stop condition {1e-5}
%     param.max_itr        - maximum iteration for reconstruction {400}
%
%    Internal parameters :
%      rho1      :   internal half quadratic penalty for Wavelet {0.001}
%      mu        :   internal half quadratic penalty for r = x {0.01}        
%      gamma     :   internal half quadratic penalty for v = Dx {0.1}
%
%    Lagrange multipliers :
%      w         :   Lagrange multilpier for (r-x)
%      y1        :   Lagrange multiplier for (u1-B1*x)
%      z         :   Lagrange multiplier for (v-D*x)
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
    param.wname = 'db2';                   % types of wavelet function
end

if ~isfield(param,'wlevel')
    param.wlevel = 2;                      % number of levels for wavelet transform
end

if ~isfield(param,'lambda1')
    param.lambda1 = 4e-5;                  % regulizer parameter for L1_Wavelet term
end

if ~isfield(param,'beta')
    param.beta    = 2e-3;                   % regulizer parameter for totalvariation term
end

if ~isfield(param,'max_itr')
    param.max_itr = 400;                    % maximum iteration for reconstruction
end

if ~isfield(param,'tol')
    param.tol     = 1e-5;                   % tolerance for stop condition
end

% initiate intermediate variables - r, u1, v, W1
x                   = b;
r                   = x;
[u1 B1_size]  = wavedec2(x,param.wlevel,param.wname);
v                 = D(x);

W1 = ones(size(u1));
W1(1:B1_size(1,1)*B1_size(1,2)) = 0;

% initiate intermediate variables - w, y1, z
w = zeros(size(r));
y1 = zeros(size(u1));
z = zeros(size(v));


cost1 = norm(r-x,'fro');
cost2 = norm(u1-wavedec2(x,param.wlevel,param.wname),'fro');
cost3 = sqrt(sum(sum(sum((v - D(x)).^2, 3))));

% fixed internal parameters rho1, mu and gamma
rho1 = 0.001;  
mu   = 0.01;
gamma= 0.1;   

% parameter settings
lambda1    = param.lambda1;
beta       = param.beta;
alpha  = 1.2;
zeta   = 0.95;

% pre-calculated fourier term
eigDtD = abs(fftn([1 -1],  [rows cols])).^2 + abs(fftn([1 -1]', [rows cols])).^2;

max_itr  = param.max_itr;
tol      = param.tol;


fprintf('Itr     relchg     \n');
for itr = 1:max_itr
    xold = x;
    
    % solving the x-subproblem
    rhs   = mu.*r + rho1.*waverec2(u1,  B1_size,param.wname) + gamma.*Dt(v) ...
              - ( w + waverec2(y1,B1_size,param.wname) + Dt(z));
    x      = real( ifft2( fft2(rhs)./((rho1+mu)+ gamma.*eigDtD)) );
    
    % solving the u-subproblem    
    tmpz1 = wavedec2(x,param.wlevel,param.wname);
    tmpu1 = tmpz1+(y1./rho1);
    u1    = max(abs(tmpu1)-(lambda1.*W1./rho1),0).*sign(tmpu1);
    
    % solving the r-subproblem
    r = (1./(S.^2 + mu)).*(w + mu*x + S.*b);

    % solving the v-subproblem
    tmpz2  = D(x);
    tmpu2  = tmpz2+(z./gamma);
    v     = max(abs(tmpu2)-(beta/gamma),0).*sign(tmpu2);
    
    % update multipliers
    w           = w - mu*(r - x);
    y1          = y1 - rho1*(u1 - tmpz1);
    z           = z - gamma*(v - tmpz2);
    
        % update penalty parameter
        new_cost1 = norm(r-x,'fro');
        new_cost2 = norm(u1-tmpz1,'fro');
        new_cost3 = (sum(sum(sum((v - tmpz2).^2, 3))));
    
        if(new_cost1 >= alpha*cost1)
            mu = mu*zeta;
        end
        if(new_cost2 >= alpha*cost2)
            rho1 = rho1*zeta;
        end
        if(new_cost3 >= alpha*cost3)
            gamma = gamma*zeta;
        end

        cost1 =new_cost1;
        cost2 =new_cost2;
        cost3 =new_cost3;
    
    relchg = norm(x - xold)/norm(x);
    
    fprintf('%3g \t %3.5e \n', itr, relchg);
    
    if (relchg<=tol)&&(itr>1)
        break;
    end
    
    figure(1); imshow(x);
    
end

xout = x;