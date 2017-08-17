function [D,Dt] = defDDt
D  = @(U) ForwardD(U);
Dt = @(V) Dive(V);
end

function Du = ForwardD(U)
Dux = [diff(U,1,2), U(:,1,:) - U(:,end,:)];
Duy = [diff(U,1,1); U(1,:,:) - U(end,:,:)];
Du  = reshape([Dux Duy], [size(Dux), 2]);
end

function DtXY = Dive(V)
X = V(:,:,1);
Y = V(:,:,2);
DtXY = [X(:,end,:) - X(:, 1,:), -diff(X,1,2)];
DtXY = DtXY + [Y(end,:,:) - Y(1, :,:); -diff(Y,1,1)];
end