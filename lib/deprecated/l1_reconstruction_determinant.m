function [ pc_rec, varargout ] = l1_reconstruction_determinant( height, width, neighborhoods, init_pc, sampling_matrix, measured_vector, settings)
%L1_RECONSTRUCTION_DETERMINANT This function reconstructs a point cloud given only a
% few measurements, based on minimization of determinants.
%   Basic Steps:
%   1. Find sets of 4 nearest vertices
%   2. Minimize the total determinants (equals six times the volume of the 
%       tetrahedron with those vertices) of the neighborhoods

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Step 2 - Minimize the total determinants
tic
% The matrix has num_neighborhoods rows and N columns, each row containing
% at most 4 non-zero entries. To speed up the construction of this matrix
% we use sparse representation.

horizontal_dim = 2;
vertical_dim = 3;

% create the row indices - repeat each row for 4 times
rows = 1 : size(neighborhoods, 1);  
rows = repmat(rows, 4, 1);
rows = rows(:);

% create the column indices - repeat each row for 4 times
columns = neighborhoods';
columns = columns(:);

% create the entries for the sparse matrix
xyz = init_pc.Location;
if settings.stretch.flag
    xyz_orig = xyz;
    [Y_stretched, Z_stretched] = stretch(height, width, xyz(:, 2), xyz(:, 3), settings);
    xyz(:, [2, 3]) = [Y_stretched, Z_stretched];
end
N = size(xyz, 1);

% A, B, C, D are the indices of 4 vertices in a neighborhood
A_vec = neighborhoods(:, 1);
B_vec = neighborhoods(:, 2);
C_vec = neighborhoods(:, 3);
D_vec = neighborhoods(:, 4);

% compute the difference in y-coordinates 
y_AB_vec = xyz(A_vec, horizontal_dim) -  xyz(B_vec, horizontal_dim);
y_AC_vec = xyz(A_vec, horizontal_dim) -  xyz(C_vec, horizontal_dim);
y_AD_vec = xyz(A_vec, horizontal_dim) -  xyz(D_vec, horizontal_dim);

% compute difference in z-coordinates
z_AB_vec = xyz(A_vec, vertical_dim) -  xyz(B_vec, vertical_dim);
z_AC_vec = xyz(A_vec, vertical_dim) -  xyz(C_vec, vertical_dim);
z_AD_vec = xyz(A_vec, vertical_dim) -  xyz(D_vec, vertical_dim);
z_BC_vec = xyz(B_vec, vertical_dim) -  xyz(C_vec, vertical_dim);
z_BD_vec = xyz(B_vec, vertical_dim) -  xyz(D_vec, vertical_dim);
z_CD_vec = xyz(C_vec, vertical_dim) -  xyz(D_vec, vertical_dim);

% fill in the matrix entries
entry_B_vec = y_AD_vec .* z_AC_vec - y_AC_vec .* z_AD_vec;  % -1
entry_C_vec = y_AB_vec .* z_AD_vec - y_AD_vec .* z_AB_vec;  % 1
entry_D_vec = y_AC_vec .* z_AB_vec - y_AB_vec .* z_AC_vec;  % -1
entry_A_vec = - (entry_B_vec + entry_C_vec + entry_D_vec);  % 1
entrices = [entry_A_vec, entry_B_vec, entry_C_vec, entry_D_vec]';
entrices = entrices(:);
    
% construct the sparse matrix
determinant_matrix = sparse(rows, columns, entrices);

matrix_setup_time = toc;

if settings.show_debug_info
    disp(['l1-reconstruction: matrix setup time = ', num2str(matrix_setup_time), 's'])
end

% remove nan terms in the determinant matrix
size_before = size(determinant_matrix, 1);
[rowsNaN, colsNaN, values] = find(isnan(determinant_matrix));
rowsNaN = unique(rowsNaN);
size_removed = size(rowsNaN, 1);
determinant_matrix(rowsNaN, :) = zeros(length(rowsNaN), N);
%% New optimization problem based on minimization of total determinants
tic

% noisy version
if settings.addNoise
%     cvx_begin
%         cvx_quiet true
%         cvx_precision best
%         variable x_rec(N,1)
%         minimize( norm( determinant_matrix * x_rec, 1) )
%         subject to
%             norm(measured_vector - sampling_matrix * x_rec, Inf) <= settings.epsilon;
%     cvx_end

% noiseless version
else
    cvx_begin
        cvx_quiet true
        cvx_precision best
        variable x_rec(N,1)
        minimize( norm( determinant_matrix * x_rec, 1) )
        subject to
            measured_vector == sampling_matrix * x_rec;
            % x_rec >= zeros(N, 1)
    cvx_end
end
solver_time = toc;

if settings.show_debug_info
    disp(['l1-reconstruction: solver time = ', num2str(solver_time), 's'])
    disp(['l1-reconstruction: total time = ', ...
        num2str(matrix_setup_time + solver_time), 's'])
end

if settings.stretch.flag
    xyz_stretched = xyz;
    xyz = xyz_orig;
end
xyz_rec = xyz;
xyz_rec(:,1) = x_rec;
pc_rec = pointCloud(xyz_rec, 'Color', init_pc.Color);

if nargout >= 2
    xyz_stretched(:, 1) = x_rec;
    pc_rec_stretched = pointCloud(xyz_stretched, 'Color', init_pc.Color);
    varargout{1} = pc_rec_stretched;
end

end

