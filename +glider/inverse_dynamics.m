function effort = inverse_dynamics(T,q,nu,a,m)
%INVERSE_DYNAMICS Branched floating-base RNEA with open-water momentum.
% effort=[required base wrench; joint efforts]. The first six MUST vanish
% for an admissible unactuated-base acceleration. External loads included.
% No call to dynamics(): independent backward recursion for validation.
validateattributes(a,{'double'},{'real','finite','size',[9,1]});
k=glider.kinematics(q,nu,m); W=zeros(6,4);
gb=T(1:3,1:3)'*m.gravity;
for i=1:4
    vi=k.V(:,i); ai=k.J(:,:,i)*a+k.a0(:,i);
    fg=m.mass(i)*k.T(1:3,1:3,i)'*gb;
    W(:,i)=m.I(:,:,i)*ai-ad(vi)'*m.I(:,:,i)*vi-[cross(m.com(:,i),fg);fg];
end
w=glider.water(q(3),nu(9),m); V=nu(1:6); I=w.I+m.added_mass;
fg=w.mass*gb; fb=-m.rho*m.volume*gb;
Fh=glider.hydrodynamics(V,m); Phi=zeros(6,1);
if strcmp(m.water.flux,'ambient_in_comoving_out') && w.dmass<0
    u=V(4:6)+cross(V(1:3),m.water.port);
    Phi=w.dmass*[cross(m.water.port,u);u];
end
W(:,1)=W(:,1)+I*a(1:6)+w.Idot*V-ad(V)'*I*V ...
    -[cross(w.c,fg);fg]-[cross(m.cb,fb);fb]-Fh-Phi;
effort=zeros(9,1);
for i=4:-1:2
    effort(6+i-1)=m.screw(:,i-1)'*W(:,i);
    parent=m.parent(i); W(:,parent)=W(:,parent)+k.X(:,:,i)'*W(:,i);
end
effort(1:6)=W(:,1);
effort=effort-glider.pump_load(T,q(3),nu(9),m);
end
