function g = gradient_fun_init(y, x_cur, PHI, PSI_wave_mode, PSI_contour_mode, lambda , gamma, beta)
% gradient_fun is a function to calculate gradient of our cost function,
% 0.5*||y-PHI*PSI*x ||_2 + lambda * ||D_w * x ||_1 + gamma * ||D_c * PSI_c * PSI_w^{-1} * x ||_1 
%                                                                         + beta * || PSI_w^{-1} * x ||_tv 




weight_option = 1 ;
 g3 = gradient_totalvariation_norm(x_cur,PSI_wave_mode.wname,PSI_wave_mode.level,PSI_wave_mode.size);
 %g2= gradient_contourlet_norm(x_cur, weight_option,PSI_contour_mode.Pyr_mode, PSI_contour_mode.dfilt, ...
 %            PSI_contour_mode.smooth_func, PSI_contour_mode.nlev_SD, PSI_wave_mode.level, PSI_wave_mode.wname, PSI_wave_mode.size);
  u_tmp = waverec2(x_cur,PSI_wave_mode.size,PSI_wave_mode.wname);
         
  f_tmp = PHI.*(PHI.*u_tmp-y);
  f = wavedec2(f_tmp,PSI_wave_mode.level,PSI_wave_mode.wname);
 % b = ((beta/lambda).*g3 + (gamma/lambda).*g2 + (1/lambda).*(-f)); 
b = ((beta/lambda).*g3  + (1/lambda).*(f)); 
 g1= gradient_wavelet_norm_conjugate(x_cur , b ,weight_option, PSI_wave_mode.size);

%   g = -f + lambda .* g1 + gamma .* g2 + beta .*g3;
g = -f + lambda .* g1  + beta .*g3;
