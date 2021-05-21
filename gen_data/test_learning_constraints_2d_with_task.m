%% Add path
%--------------------------------------------------------------------------
addpath(genpath('../library/')); % add the library and it's subfolders to the path
%--------------------------------------------------------------------------

%% definition of auxiliar functions
%--------------------------------------------------------------------------
e_dpl = @(u, u_hat) immse(u,u_hat)*size(u,1);
% Basic functions definitions:
vec = @(a) a(:);
%--------------------------------------------------------------------------

%% load data
%--------------------------------------------------------------------------
%load('../data/data_2d_notask_2sec_40traj_40datasets_test.mat');
load('../data/data_2d_withtask_2sec_50traj_40datasets.mat');
load('../data/data_2d_withtask_ground_truth_policy_grid.mat');
%--------------------------------------------------------------------------


%% organize data
%--------------------------------------------------------------------------
dataset = 1;
S = cell2mat(data.s(dataset,1:end));
D = size(S,1);
Uns = cell2mat(data.u(dataset,1:end));
Uu = cell2mat(data.u_u(dataset,1:end));
A = cell2mat(data.A(dataset,1:end)');
disp(e_dpl(Uu, Uns));
Ntraj = size(data.s,2);
Ndim = size(data.s{1},1);
bdim = size(data.b{1,1},1);
Nsamples = size(data.u{1,1},2);
%--------------------------------------------------------------------------

%% compute errors
%--------------------------------------------------------------------------
err = e_dpl(Uu, Uns);
%--------------------------------------------------------------------------

%% receptive fields centres and variance
%--------------------------------------------------------------------------
xc = -0.75:0.5:0.75;
[Cx,Cy] = meshgrid(xc,xc);
model.c = [Cx(:), Cy(:)]';
model.var = 1/(0.5.^2);
model_g = model;
model_l = model;
model_proj_g = model;
model_proj_l = model;
model_lA_sampling_g = model;
model_lA_sampling_l = model;
model_lA_svd_g = model;
model_lA_svd_l = model;
%--------------------------------------------------------------------------

%% policy regressors
%--------------------------------------------------------------------------
phi_pi = @(s) kron([s.' 1],eye(2));
phi_pi_proj = @(s,u) ((u*u')./(u'*u)) * kron([s.' 1],eye(2));
%--------------------------------------------------------------------------

%% policy regressors evaluation
%--------------------------------------------------------------------------
Phi_cell = cellfun(phi_pi, num2cell(S,1), 'un',0);
Phi = cell2mat(Phi_cell.');
%--------------------------------------------------------------------------
Phi_proj_cell = cellfun(phi_pi_proj, num2cell(S,1), num2cell(Uns,1), 'un',0);
Phi_proj = cell2mat(Phi_proj_cell.');
%--------------------------------------------------------------------------
    
%% policy weights
%--------------------------------------------------------------------------
model_l.b = receptive_fields_weighted_regression_local(model, S, Uns, Phi);
model_g.b = receptive_fields_weighted_regression_global(model, S, Uns, Phi);
%--------------------------------------------------------------------------
model_proj_l.b = receptive_fields_weighted_regression_local(model, S, Uns, Phi_proj);
model_proj_g.b = receptive_fields_weighted_regression_global(model, S, Uns, Phi_proj);
%--------------------------------------------------------------------------

%% learn constraint A - svd
%--------------------------------------------------------------------------
P_all = cell(1, Ntraj);
A_all = cell(1,Ntraj);
PhatPhi_cell = cell(1,Ntraj);
for idx=1:Ntraj
    Uns_idx = cell2mat(data.u(dataset,idx));
    [U,~,~]=svd(Uns_idx);
    A_all{idx} = U(:,end).';
    P_all{idx} = eye(Ndim) - pinv(A_all{idx})*A_all{idx};
    PhatPhi_cell{idx} = cell2mat(cellfun(@(s) P_all{idx}*phi_pi(s), num2cell(data.s{dataset,idx},1), 'un', 0).');
end
PhatPhi = cell2mat(PhatPhi_cell.');
model_lA_svd_l.b = receptive_fields_weighted_regression_local(model, S, Uns, PhatPhi);
model_lA_svd_g.b = receptive_fields_weighted_regression_global(model, S, Uns, PhatPhi);
%--------------------------------------------------------------------------

%% learn constraint A - svd - with b
%--------------------------------------------------------------------------
P_all = cell(1,Ntraj);
A_all = cell(1,Ntraj);
Psi_b = -1.0*ones(bdim, Nsamples);
PhatPhi_cell = cell(1,Ntraj);
for idx=1:Ntraj
    Uns_idx = [cell2mat(data.u(dataset,idx)); Psi_b];
    [U,~,~]=svd(Uns_idx);
    A_all{idx} = U(1:Ndim,end).';
    P_all{idx} = eye(Ndim) - pinv(A_all{idx})*A_all{idx};
    PhatPhi_cell{idx} = cell2mat(cellfun(@(s) P_all{idx}*phi_pi(s), num2cell(data.s{dataset,idx},1), 'un', 0).');
end
PhatPhi = cell2mat(PhatPhi_cell.');
model_lA_svd_l.b = receptive_fields_weighted_regression_local(model, S, Uns, PhatPhi);
model_lA_svd_g.b = receptive_fields_weighted_regression_global(model, S, Uns, PhatPhi);
%--------------------------------------------------------------------------

%% learn constraint A - sampling
%--------------------------------------------------------------------------
Nsamples = 180;
theta_samples = linspace(0,-pi,Nsamples)';
A_samples = [cos(theta_samples), sin(theta_samples)];
A_samples_cell = num2cell(A_samples,2);
Pperp_samples_cell = cellfun(@(A) pinv(A)*A, A_samples_cell, 'un',0);
P_all = cell(1, Ntraj);
A_all = cell(1,Ntraj);
PhatPhi_cell = cell(1,Ntraj);
for idx=1:Ntraj
    Uns_idx = cell2mat(data.u(dataset,idx));
    poe_idx = cell2mat(cellfun(@(P) vec(Uns_idx)'*vec(P*Uns_idx),...
        Pperp_samples_cell, 'un', 0));
    [~,min_indx] = min(poe_idx);
    P_all{idx} = eye(Ndim) - Pperp_samples_cell{min_indx};
    A_all{idx} = A_samples_cell{min_indx};
    PhatPhi_cell{idx} = cell2mat(cellfun(@(s) P_all{idx}*phi_pi(s), num2cell(data.s{dataset,idx},1), 'un', 0).');
end
%U_ns_hat = cell2mat(cellfun(@(P,v) P*v, P_all, data.u_ns(dataset,1:end), 'un', 0));
PhatPhi = cell2mat(PhatPhi_cell.');
model_lA_sampling_l.b = receptive_fields_weighted_regression_local(model, S, Uns, PhatPhi);
model_lA_sampling_g.b = receptive_fields_weighted_regression_global(model, S, Uns, PhatPhi);
%--------------------------------------------------------------------------


%% evaluate estimated polciy
%--------------------------------------------------------------------------
disp('dpl');
pi_hat = def_weighted_linear_model(model_g, phi_pi);
U_hat = cell2mat(cellfun(pi_hat, num2cell(S,1), 'un',0));
disp(e_dpl(Uu, U_hat))
%--------------------------------------------------------------------------
pi_hat = def_weighted_linear_model(model_l, phi_pi);
U_hat = cell2mat(cellfun(pi_hat, num2cell(S,1), 'un',0));
disp(e_dpl(Uu, U_hat))
%--------------------------------------------------------------------------
disp('ccl');
pi_hat = def_weighted_linear_model(model_proj_g, phi_pi);
U_hat = cell2mat(cellfun(pi_hat, num2cell(S,1), 'un',0));
disp(e_dpl(Uu, U_hat))
%--------------------------------------------------------------------------
pi_hat = def_weighted_linear_model(model_proj_l, phi_pi);
U_hat = cell2mat(cellfun(pi_hat, num2cell(S,1), 'un',0));
disp(e_dpl(Uu, U_hat))
%--------------------------------------------------------------------------
disp('learning A through sampling');
pi_hat = def_weighted_linear_model(model_lA_sampling_g, phi_pi);
U_hat = cell2mat(cellfun(pi_hat, num2cell(S,1), 'un',0));
disp(e_dpl(Uu, U_hat))
%--------------------------------------------------------------------------
pi_hat = def_weighted_linear_model(model_lA_sampling_l, phi_pi);
U_hat = cell2mat(cellfun(pi_hat, num2cell(S,1), 'un',0));
disp(e_dpl(Uu, U_hat))
%--------------------------------------------------------------------------
disp('learning A through svd');
pi_hat = def_weighted_linear_model(model_lA_svd_g, phi_pi);
U_hat = cell2mat(cellfun(pi_hat, num2cell(S,1), 'un',0));
disp(e_dpl(Uu, U_hat))
%--------------------------------------------------------------------------
pi_hat = def_weighted_linear_model(model_lA_svd_l, phi_pi);
U_hat = cell2mat(cellfun(pi_hat, num2cell(S,1), 'un',0));
disp(e_dpl(Uu, U_hat))
%--------------------------------------------------------------------------
