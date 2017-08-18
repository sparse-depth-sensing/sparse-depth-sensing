% (c) Simon Hawe, Lehrstuhl fuer Datenverarbeitung Technische Universitaet
% Muenchen, 2011. Contact: simon.hawe@tum.de
%% Setting the parameters
p           = 0;
l1smooth    = 0;
tvsmooth    = 1/sqrt(2);%1e-0;
%m           = ceil(numel(Signal)*Percentage);
%mr          = round(m/2);


%% Initializing the respecitve bases
W            = 1;
Weight       = Wavelet_weighting(Signal, 'db2', 1);
%Weight     = Wavelet_weighting(Signal);
PSI          = Wavelet(Signal, 'db2',1);
%PSI           = Wavelet(Signal);



PSI          = PSI';
TVM          = TV;
W2           = PSI;
Disp_mat     = PSI;
Intermediate = Signal;
PHI          = 1;


ind=find( SignalSampleMap~=0);
M           = Extraction(ind,size( SignalSampleMap)); 

% Edges       = pnt_selection(Signal, .8, m);
% [~,ind]     = sort((abs(Edges(:))),'descend');
%M           = Extraction(ind(1:m), size(Signal));
% M           = Extraction(ind, size(Signal));

% N=numel(Signal);
% 
% Edge_mat = edge(Signal,'canny',[],.8);
% Edge_idx = find(Edge_mat);
% %In diff stehen geordnet die indizes der element die nicht in edge
% %enthalten sind
% [~,diff]=setdiff(1:N,Edge_idx);
% diff = diff';
% Selector = randperm(numel(diff));
% Addon = round(N/100);
%  
% M           = Extraction([Edge_idx;diff(Selector(1:3*Addon))], size(Signal));

%M           = Extraction(ind(1:m), size(Signal));
%M           = Extraction(get_rand(numel(yf), m), size(yf));
%% Extracting the measurements
y           = M*(Signal);

l1min                     =  CSTVWav(y, PHI, PSI, M, W, Weight, TVM, W2, l1smooth, tvsmooth);
l1min.lambda              = .01;
l1min.gamma               = 50;
% Here you can add any evaluation function. side_eval_function is a cell
% array so any function added will be called all verbose^th iteration which
% you specify below
%l1min.side_eval_function = @(x)psnr(Signal,x); 
l1min.verbose                = 0;
l1min.max_iterations      = 1000;%650;