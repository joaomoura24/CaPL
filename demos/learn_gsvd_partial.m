%% load data
%--------------------------------------------------------------------------
file_name = '2d_withtask_2sec_50traj_40datasets.mat';
load(['../data/data_', file_name]);
%-------------------------------------------------------------------

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

%% learn for each dataset and for subset of trajectories
%--------------------------------------------------------------------------
Ndatasets = size(data.s, 1);
u_dim = size(data.s{1}, 1);
Ndatapoints = size(data.s{1}, 2);
Nphi = size(data.Phi{1},2);
b_dim = size(data.b{1,1},1);
%--------------------------------------------------------------------------
% compute intervals for computation and evaluation:
Ntraj = size(data.s, 2);
traj_i = round(Ntraj*0.1);
traj_f = round(Ntraj*0.8);
traj_eval = (traj_f+1):Ntraj;
Ntraj_eval = length(traj_eval);
traj_train = traj_i:traj_f;
Ntraj_train = length(traj_train);
b_true = cell2mat(data.b);
%--------------------------------------------------------------------------
% initialize variables
upe_svd_l = zeros(Ndatasets, Ntraj_train);
upe_svd_g = zeros(Ndatasets, Ntraj_train);
cpe_svd_l = zeros(Ndatasets, Ntraj_train);
cpe_svd_g = zeros(Ndatasets, Ntraj_train);
errb_gsvd = zeros(Ndatasets, Ntraj_train);
time_svd_l = zeros(Ndatasets, Ntraj_train);
time_svd_g = zeros(Ndatasets, Ntraj_train);
Psi_b = -1.*ones(b_dim, Ndatapoints);
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
    b_true_vec = b_true(dataset_i,:);
    parfor traj_idx = 1:Ntraj_train
        % get model
        model_dt = model;
        % get data from trajectory 1 to traj_i
        S = cell2mat(data.s(dataset_i,1:traj_train(traj_idx)));
        Uns = cell2mat(data.noise.u_50dB(dataset_i,1:traj_train(traj_idx)));
        Phi = cell2mat(data.Phi(dataset_i,1:traj_train(traj_idx))');
        Phi_cell = mat2cell(Phi, u_dim*ones(traj_train(traj_idx)*Ndatapoints,1), Nphi)';
        %------------------------------------------------------------------
        % initialize variables
        P_hat_Phi_cell = cell(1,traj_train(traj_idx));
        A_hat = cell(1,traj_train(traj_idx));
        b_hat = cell(1,traj_train(traj_idx));
        P_hat = cell(1,traj_train(traj_idx));
        b_true_vec_idx = b_true_vec;
        %------------------------------------------------------------------
        %% local
        tic;
        for idx=1:traj_train(traj_idx)
            % get data
            Phi_idx = cell2mat(data.Phi(dataset_i,idx)');
            Phi_idx_cell = mat2cell(Phi_idx, u_dim*ones(Ndatapoints,1), Nphi)'; 
            Uns_idx = cell2mat(data.noise.u_50dB(dataset_i,idx));
            % estimate constraint matrix
            Y_Ab = [Uns_idx; Psi_b];
            Z_Ab = (1/sqrt(Ndatapoints)).*repmat([eye(u_dim); zeros(b_dim,u_dim)],1,Ndatapoints);
            [~,~,Xgsvd,~,~] = gsvd(Y_Ab',Z_Ab');
            Xgsvd_inv = inv(Xgsvd');
            A_hat{idx} = Xgsvd_inv(1:u_dim,1).';
            b_hat{idx} = Xgsvd_inv(end,1);
            P_hat{idx} = eye(u_dim) - pinv(A_hat{idx})*A_hat{idx};
            % evaluate feature functions
            P_hat_Phi_cell{idx} = cell2mat(cellfun(@(phi) P_hat{idx}*phi, Phi_idx_cell, 'un', 0).');
        end
        %------------------------------------------------------------------
        % compute MSE for b
        errb_gsvd(dataset_i, traj_idx) = immse(abs(cell2mat(b_hat)),abs(b_true_vec_idx(1:traj_train(traj_idx))));
        %------------------------------------------------------------------
        P_hat_Phi = cell2mat(P_hat_Phi_cell.');
        % learn policy
        model_dt.b = receptive_fields_weighted_regression_local(model_dt, S, Uns, P_hat_Phi);
        time_gsvd_l(dataset_i,traj_idx) = toc;
        % evaluate estimated policy
        pi_hat = def_weighted_linear_model_phi(model_dt);
        U_hat = cell2mat(cellfun(pi_hat, S_eval_cell, Phi_eval_cell, 'un',0));
        U_hat_cell = mat2cell(U_hat, u_dim, Ndatapoints*ones(Ntraj_eval,1));
        U_ns_hat = cell2mat(cellfun(@(P,v) P*v, P_eval, U_hat_cell, 'un', 0));
        upe_gsvd_l(dataset_i,traj_idx) = e_dpl(Uu_eval, U_hat);
        cpe_gsvd_l(dataset_i,traj_idx) = e_dpl(Uns_eval, U_ns_hat);
        %------------------------------------------------------------------
        %% global
        tic; 
        for idx=1:traj_train(traj_idx)
            % get data
            Phi_idx = cell2mat(data.Phi(dataset_i,idx)');
            Phi_idx_cell = mat2cell(Phi_idx, u_dim*ones(Ndatapoints,1), Nphi)';
            Uns_idx = cell2mat(data.noise.u_50dB(dataset_i,idx));
            % estimate constraint matrix
            Y_Ab = [Uns_idx; Psi_b];
            Z_Ab = (1/sqrt(Ndatapoints)).*repmat([eye(u_dim); zeros(b_dim,u_dim)],1,Ndatapoints);
            [~,~,Xgsvd,~,~] = gsvd(Y_Ab',Z_Ab');
            Xgsvd_inv = inv(Xgsvd');
            A_hat{idx} = Xgsvd_inv(1:u_dim,1).';
            P_hat{idx} = eye(u_dim) - pinv(A_hat{idx})*A_hat{idx};
            % evaluate feature functions
            P_hat_Phi_cell{idx} = cell2mat(cellfun(@(phi) P_hat{idx}*phi, Phi_idx_cell, 'un', 0).');
        end
        P_hat_Phi = cell2mat(P_hat_Phi_cell.');
        % learn policy
        model_dt.b = receptive_fields_weighted_regression_global(model_dt, S, Uns, P_hat_Phi);
        time_gsvd_g(dataset_i,traj_idx) = toc;
        % evaluate estimated policy
        pi_hat = def_weighted_linear_model_phi(model_dt);
        U_hat = cell2mat(cellfun(pi_hat, S_eval_cell, Phi_eval_cell, 'un',0));
        U_hat_cell = mat2cell(U_hat, u_dim, Ndatapoints*ones(Ntraj_eval,1));
        U_ns_hat = cell2mat(cellfun(@(P,v) P*v, P_eval, U_hat_cell, 'un', 0));
        upe_gsvd_g(dataset_i,traj_idx) = e_dpl(Uu_eval, U_hat);
        cpe_gsvd_g(dataset_i,traj_idx) = e_dpl(Uns_eval, U_ns_hat);

    end
    %------------------------------------------------------------------
    % waitbar
    step = step + 1;
    waitbar(step / steps, h);
    %------------------------------------------------------------------
end
close(h);
%--------------------------------------------------------------------------

%% Save data to file
%--------------------------------------------------------------------------
save(['../data/data_errors_partial_gsvd_', file_name], 'traj_train',...
    'upe_gsvd_l','upe_gsvd_g',...
    'cpe_gsvd_l','cpe_gsvd_g',...
    'time_gsvd_l','time_gsvd_g', 'errb_gsvd');
%--------------------------------------------------------------------------