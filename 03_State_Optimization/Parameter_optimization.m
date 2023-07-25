%% Script to optimize the initial parameter set for the state filter
% Nikolaos Wassiliadis
clc; clear;
disp('### This is MATLAB: Start of optimization. ###')

% Measurement Error Covariance
R_start = 0.001; %0.001;

% Process Noise Covariance
Q_start_1  = 10^-9; %10^-9
Q_start_2  = 10^-9; %10^-9
Q_start_3  = 10^-9; %10^-99
   
%% Parameter Estimation
starter = [ R_start ...
            Q_start_1 ...
            Q_start_2 ...
            Q_start_3];

% Set optimization problem
opts = optimoptions('patternsearch','Display', 'iter', 'MeshTolerance', 1e-15,'InitialMeshSize', 1,'StepTolerance',1e-15,'MaxIterations',5000,'PlotFcn', @psplotbestf);
[x, f] = patternsearch(@subfct_optimization, starter, [], [], [], [], [0 0 0 0], [1 1 1 1] ,[], opts);

% Transfer results
R = x(1);
Q = [x(2), 0,    0;...
     0   , x(3), 0;...
     0   , 0   , x(4)];

save('Optimization_Results.mat');
disp('### This is MATLAB: Final point reached. ###')