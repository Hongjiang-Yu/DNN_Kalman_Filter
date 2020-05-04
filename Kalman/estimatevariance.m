%{
The algorithm of driving noise variance estimation is from the paper
@article{xia2015low,
  title={Low-dimensional recurrent neural network-based Kalman filter for speech enhancement},
  author={Xia, Youshen and Wang, Jun},
  journal={Neural Networks},
  volume={67},
  pages={131--139},
  year={2015},
  publisher={Elsevier}
}
However, the accuracy might be further improved. If you have any ideas, please feel free to contact me.
%}

function [Q] = estimatevariance(y,N,a,p)
y = y';
y1 = toeplitz([zeros(1,N-1) y],[zeros(1,N-1) 2]);
b = y1';
b1 = b(:,end-p+1:end);
y2 = flipud(b1);
y2 = fliplr(y2);
Q = zeros(1,N);
ry1 = (y.*y);
for i = 1:N-1
    yt = y2(i,:);
    Ry = (yt'*yt);
    %Ry = y(i+1)*y(i+1);
    ry = (yt'.*y(i+1));
    %Rw = (Ry - ry*a);
    Rw = (a*Ry*a' - a*ry)/((norm(a,2))^2);
    %tmp = ry1(i+1) - an*ry-Rw;
    Q(1,i+1) = (ry1(i+1) - a*ry-Rw)/50; % 
    %Q(1,i+1) = (ry1(i+1) - ry*a');
end



% 
% function [Q] = estimatevariance(y,N,a,p)
% y = y';
% y1 = toeplitz([zeros(1,N-1) y],[zeros(1,N-1) 2]);
% b = y1';
% b1 = b(:,end-p+1:end);
% y2 = flipud(b1);
% y2 = fliplr(y2);
% Q = zeros(1,N);
% ry1 = (y.*y)./N;
% for i = 1:N-1
%     yt = y2(i,:);
%     Ry = (yt'*yt)/N;
%     ry = (yt.*y(i+1))/N;
%     Rw = (a*Ry*a' - ry*a')/((norm(a,2))^2);
%     Q(1,i+1) = ry1(i+1) - ry*a' - Rw;
% end