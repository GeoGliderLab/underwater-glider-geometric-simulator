function [Q,detail] = pump_load(T,q4,dq4,m)
%PUMP_LOAD Quasi-static pressure reaction in the piston coordinate only.
% Pressure on piston/barrel is an internal pair: zero base generalized wrench.
% Constant back pressure is an explicit example assumption, not measured data.
xp=T(1:3,4)+T(1:3,1:3)*(m.home(1:3,4,4)+[0;0;-q4]);
delta=m.pump.surface_pressure+m.rho*m.gravity'*xp-m.pump.back_pressure;
area=pi*m.water.radius^2;
load=-double(m.pump.enabled)*(area*delta+m.pump.viscous*dq4 ...
    +m.pump.coulomb*tanh(dq4/m.pump.speed_scale));
Q=[zeros(8,1);load];
detail=struct('delta_pressure',delta,'force',load,'power',load*dq4);
end
