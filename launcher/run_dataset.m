function run_dataset(dataset, settings, arrayIndices)

%% Create folders where we save all results
settings.dataset = dataset;
output_folder = getPath('results', settings);
mkdir(output_folder)
pc_folder = fullfile(output_folder, 'pointclouds');
mkdir(pc_folder)
settings_filename = fullfile(output_folder, 'settings.mat');
save(settings_filename, 'settings');

%% Create data holder
num_data = getNumberOfImages(settings);
array_naive = repmat(struct('error', {}, 'time', {}, 'pc_rec_noblack', {}, 'depth_rec', {}), num_data, 1);
array_L1 = repmat(struct('error', {}, 'time', {}, 'pc_rec_noblack', {}, 'depth_rec', {}), num_data, 1);
array_L1_diag = repmat(struct('error', {}, 'time', {}, 'pc_rec_noblack', {}, 'depth_rec', {}), num_data, 1);
array_L1_cart = repmat(struct('error', {}, 'time', {}, 'pc_rec_noblack', {}, 'depth_rec', {}), num_data, 1);
array_L1_inv = repmat(struct('error', {}, 'time', {}, 'pc_rec_noblack', {}, 'depth_rec', {}), num_data, 1);
array_L1_inv_diag = repmat(struct('error', {}, 'time', {}, 'pc_rec_noblack', {}, 'depth_rec', {}), num_data, 1);
compression_array = zeros(num_data, 1);

%% Start the loop
if nargin <= 2
    arrayIndices = 1 : 5 : num_data;
end
for img_ID = arrayIndices
    disp('****************************************************************');
    fprintf('Image ID : %3d\n', img_ID)
    
    pc_filename = fullfile(pc_folder, sprintf('%03d.mat', img_ID));
    if exist(pc_filename, 'file') == 2
        fprintf('results for img_ID=%d already exists.\n', img_ID)
        load(pc_filename);
    else
    	[results, ~] = reconstruct_single_frame(img_ID, settings);
        save(pc_filename, 'results');
    end
        
    if settings.show_debug_info
        fprintf(' --- samples (number=%3d, percentage=%.2g%%)\n', ...
            results.K, 100*results.K/length(results.depth(:)))
    end
    
    if settings.use_naive, array_naive(img_ID) = results.naive; end
    if settings.use_L1, array_L1(img_ID) = results.L1; end
    if settings.use_L1_diag, array_L1_diag(img_ID) = results.L1_diag; end
    if settings.use_L1_cart, array_L1_cart(img_ID) = results.L1_cart; end
    if settings.use_L1_inv, array_L1_inv(img_ID) = results.L1_inv; end
    if settings.use_L1_inv_diag, array_L1_inv_diag(img_ID) = results.L1_inv_diag; end
    
%     pause
end

%% Save results array
stats_filename = fullfile(output_folder, 'stats.mat');
save(stats_filename, 'num_data', 'settings', 'compression_array', ...
    'array_naive', 'array_L1', 'array_L1_diag', 'array_L1_cart', ...
    'array_L1_inv', 'array_L1_inv_diag' ...
    );
