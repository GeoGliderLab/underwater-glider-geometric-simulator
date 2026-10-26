function k = kinematics(q,nu,m)
%KINEMATICS Shared tree recursion; body twists, Jacobians, bias accelerations.
% q=[theta2;theta3;theta4], nu=[V_base;dq]. Frames map local -> base.
k.T=repmat(eye(4),1,1,4); k.X=zeros(6,6,4);
k.J=zeros(6,9,4); k.J(:,1:6,1)=eye(6);
k.V=zeros(6,4); k.V(:,1)=nu(1:6); k.a0=zeros(6,4);
for i=2:4
    j=i-1; parent=m.parent(i); S=m.screw(:,j);
    H=m.home(:,:,i)*glider.exp_se3(S*q(j));
    X=Adjoint(TransInv(H));
    k.X(:,:,i)=X; k.T(:,:,i)=k.T(:,:,parent)*H;
    k.J(:,:,i)=X*k.J(:,:,parent); k.J(:,6+j,i)=k.J(:,6+j,i)+S;
    vj=S*nu(6+j); vp=X*k.V(:,parent);
    k.V(:,i)=vp+vj;
    k.a0(:,i)=X*k.a0(:,parent)-ad(vj)*vp;
end
end
