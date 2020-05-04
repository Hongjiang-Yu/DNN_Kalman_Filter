%function [output]=KF_Iter_M_WB(ns,fs,P,it,xx)

% Kalman filter with ideal parameter
function [output]=KF_Iter_M_WB(ns,P,it,fs,c)
% if nargin < 4
%     it = 3;
% end

w_len=fix(.020*fs); %Window length is 20~32 ms
shift_per=1; %Shift percentage (1 means no overlapping)  
%Overlap-Add method is not considered here.
Window=ones(w_len,1); %%Use Rectangular Window
%Do Framing (2D Array) for State-Space Model Implementation as 
% needed for Kalman Filter
y=segment(ns,w_len,shift_per,Window); % Noisy Speech
y1=segment(c,w_len,shift_per,Window); % h clean Speech


R =real((sqrt(sum(y(:,1).*y(:,1))))/w_len);
[A,Q]=lpc(y1,P);
%A(isnan(A)) = 0.01;
H=[zeros(1,P-1) 1]; %observation vector
G=H'; 
U_LPC=[zeros(P-1,1) eye(P-1)]; %%Upper LPC coefficients
I=eye(P); %%Identity matrix
S=diag(repmat(R(1),1,P)); %%state vector P-by-P parameters
e_SP=zeros(1,w_len*size(y,2));% allocating memory to save enhanced speech 
e_SP(1:P)=y(1:P,1)';
start=1;
Sp=e_SP(1:P)'; %pick-up first segment

t=P+1;
% t=1;
% hwb = waitbar(0,'Please wait...','Name','Processing'); %Simulation Status Bar
for n=1:size(y,2)
    
%     waitbar(n/size(y,2),hwb,['Please wait... ' num2str(fix(100*n/size(y,2))) ' %'])
    t_old = t;
    Sp_old = Sp;
    if isnan(A(n,2:end))
        t = t+w_len;
    else
    for kk = 1:it
        F=[U_LPC; fliplr(-A(n,2:end))]; %%State Transition Matrix Implementation
        for i=start:w_len
            S_=F*Sp; %posteriori estimation
            e=y(i,n)-S_(end);%innovation (kalman filter linear combination)
             %P_=F*S*F'+G*G'*Q(n);%priori estimate error coveriance    
            P_=F*S*F'+H'*H*Q(n); %Use This equation from now;
            %-------Update state of Kalman Filter
            %Minimize measurement noise covariance R(n) 
    %         K=P_*H'/(H*P_*H'+ R(n)); %Conventional Kalman Gain
            %----------Updated Kalman Gain Function----------------------------
            K=P_*H'/(P_*H'+ R(1)); %Dimension Reduction of new Kalman Gain *Myself)
            KK=K*H'; %subtract prediction error covariance to get better Kalman gain function
            %------------------------------------------------------------------
            Sg_Out=S_+KK*e; %update the segmental enhanced output        
            e_SP(t-P+1:t)=Sg_Out'; %Notice that the previous P-1 output samples are updated again
            S=(I-KK*H)*P_; %posteriori estimate error coveriance  
            Sp=Sg_Out; %Segmental Output
            t=t+1; %next segment
        end
        start=1;
        if kk < it
            t = t_old;
            Sp = Sp_old;
        end
       % [A(n,:), Q(n)] = lpc(e_SP((n-1)*w_len+1 : n*w_len),P);  % update noisy AR parameters
    end
    end
end
% close(hwb)
output=e_SP;
output = output./max(abs(output));

