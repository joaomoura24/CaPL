%% load data
%--------------------------------------------------------------------------
file_name = 'kuka_wiping_3sec_5traj_2datasets.mat';
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

%% Compute model variance
%--------------------------------------------------------------------------
fprintf(1,'Computing data variance...\n');
xall = cell2mat(data.s(:)');
model.var = std(xall,1,2).';
%--------------------------------------------------------------------------

%% Compute model local Gaussian receptive fields centres'
%--------------------------------------------------------------------------
fprintf(1,'Computing Receptive Fields Centres ...\n');
stream = RandStream('mlfg6331_64');  % Random number stream for parallel computation
options = statset('Display','off','MaxIter',1000,'UseParallel',true,'UseSubstreams',1,'Streams',stream);
Nmodels = 125;
[~,C] = kmeans(xall',Nmodels,'Distance','sqeuclidean','EmptyAction','singleton','Start','uniform',...
    'Replicates',10,'OnlinePhase','off','Options', options);
model.c = C.';
%--------------------------------------------------------------------------

%% learn for each dataset and for subset of trajectories
%--------------------------------------------------------------------------
Ndatasets = size(data.s, 1);
noise_names = fieldnames(data.noise);
Nnoise_levels = length(noise_names);
u_dim = size(data.s{1}, 1);
Ndatapoints = size(data.s{1}, 2);
Nphi = size(data.Phi{1},2);
Nphi_sim = size(data.Phi_sim{1},2);
NphiA = size(data.PhiA{1},1);
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
upe_svd_l = zeros(Ndatasets, Nnoise_levels);
upe_svd_g = zeros(Ndatasets, Nnoise_levels);
upe_sim_ccl_l = zeros(Ndatasets, Nnoise_levels);
upe_sim_ccl_g = zeros(Ndatasets, Nnoise_levels);
%--------------------------------------------------------------------------
fprintf(1,'Computing errors ...\n');
step = 0;
steps = Ndatasets;
h = waitbar(step / steps, 'Computing errors...');
for dataset_i = 1:Ndatasets
    % get all data from dataset i
    S_eval = cell2mat(data.s(dataset_i,traj_eval));
    S_eval_cell = num2cell(S_eval,1);
    Phi_eval = cell2mat(data.Phi(dataset_i,traj_eval)');
    Phi_eval_cell = mat2cell(Phi_eval, u_dim*ones(Ntraj_eval*Ndatapoints,1), Nphi)';
    Phi_sim_eval = cell2mat(data.Phi_sim(dataset_i,traj_eval)');
    Phi_sim_eval_cell = mat2cell(Phi_sim_eval, u_dim*ones(Ntraj_eval*Ndatapoints,1), Nphi_sim)';
    Uu_eval = cell2mat(data.u_u(dataset_i,traj_eval));
    parfor noise_i = 1:Nnoise_levels
        % get model
        model_dn = model;
        % get data
        S = cell2mat(data.s(dataset_i,traj_train));
        S_cell = num2cell(S_eval,1);
        Unoise = cell2mat(data.noise.(noise_names{noise_i})(dataset_i,traj_train));
        Unoise_cell = num2cell(Unoise,1);
        Phi = cell2mat(data.Phi(dataset_i,traj_train)');
        Phi_cell = mat2cell(Phi, u_dim*ones(Ntraj_train*Ndatapoints,1), Nphi)';
        Phi_sim = cell2mat(data.Phi(dataset_i,traj_train)');
        Phi_sim_cell = mat2cell(Phi_sim, u_dim*ones(Ntraj_train*Ndatapoints,1), Nphi_sim)';
        % initialize variables
        betaA_hat = cell(1,Ntraj_train);
        P_hat_Phi_cell = cell(1,Ntraj_train);
        P_hat_Phi_sim_cell = cell(1,Ntraj_train);
        for idx=1:Ntraj_train
            % get data
            Phi_idx = cell2mat(data.Phi(dataset_i,idx)');
            Phi_idx_cell = mat2cell(Phi_idx, u_dim*ones(Ndatapoints,1), Nphi)';
            Phi_sim_idx = cell2mat(data.Phi_sim(dataset_i,idx)');
            Phi_sim_idx_cell = mat2cell(Phi_sim_idx, u_dim*ones(Ndatapoints,1), Nphi_sim)';
            PhiA_idx = cell2mat(data.PhiA(dataset_i,idx)');
            PhiA_idx_cell = mat2cell(PhiA_idx, NphiA, u_dim*ones(Ndatapoints,1));
            Unoise_idx = cell2mat(data.noise.(noise_names{noise_i})(dataset_i,idx));
            Unoise_idx_cell = mat2cell(Unoise_idx, u_dim, ones(Ndatapoints,1));
            %PhiAb_idx = [PhiA_idx*Unoise_idx(:); -Phib_idx];
            Y_idx = cell2mat(cellfun(@(phiA,u) phiA*u, PhiA_idx_cell, Unoise_idx_cell, 'un', 0));
            % estimate constraint matrix
            [U,~,~]=svd(Y_idx);
            betaA_hat{idx} = U(:,(end-3+1):end).';
            % evaluate feature functions
            P_hat_Phi_cell{idx} = cell2mat(...
                cellfun(@(phiA, phi) (eye(u_dim)-pinv(betaA_hat{idx}*phiA)*betaA_hat{idx}*phiA)*phi, ...
                PhiA_idx_cell, Phi_idx_cell, 'un', 0).');
            P_hat_Phi_sim_cell{idx} = cell2mat(...
                cellfun(@(phiA, phi) (eye(u_dim)-pinv(betaA_hat{idx}*phiA)*betaA_hat{idx}*phiA)*phi, ...
                PhiA_idx_cell, Phi_sim_idx_cell, 'un', 0).');
        end
        P_hat_Phi = cell2mat(P_hat_Phi_cell.');
        P_hat_Phi_sim = cell2mat(P_hat_Phi_sim_cell.');
        %------------------------------------------------------------------
        %% local
        % learn svd policy
        model_dn.b = receptive_fields_weighted_regression_local(model_dn, S, Unoise, P_hat_Phi);
        % evaluate estimated policy
        pi_hat = def_weighted_linear_model_phi(model_dn);
        U_hat = cell2mat(cellfun(pi_hat, S_eval_cell, Phi_eval_cell, 'un', 0));
        upe_svd_l(dataset_i, noise_i) = e_dpl(Uu_eval, U_hat);
        %------------------------------------------------------------------
        %% global
        % learn svd policy 
        model_dn.b = receptive_fields_weighted_regression_global(model_dn, S, Unoise, P_hat_Phi);
        % evaluate estimated policy
        pi_hat = def_weighted_linear_model_phi(model_dn);
        U_hat = cell2mat(cellfun(pi_hat, S_eval_cell, Phi_eval_cell, 'un',0));
        upe_svd_g(dataset_i, noise_i) = e_dpl(Uu_eval, U_hat);
        %------------------------------------------------------------------
        %% local sim
        % learn svd policy
        model_dn.b = receptive_fields_weighted_regression_local(model_dn, S, Unoise, P_hat_Phi_sim);
        % evaluate estimated policy
        pi_hat = def_weighted_linear_model_phi(model_dn);
        U_hat = cell2mat(cellfun(pi_hat, S_eval_cell, Phi_eval_cell, 'un', 0));
        upe_sim_svd_l(dataset_i, noise_i) = e_dpl(Uu_eval, U_hat);
        %------------------------------------------------------------------
        %% global sim
        % learn svd policy 
        model_dn.b = receptive_fields_weighted_regression_global(model_dn, S, Unoise, P_hat_Phi_sim);
        % evaluate estimated policy
        pi_hat = def_weighted_linear_model_phi(model_dn);
        U_hat = cell2mat(cellfun(pi_hat, S_eval_cell, Phi_eval_cell, 'un',0));
        upe_sim_svd_g(dataset_i, noise_i) = e_dpl(Uu_eval, U_hat);
        %------------------------------------------------------------------
    end
    %------------------------------------------------------------------
    % waitbar
    step = step + 1;
    waitbar(step / steps, h);
end
close(h);
%--------------------------------------------------------------------------

%% Save data to file
%--------------------------------------------------------------------------
save(['../data/data_errors_with_noise_svd_', file_name],...
    'upe_svd_l','upe_svd_g','upe_sim_ccl_l','upe_sim_ccl_g');
%--------------------------------------------------------------------------