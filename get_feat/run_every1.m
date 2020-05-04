function run_every1(current_feature, noise_line, part, START, END, db, TMP_STORE)

delete('*.mat');
format compact;

global feat_set_size feat_start feat_end NUMBER_CHANNEL is_wiener_mask store_enable;

fprintf(1,'\t%s\t%s\n',current_feature,noise_line);

feat_fun = ['my_features_' current_feature];
make_global

tmp_str = strsplit(noise_line,'_');

% add support for multiple noise
noise_num = length(tmp_str);

% add support for multiple SNR
snr_num = length(db);

% store all features in one .mat file
feat_data = []; feat_label=[];
DFI = zeros(feat_set_size*snr_num*noise_num ,2);
cur_dfi_entry = 1;
cur_dfi_row = 0;


% run through all SNRs
for i=1:snr_num

    cur_db = db(i)

    % run through all noise types
    for j=1:noise_num
        cur_noise = tmp_str{j}

        SPEECH_DATA_PATH = [ TMP_STORE filesep 'db' num2str(cur_db) filesep 'mix']
        if part > 0 
            DATA_PATH = [ SPEECH_DATA_PATH filesep 'train_' cur_noise '_mix_bef2.mat'];
            disp(['training data=' DATA_PATH]);
            save_prefix = 'train';
        else
            DATA_PATH = [ SPEECH_DATA_PATH filesep 'test_' cur_noise '_mix_aft2.mat'];
            disp(['test data =' DATA_PATH]);
            save_prefix = 'test';
        end
        %global feat_set_size feat_start feat_end NUMBER_CHANNEL  store_enable;
        NUMBER_CHANNEL = 64;
        store_enable = 1; % enable saving features, resynthesized speech 

        feat_start = START;
        feat_end = END;
        feat_set_size =  feat_end - feat_start + 1;
        fprintf(1,'part:%d feat:%d - %d, feat_set_size=%d store=%d NUMBER_CHANNEL=%d.\n',PART, feat_start, feat_end, feat_set_size, store_enable, NUMBER_CHANNEL);

        disp('####### extracting features ######');

        run_get_features;  %get features
        delete('*.mat');

        noise_type = noise_line;
        f_name = strrep(current_feature, '.m', '');
        f_name = strrep(f_name, 'my_features_', '');

    end
end

STORE_PATH = [TMP_STORE filesep 'db' num2str(db) filesep 'feat'];

if store_enable
    if ~exist(STORE_PATH,'dir'); mkdir(STORE_PATH); end;
    if part >=0	    
        save([STORE_PATH filesep save_prefix  '_' noise_type  '_' f_name  '.mat' ],'feat_data','feat_label','feat_set_size','feat_start','feat_end','PART','-v7.3');
        clear feat_data feat_label feat_set_size feat_start feat_end PART
    else
        save([STORE_PATH filesep save_prefix  '_' noise_type  '_' f_name  '.mat' ],'feat_data','feat_label','feat_set_size','feat_start','feat_end','PART','DFI','-v7.3');
        clear feat_data feat_label feat_set_size feat_start feat_end PART DFI
    end
end
fprintf(1,'finish saving %s\n',f_name);
fprintf(1,'%s have been finished.\n',noise_line);
