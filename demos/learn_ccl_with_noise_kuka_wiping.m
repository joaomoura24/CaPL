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
options = statset('Display','off','MaxIter',1000,'UseParallel',1,'UseSubstreams',1,'Streams',stream);
Nmodels = 125;
[~,C] = kmeans(xall',Nmodels,'Distance','sqeuclidean','EmptyAction','singleton','Start','uniform',...
    'Replicates',10,'OnlinePhase','off','Options', options);
model.c = C.';
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
Nphi_sim = size(data.Phi_sim{1},2);
%--------------------------------------------------------------------------
% compute intervals for computation and evaluation:
Ntraj = size(data.s, 2);
traj_i = 1;
traj_f = round(Ntraj*0.8);
traj_eval = (traj_f+1):Ntraj;
Ntraj_eval = length(traj_eval);
traj_train = traj_i:traj_f;
Ntraj_train = length(traj_train);
%-------------------------------------------------------------------------
% initialize variables
upe_ccl_l = zeros(Ndatasets, Nnoise_levels);
upe_ccl_g = zeros(Ndatasets, Nnoise_levels);
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
    parfor noise_i = 1:1
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
        % evaluate feature functions
        Phi_ccl_cell = cellfun(phi_pi_ccl, Phi_cell, Unoise_cell, 'un',0);
        Phi_ccl = cell2mat(Phi_ccl_cell.');
        Phi_sim_ccl_cell = cellfun(phi_pi_ccl, Phi_sim_cell, Unoise_cell, 'un',0);
        Phi_sim_ccl = cell2mat(Phi_sim_ccl_cell.');
        %------------------------------------------------------------------
        %% local
        % learn ccl policy
        model_dn.b = receptive_fields_weighted_regression_local(model_dn, S, Unoise, Phi_ccl);
        % evaluate estimated policy
        pi_hat = def_weighted_linear_model_phi(model_dn);
        U_hat = cell2mat(cellfun(pi_hat, S_eval_cell, Phi_eval_cell, 'un', 0));
        upe_ccl_l(dataset_i, noise_i) = e_dpl(Uu_eval, U_hat);
        %------------------------------------------------------------------
        %% global
        % learn ccl policy 
        model_dn.b = receptive_fields_weighted_regression_global(model_dn, S, Unoise, Phi_ccl);
        % evaluate estimated policy
        pi_hat = def_weighted_linear_model_phi(model_dn);
        U_hat = cell2mat(cellfun(pi_hat, S_eval_cell, Phi_eval_cell, 'un',0));
        upe_ccl_g(dataset_i, noise_i) = e_dpl(Uu_eval, U_hat);
        %------------------------------------------------------------------
        %% local sim
        % learn ccl policy
        model_dn.b = receptive_fields_weighted_regression_local(model_dn, S, Unoise, Phi_sim_ccl);
        % evaluate estimated policy
        pi_hat = def_weighted_linear_model_phi(model_dn);
        U_hat = cell2mat(cellfun(pi_hat, S_eval_cell, Phi_sim_eval_cell, 'un', 0));
        upe_sim_ccl_l(dataset_i, noise_i) = e_dpl(Uu_eval, U_hat);
        %------------------------------------------------------------------
        %% global
        % learn ccl policy 
        model_dn.b = receptive_fields_weighted_regression_global(model_dn, S, Unoise, Phi_sim_ccl);
        % evaluate estimated policy
        pi_hat = def_weighted_linear_model_phi(model_dn);
        U_hat = cell2mat(cellfun(pi_hat, S_eval_cell, Phi_sim_eval_cell, 'un',0));
        upe_sim_ccl_g(dataset_i, noise_i) = e_dpl(Uu_eval, U_hat);
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
    'upe_ccl_l','upe_ccl_g','upe_sim_ccl_l','upe_sim_ccl_g');
%--------------------------------------------------------------------------