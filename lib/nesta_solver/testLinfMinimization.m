clear all
close all
clc

N = 100;
Nm2 = N-2;
K = 10;
samples = randperm(N,K);
nonsamples = setdiff([1:N],samples);
epsilon = 0.1;
D = rand(Nm2,N);
Dt = D';
DtS = Dt(samples,:);
DtSc = Dt(nonsamples,:);
theta = rand(Nm2,1);
y = rand(K,1);

%% test intermediate step
cvx_begin
cvx_quiet true
cvx_precision best
variable vs(K,1);
minimize( epsilon * vs' * (DtS * theta) )
subject to
norm( vs, Inf) <= 1;
cvx_end

expected = cvx_optval;
actual = - epsilon * norm(DtS * theta,1);
if abs(actual - expected) > 1e-3
   error('mismatch in cost 1') 
end

%% test primal VS dual
cvx_begin
cvx_quiet true
cvx_precision best
variable x(N,1);
minimize( norm(D*x,1) )
subject to
norm( x(samples) - y, Inf) <= epsilon;
cvx_end
pstar = cvx_optval

cvx_begin
cvx_quiet true
cvx_precision best
variable theta(Nm2,1);
maximize( y' * DtS * theta - epsilon * norm(DtS * theta,1) )
subject to
norm( theta , Inf) <= 1;
DtSc * theta == 0;
cvx_end
dtar = cvx_optval

cvx_begin
cvx_quiet true
cvx_precision best
variable theta(Nm2,1);
minimize( epsilon * norm(DtS * theta,1) - y' * DtS * theta )
subject to
norm( theta , Inf) <= 1;
DtSc * theta == 0;
cvx_end
dtar2 = -cvx_optval

% x - Dt * theta