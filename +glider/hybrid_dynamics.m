function [a,tau,d] = hybrid_dynamics(T,q,V,dq,ddq,m)
%HYBRID_DYNAMICS Free base + prescribed internal accelerations.
nu=[V;dq]; [M,b,Q,d]=glider.dynamics(T,q,nu,m);
ab=M(1:6,1:6)\(Q(1:6)-b(1:6)-M(1:6,7:9)*ddq);
a=[ab;ddq]; required=glider.inverse_dynamics(T,q,nu,a,m); tau=required(7:9);
d.base_residual=norm(required(1:6));
end
