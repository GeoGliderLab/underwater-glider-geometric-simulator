function [F,out] = hydrodynamics(V,m)
%HYDRODYNAMICS Passive hull/wing surrogate in still water; angular-first.
% Lift is perpendicular to local velocity, including reverse motion.
w=V(1:3); r=m.hydro.center; v=V(4:6)+cross(w,r); s=norm(v);
n=m.hydro.normal; b=m.hydro.side;
lift=zeros(3,1); drag=zeros(3,1);
if m.hydro.enabled && s>0
    e=v/s; vn=n'*v;
    lift=-m.hydro.lift*s*vn*(n-(n'*e)*e);
    drag=-(m.hydro.drag+m.hydro.induced_drag*(n'*e)^2)*s*v ...
        -m.hydro.side_drag*abs(b'*v)*(b'*v)*b;
end
moment=-double(m.hydro.enabled)*(m.hydro.rot_linear.*w ...
    +m.hydro.rot_quadratic.*abs(w).*w);
force=lift+drag; F=[cross(r,force)+moment;force];
out=struct('lift',lift,'drag',drag,'power',V'*F,'speed',s, ...
    'lift_power',v'*lift);
end
