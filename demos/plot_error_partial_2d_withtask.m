%% load data
%--------------------------------------------------------------------------
file_name = '2d_withtask_2sec_50traj_40datasets.mat';
load(['../data/data_', file_name]);
load(['../data/data_errors_partial_dpl_', file_name]);
load(['../data/data_errors_partial_ccl_', file_name]);
load(['../data/data_errors_partial_svd_', file_name]);
load(['../data/data_errors_partial_gsvd_', file_name]);
%--------------------------------------------------------------------------

%% compute average and std
%--------------------------------------------------------------------------
perc = 10;
cpe_dpl_l_mean = mean(cpe_dpl_l);
cpe_dpl_l_median = median(cpe_dpl_l);
cpe_dpl_l_lower = prctile(cpe_dpl_l,perc);
cpe_dpl_l_upper = prctile(cpe_dpl_l,100-perc);
cpe_dpl_g_mean = mean(cpe_dpl_g);
cpe_dpl_g_median = median(cpe_dpl_g);
cpe_dpl_g_lower = prctile(cpe_dpl_g,perc);
cpe_dpl_g_upper = prctile(cpe_dpl_g,100-perc);
cpe_ccl_l_mean = mean(cpe_ccl_l);
cpe_ccl_l_median = median(cpe_ccl_l);
cpe_ccl_l_lower = prctile(cpe_ccl_l,perc);
cpe_ccl_l_upper = prctile(cpe_ccl_l,100-perc);
cpe_ccl_g_mean = mean(cpe_ccl_g);
cpe_ccl_g_median = median(cpe_ccl_g);
cpe_ccl_g_lower = prctile(cpe_ccl_g,perc);
cpe_ccl_g_upper = prctile(cpe_ccl_g,100-perc);
cpe_svd_l_mean = mean(cpe_svd_l);
cpe_svd_l_median = median(cpe_svd_l);
cpe_svd_l_lower = prctile(cpe_svd_l,perc);
cpe_svd_l_upper = prctile(cpe_svd_l,100-perc);
cpe_svd_g_mean = mean(cpe_svd_g);
cpe_svd_g_median = median(cpe_svd_g);
cpe_svd_g_lower = prctile(cpe_svd_g,perc);
cpe_svd_g_upper = prctile(cpe_svd_g,100-perc);
cpe_gsvd_l_mean = mean(cpe_gsvd_l);
cpe_gsvd_l_median = median(cpe_gsvd_l);
cpe_gsvd_l_lower = prctile(cpe_gsvd_l,perc);
cpe_gsvd_l_upper = prctile(cpe_gsvd_l,100-perc);
cpe_gsvd_g_mean = mean(cpe_gsvd_g);
cpe_gsvd_g_median = median(cpe_gsvd_g);
cpe_gsvd_g_lower = prctile(cpe_gsvd_g,perc);
cpe_gsvd_g_upper = prctile(cpe_gsvd_g,100-perc);
%--------------------------------------------------------------------------
upe_dpl_l_mean = mean(upe_dpl_l);
upe_dpl_l_median = median(upe_dpl_l);
upe_dpl_l_lower = prctile(upe_dpl_l,perc);
upe_dpl_l_upper = prctile(upe_dpl_l,100-perc);
upe_dpl_g_mean = mean(upe_dpl_g);
upe_dpl_g_median = median(upe_dpl_g);
upe_dpl_g_lower = prctile(upe_dpl_g,perc);
upe_dpl_g_upper = prctile(upe_dpl_g,100-perc);
upe_ccl_l_mean = mean(upe_ccl_l);
upe_ccl_l_median = median(upe_ccl_l);
upe_ccl_l_lower = prctile(upe_ccl_l,perc);
upe_ccl_l_upper = prctile(upe_ccl_l,100-perc);
upe_ccl_g_mean = mean(upe_ccl_g);
upe_ccl_g_median = median(upe_ccl_g);
upe_ccl_g_lower = prctile(upe_ccl_g,perc);
upe_ccl_g_upper = prctile(upe_ccl_g,100-perc);
upe_svd_l_mean = mean(upe_svd_l);
upe_svd_l_median = median(upe_svd_l);
upe_svd_l_lower = prctile(upe_svd_l,perc);
upe_svd_l_upper = prctile(upe_svd_l,100-perc);
upe_svd_g_mean = mean(upe_svd_g);
upe_svd_g_median = median(upe_svd_g);
upe_svd_g_lower = prctile(upe_svd_g,perc);
upe_svd_g_upper = prctile(upe_svd_g,100-perc);
upe_gsvd_l_mean = mean(upe_gsvd_l);
upe_gsvd_l_median = median(upe_gsvd_l);
upe_gsvd_l_lower = prctile(upe_gsvd_l,perc);
upe_gsvd_l_upper = prctile(upe_gsvd_l,100-perc);
upe_gsvd_g_mean = mean(upe_gsvd_g);
upe_gsvd_g_median = median(upe_gsvd_g);
upe_gsvd_g_lower = prctile(upe_gsvd_g,perc);
upe_gsvd_g_upper = prctile(upe_gsvd_g,100-perc);
%--------------------------------------------------------------------------
time_dpl_l_mean = mean(time_dpl_l);
time_dpl_l_median = median(time_dpl_l);
time_dpl_l_lower = prctile(time_dpl_l, perc);
time_dpl_l_upper = prctile(time_dpl_l, 100-perc);
time_dpl_g_mean = mean(time_dpl_g);
time_dpl_g_median = median(time_dpl_g);
time_dpl_g_lower = prctile(time_dpl_g, perc);
time_dpl_g_upper = prctile(time_dpl_g, 100-perc);
time_ccl_l_mean = mean(time_ccl_l);
time_ccl_l_median = median(time_ccl_l);
time_ccl_l_lower = prctile(time_ccl_l, perc);
time_ccl_l_upper = prctile(time_ccl_l, 100-perc);
time_ccl_g_mean = mean(time_ccl_g);
time_ccl_g_median = median(time_ccl_g);
time_ccl_g_lower = prctile(time_ccl_g, perc);
time_ccl_g_upper = prctile(time_ccl_g, 100-perc);
time_svd_l_mean = mean(time_svd_l);
time_svd_l_median = median(time_svd_l);
time_svd_l_lower = prctile(time_svd_l, perc);
time_svd_l_upper = prctile(time_svd_l, 100-perc);
time_svd_g_mean = mean(time_svd_g);
time_svd_g_median = median(time_svd_g);
time_svd_g_lower = prctile(time_svd_g, perc);
time_svd_g_upper = prctile(time_svd_g, 100-perc);
time_gsvd_l_mean = mean(time_gsvd_l);
time_gsvd_l_median = median(time_gsvd_l);
time_gsvd_l_lower = prctile(time_gsvd_l, perc);
time_gsvd_l_upper = prctile(time_gsvd_l, 100-perc);
time_gsvd_g_mean = mean(time_gsvd_g);
time_gsvd_g_median = median(time_gsvd_g);
time_gsvd_g_lower = prctile(time_gsvd_g, perc);
time_gsvd_g_upper = prctile(time_gsvd_g, 100-perc);
%--------------------------------------------------------------------------
errb_svd_mean = mean(errb_svd);
errb_svd_median = median(errb_svd);
errb_svd_lower = prctile(errb_svd,perc);
errb_svd_upper = prctile(errb_svd,100-perc);
errb_gsvd_mean = mean(errb_gsvd);
errb_gsvd_median = median(errb_gsvd);
errb_gsvd_lower = prctile(errb_gsvd,perc);
errb_gsvd_upper = prctile(errb_gsvd,100-perc);
%--------------------------------------------------------------------------

%% plot times:
%--------------------------------------------------------------------------
figure();
errorbar(traj_train, errb_svd_median, ...
    errb_svd_median-errb_svd_lower, errb_svd_upper-errb_svd_median,'r');
hold on;
errorbar(traj_train, errb_gsvd_median, ...
    errb_gsvd_median-errb_gsvd_lower, errb_gsvd_upper-errb_gsvd_median,'y');
set(gca,'YScale','log'); grid on; legend('b err svd', 'b err gsvd');
set(gca, 'XDir','reverse');
%--------------------------------------------------------------------------
figure();
subplot(1,2,1);
errorbar(traj_train, time_dpl_l_median, time_dpl_l_median-time_dpl_l_lower, ...
    time_dpl_l_upper-time_dpl_l_median,'g');
hold on;
errorbar(traj_train, time_ccl_l_median, time_ccl_l_median-time_ccl_l_lower, ...
    time_ccl_l_upper-time_ccl_l_median,'b');
errorbar(traj_train, time_svd_l_median, time_svd_l_median-time_svd_l_lower, ...
    time_svd_l_upper-time_svd_l_median,'r');
errorbar(traj_train, time_gsvd_l_median, time_gsvd_l_median-time_gsvd_l_lower, ...
    time_gsvd_l_upper-time_gsvd_l_median,'y');
grid on; legend('dpl l', 'ccl l', 'svd l', 'gsvd l');
subplot(1,2,2);
errorbar(traj_train, time_dpl_g_median, time_dpl_g_median-time_dpl_g_lower, ...
    time_dpl_g_upper-time_dpl_g_median,'g');
hold on;
errorbar(traj_train, time_ccl_g_median, time_ccl_g_median-time_ccl_g_lower, ...
    time_ccl_g_upper-time_ccl_g_median,'b');
errorbar(traj_train, time_svd_g_median, time_svd_g_median-time_svd_g_lower, ...
    time_svd_g_upper-time_svd_g_median,'r');
errorbar(traj_train, time_gsvd_g_median, time_gsvd_g_median-time_gsvd_g_lower, ...
    time_gsvd_g_upper-time_gsvd_g_median,'y');
%set(gca,'YScale','log');
grid on; legend('dpl g', 'ccl g', 'svd g', 'gsvd g');
%--------------------------------------------------------------------------
%% plot errors:
%--------------------------------------------------------------------------
figure();
subplot(1,2,1);
errorbar(traj_train , cpe_dpl_l_median, cpe_dpl_l_median-cpe_dpl_l_lower, ...
    cpe_dpl_l_upper-cpe_dpl_l_median,'g');
hold on;
errorbar(traj_train , cpe_ccl_l_median, cpe_ccl_l_median-cpe_ccl_l_lower, ...
    cpe_ccl_l_upper-cpe_ccl_l_median,'b');
errorbar(traj_train , cpe_svd_l_median, cpe_svd_l_median-cpe_svd_l_lower, ...
    cpe_svd_l_upper-cpe_svd_l_median,'r');
errorbar(traj_train , cpe_gsvd_l_median, cpe_gsvd_l_median-cpe_gsvd_l_lower, ...
    cpe_gsvd_l_upper-cpe_gsvd_l_median,'y');
set(gca,'YScale','log'); grid on; legend('cpe dpl','cpe ccl', 'cpe svd', 'cpe gsvd');
subplot(1,2,2);
errorbar(traj_train , upe_dpl_l_median, upe_dpl_l_median-upe_dpl_l_lower, ...
    upe_dpl_l_upper-upe_dpl_l_median,'g');
hold on;
errorbar(traj_train , upe_ccl_l_median, upe_ccl_l_median-upe_ccl_l_lower, ...
    upe_ccl_l_upper-upe_ccl_l_median,'b');
errorbar(traj_train , upe_svd_l_median, upe_svd_l_median-upe_svd_l_lower, ...
    upe_svd_l_upper-upe_svd_l_median,'r');
errorbar(traj_train , upe_gsvd_l_median, upe_gsvd_l_median-upe_gsvd_l_lower, ...
    upe_gsvd_l_upper-upe_gsvd_l_median,'y');
set(gca,'YScale','log'); grid on; legend('upe dpl','upe ccl', 'upe svd', 'upe gsvd');
%--------------------------------------------------------------------------
figure();
subplot(1,2,1);
errorbar(traj_train , cpe_dpl_g_median, cpe_dpl_g_median-cpe_dpl_g_lower, ...
    cpe_dpl_g_upper-cpe_dpl_g_median,'g');
hold on;
errorbar(traj_train , cpe_ccl_g_median, cpe_ccl_g_median-cpe_ccl_g_lower, ...
    cpe_ccl_g_upper-cpe_ccl_g_median,'b');
errorbar(traj_train , cpe_svd_g_median, cpe_svd_g_median-cpe_svd_g_lower, ...
    cpe_svd_g_upper-cpe_svd_g_median,'r');
errorbar(traj_train , cpe_gsvd_g_median, cpe_gsvd_g_median-cpe_gsvd_g_lower, ...
    cpe_gsvd_g_upper-cpe_gsvd_g_median,'y');
set(gca,'YScale','log'); grid on; legend('cpe dpl','cpe ccl', 'cpe svd', 'cpe gsvd');
subplot(1,2,2);
errorbar(traj_train , upe_dpl_g_median, upe_dpl_g_median-upe_dpl_g_lower, ...
    upe_dpl_g_upper-upe_dpl_g_median,'g'); hold on;
errorbar(traj_train , upe_ccl_g_median, upe_ccl_g_median-upe_ccl_g_lower, ...
    upe_ccl_g_upper-upe_ccl_g_median,'b');
errorbar(traj_train , upe_svd_g_median, upe_svd_g_median-upe_svd_g_lower, ...
    upe_svd_g_upper-upe_svd_g_median,'r');
errorbar(traj_train , upe_gsvd_g_median, upe_gsvd_g_median-upe_gsvd_g_lower, ...
    upe_gsvd_g_upper-upe_gsvd_g_median,'r');
set(gca,'YScale','log'); grid on; legend('upe dpl','upe ccl', 'upe svd', 'upe gsvd');
%--------------------------------------------------------------------------

%% Save data to csv for plotting
%--------------------------------------------------------------------------
% define formatSpec function
formatSpec = @(format,delimiter,reps) [convertStringsToChars(join(repmat(format,1,reps),repmat(delimiter,1,reps-1))),'\r\n'];
error_name = 'errors_partial';
%--------------------------------------------------------------------------
print_data = [traj_train;...
    cpe_dpl_l_median; cpe_dpl_l_mean; cpe_dpl_l_lower; cpe_dpl_l_upper;...
    cpe_dpl_g_median; cpe_dpl_g_mean; cpe_dpl_g_lower; cpe_dpl_g_upper;...
    upe_dpl_l_median; upe_dpl_l_mean; upe_dpl_l_lower; upe_dpl_l_upper;...
    upe_dpl_g_median; upe_dpl_g_mean; upe_dpl_g_lower; upe_dpl_g_upper;...
    time_dpl_l_median; time_dpl_l_mean; time_dpl_l_lower; time_dpl_l_upper;...
    time_dpl_g_median; time_dpl_g_mean; time_dpl_g_lower; time_dpl_g_upper;...
    ];
print_names = {'Ntraj';...
    'cpe_l_median'; 'cpe_l_mean'; 'cpe_l_lower'; 'cpe_l_upper';...
    'cpe_g_median'; 'cpe_g_mean'; 'cpe_g_lower'; 'cpe_g_upper';...
    'upe_l_median'; 'upe_l_mean'; 'upe_l_lower'; 'upe_l_upper';...
    'upe_g_median'; 'upe_g_mean'; 'upe_g_lower'; 'upe_g_upper';...
    't_l_median'; 't_l_mean'; 't_l_lower'; 't_l_upper';...
    't_g_median'; 't_g_mean'; 't_g_lower'; 't_g_upper';...
    };
nn = length(print_names);
fileID = fopen(['../data/data_', error_name,'_dpl_', file_name(1:end-4), '.dat'],'w');
fprintf(fileID, ['%5s,', formatSpec("%12s",",",nn-1)], print_names{:});
fprintf(fileID, ['%5d,',formatSpec("%12.4e",",",nn-1)], print_data);
fclose(fileID);
%--------------------------------------------------------------------------
print_data = [traj_train;...
    cpe_ccl_l_median; cpe_ccl_l_mean; cpe_ccl_l_lower; cpe_ccl_l_upper;...
    cpe_ccl_g_median; cpe_ccl_g_mean; cpe_ccl_g_lower; cpe_ccl_g_upper;...
    upe_ccl_l_median; upe_ccl_l_mean; upe_ccl_l_lower; upe_ccl_l_upper;...
    upe_ccl_g_median; upe_ccl_g_mean; upe_ccl_g_lower; upe_ccl_g_upper;...
    time_ccl_l_median; time_ccl_l_mean; time_ccl_l_lower; time_ccl_l_upper;...
    time_ccl_g_median; time_ccl_g_mean; time_ccl_g_lower; time_ccl_g_upper;...
    ];
print_names = {'Ntraj';...
    'cpe_l_median'; 'cpe_l_mean'; 'cpe_l_lower'; 'cpe_l_upper';...
    'cpe_g_median'; 'cpe_g_mean'; 'cpe_g_lower'; 'cpe_g_upper';...
    'upe_l_median'; 'upe_l_mean'; 'upe_l_lower'; 'upe_l_upper';...
    'upe_g_median'; 'upe_g_mean'; 'upe_g_lower'; 'upe_g_upper';...
    't_l_median'; 't_l_mean'; 't_l_lower'; 't_l_upper';...
    't_g_median'; 't_g_mean'; 't_g_lower'; 't_g_upper';...
    };
nn = length(print_names);
fileID = fopen(['../data/data_', error_name,'_ccl_', file_name(1:end-4), '.dat'],'w');
fprintf(fileID, ['%5s,', formatSpec("%12s",",",nn-1)], print_names{:});
fprintf(fileID, ['%5d,',formatSpec("%12.4e",",",nn-1)], print_data);
fclose(fileID);
%--------------------------------------------------------------------------
print_data = [traj_train;...
    cpe_svd_l_median; cpe_svd_l_mean; cpe_svd_l_lower; cpe_svd_l_upper;...
    cpe_svd_g_median; cpe_svd_g_mean; cpe_svd_g_lower; cpe_svd_g_upper;...
    upe_svd_l_median; upe_svd_l_mean; upe_svd_l_lower; upe_svd_l_upper;...
    upe_svd_g_median; upe_svd_g_mean; upe_svd_g_lower; upe_svd_g_upper;...
    time_svd_l_median; time_svd_l_mean; time_svd_l_lower; time_svd_l_upper;...
    time_svd_g_median; time_svd_g_mean; time_svd_g_lower; time_svd_g_upper;...
    errb_svd_mean; errb_svd_mean; errb_svd_lower; errb_svd_upper;...
    ];
print_names = {'Ntraj';...
    'cpe_l_median'; 'cpe_l_mean'; 'cpe_l_lower'; 'cpe_l_upper';...
    'cpe_g_median'; 'cpe_g_mean'; 'cpe_g_lower'; 'cpe_g_upper';...
    'upe_l_median'; 'upe_l_mean'; 'upe_l_lower'; 'upe_l_upper';...
    'upe_g_median'; 'upe_g_mean'; 'upe_g_lower'; 'upe_g_upper';...
    't_l_median'; 't_l_mean'; 't_l_lower'; 't_l_upper';...
    't_g_median'; 't_g_mean'; 't_g_lower'; 't_g_upper';...
    'errb_median'; 'errb_mean'; 'errb_lower'; 'errb_upper';...
    };
nn = length(print_names);
fileID = fopen(['../data/data_', error_name,'_svd_', file_name(1:end-4), '.dat'],'w');
fprintf(fileID, ['%5s,', formatSpec("%12s",",",nn-1)], print_names{:});
fprintf(fileID, ['%5d,',formatSpec("%12.4e",",",nn-1)], print_data);
fclose(fileID);
%--------------------------------------------------------------------------
print_data = [traj_train;...
    cpe_gsvd_l_median; cpe_gsvd_l_mean; cpe_gsvd_l_lower; cpe_gsvd_l_upper;...
    cpe_gsvd_g_median; cpe_gsvd_g_mean; cpe_gsvd_g_lower; cpe_gsvd_g_upper;...
    upe_gsvd_l_median; upe_gsvd_l_mean; upe_gsvd_l_lower; upe_gsvd_l_upper;...
    upe_gsvd_g_median; upe_gsvd_g_mean; upe_gsvd_g_lower; upe_gsvd_g_upper;...
    time_gsvd_l_median; time_gsvd_l_mean; time_gsvd_l_lower; time_gsvd_l_upper;...
    time_gsvd_g_median; time_gsvd_g_mean; time_gsvd_g_lower; time_gsvd_g_upper;...
    errb_gsvd_mean; errb_gsvd_mean; errb_gsvd_lower; errb_gsvd_upper;...
    ];
print_names = {'Ntraj';...
    'cpe_l_median'; 'cpe_l_mean'; 'cpe_l_lower'; 'cpe_l_upper';...
    'cpe_g_median'; 'cpe_g_mean'; 'cpe_g_lower'; 'cpe_g_upper';...
    'upe_l_median'; 'upe_l_mean'; 'upe_l_lower'; 'upe_l_upper';...
    'upe_g_median'; 'upe_g_mean'; 'upe_g_lower'; 'upe_g_upper';...
    't_l_median'; 't_l_mean'; 't_l_lower'; 't_l_upper';...
    't_g_median'; 't_g_mean'; 't_g_lower'; 't_g_upper';...
    'errb_median'; 'errb_mean'; 'errb_lower'; 'errb_upper';...
    };
nn = length(print_names);
fileID = fopen(['../data/data_', error_name,'_gsvd_', file_name(1:end-4), '.dat'],'w');
fprintf(fileID, ['%5s,', formatSpec("%12s",",",nn-1)], print_names{:});
fprintf(fileID, ['%5d,',formatSpec("%12.4e",",",nn-1)], print_data);
fclose(fileID);
%--------------------------------------------------------------------------
