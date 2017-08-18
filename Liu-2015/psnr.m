function out = psnr(x, xhat)
out = -10*log10(mean( (x(:)-xhat(:)).^2 ));
