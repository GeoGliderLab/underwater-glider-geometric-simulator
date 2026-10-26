function [M,b,Q,d] = dynamics(T,q,nu,m)
%DYNAMICS M*nudot+b = [0;tau] + Q. All external loads are on the RHS.
% Q includes gravity, hull buoyancy, hull hydrodynamics, and water flux.
k=glider.kinematics(q,nu,m); w=glider.water(q(3),nu(9),m);
R=T(1:3,1:3); p=T(1:3,4); gb=R'*m.gravity;
M=zeros(9); b=zeros(9,1); Qg=zeros(9,1); U=0;
comB=zeros(3,1);
for i=1:4
    J=k.J(:,:,i); I=m.I(:,:,i); vi=k.V(:,i);
    M=M+J'*I*J;
    b=b+J'*(I*k.a0(:,i)-ad(vi)'*I*vi);
    gi=k.T(1:3,1:3,i)'*gb; fg=m.mass(i)*gi;
    Qg=Qg+J'*[cross(m.com(:,i),fg);fg];
    ci=k.T(1:3,4,i)+k.T(1:3,1:3,i)*m.com(:,i);
    comB=comB+m.mass(i)*ci;
    U=U-m.mass(i)*m.gravity'*(p+R*ci);
end
V=nu(1:6); If=w.I+m.added_mass;
M(1:6,1:6)=M(1:6,1:6)+If;
b(1:6)=b(1:6)+w.Idot*V-ad(V)'*If*V;
fg=w.mass*gb; Qg(1:6)=Qg(1:6)+[cross(w.c,fg);fg];
fb=-m.rho*m.volume*gb; Fb=[cross(m.cb,fb);fb];
[Fh,hydro]=glider.hydrodynamics(V,m);
Phi=zeros(6,1);
if strcmp(m.water.flux,'ambient_in_comoving_out') && w.dmass<0
    uport=V(4:6)+cross(V(1:3),m.water.port);
    Phi=w.dmass*[cross(m.water.port,uport);uport];
end
[Qp,pump]=glider.pump_load(T,q(3),nu(9),m);
Q=Qg+[Fb+Fh+Phi;zeros(3,1)]+Qp;
U=U-w.mass*m.gravity'*(p+R*w.c)+m.rho*m.volume*m.gravity'*(p+R*m.cb);
K=.5*nu'*M*nu;
% Open-system storage correction: this is NOT electrical pump power.
Pstorage=-.5*V'*w.Idot*V-m.gravity'*(w.dmass*p+R*w.first_moment_rate);
d=struct('kin',k,'water',w,'gravity',Qg,'buoyancy',Fb,'hydro',Fh, ...
    'flux',Phi,'pump',Qp,'pump_power',pump.power,'K',K,'U',U,'E',K+U,'hydro_power',hydro.power, ...
    'lift_power',hydro.lift_power,'open_power',V'*Phi+Pstorage, ...
    'com',(comB+w.mass*w.c)/(sum(m.mass)+w.mass), ...
    'total_mass',sum(m.mass)+w.mass);
end
