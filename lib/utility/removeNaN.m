function [ mat_out ] = removeNaN( mat_in )
%REMOVENAN Remove NaN values from a vector
%   Detailed explanation goes here

% convert to column vector, if the input is a row vector
if isrow(mat_in)
    flag_is_row_vec = true;
    mat_in = mat_in';
else
    flag_is_row_vec = false;
end

flag_finite_rows = find(prod(isfinite(mat_in), 2) == 1); 
mat_out = mat_in(flag_finite_rows, :);

% convert back to row vector, if the input is a row vector
if flag_is_row_vec
    mat_out = mat_out';
end

end

