% (c) Simon Hawe, Lehrstuhl fuer Datenverarbeitung Technische Universitaet
% Muenchen, 2011. Contact: simon.hawe@tum.de
function conjugate_gradient(l1min, CG_method, Disp_mat, Ground_truth)
% Initialize 
l1min.init();

% % Just for some plotting things
% figure(100)
% clf
% set(gcf,'Position',[50 50 620 780])
% 
% subplot(2,1,2)
% hold on
% grid on
% XX=Disp_mat*l1min.x;
% 
% axis([1,l1min.max_iterations,0,mean(mean(abs(XX-Ground_truth)))]);
% ylabel(['Mean Absolute Disparity Error'],'FontWeight','bold','FontSize',12);
% xlabel('Iteration','FontWeight','bold','FontSize',12);
% cnt =1;
%% Perform the real optimization
while(1)
    tic;
    % First we perform the linesearch, where we find the step size t and
    % update the current solution to x
    [l1min,worked] = l1min.linesearch();
    if ~worked
        return;
    end
    % Compute the gradient at the next point which we have found using the
    % linesearch above
    g1 = l1min.gradient();
    g0 = l1min.g;
    % Now we update the search direction using any conjugate gradient
    % method
    cg_beta = 1;
    switch CG_method
        case 'HS'
            yk       =  g1 - g0;
            cg_beta  = (real(g1(:)'*yk(:))/real(l1min.dx(:)'*yk(:)));
        case 'PR'
            cg_beta  = max(0,(g1(:)'*(g1(:)-g0(:)))/(g0(:)'*g0(:)));
        case 'MK'
            ghs      =    g1 - g0;
            cg_beta  =  -(g1(:)'*ghs(:))/(l1min.dx(:)'*g0(:));
        case 'DY'
            ghs      =   g1-g0;
            cg_beta  =   (g1(:)'*g1(:))/(l1min.dx(:)'*ghs(:));
        case 'FR'
            cg_beta  = (g1(:)'*g1(:))/(g0(:)'*g0(:));
        case 'HZ'
            cg_beta  = -(g1(:)'*g1(:))/(l1min.dx(:)'*g0(:));
    end
    
    
    % Update this for the next iteration
    [l1min, stop] = l1min.next_iteration(cg_beta, g1);
    if stop 
        return; 
    end
    
%     if ~mod(l1min.k,200)
%         l1min.lambda  = l1min.lambda/2;
%     end
    
    % Againg just some plotting
%     capture_video;
    
%      XX=Disp_mat*l1min.x;
%      TIME(cnt) = toc;
%      eer = mean((XX(:)./255-Ground_truth(:)./255).^2);
%      MSE(cnt)=eer;
%      cnt = cnt + 1;
end
