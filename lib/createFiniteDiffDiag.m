function [Hd,Vd] = createFiniteDiffDiag(Nx,Ny)
%
%  x3  0  x1
%  0   i  0
%  x4  0  x2
%
% Second order difference at i is
% (https://en.wikipedia.org/wiki/Finite_difference):
%
% fxy(i) = [f(x1) - f(x2)] - [f(x3) - f(x4)] 
%          ---------------------------------
%                          4
%
% In matrix form becomes Vd * X * Hd
%

% disp('starting create diagonal difference operators')
Vd = sparse(Nx-2, Nx, 3*(Nx-2)); % 3 nonzero elements per column
for i = 1 : Nx-2
    Vd(i,i:i+2) = 1/2 * [1 0 -1];
end
Hd = sparse(Ny, Ny-2, 3*(Ny-2)); % 3 nonzero elements per column
for i = 1 : Ny-2
    Hd(i:i+2,i) = [-1 0 +1]';
end