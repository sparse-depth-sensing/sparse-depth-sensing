% (c) Simon Hawe, Lehrstuhl fuer Datenverarbeitung Technische Universitaet
% Muenchen, 2011. Contact: simon.hawe@tum.de

function [PSNR,MSE] = psnr(original, noisy)
% Calculates PSNR between original image and noisy version
original = double(original);
%original = original-mean(original(:));
noisy    = double(noisy);
%noisy = noisy-mean(noisy(:));
[n]=numel(original);

error = abs(original - noisy);

MSE = sum(sum(error.^2))/n;

PSNR = 10*log10(255^2/MSE);



fprintf('Percentage of bad pixels:   %.4f\n', sum(sum(error>0))/n);
fprintf('Mean Error per Pixel:       %.4f\n', mean(error(:)));
fprintf('PSNR:                       %.4f\n', PSNR);
fprintf('MSE:                        %.4f\n', MSE);
fprintf('Max Error:                  %.4f\n', max(abs(error(:))));




