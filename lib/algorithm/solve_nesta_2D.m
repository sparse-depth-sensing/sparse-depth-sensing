function [zFast,timeFast,iterFast] = solve_nesta_2D(TV2,y,R,samples,epsilon,typemin,xInit,mu)

if nargin < 8
    mu = 0.001; % 05;
end

opts = [];
opts.TOlVar = 1e-6;
opts.verbose = 0; % show intermediate results
% opts.errFcn = @(x) norm( TV2 * x , 1 ); % only for debug: displayed at the end of each iteration
opts.D = TV2;

if strcmp(lower(typemin),'tv2_cartesian')
    tic
    opts.normU = sqrt(eigs(TV2' * TV2,1,'LM'));
    time_compute_norm = toc;
    % disp(sprintf('tv2_cartesian norm computation time = %f', time_compute_norm))
end


opts.stoptest = 1;
opts.maxiter = 10000;
opts.typemin = typemin;
opts.typecon = 'Linf';
% warning('using naive initialization')
opts.xplug = xInit;
opts.samples = samples;
counter();
Rhandle = @(x) R*x;
Rt = R';
Rthandle = @(x) Rt*x;
Ac = @(z) counter(Rhandle,z);
Atc = @(z) counter(Rthandle,z);

tic;
[zFast,iterFast,~,~,timeFast] = myNESTA(Ac,Atc,y,mu,epsilon,opts);
time_nesta = toc;
% disp(['myNESTA time: ', num2str(time_nesta)])