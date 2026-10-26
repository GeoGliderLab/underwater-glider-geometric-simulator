function I = spatial_inertia(m,c,Jc)
%SPATIAL_INERTIA Angular-first inertia at an arbitrary body origin.
C = VecToso3(c);
I = [Jc-m*C*C,m*C;-m*C,m*eye(3)];
end
