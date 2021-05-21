%% load data
%--------------------------------------------------------------------------
load('../data/data_2d_withtask_2sec_50traj_40datasets.mat');
load('../data/data_2d_withtask_ground_truth_policy_grid.mat');
K = size(data.s, 2); % number of trajectories
D = size(data.s, 1); % number of datasets
%--------------------------------------------------------------------------

%% definition of auxiliar functions
%--------------------------------------------------------------------------
e_dpl = @(u, u_hat) immse(u,u_hat)*size(u,1);
%--------------------------------------------------------------------------

%% receptive fields centres and variance
%--------------------------------------------------------------------------
xc = -0.75:0.5:0.75;
[Cx,Cy] = meshgrid(xc,xc);
model.c = [Cx(:), Cy(:)]';
model.var = diag([0.1^2, 0.1^2]);
%--------------------------------------------------------------------------

%% policy regressors
%--------------------------------------------------------------------------
phi_pi = @(s) kron(s.',eye(2));
phi_pi_ccl = @(s,u) ((u*u')./(u'*u)) * kron(s.',eye(2));
%--------------------------------------------------------------------------

%% load data
%--------------------------------------------------------------------------
for d=7
    %----------------------------------------------------------------------
    % get data:
    Ntraj = 20;
    S = cell2mat(data.s(d,1:Ntraj));
    U_ns = cell2mat(data.u(d,1:Ntraj));
    %U_u = cell2mat(data.u_u(d,1:Ntraj));
    Phi_ccl_cell = cellfun(phi_pi_ccl, num2cell(S,1), num2cell(U_ns,1), 'un',0);
    Phi_ccl = cell2mat(Phi_ccl_cell.');
    Phi_dpl_cell = cellfun(phi_pi, num2cell(S,1), 'un',0);
    Phi_dpl = cell2mat(Phi_dpl_cell.');
    %----------------------------------------------------------------------
    % plot data
    figure(1);
    subplot(1,3,1);
    quiver(grid_data.s(1,:),grid_data.s(2,:),grid_data.u_u(1,:),grid_data.u_u(2,:),'color',[0 0 1]);
    hold on; plot(S(1,:), S(2,:),'.r'); hold off;
    xlim([-1.5 1.5]); ylim([-1.5 1.5]);
    title(['Dataset ',num2str(d)]);
    xlabel('m'); ylabel('m');
    axis square; grid on;
    %----------------------------------------------------------------------
    % learn local policy
    model.b = receptive_fields_weighted_regression_local(model, S, U_ns, Phi_dpl);
    pi_hat = def_weighted_linear_model(model, phi_pi);
    U_grid_hat_dpl_l = cell2mat(cellfun(pi_hat, num2cell(grid_data.s,1), 'un',0));
    %----------------------------------------------------------------------
    % learn global policy
    model.b = receptive_fields_weighted_regression_global(model, S, U_ns, Phi_dpl);
    pi_hat = def_weighted_linear_model(model, phi_pi);
    U_grid_hat_dpl_g = cell2mat(cellfun(pi_hat, num2cell(grid_data.s,1), 'un',0));
    %----------------------------------------------------------------------
    % plot learned model
    subplot(1,3,2);
    quiver(grid_data.s(1,:),grid_data.s(2,:),grid_data.u_u(1,:),grid_data.u_u(2,:),'color',[0 0 1]);
    hold on;
    quiver(grid_data.s(1,:),grid_data.s(2,:),U_grid_hat_dpl_l(1,:),U_grid_hat_dpl_l(2,:),'color',[0 1 0]);
    quiver(grid_data.s(1,:),grid_data.s(2,:),U_grid_hat_dpl_g(1,:),U_grid_hat_dpl_g(2,:),'color',[1 0 0]);
    hold off;
    legend('ground truth', 'dpl local', 'dpl global');
    xlim([-1.5 1.5]); ylim([-1.5 1.5]);
    xlabel('m'); ylabel('m');
    axis square; grid on;
    %----------------------------------------------------------------------
    % learn local policy
    model.b = receptive_fields_weighted_regression_local(model, S, U_ns, Phi_ccl);
    pi_hat = def_weighted_linear_model(model, phi_pi);
    U_grid_hat_ccl_l = cell2mat(cellfun(pi_hat, num2cell(grid_data.s,1), 'un',0));
    %----------------------------------------------------------------------
    % learn global policy
    model.b = receptive_fields_weighted_regression_global(model, S, U_ns, Phi_ccl);
    pi_hat = def_weighted_linear_model(model, phi_pi);
    U_grid_hat_ccl_g = cell2mat(cellfun(pi_hat, num2cell(grid_data.s,1), 'un',0));
    %----------------------------------------------------------------------
    % plot learned model
    subplot(1,3,3);
    quiver(grid_data.s(1,:),grid_data.s(2,:),grid_data.u_u(1,:),grid_data.u_u(2,:),'color',[0 0 1]);
    hold on;
    quiver(grid_data.s(1,:),grid_data.s(2,:),U_grid_hat_ccl_l(1,:),U_grid_hat_ccl_l(2,:),'color',[0 1 0]);
    quiver(grid_data.s(1,:),grid_data.s(2,:),U_grid_hat_ccl_g(1,:),U_grid_hat_ccl_g(2,:),'color',[1 0 0]);
    hold off;
    legend('ground truth', 'ccl local', 'ccl global');
    xlim([-1.5 1.5]); ylim([-1.5 1.5]);
    xlabel('m'); ylabel('m');
    axis square; grid on;
    %----------------------------------------------------------------------
%     figure();
%     quiver(grid_data.s(1,:),grid_data.s(2,:),grid_data.u_u(1,:),grid_data.u_u(2,:),'color',[1 0 0],'AutoScale','off');
%     hold on;
%     quiver(grid_data.s(1,:),grid_data.s(2,:),U_grid_hat_dpl_l(1,:),U_grid_hat_dpl_l(2,:),'color',[0 1 0],'AutoScale','off');
%     quiver(grid_data.s(1,:),grid_data.s(2,:),U_grid_hat_ccl_l(1,:),U_grid_hat_ccl_l(2,:),'color',[0 0 1],'AutoScale','off');
%     hold off;
%     legend('ground truth', 'dpl local', 'ccl local');
%     xlim([-1.5 1.5]); ylim([-1.5 1.5]);
%     xlabel('m'); ylabel('m');
%     axis square; grid on;
    pause;
end
%--------------------------------------------------------------------------


%% Save data to csv for plotting
%--------------------------------------------------------------------------
% define formatSpec function
formatSpec = @(format,delimiter,reps) [convertStringsToChars(join(repmat(format,1,reps),repmat(delimiter,1,reps-1))),'\r\n'];
%--------------------------------------------------------------------------
print_data = [model.c];
print_names = {'c1'; 'c2'};
nn = length(print_names);
fileID = fopen('../data/data_2d_withtask_local_models_centers.dat','w');
fprintf(fileID, formatSpec("%7s",",",nn), print_names{:});
fprintf(fileID, formatSpec("%7.3f",",",nn), print_data);
fclose(fileID);
%--------------------------------------------------------------------------
print_data = [grid_data.s; grid_data.u_u;];
print_names = {'s1'; 's2';'u_u1'; 'u_u2'};
nn = length(print_names);
fileID = fopen('../data/data_2d_withtask_grid_ground_truth_policy.dat','w');
fprintf(fileID, formatSpec("%7s",",",nn), print_names{:});
fprintf(fileID, formatSpec("%7.3f",",",nn), print_data);
fclose(fileID);
%--------------------------------------------------------------------------
print_data = [cell2mat(data.s(d,1:end)); cell2mat(data.u(d,1:end));...
     cell2mat(data.u_u(d,1:end))];
print_names = {'s1'; 's2'; 'u_ns1'; 'u_ns2'; 'u_u1'; 'u_u2'};
nn = length(print_names);
fileID = fopen('../data/data_2d_withtask_samples.dat','w');
fprintf(fileID, formatSpec("%7s",",",nn), print_names{:});
fprintf(fileID, formatSpec("%7.3f",",",nn), print_data);
fclose(fileID);
%--------------------------------------------------------------------------
print_data = [grid_data.s;
    U_grid_hat_dpl_l; U_grid_hat_dpl_g;...
    U_grid_hat_ccl_l; U_grid_hat_ccl_g;...
    ];
print_names = {'s1'; 's2';...
    'u_dpl_l1'; 'u_dpl_l2'; 'u_dpl_g1'; 'u_dpl_g2';
    'u_ccl_l1'; 'u_ccl_l2'; 'u_ccl_g1'; 'u_ccl_g2';
};
nn = length(print_names);
fileID = fopen('../data/data_2d_withtask_grid_learned_policy.dat','w');
fprintf(fileID, formatSpec("%9s",",",nn), print_names{:});
fprintf(fileID, formatSpec("%9.4f",",",nn), print_data);
fclose(fileID);
%--------------------------------------------------------------------------