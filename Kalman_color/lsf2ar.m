function a=lsf2ar(lsf)
% �������Ƶ��lsf�Ǹ������򷵻ش�����Ϣ
if (~isreal(lsf)) ,
       error ('Line spectral frequencies must be real. ' ) ;
end
% �������Ƶ��lsf����O��pi��Χ���򷵻ش�����Ϣ
if (max(lsf) > pi || min(lsf)< 0),
       error ( 'Line spectral frequencies must be between 0 and pi. ' ) ;
end
lsf=lsf(:);                   % ��lsfת��Ϊ������
p=length(lsf);                % lsf�״�Ϊp
% ��lsf�γ����
z= exp(j * lsf);
rP=z(1:2:end);                % �����z(1)��z(3)��z(p-1)����rP
rQ=z(2:2:end);                % ��ż��z(2)��z(4)��z(p)����rQ
% ���ǹ����
rQ=[rQ;conj(rQ)];             % ��rQ�Ĺ��������
rP=[rP;conj(rP)];             % ��rP�Ĺ��������
% ���ɶ���ʽP��Q��ע�������ʵϵ��
Q =poly(rQ);
P =poly(rP);
% ����z=1��z=-1���γɶԳƺͷ��Գƶ���ʽ
if rem(p,2),
% ����������״Σ���z=+l��z=-1����Q1(z)�ĸ�
     Q1=conv(Q,[1 0 -1]);
     P1=P;
else
% �����ż���״Σ�z=-1�ǶԳƶ���ʽP1(z)�ĸ���z=1�Ƿ��Գƶ���ʽQl(z)�ĸ�
     Q1=conv(Q,[1 -1]);
     P1=conv(P,[1 1]);
end
% ��ʽ(4-5-8)��P1��Q1���LPCϵ��
a=.5 * (P1+Q1);
a(end)=[];                    %���һ��ϵ����O��������
