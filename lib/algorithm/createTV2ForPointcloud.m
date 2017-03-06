function [ TV2 ] = createTV2ForPointcloud( height, width, X, Y )
%createTV2ForPointcloud Summary of this function goes here
%   Detailed explanation goes here

% height = 4;
% width = 5;
% X = rand(height, width);
% Y = rand(height, width);

N = height * width;
X = reshape(X, height, width);
Y = reshape(Y, height, width);

% get the differences, both horizontally and vertically
X_diff = diff(X, [], 2);
Y_diff = diff(Y, [], 1);

% % protection
% X_diff(isnan(X_diff)) = 0;
% X_diff(isnan(X_diff)) = 0;

% get the reciprocal of the differences
X_diff_reciprocal = 1 ./ X_diff;
Y_diff_reciprocal = 1 ./ Y_diff;

%% TV2_horizontal
% Each row of the TV2_horizontal is [1/delta_x1, -1/delta_x1 - 1/delta_x2, 1/delta_x2].
num_entries = height * (width-2);

% We construct this matrix first along each column
left_entries = reshape(X_diff_reciprocal(:, 1:end-1), [], 1);
middle_entries = reshape(-X_diff_reciprocal(:, 1:end-1) - X_diff_reciprocal(:, 2:end), [], 1);
right_entries = reshape(X_diff_reciprocal(:, 2:end), [], 1);
entries = [left_entries, middle_entries, right_entries];
entries = reshape(entries', [], 1);

% create the corresponding row indices in TV2_horizontal
rows = repmat([1 : num_entries], 3, 1);             % do this for all columns
rows = rows(:);


colSub = [1 : 3]';     % col indices for a column of z's
colSub = repmat(colSub, height, 1);
colSub = [colSub, ones( 3*height, width-3)];
colSub = cumsum(colSub, 2);                                     % do this for all columns
colSub = colSub(:);
rowSub = repmat([1 : height], 3, 1);
rowSub = rowSub(:);
rowSub = repmat(rowSub, width - 2, 1);

% create the corresponding column indices in TV2_horizontal
cols = sub2ind([height, width], rowSub, colSub);
TV2_horizontal = sparse(rows, cols, entries);

%% TV2_vertical
% Each column of the TV2_vertical is [1/delta_y1, -1/delta_y1 - 1/delta_y2, 1/delta_y2]'.
num_entries = (height-2) * width;

% We construct this matrix first along each column
top_entries = reshape(Y_diff_reciprocal(1:end-1, :), [], 1);
middle_entries = reshape(-Y_diff_reciprocal(1:end-1, :) - Y_diff_reciprocal(2:end, :), [], 1);
bottom_entries = reshape(Y_diff_reciprocal(2:end, :), [], 1);
entries = [top_entries, middle_entries, bottom_entries];
entries = reshape(entries', [], 1);

% create the corresponding row indices in TV2_horizontal
rows = repmat([1 : num_entries], 3, 1);             % do this for all columns
rows = rows(:);

colSub = ones(3 * (height-2), 1);
colSub = [colSub, ones( size(colSub, 1), width-1)];
colSub = cumsum(colSub, 2);                                     % do this for all columns
colSub = colSub(:);
rowSub = [1 2 3]';
rowSub = [rowSub, ones( 3, height-3)];
rowSub = cumsum(rowSub, 2);
rowSub = rowSub(:);
rowSub = repmat(rowSub, width, 1);

% create the corresponding column indices in TV2_vertical
cols = sub2ind([height, width], rowSub, colSub);

TV2_vertical = sparse(rows, cols, entries);

TV2 = [TV2_horizontal; TV2_vertical];
% end

