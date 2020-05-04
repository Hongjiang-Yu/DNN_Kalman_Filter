function [stoi_score, pesq_score] = kalman(filepath, wavpath)
load(filepath)
num_setences = size(DFI,1);
for wavnum = 1:num_setences
    fprintf('processing the %d senstence\n', wavnum);

name = num2str(wavnum);
noisy = [wavpath 'kalman_' name '_mixture.wav'];% noisy
clean = [wavpath 'kalman_' name '_clean.wav'];  %clean
Enhanced1 = [wavpath 'kalman_' name '_est.wav'];%  estimate
Enhanced2 = [wavpath 'kalman_' name '_ideal.wav']; % ideal

[y,fs1]=audioread(noisy);
[c,fs]=audioread(clean);
P=12;
iter=1;

index = DFI(wavnum,:);
estlsf = output(index(1):index(2),:);
for i = 1:size(estlsf,1)
    A = estlsf(i,:);
    A(A<0)=0;
    A(A>pi)=pi-0.0001;
    estlpc(i,:) = lsf2ar(A);
end

EN1=KF_Iter_M_WB_new(y,P,iter,fs,estlpc);  % enhanced using estimate lsf
EN2=KF_Iter_M_WB(y,P,iter,fs,c);% ideal using clean lsf

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
save([wavpath 'results.mat' ],'stoi_score','pesq_score');
end