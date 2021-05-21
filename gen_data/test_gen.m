% Setting parameters
%%-------------------------------------------------------------------------
ro_param = -0.5; % m
w_param = 2.0; % rad/1
f_param = 50.0; % Hz
tf = 1.0; % seconds
%%-------------------------------------------------------------------------

% Define dynamics equatiom in polar coordinates
%%-------------------------------------------------------------------------
f_z = @(z) [z(1)*(ro_param-(z(1)^2)); w_param];
%%-------------------------------------------------------------------------

% Define transformation from polar to cartesian coordinates and vice versa
%%-------------------------------------------------------------------------
t = @(z) [z(1)*cos(z(2)); z(1)*sin(z(2))];
t_inv = @(s) [sqrt((s(1)^2)+(s(2)^2)); atan2(s(2),s(1))];
grad_t = @(z) [cos(z(2)), -z(1)*sin(z(2)); sin(z(2)), z(1)*cos(z(2))];
%%-------------------------------------------------------------------------

% Define dynamics equatiom in cartesian coordinates
%%-------------------------------------------------------------------------
f_s = @(s) grad_t(t_inv(s))*f_z(t_inv(s));
%%-------------------------------------------------------------------------

% Build grid for evaluating policy
%%-------------------------------------------------------------------------
s1 = linspace(-1,1,6);
[S1,S2] = meshgrid(s1,s1);
s_grid = [S1(:)'; S2(:)'];
s_grid_cell = num2cell(s_grid,1);
u_grid_cell = cellfun(f_s, s_grid_cell, 'un', 0);
u_grid = cell2mat(u_grid_cell);
figure(1); quiver(s_grid(1,:),s_grid(2,:),u_grid(1,:),u_grid(2,:));
grid on; axis square; hold on;
xlabel('m'); ylabel('m'); 
%%-------------------------------------------------------------------------

% Simulate Unconstrained trajectory
%%-------------------------------------------------------------------------
z0 = [rand(), (2*pi)*rand()];
s0 = t(z0);
time = linspace(0,tf,f_param);
tic; sol = ode113(@(t,s) f_s(s),[0 tf], s0); toc;
tic; [s_traj, ~] = deval(sol,time,[1 2]); toc; % evaluation of solution
plot(s_traj(1,:), s_traj(2,:), 'g');
plot(s0(1), s0(2), 'r*');hold off;
%%-------------------------------------------------------------------------

% Simulate Constrained trajectory
%%-------------------------------------------------------------------------
% % initial conditions
% t0 = (2*pi)*rand();
% z0 = [rand(), (2*pi)*rand()];
% s0 = t(z0);
% % sonstraint
% A = [cos(t0), sin(t0)];
% P = eye(2) - pinv(A)*A;
% % set solver
% tic; sol = ode45(@(t,s) P*f_s(s),[0 tf], s0); toc;
% time = linspace(0,tf,f_param);
% % get data and ploting
% tic; [s_traj, ~] = deval(sol,time,[1 2]); toc; % evaluation of solution
% plot(s_traj(1,:), s_traj(2,:), 'g');
% plot(s0(1), s0(2), 'r*');hold off;
%%-------------------------------------------------------------------------