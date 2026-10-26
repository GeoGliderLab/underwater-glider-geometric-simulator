function [a,d] = forward_dynamics(T,q,nu,tau,m)
%FORWARD_DYNAMICS Torque/force driven nine-velocity model.
validateattributes(tau,{'double'},{'real','finite','size',[3,1]});
[M,b,Q,d]=glider.dynamics(T,q,nu,m);
a=M\([zeros(6,1);tau]+Q-b);
d.base_residual=norm(M(1:6,:)*a+b(1:6)-Q(1:6));
end
