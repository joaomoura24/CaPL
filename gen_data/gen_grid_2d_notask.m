% Setting parameters
%%-------------------------------------------------------------------------
ro_param = -0.5; % m
w_param = 1.0; % rad/1
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
grid_data.s = [S1(:)'; S2(:)'];
grid_data.u_u = cell2mat(cellfun(f_s, num2cell(grid_data.s,1), 'un', 0));
%%-------------------------------------------------------------------------

% Ploting generated grid
%%-------------------------------------------------------------------------
quiver(grid_data.s(1,:),grid_data.s(2,:),grid_data.u_u(1,:),grid_data.u_u(2,:),'color',[0 0 1]);
legend('ground truth');
xlim([-1.5 1.5]); ylim([-1.5 1.5]);
xlabel('m'); ylabel('m');
axis square; grid on;
%%-------------------------------------------------------------------------

% Save data to file
%%-------------------------------------------------------------------------
save('../data/data_2d_notask_ground_truth_policy_grid.mat','grid_data');
%%-------------------------------------------------------------------------