function p = parameters()
%PARAMETERS Editable SI parameters. See docs/PARAMETERS.md for provenance.
% This is a physically feasible demonstrator, not an identified vehicle.
p.name = 'Enclosed R-P / P underwater glider';
p.rho = 1000; p.gravity = [0;0;-9.8];
p.radius = .2142/2; p.length = .300;
p.volume = 12.096/p.rho; % effective displacement from Julio's m_buoy
p.cb = zeros(3,1);
p.mass = [10.780,.50003,.50003,.150];
p.com = [0,0,0,0;0,0,0,0;-.0225,0,0,0];
% Source shell inertia is infeasible; use an explicitly provisional cylinder.
p.inertia = zeros(3,3,4);
p.inertia(:,:,1) = diag(p.mass(1)*[(3*p.radius^2+p.length^2)/12, ...
    (3*p.radius^2+p.length^2)/12,p.radius^2/2]);
p.inertia(:,:,2) = diag([.000225014,.000216680,.000216680]);
p.inertia(:,:,3) = p.inertia(:,:,2);
p.inertia(:,:,4) = diag([.000034351,.000034351,.000063077]);
% Proposed placements ensure enclosure; source placements violate enclosure.
p.home = repmat(eye(4),1,1,4);
p.home(1:3,4,2) = [0;0;.025];
p.home(1:3,4,3) = [.040;0;0];
p.home(1:3,4,4) = [0;0;-.040];
p.screw = [0,0,0;0,0,0;1,0,0;0,1,0;0,0,0;0,0,-1];
p.limits = [-pi,pi;0,.040;0,.100];
p.water.radius = .065/2;
p.water.stroke = .100;
p.water.tip = [0;0;-.140]; % fixed chamber end; piston is tip + h*ez
p.water.enabled = true;
p.water.flux = 'ambient_in_comoving_out';
% No directional jet is modeled. Port is a net momentum-flux closure.
p.water.port = p.water.tip;
% Illustrative pressure-load closure: constant back pressure, hydrostatic water.
% Replace with measured chamber pressure/line losses for pump sizing.
p.pump.enabled = true;
p.pump.surface_pressure = 101325; p.pump.back_pressure = 101325;
p.pump.viscous = 0; p.pump.coulomb = 0; p.pump.speed_scale = .001;
% Added fluid inertia, angular-first. Provisional, independently editable.
p.added_mass = diag([.020,.020,.010,2,6,3]);
p.hydro.enabled = true;
p.hydro.center = zeros(3,1);
p.hydro.normal = [1;0;0]; p.hydro.side = [0;1;0];
p.hydro.drag = 30.1376; p.hydro.induced_drag = 15;
p.hydro.lift = 121.54; p.hydro.side_drag = 9.042;
p.hydro.rot_linear = [.04;.04;.02];
p.hydro.rot_quadratic = [1.7;10.347;.43];
p.visual.mass_radius = .018;
p.visual.wing_span = .44; p.visual.wing_chord = .10;
end
