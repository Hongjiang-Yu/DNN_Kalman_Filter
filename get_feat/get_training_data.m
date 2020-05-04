function features= get_training_data( mix_sig, fun_name )
%Returns training features and labels
% Input:
% mix_sig: noisy speech
% voice_sig: clean speech
% fun_name: function name for obtaining the feature
% fs: sampling frequency
% win_len: window length
% win_shift: shift between windows

%num_harm = 12;
%sca_fac = 10;

isTrun = 0;

% Obtain features for training & testing
f1 = feval(fun_name, mix_sig);

features = single(f1);


end

