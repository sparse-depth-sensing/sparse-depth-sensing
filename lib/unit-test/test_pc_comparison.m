close all; clear; clc

%Point Cloud 1
X1 = randn(100,1);
Y1 = randn(100,1);
Z1 =(exp(-X1.^2-Y1.^2));
% Point Cloud 2
X2 = randn(107,1);
Y2 = randn(107,1);
Z2 = (exp(-X2.^2-Y2.^2));

% Mesh for interpolation
x=linspace(min([X1;X2]),max([X1;X2]),40);
y=linspace(min([Y1;Y2]),max([Y1;Y2]),40);
[X,Y]=meshgrid(x,y);

% Calculate interpolants
V1=TriScatteredInterp(X1,Y1,Z1);
V2=TriScatteredInterp(X2,Y2,Z2);
F1=V1(X,Y);
F2=V2(X,Y);

% Plot to check results!
figure(1)
scatter3(X1,Y1,Z1)
hold on
mesh(X,Y,F1)
hold off
figure(2)
scatter3(X2,Y2,Z2)
hold on
mesh(X,Y,F2)
hold off

figure(3);
a = mesh(X,Y,F2-F1)