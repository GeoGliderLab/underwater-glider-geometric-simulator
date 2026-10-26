function log=run_effort_demo()
%RUN_EFFORT_DEMO Short force-driven example with model-based coupling compensation.
root=setup_glider(); m=glider.model(); c=glider.config();
c.mode='effort'; c.duration=2; c.dt=.005;
c.q0=[0;.02;.05]; c.nu0=zeros(9,1);
c.effort=@controller;
log=glider.simulate(m,c);
save(fullfile(root,'results','effort_demo.mat'),'log','m','c');
end

function tau=controller(t,T,q,nu,m)
% Illustrative computed torque; no actuator saturation or robustness claim.
qd=[.2*sin(t);.02+.003*sin(t);.05];
dqd=[.2*cos(t);.003*cos(t);0]; ddqd=[-.2*sin(t);-.003*sin(t);0];
ddq=ddqd+25*(qd-q)+10*(dqd-nu(7:9));
[~,tau]=glider.hybrid_dynamics(T,q,nu(1:6),nu(7:9),ddq,m);
end
