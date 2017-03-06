% Test the determinant-based approach on very simple case to understand
% what happens

close all; clear; clc;
markersize = 300;

%% Construct a simple case as ground truth
xyz = [ ...
    0 0 0; ...
    0 2 2; ...
    2 2 4; ...
    2 0 2; ...
    1 1 2; ...
    ...% 0.5 0.5 1; ...
        ];
   
pc = pointCloud(xyz);
figure(1); subplot(121);
pcshow(pc, 'MarkerSize', markersize); 
xlabel('x'); ylabel('y'); zlabel('z'); 
title('Ground Truth');

N = size(xyz, 1);
gt = xyz(:, 3);

%% Create measurements
samples = [1 : N-1];
sampling_matrix = eye(N);
sampling_matrix = sampling_matrix(samples, :);

measured_vector = sampling_matrix * gt;

%% Construct the neighborhoods
neighborhoods = [...
    1 2 3 5; ...
    1 2 4 5; ...
    1 3 4 5; ...
    2 3 4 5; ...
    ];

%% The optimization problem
horizontal_dim = 1;
vertical_dim = 2;

% create the row indices - repeat each row for 4 times
rows = 1 : size(neighborhoods, 1);  
rows = repmat(rows, 4, 1);
rows = rows(:);

% create the column indices - repeat each row for 4 times
columns = neighborhoods';
columns = columns(:);

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

cvx_begin
    cvx_quiet true
    cvx_precision best
    variable rec(N,1)
    minimize( norm( determinant_matrix * rec, 1) )
    subject to
        measured_vector == sampling_matrix * rec;
cvx_end

%% Visualize the reconstruction
xyz_rec = xyz;
xyz_rec(:,3) = rec;
pc_rec = pointCloud(xyz_rec);

figure(1); subplot(122);
pcshow(pc_rec, 'MarkerSize', markersize); 
xlabel('x'); ylabel('y'); zlabel('z'); 
title('Reconstruction');

error = norm(rec - gt, 1)