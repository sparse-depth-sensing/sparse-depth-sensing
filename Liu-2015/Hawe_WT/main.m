% (c) Simon Hawe, Lehrstuhl fuer Datenverarbeitung Technische Universitaet
% Muenchen, 2011. Contact: simon.hawe@tum.de
% This is a modification for disparity map reconstruction from sparse
% samples.
%
% by Lee-Kang Lester Liu 04/19/2013
%

clear all;
clc
close all;


%    Ground_Truth = double(imread('new_disp1.png'));
%    Signal = double(imread('new_disp1.png'));
%    SignalSampleMap = double(Signal~=0);
Name = {'aloe', 'baby', 'clothes', 'lampshade', 'midd', 'rocks'};
pp=[5 10 15 20];
for ii = 1%: 6
    for kk=4%:length(pp)
        for itr =1%:10
            
            clearvars -except pp kk itr Name ii
            c=cd('C:\Users\Lester\Dropbox\L_SparseReconstructionPapers\Code');
            disp = imread([Name{ii},'.png']);
            cd(c);
            Ground_Truth = double(disp);
            Signal = Ground_Truth;
            c=cd(['C:\Users\Lester\Dropbox\L_SparseReconstructionPapers\Code\Sparse Reconstruction-Code\Sample_Maps\',Name{ii}]);
            filename = sprintf('_%02d_%02d.png',pp(kk),itr);
            SignalSampleMap= double(imread([Name{ii},filename]));
            cd(c);

            Percentage  = 0.07;
            
            % In this file all parameters specific for this kind of CG reconstruction
            % are initialized. It's not in the main file just for readabilty. It's not
            % a function for simply hacky debugging :)
            
            iccv_setup
            
            for lev = 1:1
                % Select conjugate gradient methd
                CG_method   = 'HS';
                % Set convergence threshold
                l1min.delta_conv = 1e-6;
                
                for i = 1:2
                    %l1min.lambda  =0.05;
                    conjugate_gradient(l1min, CG_method,Disp_mat, Signal);
                    l1min.lambda    = l1min.lambda*.01;
                    l1min.tvSmooth  = l1min.tvSmooth*.01;
                    l1min.tv_method = 'iso';
                end
            end
            
            X = (real(Disp_mat*l1min.x));XX=double((abs(X)));
            c=cd(['C:\Users\Lester\Dropbox\L_SparseReconstructionPapers\Code\Sparse Reconstruction-Code\Recon_Maps\',Name{ii}]);
            filename = sprintf('Wavelet_db2_%02d_%02d.png',pp(kk),itr);
            imwrite(uint8(XX),filename);
            cd(c);
            %     c=cd('C:\Users\Lester\Dropbox\L_SparseReconstructionPapers\Code\L_Train_Disparity_Dictionary');
            %     filename=sprintf('CurveetCS%02dpAloesparse%03d.png',pp(kk),itr);
            %     imwrite(uint8(XX),filename);
            %     cd(c);
        end
    end
end
%%