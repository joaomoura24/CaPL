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
b_dim = size(data.b{1,1},1);
%--------------------------------------------------------------------------

%% learn for each dataset and for subset of trajectories
%--------------------------------------------------------------------------
Ndatasets = size(data.s, 1);
noise_names = fieldnames(data.noise);
Nnoise_levels = length(noise_names);
u_dim = size(data.s{1}, 1);
Ndatapoints = size(data.s{1}, 2);
Nphi = size(data.Phi{1},2);
b_true = cell2mat(data.b);
%--------------------------------------------------------------------------
% compute intervals for computation and evaluation:
Ntraj = size(data.s, 2);
traj_i = 1;
traj_f = round(Ntraj*0.8);
traj_eval = (traj_f+1):Ntraj;
Ntraj_eval = length(traj_eval);
traj_train = traj_i:traj_f;
Ntraj_train = length(traj_train);
Psi_b = -1.*ones(b_dim, Ndatapoints);
%--------------------------------------------------------------------------
% initialize variables
upe_gsvd_l = zeros(Ndatasets, Nnoise_levels);
upe_gsvd_g = zeros(Ndatasets, Nnoise_levels);
cpe_gsvd_l = zeros(Ndatasets, Nnoise_levels);
cpe_gsvd_g = zeros(Ndatasets, Nnoise_levels);
errb_gsvd = zeros(Ndatasets, Nnoise_levels);
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
    b_true_vec = b_true(dataset_i,1:Ntraj_train);
    parfor noise_i = 1:Nnoise_levels
        % get model
        model_dn = model;
        % get data
        Unoise = cell2mat(data.noise.(noise_names{noise_i})(dataset_i,traj_train));
        S = cell2mat(data.s(dataset_i,traj_train));
        Phi = cell2mat(data.Phi(dataset_i,traj_train)');
        % initialize variables
        A_hat = cell(1,Ntraj_train);
        b_hat = cell(1,Ntraj_train);
        P_hat = cell(1,Ntraj_train);
        P_hat_Phi_cell = cell(1,Ntraj_train);
        for idx=1:Ntraj_train
            % get data
            Phi_idx = cell2mat(data.Phi(dataset_i,idx)');
            Phi_idx_cell = mat2cell(Phi_idx, u_dim*ones(Ndatapoints,1), Nphi)';
            Unoise_idx = cell2mat(data.noise.(noise_names{noise_i})(dataset_i,idx));
            % estimate constraint matrix
            Y_Ab = [Unoise_idx; Psi_b];
            Z_Ab = (1/sqrt(Ndatapoints)).*repmat([eye(u_dim); zeros(b_dim,u_dim)],1,Ndatapoints);
            [~,~,Xgsvd,~,~] = gsvd(Y_Ab',Z_Ab');
            Xgsvd_inv = inv(Xgsvd');
            A_hat{idx} = Xgsvd_inv(1:u_dim,1).';
            b_hat{idx} = Xgsvd_inv(end,1);
            P_hat{idx} = eye(u_dim) - pinv(A_hat{idx})*A_hat{idx};
            % evaluate feature functions
            P_hat_Phi_cell{idx} = cell2mat(cellfun(@(phi) P_hat{idx}*phi, Phi_idx_cell, 'un', 0).');
        end
        P_hat_Phi = cell2mat(P_hat_Phi_cell.');
        %------------------------------------------------------------------
        % compute MSE for b
        errb_gsvd(dataset_i, noise_i) = immse(abs(cell2mat(b_hat)),abs(b_true_vec));
        %------------------------------------------------------------------
        %% local
        % learn svd policy
        model_dn.b = receptive_fields_weighted_regression_local(model_dn, S, Unoise, P_hat_Phi);
        % evaluate estimated policy
        pi_hat = def_weighted_linear_model_phi(model_dn);
        U_hat = cell2mat(cellfun(pi_hat, S_eval_cell, Phi_eval_cell, 'un', 0));
        U_hat_cell = mat2cell(U_hat, u_dim, Ndatapoints*ones(Ntraj_eval,1));
        U_ns_hat = cell2mat(cellfun(@(P,v) P*v, P_eval, U_hat_cell, 'un', 0));
        upe_gsvd_l(dataset_i, noise_i) = e_dpl(Uu_eval, U_hat);
        cpe_gsvd_l(dataset_i, noise_i) = e_dpl(Uns_eval, U_ns_hat);
        %------------------------------------------------------------------
        %% global
        % learn svd policy 
        model_dn.b = receptive_fields_weighted_regression_global(model_dn, S, Unoise, P_hat_Phi);
        % evaluate estimated policy
        pi_hat = def_weighted_linear_model_phi(model_dn);
        U_hat = cell2mat(cellfun(pi_hat, S_eval_cell, Phi_eval_cell, 'un',0));
        U_hat_cell = mat2cell(U_hat, u_dim, Ndatapoints*ones(Ntraj_eval,1));
        U_ns_hat = cell2mat(cellfun(@(P,v) P*v, P_eval, U_hat_cell, 'un', 0));
        upe_gsvd_g(dataset_i, noise_i) = e_dpl(Uu_eval, U_hat);
        cpe_gsvd_g(dataset_i, noise_i) = e_dpl(Uns_eval, U_ns_hat);
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
save(['../data/data_errors_with_noise_gsvd_', file_name],...
    'upe_gsvd_l','upe_gsvd_g',...
    'cpe_gsvd_l','cpe_gsvd_g', 'errb_gsvd');
%--------------------------------------------------------------------------