function [E,K,U] = energy(T,q,nu,m)
%ENERGY Mechanical storage including added fluid inertia and hydrostatics.
[~,~,~,d]=glider.dynamics(T,q,nu,m); E=d.E; K=d.K; U=d.U;
end
