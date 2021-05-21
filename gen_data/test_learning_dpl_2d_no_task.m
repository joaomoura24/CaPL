%% Add path
%--------------------------------------------------------------------------
addpath(genpath('../library/')); % add the library and it's subfolders to the path
%--------------------------------------------------------------------------

%% definition of auxiliar functions
%--------------------------------------------------------------------------
e_dpl = @(u, u_hat) immse(u,u_hat)*size(u,1);
%--------------------------------------------------------------------------

%% load data
%--------------------------------------------------------------------------
load('../data/data_2d_notask.mat');
load('../data/data_2d_notask_ground_truth_policy_grid.mat');
%--------------------------------------------------------------------------


%% organize data
%--------------------------------------------------------------------------
dataset = 1;
S = cell2mat(data.s(dataset,1:end));
D = size(S,1);
Uns = cell2mat(data.u_ns(dataset,1:end));
Uu = cell2mat(data.u_u(dataset,1:end));
%A = cell2mat(data.A(dataset));
disp(e_dpl(Uu, Uns));
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

%% evaluate estimated polciy
%--------------------------------------------------------------------------
pi_hat = def_weighted_linear_model(model_g, phi_pi);
U_hat = cell2mat(cellfun(pi_hat, num2cell(S,1), 'un',0));
disp(e_dpl(Uu, U_hat))
%--------------------------------------------------------------------------
pi_hat = def_weighted_linear_model(model_l, phi_pi);
U_hat = cell2mat(cellfun(pi_hat, num2cell(S,1), 'un',0));
disp(e_dpl(Uu, U_hat))
%--------------------------------------------------------------------------
pi_hat = def_weighted_linear_model(model_proj_g, phi_pi);
U_hat = cell2mat(cellfun(pi_hat, num2cell(S,1), 'un',0));
disp(e_dpl(Uu, U_hat))
%--------------------------------------------------------------------------
pi_hat = def_weighted_linear_model(model_proj_l, phi_pi);
U_hat = cell2mat(cellfun(pi_hat, num2cell(S,1), 'un',0));
disp(e_dpl(Uu, U_hat))
%--------------------------------------------------------------------------
