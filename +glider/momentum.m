function P = momentum(T,q,nu,m)
%MOMENTUM Spatial momentum [angular about world origin; linear].
k=glider.kinematics(q,nu,m); w=glider.water(q(3),nu(9),m);
pb=(w.I+m.added_mass)*nu(1:6);
for i=1:4
    X=Adjoint(TransInv(k.T(:,:,i)));
    pb=pb+X'*m.I(:,:,i)*k.V(:,i);
end
P=Adjoint(TransInv(T))'*pb;
end
