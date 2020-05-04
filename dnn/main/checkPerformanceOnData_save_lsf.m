function [output] = checkPerformanceOnData_save_lsf(net,data,label,opts,write_wav,num_split)
disp('save_lsf_func');
global feat noise frame_index DFI;
global small_mix_cell small_noise_cell small_speech_cell;
num_test_sents = size(DFI,1)

% support multiple snr and noise
global tmp_str noise_num snr_num;
global num_mix_per_test_part;

num_test_sents = size(DFI,1)

if nargin < 6
    num_split = 1;
end

num_samples = size(data,1);

if ~opts.eval_on_gpu
    for i = 1:length(net)
        net(i).W = gather(net(i).W);
        net(i).b = gather(net(i).b);
        data = gather(data);
    end
end

output = getOutputFromNetSplit(net,data,5,opts);

noise_feat = sprintf('%-15s', [noise ' ' feat]);

est_lsf = cell(num_test_sents);
clean_lsf = cell(num_test_sents);
%  est_q = cell(num_test_sents);
%  clean_q = cell(num_test_sents);

% save the model first
save_prefix_path = ['STORE' filesep 'db' num2str(opts.db) filesep];
if ~exist(save_prefix_path,'dir'); mkdir(save_prefix_path); end;
if ~exist([save_prefix_path 'est_lsf'],'dir'); mkdir([save_prefix_path 'est_lsf']); end;
if ~exist([save_prefix_path 'model'],'dir'); mkdir([save_prefix_path 'model']); end;
save([save_prefix_path 'model' filesep 'model_' noise '_db' num2str(opts.db) '.mat' ],'net','opts');
save([save_prefix_path 'est_lsf' filesep 'est_labels_' noise '_db' num2str(opts.db) '.mat' ],'label','output','DFI');
%save([save_prefix_path 'est_lsf' filesep 'est_labels_q' noise '_db' num2str(opts.db) '.mat' ],'label','output','DFI');
single_snr_noise_mse = zeros(snr_num,noise_num);
for k=1:snr_num

  %cur_db = opts.db(k);

  for l=1:noise_num
    cur_db = opts.db(k)
    cur_noise = tmp_str{l}

    for m=1:num_mix_per_test_part
      i=m+num_mix_per_test_part*((k-1)*noise_num+l-1);
%for i=1:num_test_sents
      mix = double(small_mix_cell{i});
      mix_s{i} = mix;
      clean_s{i} = double(small_speech_cell{i});
      est_lsf{i} = transpose(output(DFI(i,1):DFI(i,2),:));
      clean_lsf{i} = transpose(label(DFI(i,1):DFI(i,2),:));
%       est_q{i} = transpose(output(DFI(i,1):DFI(i,2),:));
%       clean_q{i} = transpose(label(DFI(i,1):DFI(i,2),:));

      cur_mse = mse(est_lsf{i}, clean_lsf{i});
      single_snr_noise_mse(k,l) = single_snr_noise_mse(k,l) + cur_mse;
      fprintf(1,['MSE#  index=%-8d MSE=%-12.4f \n'], i, cur_mse);

    end
  end
end


pause(5);
save_wav_path = ['WAVE' filesep];
if ~exist(save_wav_path,'dir'); mkdir(save_wav_path); end;

save_wav_path = [save_wav_path 'db' num2str(opts.db) filesep];
if ~exist(save_wav_path,'dir'); mkdir(save_wav_path); end;

save_wav_path = [save_wav_path 'kalman_'];

if write_wav == 1
    %write to wav files
    disp('writing waves ......');
    warning('off','all');
    for i=1:num_test_sents
       sig = mix_s{i};
       sig = sig/max(abs(sig))*0.9999;
       audiowrite([save_wav_path num2str(i) '_mixture.wav'], sig,16e3);

       sig = clean_s{i};
       sig = sig/max(abs(sig))*0.9999;
       audiowrite([save_wav_path num2str(i) '_clean.wav'], sig,16e3);
    end
    warning('on','all');
    disp('finish waves');
end



fprintf('\n\n')
single_snr_noise_mse = single_snr_noise_mse / num_mix_per_test_part