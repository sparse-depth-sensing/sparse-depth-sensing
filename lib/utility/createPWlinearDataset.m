close all; clear; clc;
addpath(genpath('..'));
addpath('../../data');

nb_data = 500;
nb_corners = 10;
width = 200;
height = 200;
maxValue = 10;
doShow = false;

dataDirPath = sprintf('../../data/pwlinear_nbCorners=%d', nb_corners);
mkdir(dataDirPath);

for i = 1 : nb_data
    i
    filename = sprintf('%s/%03d.mat', dataDirPath, i);
    depth = 1000 * createPWlinearImage(nb_corners, width, height, maxValue, doShow);
    save(filename, 'depth');
end

function img = createPWlinearImage(nrCorners, Nx, Ny, maxValue, doPlot)

    if nargin < 1
        Nx = 5;
        Ny = 5;
        nrCorners = 1;
    end
    if nargin < 5
        doPlot = 0;
    end
    % grid over the image
    [Xq, Yq] = meshgrid(1:Nx, 1:Ny);

    % pick random corner position
    N = Nx*Ny;
    samples = randperm(N, nrCorners);
    % samples = Nx*floor(Ny/2) + ceil(Nx/2);
    % we resample until we do not pick one of the extrema, which are already
    % included in the sample set later on
    while isempty(find(samples == 1))==0      || isempty(find(samples == Nx))==0 || ...
          isempty(find(samples == Nx*Ny))==0  || isempty(find(samples == Nx*(Ny-1)+1))==0  
       samples = randperm(N, nrCorners); % resample
    end
    % the following notation is the same as piking entries from vec(Matrix)
    samples = [samples 1 Nx Nx*Ny Nx*(Ny-1)+1];
    X_sample = Xq(samples)';
    Y_sample = Yq(samples)';
    % pick corners' height
    y = [maxValue * (2*rand(nrCorners,1) - 1); 0; 0; 0; 0]; % * ones(nrCorners,1), (rand(nrCorners,1) 

    % create piecewise linear function
    Fun = scatteredInterpolant(X_sample, Y_sample, y, 'linear');
    img = Fun(Xq, Yq);
    % normalize height in [0,1]
    % img = zeroOne(img);

    if doPlot == 1
        figure(100); clf;
        surf(1:Nx, 1:Ny, img); hold on; shading interp % flat %  faceted %
        % set(gcf,'numbertitle','off','name','depth image segmentation')
        set(gcf,'name','original with anchors')
        plot3(X_sample, Y_sample, img(samples), 'o', 'markersize', 20)
    end

end
