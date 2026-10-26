function report = validate_glider()
%VALIDATE_GLIDER Independent differential identities and integration checks.
root=setup_glider(); rng(42); m=glider.model();
report=struct('matlab',version,'states',25);
report.exp_error=0; report.jacobian_error=0; report.mass_error=0;
report.bias_error=0; report.gravity_error=0; report.water_derivative_error=0;
report.open_energy_rate_error=0; report.max_hydro_power=-Inf;
report.lift_power_error=0; report.min_mass_eigenvalue=Inf;
report.rnea_error=0;
p=m; p.water.enabled=false; p.hydro.enabled=false; p.added_mass=zeros(6); p.pump.enabled=false;
dry=glider.model(p); epsq=2e-6;
for trial=1:report.states
    q=[(2*rand-1)*2;.005+.03*rand;.01+.08*rand];
    nu=.2*randn(9,1); nu(8:9)=.01*randn(2,1);
    T=glider.exp_se3(randn(6,1)*.2); T(3,4)=-5;
    x=randn(6,1)*10^(-6+8*rand);
    report.exp_error=max(report.exp_error,norm(glider.exp_se3(x)-expm(VecTose3(x)),'fro'));
    kin=glider.kinematics(q,nu,dry);
    % Independent finite differences of global link poses, without Jacobian recursion.
    Jfd=zeros(6,9,4);
    for j=1:9
        z=zeros(9,1); z(j)=epsq;
        Tp=poses(T*expm(VecTose3(z(1:6))),q+z(7:9),dry);
        Tm=poses(T*expm(VecTose3(-z(1:6))),q-z(7:9),dry);
        T0=poses(T,q,dry);
        for i=1:4
            D=T0(:,:,i)\((Tp(:,:,i)-Tm(:,:,i))/(2*epsq));
            Jfd(:,j,i)=[D(3,2);D(1,3);D(2,1);D(1:3,4)];
        end
    end
    report.jacobian_error=max(report.jacobian_error,max(abs(Jfd-kin.J),[],'all'));
    [M,b,Q]=glider.dynamics(T,q,nu,dry); Mfd=zeros(9); Md=zeros(9); gradK=zeros(3,1);
    for i=1:4, Mfd=Mfd+Jfd(:,:,i)'*dry.I(:,:,i)*Jfd(:,:,i); end
    report.mass_error=max(report.mass_error,norm(Mfd-M,'fro')/norm(M,'fro'));
    for j=1:3
        dq=zeros(3,1); dq(j)=epsq;
        Mp=glider.dynamics(T,q+dq,nu,dry); Mm=glider.dynamics(T,q-dq,nu,dry);
        D=(Mp-Mm)/(2*epsq); Md=Md+D*nu(6+j); gradK(j)=.5*nu'*D*nu;
    end
    bref=Md*nu-[ad(nu(1:6))'*(M(1:6,:)*nu);gradK];
    report.bias_error=max(report.bias_error,norm(b-bref,Inf));
    gradU=zeros(9,1);
    for j=1:9
        z=zeros(9,1); z(j)=epsq;
        [~,~,Up]=glider.energy(T*expm(VecTose3(z(1:6))),q+z(7:9),nu,dry);
        [~,~,Um]=glider.energy(T*expm(VecTose3(-z(1:6))),q-z(7:9),nu,dry);
        gradU(j)=(Up-Um)/(2*epsq);
    end
    report.gravity_error=max(report.gravity_error,norm(Q+gradU,Inf));
    w=glider.water(q(3),nu(9),m);
    wp=glider.water(q(3)+epsq,nu(9),m); wm=glider.water(q(3)-epsq,nu(9),m);
    report.water_derivative_error=max(report.water_derivative_error, ...
        norm((wp.I-wm.I)/(2*epsq)-w.dIdq,'fro'));
    tau=.2*randn(3,1); [a,dd]=glider.forward_dynamics(T,q,nu,tau,m);
    h=1e-6;
    Ep=glider.energy(T*expm(VecTose3(h*nu(1:6))),q+h*nu(7:9),nu+h*a,m);
    Em=glider.energy(T*expm(VecTose3(-h*nu(1:6))),q-h*nu(7:9),nu-h*a,m);
    predicted=tau'*nu(7:9)+dd.hydro_power+dd.open_power+dd.pump_power;
    report.open_energy_rate_error=max(report.open_energy_rate_error,abs((Ep-Em)/(2*h)-predicted));
    report.max_hydro_power=max(report.max_hydro_power,dd.hydro_power);
    report.lift_power_error=max(report.lift_power_error,abs(dd.lift_power));
    Mall=glider.dynamics(T,q,nu,m);
    report.min_mass_eigenvalue=min(report.min_mass_eigenvalue,min(eig(Mall)));
    aa=randn(9,1); [MM,bb,QQ]=glider.dynamics(T,q,nu,m);
    rr=glider.inverse_dynamics(T,q,nu,aa,m);
    report.rnea_error=max(report.rnea_error,norm(rr-(MM*aa+bb-QQ),Inf));
end
assert(report.exp_error<2e-11 && report.jacobian_error<1e-7);
assert(report.mass_error<1e-7 && report.bias_error<1e-7 && report.gravity_error<1e-6);
assert(report.water_derivative_error<1e-7 && report.open_energy_rate_error<2e-6);
assert(report.rnea_error<1e-10);
assert(report.max_hydro_power<=1e-12 && report.lift_power_error<1e-12 && report.min_mass_eigenvalue>0);
% Empty/full tank, neutral buoyancy and containment of proposed visual envelopes.
w0=glider.water(m.water.stroke,0,m); wf=glider.water(0,0,m);
assert(norm(w0.I,'fro')==0 && abs(wf.mass-m.rho*pi*m.water.radius^2*m.water.stroke)<1e-14);
report.neutral_q4=m.water.stroke-(m.rho*m.volume-sum(m.mass))/(m.rho*pi*m.water.radius^2);
assert(report.neutral_q4>0 && report.neutral_q4<m.water.stroke);
report.internal_clearance=m.radius-(m.home(1,4,3)+m.limits(2,2)+m.visual.mass_radius);
assert(report.internal_clearance>0);
% Pressure force sign/virtual work and the momentum flux limiting cases.
[Qp,pp]=glider.pump_load([eye(3),[0;0;-5];0,0,0,1],.05,.01,m);
assert(Qp(9)<0 && norm(Qp(1:8))==0 && pp.power<0);
T=eye(4); T(3,4)=-5; q=[0;.02;.05]; nu=zeros(9,1); nu(4)=.2; nu(9)=.01;
[~,~,~,dout]=glider.dynamics(T,q,nu,m); nu(9)=-.01;
[~,~,~,din]=glider.dynamics(T,q,nu,m);
assert(norm(din.flux)==0 && dout.flux(4)<0);
% Fixed ballast, internal motion, no external forces: spatial momentum conserved.
p=m; p.gravity=zeros(3,1); p.added_mass=zeros(6); p.hydro.enabled=false;
free=glider.model(p); c=glider.config(); c.duration=4; c.dt=.01;
c.times=[0,4]; c.waypoints=[0,1;.02,.035;.05,.05];
c.nu0=[.1;-.1;.08;.03;.02;-.01;0;0;0]; c.q0=c.waypoints(:,1);
L=glider.simulate(free,c); c.dt=.005; L2=glider.simulate(free,c);
P=zeros(6,numel(L.t)); P2=zeros(6,numel(L2.t));
for j=1:numel(L.t), P(:,j)=glider.momentum(L.T(:,:,j),L.q(:,j),L.nu(:,j),free); end
for j=1:numel(L2.t), P2(:,j)=glider.momentum(L2.T(:,:,j),L2.q(:,j),L2.nu(:,j),free); end
report.momentum_error=max(vecnorm(P-P(:,1)));
report.momentum_error_half_step=max(vecnorm(P2-P2(:,1)));
report.energy_error=max(abs(L.energy_residual));
report.energy_error_half_step=max(abs(L2.energy_residual));
assert(report.momentum_error<1e-4 && report.momentum_error_half_step<.35*report.momentum_error);
assert(report.energy_error_half_step<.4*report.energy_error && report.energy_error<1e-4);
% Actual force-driven trajectory, and an independent hybrid/forward round trip.
c.mode='effort'; c.duration=.2; c.dt=.002; c.nu0=zeros(9,1); c.q0=[0;.02;.05];
c.effort=@(t,T,q,nu,m) [.001;.001;0]; Le=glider.simulate(free,c);
assert(all(isfinite(Le.nu),'all') && norm(Le.q(:,end)-Le.q(:,1))>0);
q=[.2;.02;.05]; nu=[.01*ones(6,1);.02;.001;-.001]; ddq=[.01;.002;.003];
[a,tau]=glider.hybrid_dynamics(eye(4),q,nu(1:6),nu(7:9),ddq,m);
af=glider.forward_dynamics(eye(4),q,nu,tau,m);
report.hybrid_roundtrip=norm(a-af); assert(report.hybrid_roundtrip<1e-10);
test_inputs(m);
report.status='PASS';
glider.write_json(fullfile(root,'results','validation.json'),report);
disp(report);
end

function H=poses(T,q,m)
H=repmat(T,1,1,4);
for i=2:4, H(:,:,i)=H(:,:,m.parent(i))*m.home(:,:,i)*expm(VecTose3(m.screw(:,i-1)*q(i-1))); end
end

function test_inputs(m)
c=glider.config(); c.duration=.02;
c.dt=0; mustfail(@()glider.simulate(m,c)); c.dt=.01;
c.T0(1,1)=2; mustfail(@()glider.simulate(m,c)); c.T0=eye(4); c.T0(3,4)=-5;
c.waypoints(3,2)=.2; c.times=[0,.01,.02,.03,.04,.05,.06,.07,.08];
mustfail(@()glider.simulate(m,c));
p=glider.parameters(); p.inertia(:,:,1)=diag([1,1,3]); mustfail(@()glider.model(p));
end

function mustfail(f)
failed=false;
try
    f();
catch
    failed=true;
end
assert(failed,'Expected input rejection.');
end
