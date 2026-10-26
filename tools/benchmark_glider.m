function report=benchmark_glider()
%BENCHMARK_GLIDER Full dynamics, changing states, warmed serial loop.
root=setup_glider(); m=glider.model(); T=eye(4); T(3,4)=-5;
q=[.3;.02;.04]; nu=.05*ones(9,1);
for i=1:100, glider.dynamics(T,q,nu,m); end
n=2000; tic;
for i=1:n
    q(1)=.3+.1*sin(i); glider.dynamics(T,q,nu,m);
end
report=struct('evaluations',n,'microseconds_per_dynamics',toc/n*1e6,'matlab',version);
glider.write_json(fullfile(root,'results','benchmark.json'),report); disp(report);
end
