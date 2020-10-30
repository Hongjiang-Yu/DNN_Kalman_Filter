function [Q1,Q2] = estimatevariance2(y,N,a,an,p)
[ay,qy ]= lpc(y,p);

for m = 1:p+1
    exp_matrix(m, :) = exp(-j*(m-1)*((1:N)-1)*2*pi/N);
end
Ax = (abs( exp_matrix'* a').^ 2);
An = (abs( exp_matrix'* an').^ 2);
Ay = (abs( exp_matrix'* ay').^ 2);
pyy = qy./Ay;
C1 = sum(1./((pyy.^2).*(Ax).^2));
C2 = sum(1./((pyy.^2).*Ax.*An));
C3 = sum(1./((pyy.^2).*(An).^2));
D1 = sum(1./((pyy).*Ax));
D2 = sum(1./((pyy).*An));
C = [C1,C2;C2,C3];
D = [D1;D2];
    zx =C^(-1)*D;
    Q1 = zx(1);
   Q2 = zx(2);

end