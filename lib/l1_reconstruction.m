function [ z ] = l1_reconstruction( height, width, R, y, settings)
% RECONSTRUCTION L1 reconstruction for sparse depth measurements
%   Detailed explanation goes here

%% create TV matrix for optimization
[H,V] = createFiniteDiff2(height, width);
TV2_V = kron(speye(width), V);      % for computing 2nd-derivative in the vertical direction
TV2_H = kron(H', speye(height));    % for computing 2nd-derivative in the horizontal direction

% assemble matrix to be used for optimization
if settings.useDiagonalTerm
    [Hd, Vd] = createFiniteDiffDiag(height, width);
    TV2_xy = kron(Hd',Vd); 
    TV2 = sparse([TV2_V; TV2_H; TV2_xy]);
else
    TV2 = sparse([TV2_V; TV2_H]); % not using diagonal terms
end
N = height * width;

%% Solving the problem

% bounded optimization problem
if settings.isBounded
    
    % noisy measurements
    if settings.addNoise
        cvx_begin
        cvx_quiet true
        cvx_precision best
        variable z(N,1)
        minimize( norm( TV2 * z,1) )
        subject to
        norm(y - R * z, Inf) <= settings.epsilon;
        0 <= z <= settings.maxValue;
        cvx_end
    % noiseless measurements
    else 
        cvx_begin
        cvx_quiet true
        cvx_precision best
        variable z(N,1)
        minimize( norm( TV2 * z,1) )
        subject to
        y == R * z;
        0 <= z <= settings.maxValue;
        cvx_end
    end

% unbounded optimization problem
else
    
    % noisy measurements
    if settings.addNoise
        cvx_begin
        cvx_quiet true
        cvx_precision best
        variable z(N,1)
        minimize( norm( TV2 * z,1) )
        subject to
        norm(y - R * z, Inf) <= settings.epsilon;
        cvx_end
        
    % noiseless measurements
    else 
        cvx_begin
        cvx_quiet true
        cvx_precision best
        variable z(N,1)
        minimize( norm( TV2 * z,1) )
        subject to
        y == R * z;
        cvx_end
    end
end

end

