X = (real(Disp_mat*l1min.x));
k = l1min.k;
addon = 0;
mul = 1.15;
fig=figure(100); 
%subplot(2,2,[1,2]); 
subplot(2,1,1)
imshow(uint8(abs(X))); title(sprintf('CS Reconstruction at %dth Iteration',k+addon),'FontWeight','bold','FontSize',12);
pos1 = get(gca,'position');
%      pos1(2)=(pos1(2)-pos1(3)*mul+pos1(3))-0.05;
% pos1(3)=pos1(3)*mul;
pos1(1)=pos1(1)-pos1(3)*0.25;
pos1(2)=pos1(2)-pos1(4)*0.37;
pos1(3)=pos1(3)*1.5;
pos1(4)=pos1(4)*1.5;
set(gca,'position',pos1);
hold on
drawnow;
hold on

subplot(2,1,2)
hold on
plot(k+addon,mean(mean(abs(abs(X)-Ground_truth))),'g*-','LineWidth',1.5);
drawnow;

