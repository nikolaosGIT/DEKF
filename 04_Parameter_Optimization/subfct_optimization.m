%% Objective function for parameter estimation
function [obj] = subfct_optimization(starter)
%% Initialize Plant and framework
load('Initialization.mat');

% Reset estimation error to properly tune parameter estimation
x_init= [1; 0; 0];

% Measurement Error Covariance
R_par = starter(1);

% Process Noise Covariance
Q_par = [starter(2),     0;...
         0,          starter(3)];

%% Simulation
options = simset('SrcWorkspace','current');
load_system('DEKF.slx');
sim('DEKF.slx',[],options); 

%% Postprocessing to calculate the objective function
% Transfer dataset (1 = capacity, 2 = resistance)
S(1).th_est = squeeze(theta_est.signals.values(1,1,:));
S(1).th_ref = squeeze(theta_ref.signals.values(:,1));
S(1).cov = squeeze(S_est.signals.values(1,1,:));
S(2).th_est = squeeze(theta_est.signals.values(2,1,:));
S(2).th_ref = squeeze(theta_ref.signals.values(:,2));
S(2).cov = squeeze(S_est.signals.values(2,2,:));

% Calculate RMSE for both parameter estimates
RMSE = 0;
for k=1:2
        try
            RMSE = RMSE + sqrt(mean((S(k).th_est-S(k).th_ref).^2));
        catch
            RMSE = RMSE + 1000; % Penalty for NaNs in estimation
        end
end

% Postprocessing to calculate penalty for divergence
err = 1000; % Penalty for covariance drift
pen1 = 0;
for k=1:2
    if S(k).cov(end)>S(k).cov(1)
        pen1 = pen1 + (S(k).cov(end)-S(k).cov(1)) * err;
    end
end

% Calculate objective function
obj = RMSE + pen1;

end