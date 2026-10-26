function log = simulate(m,c)
%SIMULATE Explicit Lie midpoint on SE(3), midpoint in velocities/joints.
% Group preservation is exact up to roundoff; energy is not exactly preserved.
validateattributes(c.dt,{'double'},{'scalar','real','finite','positive'});
validateattributes(c.duration,{'double'},{'scalar','real','finite','positive'});
assert(ismember(c.mode,{'prescribed','effort'}),'glider:mode','Unknown mode.');
assert(all(diff(c.times)>0) && size(c.waypoints,1)==3 && ...
    size(c.waypoints,2)==numel(c.times) && all(isfinite(c.waypoints),'all'), ...
    'glider:reference','Invalid reference schedule.');
assert(isequal(size(c.T0),[4,4]) && all(isfinite(c.T0),'all') && ...
    norm(c.T0(1:3,1:3)'*c.T0(1:3,1:3)-eye(3),'fro')<1e-10 && ...
    abs(det(c.T0(1:3,1:3))-1)<1e-10 && ...
    norm(c.T0(4,:)-[0,0,0,1])<1e-12,'glider:pose','Invalid initial SE(3) pose.');
validateattributes(c.nu0,{'double'},{'real','finite','size',[9,1]});
validateattributes(c.q0,{'double'},{'real','finite','size',[3,1]});
N=ceil(c.duration/c.dt); t=linspace(0,c.duration,N+1); h=t(2)-t(1);
log.t=t; log.T=zeros(4,4,N+1); log.q=zeros(3,N+1); log.nu=zeros(9,N+1);
log.tau=zeros(3,N+1); log.E=zeros(1,N+1); log.power=zeros(4,N+1);
log.com=zeros(3,N+1); log.mass=zeros(1,N+1); log.residual=zeros(1,N+1);
T=c.T0; q=c.q0; nu=c.nu0;
for j=1:N+1
    [a,tau,d,q,nu]=stage(t(j),T,q,nu,m,c);
    log.T(:,:,j)=T; log.q(:,j)=q; log.nu(:,j)=nu; log.tau(:,j)=tau;
    log.E(j)=d.E; log.com(:,j)=d.com; log.mass(j)=d.total_mass;
    log.power(:,j)=[tau'*nu(7:9);d.hydro_power;d.open_power;d.pump_power];
    log.residual(j)=d.base_residual;
    if j==N+1, break; end
    Th=T*glider.exp_se3(h/2*nu(1:6));
    qh=q+h/2*nu(7:9); nuh=nu+h/2*a;
    [ah,~,~,~,nuh]=stage(t(j)+h/2,Th,qh,nuh,m,c);
    T=T*glider.exp_se3(h*nuh(1:6));
    q=q+h*nuh(7:9); nu=nu+h*ah;
end
log.work=cumtrapz(t,log.power,2);
log.energy_residual=log.E-log.E(1)-sum(log.work,1);
log.step=h; log.mode=c.mode;
end

function [a,tau,d,q,nu]=stage(t,T,q,nu,m,c)
if strcmp(c.mode,'prescribed')
    [q,dq,ddq]=glider.reference(t,c); nu(7:9)=dq;
end
assert(all(isfinite([q;nu;T(:)])),'glider:finite','Nonfinite state.');
assert(all(q>=m.limits(:,1)-1e-10) && all(q<=m.limits(:,2)+1e-10), ...
    'glider:limits','Joint limit crossed. Use a bounded command or model a stop.');
if c.surface_guard
    extent=norm([m.radius,m.length/2]);
    assert(T(3,4)+extent<0,'glider:surface','Fully-submerged model reached the surface.');
end
if strcmp(c.mode,'prescribed')
    [a,tau,d]=glider.hybrid_dynamics(T,q,nu(1:6),nu(7:9),ddq,m);
else
    tau=c.effort(t,T,q,nu,m); [a,d]=glider.forward_dynamics(T,q,nu,tau,m);
end
end
