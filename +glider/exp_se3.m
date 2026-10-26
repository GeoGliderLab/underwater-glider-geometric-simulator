function T = exp_se3(x)
%EXP_SE3 Stable SE(3) exponential, x=[rotation vector; translation algebra].
% Small rotations retain their translation/rotation coupling.
w=x(1:3); u=x(4:6); a2=w'*w; W=VecToso3(w);
if a2<1e-8
    A=1-a2/6+a2^2/120; B=.5-a2/24+a2^2/720;
    C=1/6-a2/120+a2^2/5040;
else
    a=sqrt(a2); A=sin(a)/a; B=(1-cos(a))/a2; C=(a-sin(a))/(a*a2);
end
T=[eye(3)+A*W+B*(W*W),(eye(3)+B*W+C*(W*W))*u;0,0,0,1];
end
