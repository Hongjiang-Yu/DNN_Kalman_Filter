function Seg=segment(signal,W,SP,Window)

% SEGMENT chops a signal to overlapping windowed segments
% A= SEGMENT(X,W,SP,WIN) returns a matrix which its columns are segmented
% and windowed frames of the input one dimentional signal, X. 
%W - number of samples per window, default value W=256. 
% SP - shift percentage, default value SP=0.4. 
% WIN - window multiplied with each segment 
%W - length of Window. default window is hamming window.

if nargin<3
    SP=.4; %%default
end
if nargin<2
    W=256;
end
if nargin<4
    Window=hamming(W);
end

L=length(signal);
SP=fix(W.*SP);
N=fix((L-W)/SP +1); %number of segments
id=(repmat(1:W,N,1)+repmat((0:(N-1))'*SP,1,W))';
hw=repmat(Window,1,N);
Seg=signal(id).*hw;

