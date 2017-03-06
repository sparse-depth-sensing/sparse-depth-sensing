function [ z_coordinates ] = l1ReconstructionOnPointcloud( height, width, R, y, XY, settings, samples, zinit)
% l1ReconstructionOnPointcloud L1 reconstruction for sparse depth measurements
%   Note that this function produces a list of z coordinates for the point
%   cloud, NOT a depth image.

if settings.stretch.flag
    [Y_stretched, Z_stretched] = stretch(height, width, XY(:, 1), XY(:, 2), settings);
    XY = [Y_stretched, Z_stretched];
end

%% create TV matrix for optimization
tic
TV2 = createTV2ForPointcloud(height, width, XY(:,1), XY(:,2) );
TV2 = removeNaN(TV2);
time_create_TV2 = toc;
% disp(['cartesian create TV2: ', num2str(time_create_TV2)])
% disp(['size of TV2: ', num2str(size(TV2, 1)), ' ', num2str(size(TV2, 2))])

%% Solving the problem
% using nesta
if strcmp(lower(settings.solver), 'nesta')  
    [z_coordinates,timeFast,iterFast] = solve_nesta_2D(TV2,y, ...
        R,samples,settings.epsilon,'tv2_cartesian',zinit,settings.mu);
else
    N = height * width;
    
    % noisy measurements
    if settings.epsilon > 0
        cvx_begin
        cvx_quiet true
        cvx_precision best
        variable z_coordinates(N,1)
        minimize( norm( TV2 * z_coordinates,1) )
        subject to
        norm(y - R * z_coordinates, Inf) <= settings.epsilon;
        cvx_end

    % noiseless measurements
    else 
        cvx_begin
        cvx_quiet true
        cvx_precision best
        variable z_coordinates(N,1)
        minimize( norm( TV2 * z_coordinates,1) )
        subject to
            y == R * z_coordinates;
        cvx_end
    end
end

end

