%% load data
%--------------------------------------------------------------------------
file_name = '2d_notask_2sec_50traj_40datasets.mat';
load(['../data/data_', file_name]);
load(['../data/data_errors_with_noise_dpl_', file_name]);
load(['../data/data_errors_with_noise_ccl_', file_name]);
load(['../data/data_errors_with_noise_svd_', file_name]);
%--------------------------------------------------------------------------

%% Get noise xlabel
%--------------------------------------------------------------------------
noise_names = fieldnames(data.noise);
x_noise = cell2mat(cellfun(@(str) str2double(str(3:4)), noise_names, 'un',0))';
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
%--------------------------------------------------------------------------

%% plot errors:
%--------------------------------------------------------------------------
figure();
subplot(1,2,1);
errorbar(x_noise, cpe_dpl_l_median, ...
    cpe_dpl_l_median-cpe_dpl_l_lower, cpe_dpl_l_upper-cpe_dpl_l_median,'g');
hold on;
errorbar(x_noise, cpe_ccl_l_median, ...
    cpe_ccl_l_median-cpe_ccl_l_lower, cpe_ccl_l_upper-cpe_ccl_l_median,'b');
errorbar(x_noise, cpe_svd_l_median, ...
    cpe_svd_l_median-cpe_svd_l_lower, cpe_svd_l_upper-cpe_svd_l_median,'r');
set(gca,'YScale','log'); grid on; legend('cpe dpl', 'cpe ccl', 'cpe svd');
set(gca, 'XDir','reverse');
subplot(1,2,2);
errorbar(x_noise, upe_dpl_l_median, ...
    upe_dpl_l_median-upe_dpl_l_lower, upe_dpl_l_upper-upe_dpl_l_median,'g');
hold on;
errorbar(x_noise, upe_ccl_l_median, ...
    upe_ccl_l_median-upe_ccl_l_lower, upe_ccl_l_upper-upe_ccl_l_median,'b');
errorbar(x_noise, upe_svd_l_median, ...
    upe_svd_l_median-upe_svd_l_lower, upe_svd_l_upper-upe_svd_l_median,'r');
set(gca,'YScale','log'); grid on; legend('upe dpl', 'upe ccl', 'upe svd');
set(gca, 'XDir','reverse');
%--------------------------------------------------------------------------
figure();
subplot(1,2,1);
errorbar(x_noise, cpe_dpl_g_median, ...
    cpe_dpl_g_median-cpe_dpl_g_lower, cpe_dpl_g_upper-cpe_dpl_g_median,'g');
hold on;
errorbar(x_noise, cpe_ccl_g_median, ...
    cpe_ccl_g_median-cpe_ccl_g_lower, cpe_ccl_g_upper-cpe_ccl_g_median,'b');
errorbar(x_noise, cpe_svd_g_median, ...
    cpe_svd_g_median-cpe_svd_g_lower, cpe_svd_g_upper-cpe_svd_g_median,'r');
set(gca,'YScale','log'); grid on; legend('cpe dpl', 'cpe ccl', 'cpe svd');
set(gca, 'XDir','reverse');
subplot(1,2,2);
errorbar(x_noise, upe_dpl_g_median, ...
    upe_dpl_g_median-upe_dpl_g_lower, upe_dpl_g_upper-upe_dpl_g_median,'g');
hold on;
errorbar(x_noise, upe_ccl_g_median, ...
    upe_ccl_g_median-upe_ccl_g_lower, upe_ccl_g_upper-upe_ccl_g_median,'b');
errorbar(x_noise, upe_svd_g_median, ...
    upe_svd_g_median-upe_svd_g_lower, upe_svd_g_upper-upe_svd_g_median,'r');
set(gca,'YScale','log'); grid on; legend('upe dpl', 'upe ccl', 'upe svd');
set(gca, 'XDir','reverse');
%--------------------------------------------------------------------------

%% Save data to csv for plotting
%--------------------------------------------------------------------------
% define formatSpec function
formatSpec = @(format,delimiter,reps) [convertStringsToChars(join(repmat(format,1,reps),repmat(delimiter,1,reps-1))),'\r\n'];
error_name = 'errors_noise';
%--------------------------------------------------------------------------
print_data = [x_noise;...
    cpe_dpl_l_median; cpe_dpl_l_mean; cpe_dpl_l_lower; cpe_dpl_l_upper;...
    cpe_dpl_g_median; cpe_dpl_g_mean; cpe_dpl_g_lower; cpe_dpl_g_upper;...
    upe_dpl_l_median; upe_dpl_l_mean; upe_dpl_l_lower; upe_dpl_l_upper;...
    upe_dpl_g_median; upe_dpl_g_mean; upe_dpl_g_lower; upe_dpl_g_upper;...
    ];
print_names = {'dB';...
    'cpe_l_median'; 'cpe_l_mean'; 'cpe_l_lower'; 'cpe_l_upper';...
    'cpe_g_median'; 'cpe_g_mean'; 'cpe_g_lower'; 'cpe_g_upper';...
    'upe_l_median'; 'upe_l_mean'; 'upe_l_lower'; 'upe_l_upper';...
    'upe_g_median'; 'upe_g_mean'; 'upe_g_lower'; 'upe_g_upper';...
    };
nn = length(print_names);
fileID = fopen(['../data/data_', error_name,'_dpl_', file_name(1:end-4), '.dat'],'w');
fprintf(fileID, ['%3s,', formatSpec("%12s",",",nn-1)], print_names{:});
fprintf(fileID, ['%3d,',formatSpec("%12.4e",",",nn-1)], print_data);
fclose(fileID);
%--------------------------------------------------------------------------
print_data = [x_noise;...
    cpe_ccl_l_median; cpe_ccl_l_mean; cpe_ccl_l_lower; cpe_ccl_l_upper;...
    cpe_ccl_g_median; cpe_ccl_g_mean; cpe_ccl_g_lower; cpe_ccl_g_upper;...
    upe_ccl_l_median; upe_ccl_l_mean; upe_ccl_l_lower; upe_ccl_l_upper;...
    upe_ccl_g_median; upe_ccl_g_mean; upe_ccl_g_lower; upe_ccl_g_upper;...
    ];
print_names = {'dB';...
    'cpe_l_median'; 'cpe_l_mean'; 'cpe_l_lower'; 'cpe_l_upper';...
    'cpe_g_median'; 'cpe_g_mean'; 'cpe_g_lower'; 'cpe_g_upper';...
    'upe_l_median'; 'upe_l_mean'; 'upe_l_lower'; 'upe_l_upper';...
    'upe_g_median'; 'upe_g_mean'; 'upe_g_lower'; 'upe_g_upper';...
    };
nn = length(print_names);
fileID = fopen(['../data/data_', error_name,'_ccl_', file_name(1:end-4), '.dat'],'w');
fprintf(fileID, ['%3s,', formatSpec("%12s",",",nn-1)], print_names{:});
fprintf(fileID, ['%3d,',formatSpec("%12.4e",",",nn-1)], print_data);
fclose(fileID);
%--------------------------------------------------------------------------
print_data = [x_noise;...
    cpe_svd_l_median; cpe_svd_l_mean; cpe_svd_l_lower; cpe_svd_l_upper;...
    cpe_svd_g_median; cpe_svd_g_mean; cpe_svd_g_lower; cpe_svd_g_upper;...
    upe_svd_l_median; upe_svd_l_mean; upe_svd_l_lower; upe_svd_l_upper;...
    upe_svd_g_median; upe_svd_g_mean; upe_svd_g_lower; upe_svd_g_upper;...
    ];
print_names = {'dB';...
    'cpe_l_median'; 'cpe_l_mean'; 'cpe_l_lower'; 'cpe_l_upper';...
    'cpe_g_median'; 'cpe_g_mean'; 'cpe_g_lower'; 'cpe_g_upper';...
    'upe_l_median'; 'upe_l_mean'; 'upe_l_lower'; 'upe_l_upper';...
    'upe_g_median'; 'upe_g_mean'; 'upe_g_lower'; 'upe_g_upper';...
    };
nn = length(print_names);
fileID = fopen(['../data/data_', error_name,'_svd_', file_name(1:end-4), '.dat'],'w');
fprintf(fileID, ['%3s,', formatSpec("%12s",",",nn-1)], print_names{:});
fprintf(fileID, ['%3d,',formatSpec("%12.4e",",",nn-1)], print_data);
fclose(fileID);
%--------------------------------------------------------------------------
