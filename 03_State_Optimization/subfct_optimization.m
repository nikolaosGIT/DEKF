%% Objective function
function [obj] = subfct_optimization(starter)
%% Initialize Plant and framework
load('Initialization.mat');

% Measurement Error Covariance
R = starter(1);

% Process Noise Covariance
Q = [starter(2),     0,          0;...
         0,          starter(3), 0;
         0,          0,          starter(4)];

%% Simulation
options = simset('SrcWorkspace','current');
load_system('DEKF.slx');
sim('DEKF.slx',[],options);

%% Postprocessing to calculate objetive function

% Transfer dataset
Opt.SOC = squeeze(SOC_est.signals.values)-squeeze(SOC_ref.signals.values);
Opt.grad = abs(diff(squeeze(SOC_est.signals.values)));
Opt.P = P_est.signals.values;

RMSE = 0;
frame = 1500/0.025; % Convergence target 1500s at 0.025s sample rate

% Calculate RMSE for accuracy
try
    RMSE = sqrt(sum(Opt.SOC(frame:end).^2));
    catch
    RMSE = 1000;
end

% Postprocessing to punish divergence
err = 1000; % Penalty for errorenous covariance drift
pen1 = 0;
if Opt.P(1,1,end)>Opt.P(1,1,1)
    pen1 = abs(Opt.P(1,1,end)-Opt.P(1,1,1)) * err;
end

% Postprocessing to punish high gradients and to set stability
pen2 = 0;
gradlimit = 0.8*10^-5;
for i=frame:length(Opt.grad)
    if Opt.grad(i)>gradlimit
        pen2 = pen2 + 1;
    end
end

% Calculate objective function
obj = RMSE + pen1 + pen2;

end