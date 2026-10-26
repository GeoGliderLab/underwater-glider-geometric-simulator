function c = config()
%CONFIG Demonstration: smooth repeated ballast/attitude manoeuvres.
c.dt=.02; c.duration=80; c.mode='prescribed';
c.T0=eye(4); c.T0(3,4)=-5; c.nu0=zeros(9,1);
c.times=[0,16,20,36,40,56,60,76,80];
c.waypoints=[0,0,pi,pi,0,0,-pi,-pi,0; ...
    .030,.030,.030,.030,.030,.030,.030,.030,.030; ...
    .015,.015,.095,.095,.015,.015,.095,.095,.015];
c.q0=c.waypoints(:,1);
c.effort=@(t,T,q,nu,m) zeros(3,1);
c.surface_guard=true; % model assumes the complete hull is submerged
end
