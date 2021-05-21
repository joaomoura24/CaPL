%% Setting parameters
%--------------------------------------------------------------------------
ro_param = -0.5; % m
w_param = 1.0; % rad/1
freq_param = 50.0; % Hz
tf_param = 2; % seconds
Ntraj = 50; % number of trajectories
Ndatasets = 40; % number of data sets
noise_levels = 50:-2:10;
Nnoiselevels = length(noise_levels);
%--------------------------------------------------------------------------

%% policy regressors
%--------------------------------------------------------------------------
phi_pi = @(s) kron(s.',eye(2));
%--------------------------------------------------------------------------

%% Define dynamics equatiom in polar coordinates
%--------------------------------------------------------------------------
f_z = @(z) [z(1)*(ro_param-(z(1)^2)); w_param];
%--------------------------------------------------------------------------

%% Define transformation from polar to cartesian coordinates and vice versa
%--------------------------------------------------------------------------
t = @(z) [z(1)*cos(z(2)); z(1)*sin(z(2))];
t_inv = @(s) [sqrt((s(1)^2)+(s(2)^2)); atan2(s(2),s(1))];
grad_t = @(z) [cos(z(2)), -z(1)*sin(z(2)); sin(z(2)), z(1)*cos(z(2))];
%--------------------------------------------------------------------------

%% Define dynamics equatiom in cartesian coordinates
%--------------------------------------------------------------------------
f_s = @(s) grad_t(t_inv(s))*f_z(t_inv(s));
%--------------------------------------------------------------------------

%% initialize data structure 
%--------------------------------------------------------------------------
s = cell(Ndatasets,Ntraj);
Phi = cell(Ndatasets,Ntraj);
u = cell(Ndatasets,Ntraj);
u_u = cell(Ndatasets,Ntraj);
A = cell(Ndatasets,Ntraj);
b = cell(Ndatasets,Ntraj);
time = linspace(0,tf_param,freq_param*tf_param);
%--------------------------------------------------------------------------

for noise_level=noise_levels
    u_var_name = ['u_',int2str(noise_level),'dB'];
    data.noise.(u_var_name) = cell(Ndatasets,Ntraj);
end

%% Simulate Constrained trajectory
%--------------------------------------------------------------------------
step = 0;
steps = Ndatasets;
h = waitbar(step / steps, 'Generating the trajectories...');
for d=1:Ndatasets
    parfor k=1:Ntraj
        % initial conditions
        t0 = (2*pi)*rand();
        z0 = [rand(), (2*pi)*rand()];
        s0 = t(z0);
        b0 = (rand()*0.6)-0.3
        % constraint
        A{d,k} = [cos(t0), sin(t0)];
        b{d,k} = b0;
        pinvA = pinv(A{d,k})
        P = eye(2) - pinvA*A{d,k};
        % set solver
        sol = ode45(@(t,s) pinvA*b0+P*f_s(s),[0 tf_param], s0);
        % get data and ploting
        [s{d,k}, u{d,k}] = deval(sol,time,[1 2]); % evaluation of solution
        % compute null space ground truth policy
        u_u{d,k} = cell2mat(cellfun(f_s, num2cell(s{d,k},1), 'un', 0));
        % compute regressors 
        Phi_cell = cellfun(phi_pi, num2cell(s{d,k},1), 'un',0);
        Phi{d,k} = cell2mat(Phi_cell.');
    end
    % disp the time of computation
    step = step + 1;
    waitbar(step / steps, h);
end
close(h);
%--------------------------------------------------------------------------
% save data
data.A = A;
data.b = b;
data.s = s;
data.Phi = Phi;
data.u = u;
data.u_u = u_u;
%--------------------------------------------------------------------------
%% add noise
step = 0;
steps = Ndatasets*Ntraj*Nnoiselevels;
h = waitbar(step / steps, 'Adding noise...');
for d=1:Ndatasets
    for k=1:Ntraj
        for noise_level=noise_levels
            u_var_name = ['u_',int2str(noise_level),'dB'];
            data.noise.(u_var_name){d,k} = ...
                awgn(u{d,k},noise_level,'measured');
            % disp the time of computation
            step = step + 1;
            waitbar(step / steps, h); 
        end
    end
end
close(h);
%--------------------------------------------------------------------------

%% Save data to file
%--------------------------------------------------------------------------
% Get file information
file_curr = dbstack();
data_file_dir = ['../data/', file_curr.name(5:end),...
    '_', int2str(tf_param), 'sec_', int2str(Ntraj),...
    'traj_', int2str(Ndatasets), 'datasets.mat'];
save(data_file_dir,'data');
%--------------------------------------------------------------------------