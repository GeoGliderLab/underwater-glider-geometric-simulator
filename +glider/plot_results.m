function plot_results(log,m,outdir)
%PLOT_RESULTS Reproducible figures, with SI units and explicit model scope.
if ~exist(outdir,'dir'), mkdir(outdir); end
color=[.05,.40,.50;.94,.43,.12;.46,.27,.60];
f=figure('Visible','off','Color','w','Position',[50,50,1250,850]);
layout=tiledlayout(f,2,2,'TileSpacing','compact','Padding','compact');
title(layout,'UNDERWATER GLIDER | Enclosed R-P / P mechanism','FontSize',19,'FontWeight','bold');
subtitle(layout,'Geometric simulation in SE(3) | Demonstration parameters, still water');
p=squeeze(log.T(1:3,4,:));
ax=nexttile; plot3(ax,p(1,:),p(2,:),-p(3,:),'Color',color(1,:),'LineWidth',2);
hold(ax,'on'); scatter3(ax,p(1,1),p(2,1),-p(3,1),45,color(2,:),'filled');
grid(ax,'on'); set(ax,'ZDir','reverse'); view(ax,38,25);
xlabel(ax,'x [m]'); ylabel(ax,'y [m]'); zlabel(ax,'Depth [m]'); title(ax,'Free-base trajectory');
ax=nexttile; yyaxis(ax,'left'); plot(ax,log.t,-p(3,:),'LineWidth',1.7); ylabel(ax,'Depth [m]');
set(ax,'YDir','reverse'); yyaxis(ax,'right'); plot(ax,log.t,log.mass-m.rho*m.volume,'LineWidth',1.5);
ylabel(ax,'Mass minus displaced mass [kg]'); xlabel(ax,'Time [s]'); grid(ax,'on'); title(ax,'Ballast cycle');
ax=nexttile; plot(ax,log.t,1000*log.com','LineWidth',1.5); colororder(ax,color);
xlabel(ax,'Time [s]'); ylabel(ax,'Body-frame COM [mm]'); grid(ax,'on'); legend(ax,'x','y','z','Location','best');
title(ax,'Center of mass inside the shell');
ax=nexttile; plot(ax,log.t,log.E-log.E(1),'Color',color(1,:),'LineWidth',1.7); hold(ax,'on');
plot(ax,log.t,sum(log.work,1),'--','Color',color(2,:),'LineWidth',1.4);
xlabel(ax,'Time [s]'); ylabel(ax,'Mechanical energy [J]'); grid(ax,'on');
legend(ax,'Stored energy change','Integrated power balance','Location','best'); title(ax,'Open-system energy accounting');
set(findall(f,'Type','axes'),'FontName','Arial','FontSize',10);
exportgraphics(f,fullfile(outdir,'simulation.png'),'Resolution',170); close(f);

f=figure('Visible','off','Color','w','Position',[50,50,1100,850]);
layout=tiledlayout(f,3,2,'TileSpacing','compact','Padding','compact');
title(layout,'INTERNAL ACTUATION | Prescribed motion and mechanical reactions','FontSize',17);
names={'Revolute angle [rad]','Mass travel [m]','Piston travel [m]'};
efforts={'Torque [N m]','Force [N]','Piston force [N]'};
for i=1:3
    ax=nexttile; plot(ax,log.t,log.q(i,:),'LineWidth',1.6,'Color',color(i,:));
    ylim(ax,m.limits(i,:));
    ylabel(ax,names{i}); xlabel(ax,'Time [s]'); grid(ax,'on');
    ax=nexttile; plot(ax,log.t,log.tau(i,:),'LineWidth',1.6,'Color',color(i,:));
    ylabel(ax,efforts{i}); xlabel(ax,'Time [s]'); grid(ax,'on');
end
exportgraphics(f,fullfile(outdir,'actuation.png'),'Resolution',160); close(f);

f=figure('Visible','off','Color','w','Position',[50,50,1100,800]); ax=axes(f);
glider.draw_robot(ax,eye(4),[.7;.03;.045],m);
title(ax,{'GLIDER | Transparent shell and internal mechanisms', ...
    'Moving mass, rotary carrier, piston and ballast water'},'FontSize',14);
xlim(ax,[-.19,.19]); ylim(ax,[-.24,.24]); zlim(ax,[-.18,.18]);
exportgraphics(f,fullfile(outdir,'glider_preview.png'),'Resolution',180); close(f);

f=figure('Visible','off','Color','w','Position',[50,50,1000,480]);
tiledlayout(f,1,2,'TileSpacing','compact'); ax=nexttile;
plot(ax,log.t,log.energy_residual,'LineWidth',1.5,'Color',color(1,:));
xlabel(ax,'Time [s]'); ylabel(ax,'Energy residual [J]'); grid(ax,'on');
title(ax,'Integration and power quadrature error'); ax=nexttile;
orth=zeros(size(log.t));
for j=1:numel(orth), R=log.T(1:3,1:3,j); orth(j)=norm(R'*R-eye(3),'fro'); end
semilogy(ax,log.t,max(orth,eps),'LineWidth',1.5,'Color',color(3,:));
xlabel(ax,'Time [s]'); ylabel(ax,'||R^T R - I||_F'); grid(ax,'on'); title(ax,'Rotation-group preservation');
exportgraphics(f,fullfile(outdir,'diagnostics.png'),'Resolution',160); close(f);
end
