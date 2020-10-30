function  [output,output_p] =  KF_color(ns,P,fs,estlpc_c,estlpc_n)

w_len=160; %Window length is 20~32 ms
shift_per=1; %Shift percentage (1 means no overlapping)  
%Overlap-Add method is not considered here.
Window=ones(w_len,1); %%Use Rectangular Window
%Do Framing (2D Array) for State-Space Model Implementation as 
% needed for Kalman Filter
y1=segment(ns,w_len,shift_per,Window); % Noisy Speech
 [An_i,Qn_i]=lpc(y1,P);
% [An,Qn]=lpc(y3,P);
Ac = estlpc_c;
An = estlpc_n;

Hc=[zeros(1,P-1) 1]'; %observation vector
G0 = zeros(P,1);
G = [Hc,G0;G0,Hc];
H = [Hc;Hc];

U_LPC=[zeros(P-1,1) eye(P-1)]; %%Upper LPC coefficients
U_LPC0 = zeros(P,P);
I=eye(P*2); %%Identity matrix
S=diag(repmat(0,1,P*2)); %%state vector P-by-P parameters
e_SP=zeros(1,w_len*size(y1,2));% allocating memory to save enhanced speech 
e_SP(1:P)=y1(1:P,1)';
e_NP(1:P)=y1(1:P,1)';
start=1;
Sp=[e_SP(1:P)';e_NP(1:P)']; %pick-up first segment

t=P+1;
kk=1;
% hwb = waitbar(0,'Please wait...','Name','Processing'); %Simulation Status Bar
for n=1:size(y1,2)   
   [Q1,Q2] = estimatevariance2(y1(:,n),w_len,Ac(n,1:end),An(n,1:end),P);
   qt = Qn_i(n);
   qc = mean(Q1);
   qn = mean(Q2);
   
   if qc<0 || isnan(qc)
       qc = 1e-8;
   end
   if qn<0 || isnan(qn)
       qn = 1e-8;
   end
   
   qn1= qt-qc; 
   if qn1<0 || isnan(qn1)
       qn1 = 1e-8;
   end
   
   q = [qc,0;0,qn1];
        Fc=[U_LPC; fliplr(-Ac(n,2:end))]; %State Transition Matrix Implementation clean 
        Fn=[U_LPC; fliplr(-An(n,2:end))];
        F = [Fc,U_LPC0; U_LPC0,Fn];      
        Psum = zeros(P,P);
        for i=start:w_len
            S_=F*Sp; %posteriori estimation
            e=y1(i,n)*2-S_(P)-S_(end);%innovation (kalman filter linear combination)
            ez(kk) = e;
            kk=kk+1;
             %P_=F*S*F'+G*G'*Q(n);%priori estimate error coveriance    
            P_=F*S  *F'+G*q*G'; %Use This equation from now;
            %-------Update state of Kalman Filter
            %Minimize measurement noise covariance R(n) 
    %         K=P_*H'/(H*P_*H'+ R(n)); %Conventional Kalman Gain
            %----------Updated Kalman Gain Function----------------------------
            K=P_*H/(H'*P_*H); %Dimension Reduction of new Kalman Gain *Myself)
            %K=Kk*H; %subtract prediction error covariance to get better Kalman gain function
            %------------------------------------------------------------------
            Sg_Out=S_+K*e; %update the segmental enhanced output
            Sg_Out1 = Sg_Out(1:P);
            e_SP(t-P+1:t)=Sg_Out1'; %Notice that the previous P-1 output samples are updated again
            S=(I-K*H')*P_; %posteriori estimate error coveriance  
            Sp=Sg_Out; %Segmental Output
            t=t+1; %next segment
         if i>w_len/2
                Psum = Psum+P_(1:P,1:P);
            end
        end
        Psum1{n} = Psum;
        start=1;  
       

end
e_SP = e_SP./max(abs(e_SP));
output = e_SP;

Nband = 4;
s_per = Post_processing2(e_SP,fs,Nband,'linear');
output_p=s_per;
output_p = output_p./max(abs(output_p));

