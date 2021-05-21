%% Setting parameters
%--------------------------------------------------------------------------
Dangle = 30*pi/180; % variation of angle in roll and pitch
% timming:
ti_param = 3; % because the initial state of the simulation is not on the
freq_param = 50.0; % Hz
tf_param = 6; % seconds
% constraint, the simulation takes some time until the proportional
% controller converges the state to the constraint. This initial
% convergence time is cut out of the training data
s0 = [0;0;0;pi/2;0;-pi/2;0]; % initial condition
noise_levels = 50:-2:10;
Nnoiselevels = length(noise_levels);
Kp = 5; % proportional gain
Ntraj = 5; % number of trajectories
Ndatasets = 2; % number of data sets
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
error('stop here')
%% Add path
%--------------------------------------------------------------------------
addpath(genpath('../library/')); % add the library and it's subfolders to the path
%--------------------------------------------------------------------------

%% Initialize roobot model and the Regressors for the constraint and main task
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
fprintf(1,'Defining robot model ...\n');
DH = [0.0, 0.31, 0.0, pi/2; % Robot Kinematic model specified by the Denavit-Hartenberg
      0.0, 0.0, 0.0, -pi/2;
      0.0, 0.4, 0.0, -pi/2;
      0.0, 0.0, 0.0, pi/2;
      0.0, 0.39, 0.0, pi/2;
      0.0, 0.0, 0.0, -pi/2;
      0.0, 0.21-0.132, 0.0, 0.0];
robot = SerialLink(DH); % Peters Cork robotics library has to be installed
 % Phi_A(x): vector of regressors for the Constraint matrix as a function
 % of the state
phi_A = def_phia_4_spm(robot);
% Phi_b(x): vector of regressors for the main task as a function of the
% state
phi_b = def_phib_4_spm_sim(robot);
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

%% initialize data structure 
%--------------------------------------------------------------------------
s = cell(Ndatasets,Ntraj);
Phi = cell(Ndatasets,Ntraj);
Phi_sim = cell(Ndatasets,Ntraj);
PhiA = cell(Ndatasets,Ntraj);
Phib = cell(Ndatasets,Ntraj);
u = cell(Ndatasets,Ntraj);
u_u = cell(Ndatasets,Ntraj);
BetaA = cell(Ndatasets,Ntraj);
Betab = cell(Ndatasets,Ntraj);
time = linspace(ti_param,tf_param,freq_param*(tf_param-ti_param));
p = cell(Ndatasets,Ntraj);
%--------------------------------------------------------------------------

%% Simulate Constrained trajectory
%--------------------------------------------------------------------------
fprintf(1,'Generating data ...\n');
step = 0;
steps = Ndatasets;
h = waitbar(step / steps, 'Generating the trajectories...');
for d=1:Ndatasets
    % temporary variables for parfor
    parfor k=1:Ntraj
        % Random variables:
        c = [rand().*0.2 + 0.35; rand().*0.1-0.05; rand().*0.2+0.25]; % generate random circle centre
        r = 0.05; % generate random circle radious
        roll = rand()*(2*Dangle) - Dangle; 
        pitch = rand()*(2*Dangle) - Dangle;
        T = rpy2tr(roll, pitch, 0); % homogeneous transformation for the end-effector
        n = T(1:3,3);
        % Constant matrices:
        BetaA_dk = blkdiag(n.', n.', n.'); % constant gain matrix for the Constraint matrix
        Betab_dk = -Kp*[BetaA_dk [-n.'*c; 0; 0]];
        % Definition of Constraint matrix and main task
        A = @(x) BetaA_dk*feval(phi_A,x); % Constraint matrix as a function of configuration
        b = @(x) Betab_dk*feval(phi_b,x); % main task as a function of the configuration
        % Constrained Policie
        phi_pi = @(s) kron([s; c; 1].',eye(7));
        phi_pi_sim = def_phi_4_cwm_sim(robot, c, r); % Get regressors for the unconstrained policy
        unconstrainedPolicy = @(s) phi_pi_sim(s)*[10; 10];
        constrainedPolicy = def_constrained_policy(A, b, unconstrainedPolicy);
        % solving motion
        sol = ode45(@(t,x) constrainedPolicy(x),[0 tf_param], s0);
        [s_dk, u_dk] = deval(sol,time); % evaluation of solution
        s_dk_cell = num2cell(s_dk,1);
        % compute null space ground truth policy
        u_u{d,k} = cell2mat(cellfun(unconstrainedPolicy, s_dk_cell, 'un', 0));
        % compute regressors
        Phi_cell = cellfun(phi_pi, s_dk_cell, 'un',0);
        Phi{d,k} = cell2mat(Phi_cell.');
        Phi__sim_cell = cellfun(phi_pi, s_dk_cell, 'un',0);
        Phi_sim{d,k} = cell2mat(Phi__sim_cell.');
        PhiA_cell = cellfun(phi_A, s_dk_cell, 'un',0);
        PhiA{d,k} = cell2mat(PhiA_cell);
        Phib_cell = cellfun(phi_b, s_dk_cell, 'un',0);
        Phib{d,k} = cell2mat(Phib_cell);
        % computation for plot purposes
        p{d,k}=transl(robot.fkine(s_dk.'));
        %error('stop here');
        % save variables:
        BetaA{d,k} = BetaA_dk;
        Betab{d,k} = Betab_dk;
        s{d,k} = s_dk;
        u{d,k} = u_dk;
    end
    %----------------------------------------------------------------------
    % disp the time of computation
    step = step + 1;
    waitbar(step / steps, h);
    %----------------------------------------------------------------------
end
close(h);
%--------------------------------------------------------------------------
% save variables to data structure:
data.BetaA = BetaA;
data.Betab = Betab;
data.s = s;
data.u = u;
data.u_u = u_u;
data.Phi = Phi;
data.Phi_sim = Phi_sim;
data.PhiA = PhiA;
data.Phib = Phib;
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

% Plot end-effector positions
%--------------------------------------------------------------------------
% fprintf(1,'Plotting Results...\n');
% for d=1:Ndatasets
%     figure(); hold on;
%     for k=1:Ntraj
%         % plot
%         plot3(p{d,k}(:,1),p{d,k}(:,2),p{d,k}(:,3));
%     end
%     hold off; grid on;
%     xlabel('x'); ylabel('y'); zlabel('z');
%     axis equal;
% end
%--------------------------------------------------------------------------


%% Save data to file
%--------------------------------------------------------------------------
% Get file information
file_curr = dbstack();
data_file_dir = ['../data/', file_curr.name(5:end),...
    '_', int2str(tf_param-ti_param), 'sec_', int2str(Ntraj),...
    'traj_', int2str(Ndatasets), 'datasets.mat'];
save(data_file_dir,'data');
%--------------------------------------------------------------------------