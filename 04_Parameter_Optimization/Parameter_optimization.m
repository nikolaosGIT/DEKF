%% Script to optimize the initial parameter set for the parameter filter
% Nikolaos Wassiliadis
clc; clear;
disp('### This is MATLAB: Start of optimization. ###')

% Measurement Error Covariance
R_start = 0.001; %0.001;

% Process Noise Covariance
Q_start_1  = 10^-9; %10^-9
Q_start_2  = 10^-9; %10^-9
   
%% Parameter Estimation
starter = [ R_start ...
            Q_start_1 ...
            Q_start_2];

% Set optimization problem
opts = optimoptions('patternsearch','Display', 'iter', 'MeshTolerance', 1e-15,'InitialMeshSize', 1,'StepTolerance',1e-15,'MaxIterations',5000,'PlotFcn', @psplotbestf);
[x, f] = patternsearch(@subfct_optimization, starter, [], [], [], [], [0 0 0], [inf inf inf] ,[], opts);

% Transfer results
R_par = x(1);
Q_par = [x(2),      0;...
            0,      x(3)];

save('Optimization_Results.mat');
disp('### This is MATLAB: Final point reached. ###')