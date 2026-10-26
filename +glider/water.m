function w = water(q4,dq4,m)
%WATER Eulerian, body-locked water distribution. Not a rigid piston payload.
% Relative fluid momentum is neglected; derivatives are analytic.
h=m.water.stroke-q4; r=m.water.radius;
assert(h>=-1e-10 && h<=m.water.stroke+1e-10,'glider:limits','Piston outside chamber.');
a=m.rho*pi*r^2*double(m.water.enabled);
w.mass=a*h; w.dmass=-a*dq4; w.h=h;
w.c=m.water.tip+[0;0;h/2]; cp=[0;0;-.5];
C=VecToso3(w.c); Cp=VecToso3(cp);
J=w.mass*diag([(3*r*r+h*h)/12,(3*r*r+h*h)/12,r*r/2]);
Jp=-a*diag([(3*r*r+h*h)/12,(3*r*r+h*h)/12,r*r/2]) ...
    +w.mass*diag([-h/6,-h/6,0]);
w.I=glider.spatial_inertia(w.mass,w.c,J);
mp=-a;
w.dIdq=[Jp-mp*C*C-w.mass*(Cp*C+C*Cp),mp*C+w.mass*Cp; ...
    -mp*C-w.mass*Cp,mp*eye(3)];
w.Idot=w.dIdq*dq4;
w.first_moment_rate=w.dmass*w.c+w.mass*cp*dq4;
end
