function [H,V] = createFiniteDiff2(Nx,Ny)
%
% First order finite difference operator
% For an Nx x Ny image Z:
% Z*H returns the 2nd order difference in the horizontal direction
% H*V returns the 2nd order difference) in the vertical direction
%
% NOTE: If called with a single input Nx and output argument returns V
% which is the 2nd order difference operator to be applied to a vector of
% size Nx
% disp('starting create 2nd order difference operators')
% vertical direction 2nd derivative
V = sparse(Nx-2, Nx, 3*(Nx-2)); % 3 nonzero elements per column
for i = 1 : Nx-2
    V(i,i:i+2) = [1 -2 1];
end

% horizontal direction 2nd derivative
if nargin && nargout == 2
    H = sparse(Ny, Ny-2, 3*(Ny-2)); % 3 nonzero elements per column
    for i = 1 : Ny-2
        H(i:i+2,i) = [1 -2 1]';
    end
else
    H = V;
end
% disp('done!')








