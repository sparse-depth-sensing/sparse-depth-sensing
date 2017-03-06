clear all
close all
clc

N = 100;
Nm2 = N-2;
K = 10;
samples = randperm(N,K);
nonsamples = setdiff([1:N],samples);
epsilon = 0.1;

y = 10 + randn(K,1);
c = randn(N,1);
xk = randn(N,1);
L = abs(randn);

%% expected
cvx_begin
cvx_quiet true
cvx_precision best
variable x(N,1);
minimize( L/2 * (x - xk)' * (x - xk) + c' * x )
subject to
norm( x(samples) - y, Inf) <= epsilon;
cvx_end

expected = x;
actual = xk - c/L;
actual(samples) = max(y-epsilon, actual(samples));
actual(samples) = min(y+epsilon, actual(samples));

if norm(actual - expected) > 1e-3
   error('mismatch in solution')
end
