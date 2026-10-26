function [q,dq,ddq] = reference(t,c)
%REFERENCE Piecewise quintic: continuous position, velocity, acceleration.
if t<=c.times(1), q=c.waypoints(:,1); dq=zeros(3,1); ddq=dq; return; end
if t>=c.times(end), q=c.waypoints(:,end); dq=zeros(3,1); ddq=dq; return; end
i=find(c.times<=t,1,'last'); h=c.times(i+1)-c.times(i); s=(t-c.times(i))/h;
delta=c.waypoints(:,i+1)-c.waypoints(:,i);
q=c.waypoints(:,i)+delta*(10*s^3-15*s^4+6*s^5);
dq=delta*(30*s^2-60*s^3+30*s^4)/h;
ddq=delta*(60*s-180*s^2+120*s^3)/h^2;
end
