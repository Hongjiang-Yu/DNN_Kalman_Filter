function run_every(noise, feat, db, num_mix_per_test_part)
% GPU detection
try
   gpuDevice;
catch err
   disp('no gpu available, use cpu instead');
end
disp('done with GPU detection.');
format compact
warning('off','all');
global feat noise frame_index DFI is_wiener_mask;
global train_data train_label cv_data cv_label test_data test_label...
       small_mix_cell small_noise_cell small_speech_cell;
warning('on','all');

fprintf(1,'Feat=%s Noise=%s\n', feat, noise);

tic;
save_mvn_prefix_path = ['MVN_STORE' filesep];
MVN_DATA_PATH = [save_mvn_prefix_path 'allmvntrain_' noise '_' feat '_' num2str(db) '.mat']
train_handle = matfile(MVN_DATA_PATH,'Writable',false);

test_data = train_handle.test_data;
test_label = train_handle.test_label;
cv_data = train_handle.cv_data;
cv_label = train_handle.cv_label;

DFI = train_handle.DFI;
small_mix_cell = train_handle.small_mix_cell;
small_noise_cell = train_handle.small_noise_cell;
small_speech_cell = train_handle.small_speech_cell;

% add support for multiple noise
tmp_str = strsplit(noise, '_');
noise_num = length(tmp_str);

% add support for multiple SNR
snr_num = length(db);

toc
dnn_train
