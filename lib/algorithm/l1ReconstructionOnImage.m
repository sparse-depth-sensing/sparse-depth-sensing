function [ z, time ] = l1ReconstructionOnImage( height, width, R, y, settings, samples, zinit)
% l1ReconstructionOnImage L1 reconstruction for sparse depth measurements
%   Detailed explanation goes here

%% create TV matrix for optimization
tic
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
time_create_TV2 = toc;
% disp(['perspective create TV2: ', num2str(time_create_TV2)])
% disp(['size of TV2: ', num2str(size(TV2, 1)), ' ', num2str(size(TV2, 2))])

%% Solving the problem
tic
% using nesta
if strcmp(lower(settings.solver), 'nesta')    
    [z,timeFast,iterFast] = solve_nesta_2D(TV2,y, ...
        R,samples,settings.epsilon,'TV2',zinit,settings.mu);
%     [z,timeFast,iterFast] = solve_nesta_2D(TV2,y, ...
%         R,samples,settings.epsilon,'tv2_cartesian',zinit,settings.mu);
% using CVX
elseif strcmp(lower(settings.solver), 'cvx')    
    N = height * width;
    
    % noisy measurements
    if settings.epsilon > 0
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
else
    error(['Wrong settings.solver: ', settings.solver])
end
time = toc;
end

