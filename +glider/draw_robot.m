function h=draw_robot(ax,T,q,m,h)
%DRAW_ROBOT Procedural cutaway: enclosed mechanisms, shell and fixed wings.
% Reuses graphic handles for animation. Geometry is a demonstrator, not CAD.
if nargin<5 || isempty(h)
    hold(ax,'on'); h.root=hgtransform('Parent',ax);
    [x,y,z]=cylinder(m.radius,48); z=(z-.5)*m.length;
    surf(x,y,z,'Parent',h.root,'FaceColor',[.12,.49,.62],'FaceAlpha',.12, ...
        'EdgeColor','none');
    a=linspace(0,2*pi,96);
    for zz=[-m.length/2,m.length/2]
        plot3(m.radius*cos(a),m.radius*sin(a),zz+0*a,'Parent',h.root, ...
            'Color',[.12,.38,.49],'LineWidth',1.5);
    end
    % Wing span along body y, chord along body z; normal is body x.
    for side=[-1,1]
        ys=side*[m.radius,m.visual.wing_span/2,m.visual.wing_span/2,m.radius];
        zs=[-.5,-.3,.3,.5]*m.visual.wing_chord;
        patch(zeros(1,4),ys,zs,[.14,.38,.49],'Parent',h.root,'FaceAlpha',.85, ...
            'EdgeColor',[.08,.24,.32]);
    end
    [xs,ys,zs]=sphere(20);
    h.mass=surf(m.visual.mass_radius*xs,m.visual.mass_radius*ys, ...
        m.visual.mass_radius*zs,'Parent',h.root,'FaceColor',[.96,.51,.17], ...
        'EdgeColor','none');
    h.unit={xs,ys,zs};
    h.carrier=plot3(0,0,0,'Parent',h.root,'Color',[.58,.30,.68],'LineWidth',5);
    h.arm=plot3(0,0,0,'Parent',h.root,'Color',[.96,.51,.17],'LineWidth',4);
    [xc,yc,zc]=cylinder(m.water.radius,32);
    h.cyl={xc,yc,zc};
    surf(xc,yc,m.water.tip(3)+m.water.stroke*zc,'Parent',h.root, ...
        'FaceColor',[.63,.75,.81],'FaceAlpha',.12,'EdgeColor','none');
    h.water=surf(.98*xc,.98*yc,m.water.tip(3)+.05*zc,'Parent',h.root, ...
        'FaceColor',[.10,.66,.80],'FaceAlpha',.7,'EdgeColor','none');
    h.piston=surf(xc,yc,.006*(zc-.5),'Parent',h.root, ...
        'FaceColor',[.25,.31,.39],'EdgeColor','none');
    h.rod=plot3([0,0],[0,0],[0,-.04],'Parent',h.root,'LineWidth',3,'Color',[.25,.31,.39]);
    h.cg=plot3(0,0,0,'o','Parent',h.root,'MarkerFaceColor',[.82,.18,.21], ...
        'MarkerEdgeColor','w','MarkerSize',7);
    plot3(m.cb(1),m.cb(2),m.cb(3),'+','Parent',h.root,'Color',[.05,.25,.3], ...
        'MarkerSize',10,'LineWidth',2);
    axis(ax,'equal'); grid(ax,'on'); view(ax,35,22);
    xlabel(ax,'x [m]'); ylabel(ax,'y [m]'); zlabel(ax,'z [m]');
    set(ax,'FontName','Arial','FontSize',11,'Color',[.98,.99,1]);
    camlight(ax,'headlight'); lighting(ax,'gouraud');
end
k=glider.kinematics(q,zeros(9,1),m);
c2=k.T(1:3,4,2); c3=k.T(1:3,4,3); c4=k.T(1:3,4,4);
% Reconstruct only the graphics transform: hgtransform warns on accumulated
% 1e-14 orthogonality roundoff. The simulated state/log is never modified.
R=T(1:3,1:3); axisvector=[R(3,2)-R(2,3);R(1,3)-R(3,1);R(2,1)-R(1,2)];
s=norm(axisvector)/2; c=(trace(R)-1)/2; angle=atan2(s,c);
if c<-.999999
    [U,D]=eig((R+R')/2); [~,j]=max(diag(D)); axisdisplay=U(:,j);
    if axisdisplay'*axisvector<0, axisdisplay=-axisdisplay; end
elseif s>0
    axisdisplay=axisvector/(2*s);
else
    axisdisplay=[1;0;0];
end
Td=makehgtform('translate',T(1:3,4));
if angle>1e-14, Td=Td*makehgtform('axisrotate',axisdisplay,angle); end
set(h.root,'Matrix',Td);
set(h.mass,'XData',m.visual.mass_radius*h.unit{1}+c3(1), ...
    'YData',m.visual.mass_radius*h.unit{2}+c3(2), ...
    'ZData',m.visual.mass_radius*h.unit{3}+c3(3));
a=linspace(0,2*pi,50); R2=k.T(1:3,1:3,2);
ring=c2+R2*[.027*cos(a);.027*sin(a);zeros(size(a))];
set(h.carrier,'XData',ring(1,:),'YData',ring(2,:),'ZData',ring(3,:));
set(h.arm,'XData',[c2(1),c3(1)],'YData',[c2(2),c3(2)],'ZData',[c2(3),c3(3)]);
height=m.water.stroke-q(3);
set(h.water,'ZData',m.water.tip(3)+height*h.cyl{3});
set(h.piston,'ZData',c4(3)+.006*(h.cyl{3}-.5));
set(h.rod,'ZData',[-.015,c4(3)]);
[~,~,~,d]=glider.dynamics(T,q,zeros(9,1),m);
set(h.cg,'XData',d.com(1),'YData',d.com(2),'ZData',d.com(3));
end
