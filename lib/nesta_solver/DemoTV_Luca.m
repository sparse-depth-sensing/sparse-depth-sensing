clear all
close all
clc

%  min ||x||_TV s.t. ||b - A x||_2 <= epsilon
Setup_Nesta
addpath('../../myLib')
addpath('../')
TypeCon = 'Linf'; % Linf, L2
typemin = 'TV2'; % TV2, TV
methodsToTest = {'NESTA1','CVX'} % 'NESTA2','NESTA3'}

%% Create some GT matrix
n = 128;   %--- The data are n*n images
Dyna = 40; %--- Dynamic range in dB
N = n*n;
I = MakeRDSquares(n,7,Dyna);
x_true = I(:);
zz = zeros(N,1);

%% create TV2 matrix for optimization
switch  typemin
    case 'TV'
        [H1,V1] = createFiniteDiff1(n,n);
        TV_V = kron(speye(n), V1);
        TV_H = kron(H1',speye(n));
        TV = sparse([TV_V; TV_H]);
    case 'TV2'
        [H,V] = createFiniteDiff2(n,n);
        TV_V = kron(speye(n), V);
        TV_H = kron(H',speye(n));
        TV = sparse([TV_V; TV_H]);
    otherwise
        error('main: unknown typemin')
end

%% Samples
L = round(N*0.1);
samples = randperm(N,L);
Amat = speye(N); Amat = Amat(samples,:); % random rows
A = @(z) Amat*z;
At = @(z) Amat'*z;
b0 = A(x_true);
sigma = 0.1;
noise = sigma*randn(size(b0));
b = b0+noise;
epsilon = norm(b - A(I(:)));
if sigma == 0
   epsilon = 0; 
end

%% Setting up the experiment for Nesta
if any(strcmp(methodsToTest, 'NESTA1'))
    fprintf('running myNESTA:\n');
    mu = 0.2;
    opts = [];
    % opts.maxintiter = 4; % nr of continuation steps (def: 5)
    opts.TOlVar = 1e-5;
    opts.verbose = 0; % show intermediate results
    opts.errFcn = @(x) norm( TV * x , 1 ); % only for debug: displayed at the end of each iteration
    opts.maxiter = 10000;
    % U = @(z) z;
    % Ut = @(z) z;
    % opts.U = U;
    % opts.Ut = Ut;
    opts.D = TV;
    opts.stoptest = 1;
    opts.typemin = typemin;
    opts.typecon = TypeCon;
    opts.samples = samples;
    counter();
    Ac = @(z) counter(A,z);
    Atc = @(z) counter(At,z);
    [x_nesta,niter,resid,err,t.myNESTA] = myNESTA(Ac,Atc,b,mu,epsilon,opts);
else
    fprintf('skipping NESTA1: see methodsToTest variable \n');
    x_nesta = zz;
end
tvnesta = calctv(n,n,reshape(x_nesta,n,n));
Xnesta = reshape(x_nesta,n,n);

%% CVX version
tic;
if n < 300 && any(strcmp(methodsToTest, 'CVX'))
    if strcmpi(TypeCon,'L2')
        [xCVX,~,~] = minimizeL1cvx(TV,N,Amat,b,'l1',epsilon,epsilon,-1);
    elseif strcmpi(TypeCon,'Linf')
        [xCVX,~,~] = minimizeL1cvx(TV,N,Amat,b,'l1inf',epsilon,epsilon,-1);
    else
        error('wrong TypeCon for cvx')
    end
else
    fprintf('skipping CVX: problem is too large\n');
    xCVX = zz;
end
t.CVX = toc;
Xcvx = reshape(xCVX,n,n);

%% myNESTA, v2: manually setting TV matrix
if any(strcmp(methodsToTest, 'NESTA2'))
    fprintf('running myNESTA 2.0:\n');
    U = @(z) TV * z;
    Ut = @(z) TV' * z;
    mu = 0.2; %--- can be chosen to be small
    opts = [];
    % opts.maxintiter = 4; % nr of continuation steps (def: 5)
    opts.TOlVar = 1e-5;
    opts.verbose = 1;
    opts.maxiter = 10000;
    opts.U = U;
    opts.Ut = Ut;
    opts.stoptest = 1;
    opts.typemin = 'l1';
    counter();
    Ac = @(z) counter(A,z);
    Atc = @(z) counter(At,z);
    tic;
    [x_nesta2,niter2,resid2,err2] = myNESTA(Ac,Atc,b,mu,epsilon,opts);
else
    fprintf('skipping NESTA2: see methodsToTest variable \n');
    x_nesta2 = zz;
end
t.NESTA2 = toc;
tvnesta2 = calctv(n,n,reshape(x_nesta2,n,n));
Xnesta2 = reshape(x_nesta2,n,n);

%% myNESTA, v3: my implementation
fprintf('running myNESTA 3.0:\n');
% [x_nesta3,t.NESTA3,iterNesta3] = l2_reweighted_1D_linf_nesterov(TV,b,Amat,samples,delta);
x_nesta3 = zz;
Xnesta3 = reshape(x_nesta3,n,n);
t.NESTA3 = 0;

costNesta = norm(TV * x_nesta , 1);
costCVX   = norm(TV * xCVX , 1);
costNesta2 = norm(TV * x_nesta2 , 1);
costNesta3 = norm(TV * x_nesta3 , 1);

fprintf('======================= \n')
fprintf('myNESTA : cost = %g, time = %g \n',costNesta,t.myNESTA)
fprintf('CVX:    cost = %g, time = %g \n',costCVX,t.CVX)
fprintf('NESTA2: cost = %g, time = %g \n',costNesta2,t.NESTA2)
fprintf('NESTA3: cost = %g, time = %g \n',costNesta3,t.NESTA3)
fprintf('======================= \n')

%% Plot results
figure(1); clf;
subplot(2,3,1);
image( I );  title('Original image');
map = colormap(hsv); map(1,:) = [1,1,1]; colormap(map);
axis square; axis off
% myNESTA
subplot(2,3,2);
image(Xnesta); title(sprintf('Reconstruction via myNESTA\n%.1f sec',t.myNESTA));
axis square; axis off
% CVX
subplot(2,3,3);
image( Xcvx ); title(sprintf('Reconstruction via CVX\n%.1f sec',t.CVX));
axis square; axis off
% NESTA2
subplot(2,3,4);
image(Xnesta2); title(sprintf('Reconstruction via NESTA2\n%.1f sec',t.NESTA2));
axis square; axis off
% NESTA3
subplot(2,3,5);
image(Xnesta3); title(sprintf('Reconstruction via NESTA3\n%.1f sec',t.NESTA3));
axis square; axis off