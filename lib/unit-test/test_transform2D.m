function [ flag_pass ] = test_transform2D( )
addpath('..')

flag_pass = true;
epsilon = 1e-5;
for i = 1 : 100
    %% randomly generate points
    x_b = rand(i, 1);
    y_b = rand(i, 1);
    t_x = rand;
    t_y = rand; 
    theta = rand;
    
    %% apply 2D geometric transformations
    [ x_w, y_w ] = transform2d_body2world(x_b, y_b, t_x, t_y, theta);
    [ x_b_test, y_b_test ] = transform2d_world2body( x_w, y_w, t_x, t_y, theta );
    
    %% verify whether the forward and backward transformations return the original values
    if norm(x_b_test - x_b, 1) > epsilon || norm(y_b_test - y_b, 1) > epsilon
        flag_pass = false;
    end
    
end

if flag_pass
    disp('test_transform2D passed.')
else
    disp('test_transform2D failed.')
end

end

