function [stoi_score, pesq_score] = kalman_color(filepath, wavpath)
load(filepath)
num_setences = size(DFI,1);
for wavnum = 1:num_setences
    fprintf('processing the %d senstence\n', wavnum);

name = num2str(wavnum);
noisy = [wavpath 'kalman_' name '_mixture.wav'];% noisy
clean = [wavpath 'kalman_' name '_clean.wav'];  %clean
Enhanced1 = [wavpath 'kalman_' name '_est_color.wav'];%  estimate without post processing
Enhanced2 = [wavpath 'kalman_' name '_est_color_p.wav'];%  estimate with post processing
[y,fs1]=audioread(noisy);
[c,fs]=audioread(clean);
P=12;
iter=1;

index = DFI(wavnum,:);
estlsf_c = output(index(1):index(2),1:P); %clean speech lsf
estlsf_n = output(index(1):index(2),P+1:end); %noise lsf
for i = 1:size(estlsf_c,1)
    Ac = estlsf_c(i,:);
    An = estlsf_n(i,:);
    Ac(Ac<0)=0;
    Ac(Ac>pi)=pi-0.0001;
    An(An<0)=0;
    An(An>pi)=pi-0.0001;
    estlpc_c(i,:) = lsf2ar(Ac);
    estlpc_n(i,:) = lsf2ar(An);
end


[EN1,EN2]=KF_color(y,P,fs,estlpc_c,estlpc_n);  % enhanced using estimate lsf

audiowrite(Enhanced1,EN1,fs);
audiowrite(Enhanced2,EN2,fs);


min1 =  min(length(y),min(length(c),min(length(EN2),length(EN1))));
c = c(1:min1);
y = y(1:min1);
EN1 = EN1(1:min1);
EN2 = EN2(1:min1);

stoi_score(wavnum,1) = stoi(c,y,fs);
stoi_score(wavnum,2) = stoi(c,EN1,fs);
stoi_score(wavnum,3) = stoi(c,EN2,fs);
pesq_score(wavnum,1) = pesq(c, y,fs);
pesq_score(wavnum,2)= pesq(c, EN1',fs);
pesq_score(wavnum,3)= pesq(c, EN2',fs);

end
save([wavpath 'results_color.mat' ],'stoi_score','pesq_score');
end