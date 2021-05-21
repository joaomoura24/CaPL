%% load data
%--------------------------------------------------------------------------
file_name = '2d_withtask_2sec_50traj_40datasets.mat';
load(['../data/data_', file_name]);
%--------------------------------------------------------------------------

%% Add path
%--------------------------------------------------------------------------
addpath(genpath('../library/')); % add the library and it's subfolders to the path
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
phi_pi_ccl = @(phi,u) ((u*u')./(u'*u)) * phi;
%--------------------------------------------------------------------------

%% learn for each dataset and for subset of trajectories
%--------------------------------------------------------------------------
Ndatasets = size(data.s, 1);
u_dim = size(data.s{1}, 1);
Ndatapoints = size(data.s{1}, 2);
Nphi = size(data.Phi{1},2);
%--------------------------------------------------------------------------
% compute intervals for computation and evaluation:
Ntraj = size(data.s, 2);
traj_i = round(Ntraj*0.1);
traj_f = round(Ntraj*0.8);
traj_eval = (traj_f+1):Ntraj;
Ntraj_eval = length(traj_eval);
traj_train = traj_i:traj_f;
Ntraj_train = length(traj_train);
%--------------------------------------------------------------------------
% initialize variables
upe_ccl_l = zeros(Ndatasets, Ntraj_train);
upe_ccl_g = zeros(Ndatasets, Ntraj_train);
cpe_ccl_l = zeros(Ndatasets, Ntraj_train);
cpe_ccl_g = zeros(Ndatasets, Ntraj_train);
time_ccl_l = zeros(Ndatasets, Ntraj_train);
time_ccl_g = zeros(Ndatasets, Ntraj_train);
%--------------------------------------------------------------------------
step = 0;
steps = Ndatasets;
h = waitbar(step / steps, 'Computing errors...');
for dataset_i = 1:Ndatasets
    % get all data from dataset i
    S_eval = cell2mat(data.s(dataset_i,traj_eval));
    S_eval_cell = num2cell(S_eval,1);
	Phi_eval = cell2mat(data.Phi(dataset_i,traj_eval)');
    Phi_eval_cell = mat2cell(Phi_eval, u_dim*ones(Ntraj_eval*Ndatapoints,1), Nphi)';
    Uns_eval = cell2mat(data.u(dataset_i,traj_eval));
    Uu_eval = cell2mat(data.u_u(dataset_i,traj_eval));
    A_eval = data.A(dataset_i,traj_eval);
    P_eval = cellfun(@(v) eye(length(v))-pinv(v)*v, A_eval, 'un', 0);
    parfor traj_idx = 1:Ntraj_train
        % get model
        model_dt = model;
        % get data from trajectory 1 to traj_i
        S = cell2mat(data.s(dataset_i,1:traj_train(traj_idx)));
        Phi_pi = cell2mat(data.Phi(dataset_i,1:traj_train(traj_idx))');
        Phi_pi_cell = mat2cell(Phi_pi, u_dim*ones(traj_train(traj_idx)*Ndatapoints,1), Nphi)';
        Uns = cell2mat(data.noise.u_50dB(dataset_i,1:traj_train(traj_idx)));
        Uns_cell = num2cell(Uns,1);
        %------------------------------------------------------------------
        %% local
        tic;
        % evaluate feature functions
        Phi_cell = cellfun(phi_pi_ccl, Phi_pi_cell, Uns_cell, 'un',0);
        Phi = cell2mat(Phi_cell.');
        % learn dpl policy 
        model_dt.b = receptive_fields_weighted_regression_local(model_dt, S, Uns, Phi);
        time_ccl_l(dataset_i,traj_idx) = toc;
        % evaluate estimated policy
        pi_hat = def_weighted_linear_model_phi(model_dt);
        U_hat = cell2mat(cellfun(pi_hat, S_eval_cell, Phi_eval_cell, 'un',0));
        U_hat_cell = mat2cell(U_hat, u_dim, Ndatapoints*ones(Ntraj_eval,1));
        U_ns_hat = cell2mat(cellfun(@(P,v) P*v, P_eval, U_hat_cell, 'un', 0));
        upe_ccl_l(dataset_i,traj_idx) = e_dpl(Uu_eval, U_hat);
        cpe_ccl_l(dataset_i,traj_idx) = e_dpl(Uns_eval, U_ns_hat);
        %------------------------------------------------------------------
        %% global
        tic; 
        % evaluate feature functions
        Phi_cell = cellfun(phi_pi_ccl, Phi_pi_cell, Uns_cell, 'un',0);
        Phi = cell2mat(Phi_cell.');
        % learn dpl policy 
        model_dt.b = receptive_fields_weighted_regression_global(model_dt, S, Uns, Phi);
        time_ccl_g(dataset_i,traj_idx) = toc;
        % evaluate estimated policy
        pi_hat = def_weighted_linear_model_phi(model_dt);
        U_hat = cell2mat(cellfun(pi_hat, S_eval_cell, Phi_eval_cell, 'un',0));
        U_hat_cell = mat2cell(U_hat, u_dim, Ndatapoints*ones(Ntraj_eval,1));
        U_ns_hat = cell2mat(cellfun(@(P,v) P*v, P_eval, U_hat_cell, 'un', 0));
        upe_ccl_g(dataset_i,traj_idx) = e_dpl(Uu_eval, U_hat);
        cpe_ccl_g(dataset_i,traj_idx) = e_dpl(Uns_eval, U_ns_hat);

    end
    %----------------------------------------------------------------------
    % waitbar
    step = step + 1;
    waitbar(step / steps, h);
    %----------------------------------------------------------------------
end
close(h);
%--------------------------------------------------------------------------

%% Save data to file
%--------------------------------------------------------------------------
save(['../data/data_errors_partial_ccl_', file_name], 'traj_train',...
    'upe_ccl_l','upe_ccl_g',...
    'cpe_ccl_l','cpe_ccl_g',...
    'time_ccl_l','time_ccl_g');
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------