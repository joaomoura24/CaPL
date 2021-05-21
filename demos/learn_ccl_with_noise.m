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
D = size(data.s{1},1);
model.var = diag([0.1^2, 0.1^2]);
%--------------------------------------------------------------------------

%% policy regressors
%--------------------------------------------------------------------------
phi_pi_ccl = @(phi,u) ((u*u')./(u'*u)) * phi;
%--------------------------------------------------------------------------

%% learn for each dataset and for subset of trajectories
%--------------------------------------------------------------------------
Ndatasets = size(data.s, 1);
noise_names = fieldnames(data.noise);
Nnoise_levels = length(noise_names);
u_dim = size(data.s{1}, 1);
Ndatapoints = size(data.s{1}, 2);
Nphi = size(data.Phi{1},2);
%--------------------------------------------------------------------------
% compute intervals for computation and evaluation:
Ntraj = size(data.s, 2);
traj_i = 1;
traj_f = round(Ntraj*0.8);
traj_eval = (traj_f+1):Ntraj;
Ntraj_eval = length(traj_eval);
traj_train = traj_i:traj_f;
Ntraj_train = length(traj_train);
%--------------------------------------------------------------------------
% initialize variables
upe_ccl_l = zeros(Ndatasets, Nnoise_levels);
upe_ccl_g = zeros(Ndatasets, Nnoise_levels);
cpe_ccl_l = zeros(Ndatasets, Nnoise_levels);
cpe_ccl_g = zeros(Ndatasets, Nnoise_levels);
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
    parfor noise_i = 1:Nnoise_levels
        % get model
        model_dn = model;
        % get data
        Unoise = cell2mat(data.noise.(noise_names{noise_i})(dataset_i,traj_train));
        Unoise_cell = num2cell(Unoise,1);
        S = cell2mat(data.s(dataset_i,traj_train));
        Phi = cell2mat(data.Phi(dataset_i,traj_train)');
        Phi_cell = mat2cell(Phi, u_dim*ones(Ntraj_train*Ndatapoints,1), Nphi)';
        % evaluate feature functions
        Phi_ccl_cell = cellfun(phi_pi_ccl, Phi_cell, Unoise_cell, 'un',0);
        Phi_ccl = cell2mat(Phi_ccl_cell.');
        %------------------------------------------------------------------
        %% local
        % learn ccl policy
        model_dn.b = receptive_fields_weighted_regression_local(model_dn, S, Unoise, Phi_ccl);
        % evaluate estimated policy
        pi_hat = def_weighted_linear_model_phi(model_dn);
        U_hat = cell2mat(cellfun(pi_hat, S_eval_cell, Phi_eval_cell, 'un', 0));
        U_hat_cell = mat2cell(U_hat, u_dim, Ndatapoints*ones(Ntraj_eval,1));
        U_ns_hat = cell2mat(cellfun(@(P,v) P*v, P_eval, U_hat_cell, 'un', 0));
        upe_ccl_l(dataset_i, noise_i) = e_dpl(Uu_eval, U_hat);
        cpe_ccl_l(dataset_i, noise_i) = e_dpl(Uns_eval, U_ns_hat);
        %------------------------------------------------------------------
        %% global
        % learn ccl policy 
        model_dn.b = receptive_fields_weighted_regression_global(model_dn, S, Unoise, Phi_ccl);
        % evaluate estimated policy
        pi_hat = def_weighted_linear_model_phi(model_dn);
        U_hat = cell2mat(cellfun(pi_hat, S_eval_cell, Phi_eval_cell, 'un',0));
        U_hat_cell = mat2cell(U_hat, u_dim, Ndatapoints*ones(Ntraj_eval,1));
        U_ns_hat = cell2mat(cellfun(@(P,v) P*v, P_eval, U_hat_cell, 'un', 0));
        upe_ccl_g(dataset_i, noise_i) = e_dpl(Uu_eval, U_hat);
        cpe_ccl_g(dataset_i, noise_i) = e_dpl(Uns_eval, U_ns_hat);

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
save(['../data/data_errors_with_noise_ccl_', file_name],...
    'upe_ccl_l','upe_ccl_g',...
    'cpe_ccl_l','cpe_ccl_g');
%--------------------------------------------------------------------------