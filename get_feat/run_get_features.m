global feat_set_size feat_start feat_end NUMBER_CHANNEL;
global feat_data feat_label;
global cur_dfi_entry cur_dfi_row DFI is_color;
rng default;

DATA_PATH  %%%% bef %%%%%%
MAT = matfile(DATA_PATH,'Writable',false);
small_speech_cell =  MAT.small_speech_cell(1,feat_start:feat_end);
small_noise_cell =  MAT.small_noise_cell(1,feat_start:feat_end);
small_mix_cell =  MAT.small_mix_cell(1,feat_start:feat_end);

order_lpc = 12;
win_len = 160;
%win_shift = 1;
fs = 16e3;

for i=1:feat_set_size
    [tmp_features1] = get_training_data( small_mix_cell{i},fun_name);
    if is_color ==1
        [tmp_features2, tmp_lsf] = get_lsf_color( small_mix_cell{i}, small_speech_cell{i}, small_noise_cell{i}, order_lpc, fs, win_len);%, win_shift);
    else
        [tmp_features2, tmp_lsf] = get_lsf( small_mix_cell{i}, small_speech_cell{i}, order_lpc, fs, win_len);%, win_shift);
    end
    tmp_features = [tmp_features2;tmp_features1];
    %tmp_features = [tmp_features2];
    feat_data = [feat_data; transpose(tmp_features)];
    feat_label = [feat_label; transpose(tmp_lsf)];  
    fprintf(1,'index = %d\n',i);
end

%if this is a test set, create double frame index 
%DFI = zeros(feat_set_size,2); % double frame index
if part < 0
    start_pointer = cur_dfi_entry;
    stop_pointer = 0;
    disp('creating double frame index DFI...')
    for i=1:feat_set_size
	number_frames = size(enframe(small_mix_cell{i},win_len),1);%,win_shift),1);
        stop_pointer = start_pointer + number_frames - 1; %160 is the OFFSET when 16e3 sampling rate is used
        DFI(i+cur_dfi_row,:) = [start_pointer, stop_pointer];
        start_pointer = start_pointer + number_frames;
    end
    cur_dfi_row = cur_dfi_row + feat_set_size;	    
    cur_dfi_entry = start_pointer;
    disp(['stop_pointer=' num2str(stop_pointer)]);
    disp(['data_frames=' num2str(size(feat_data,1)) ' num. of test sentence=' num2str(feat_set_size)]);
end
