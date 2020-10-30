format compact

feat_line = 'Joint' ;% feature tpye
%noise_line = 'babble_white_street_factory' ;% multiple noise type
noise_line = 'babble_white';

repeat_time = 1; % number of times that each clean utterance is mixed with noise for training.
train_list = ['config' filesep 'list670.txt'];
test_list = ['config' filesep 'list80.txt'];

% cut noise into two parts, the first part is for training and the second part is for test
noise_cut = 0.5;

% create mixtures at certain SNR
mix_db = [0, 3]; % multiple input SNRs

% % use lsf as learning target
% is_lsf = 1;

%% speech separation steps

% 1. generate mixtures or not. 0: no, 1: yes.
is_gen_mix = 0;

% 2. generate features/masks or not. 0: no, 1: yes.
is_gen_feat = 0;

% 3. perform dnn training/test or not. 0: no, 1: yes.
is_dnn = 0;

% 4. Kalman filter
is_kalman = 1;
is_color = 1;% choose basic Kalman filtering or colored-noise Kalman filtering