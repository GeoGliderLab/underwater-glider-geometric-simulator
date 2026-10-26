function summary=run_glider_demo()
%RUN_GLIDER_DEMO Run, halve the time step, plot, and save reproducible results.
root=setup_glider(); m=glider.model(); c=glider.config();
outdir=fullfile(root,'results'); if ~exist(outdir,'dir'), mkdir(outdir); end
tic; log=glider.simulate(m,c); elapsed=toc;
fine=c; fine.dt=c.dt/2; refined=glider.simulate(m,fine);
refidx=1:2:numel(refined.t);
dp=squeeze(log.T(1:3,4,:))-squeeze(refined.T(1:3,4,refidx));
orth=zeros(size(log.t)); deterror=orth; angle=orth;
for j=1:numel(log.t)
    R=log.T(1:3,1:3,j); Rf=refined.T(1:3,1:3,refidx(j));
    orth(j)=norm(R'*R-eye(3),'fro'); deterror(j)=abs(det(R)-1);
    angle(j)=norm(logm(R'*Rf),'fro')/sqrt(2);
end
p=squeeze(log.T(1:3,4,:));
summary=struct('status','PASS','matlab',version,'duration_s',c.duration, ...
    'step_s',log.step,'runtime_s',elapsed,'position_refinement_m',max(vecnorm(dp)), ...
    'rotation_refinement_rad',max(angle),'orthogonality_error',max(orth), ...
    'determinant_error',max(deterror),'base_equation_residual',max(log.residual), ...
    'energy_residual_J',max(abs(log.energy_residual)), ...
    'energy_residual_half_step_J',max(abs(refined.energy_residual)), ...
    'depth_range_m',[-max(p(3,:)),-min(p(3,:))], ...
    'horizontal_range_m',max(vecnorm(p(1:2,:)-p(1:2,1))), ...
    'max_joint_efforts',max(abs(log.tau),[],2));
assert(summary.orthogonality_error<1e-10 && summary.position_refinement_m<.01);
assert(summary.rotation_refinement_rad<.01 && summary.base_equation_residual<1e-9);
assert(summary.energy_residual_half_step_J<.4*summary.energy_residual_J);
save(fullfile(outdir,'demo.mat'),'log','m','c','summary');
glider.write_json(fullfile(outdir,'demo_summary.json'),summary);
glider.plot_results(log,m,outdir); disp(summary);
end
