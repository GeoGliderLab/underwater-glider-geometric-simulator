function animate_glider(log,m,video_file)
%ANIMATE_GLIDER Live cutaway + trajectory. Optional MPEG-4 output path.
% Usage: s=load('results/demo.mat'); animate_glider(s.log,s.m)
if nargin<3, video_file=''; end
visibility='on'; if ~isempty(video_file), visibility='off'; end
f=figure('Color','w','Name','Underwater glider','Visible',visibility,'Position',[50,50,1200,650]);
tiledlayout(f,1,2,'TileSpacing','compact'); a1=nexttile; a2=nexttile;
body=glider.draw_robot(a1,eye(4),log.q(:,1),m);
title(a1,'Body orientation and internal mechanisms');
limit=max(m.length,m.visual.wing_span)*.65;
xlim(a1,[-limit,limit]); ylim(a1,[-limit,limit]); zlim(a1,[-limit,limit]);
p=squeeze(log.T(1:3,4,:));
plot3(a2,p(1,:),p(2,:),-p(3,:),'Color',[.8,.85,.87]); hold(a2,'on');
track=animatedline(a2,'Color',[.05,.4,.5],'LineWidth',2);
grid(a2,'on'); view(a2,35,25); set(a2,'ZDir','reverse');
xlabel(a2,'x [m]'); ylabel(a2,'y [m]'); zlabel(a2,'Depth [m]');
if ~isempty(video_file)
    v=VideoWriter(video_file,'MPEG-4'); v.FrameRate=25; open(v);
    cleanup=onCleanup(@()close(v));
end
indices=unique([1: max(1,round(.08/log.step)):numel(log.t),numel(log.t)]);
for j=indices
    if ~isvalid(f), break; end
    T=log.T(:,:,j); T(1:3,4)=0;
    body=glider.draw_robot(a1,T,log.q(:,j),m,body);
    addpoints(track,p(1,j),p(2,j),-p(3,j));
    title(a2,sprintf('t = %.1f s | mass = %.3f kg',log.t(j),log.mass(j)));
    drawnow;
    if ~isempty(video_file)
        frame=getframe(f); pixels=frame.cdata;
        pixels=pixels(1:2*floor(size(pixels,1)/2),1:2*floor(size(pixels,2)/2),:);
        writeVideo(v,pixels);
    end
end
if ~isempty(video_file) && isvalid(f), close(f); end
end
