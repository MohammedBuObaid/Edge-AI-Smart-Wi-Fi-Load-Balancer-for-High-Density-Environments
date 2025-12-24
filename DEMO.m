clc; clear; close all;

% Parameters
baseDelay   = 20;   % ms
delayFactor = 3;    % ms per user
lossFactor  = 0.4;  % % per user

APs = {'AP1','AP2','AP3'};
N   = numel(APs);

% -------- User Input --------
disp('Enter number of users for each AP');
users = zeros(1,N);
for i = 1:N
    users(i) = input(['Users on ' APs{i} ': ']);
end

% -------- Before Edge-AI --------
lat_before  = baseDelay + users * delayFactor;
loss_before = users * lossFactor;
fair_before = (sum(users)^2) / (N * sum(users.^2));

% -------- Edge-AI Logic (near-equal + remainder) --------
total_users = sum(users);
fair_users  = floor(total_users / N);
remainder   = mod(total_users, N);

users_after = repmat(fair_users, 1, N);
for k = 1:remainder
    users_after(k) = users_after(k) + 1;
end

% -------- After Edge-AI --------
lat_after  = baseDelay + users_after * delayFactor;
loss_after = users_after * lossFactor;
fair_after = (sum(users_after)^2) / (N * sum(users_after.^2));

% -------- Output --------
disp(' ');
disp('=== BEFORE EDGE-AI ===');
for i = 1:N
    fprintf('%s | Users=%d | Lat=%.1f ms | Loss=%.1f%%\n', ...
        APs{i}, users(i), lat_before(i), loss_before(i));
end
fprintf('Fairness Before: %.3f\n', fair_before);

disp(' ');
disp('=== AFTER EDGE-AI ===');
for i = 1:N
    fprintf('%s | Users=%d | Lat=%.1f ms | Loss=%.1f%%\n', ...
        APs{i}, users_after(i), lat_after(i), loss_after(i));
end
fprintf('Fairness After : %.3f\n', fair_after);

% -------- Latency Comparison --------
figure;
bar([lat_before; lat_after]');
set(gca,'XTickLabel',APs);
ylabel('Latency (ms)');
legend('Before','After');
title('Latency Comparison');
grid on;

% -------- Packet Loss Comparison --------
figure;
bar([loss_before; loss_after]');
set(gca,'XTickLabel',APs);
ylabel('Packet Loss (%)');
legend('Before','After');
title('Packet Loss Comparison');
grid on;

% -------- Latency Over Time --------
T = 12;
lat_t_before = mean(lat_before) + rand(1,T)*6;
lat_t_after  = mean(lat_after)  + rand(1,T)*2;

figure;
plot(lat_t_before,'-o'); hold on;
plot(lat_t_after,'-s');
xlabel('Time');
ylabel('Latency (ms)');
legend('Before','After');
title('Latency Over Time');
grid on;

% -------- Congestion Prediction (AI-style) --------
actual = users(1) + randi([-3 3],1,T);
pred   = movmean(actual,3);

figure;
plot(actual,'--o'); hold on;
plot(pred,'LineWidth',2);
xlabel('Time');
ylabel('Clients');
legend('Actual','Predicted');
title('Congestion Prediction');
grid on;
