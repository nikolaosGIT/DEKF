%% Simulation Script for the Dual Extended Kalman Filter
% Nikolaos Wassiliadis
clear; clc;
disp('### This is MATLAB: Start of simulation. ###')

%% Initialize plant and framework

% Add subfolders to path
addpath(genpath(pwd));

% Power source
for p=1:3
    clearvars -except p
    sel_power = p;
    switch sel_power
        case 1
            load('Low_Dynamics.mat')
        case 2
            load('High_Dynamics.mat')
        case 3
            load('Real_Dynamics.mat')
    end
    Load_power(:,1) = Results.time;
    Load_power(:,2) = -1*Results.signals.values(:,3)/(14*18*8);

    % Load static battery parameter set (DEKF set)
    temp = load('BatPara_Static.mat');
    Bat_param.Static = temp.Bat_param.Static;

    % Noise [A^2/V^2]
    Cnoise = 0.000225; % Taken from applied sensor datasheet
    Vnoise = 1.1111e-05; % Taken from applied sensor datasheet

    % Sensor resolution [mA/mV]
    Cres = 10; % Taken from applied sensor datasheet
    Vres = 1.5; % Taken from applied sensor datasheet

    % TUM-BMS sample period [s]
    dt = 0.025; % 40 Hz

    %% Initialize Dual Extended Kalman Filter (State Filter)

    % Initialize State error covariance
    P_init = [0.64,  0,      0;...
              0,     0.0625, 0;...
              0,     0,      0.0625];

    % Frist guess [SOC, URC1, URC2]
    x_init = [0.8, 0, 0]';

    % Error covariances from optimization
    R = 0.7733;
    Q  = [1.2328e-09,  0,      0;...
          0,           5.3216e-11, 0;...
          0,           0,      1.7166e-04];


    %% Initialize Dual Extended Kalman Filter (parameter filter)

    % Initalize state error covariance
    S_init = [11.56 0;...
              0     0.0225];

    % First guess [C; R0]
    theta_init = [ 3.4, 0.15]';

    % Error covariances from optimization
    R_par = 7.2724e-04;
    Q_par  = [1.6936e-15    0;...
              0             5.6659e-11];

    %% Simulation

    % Load dynamic battery parameter set (plant set)
    for i=1:5
        switch i
            case 1
                temp = load('BatPara_100.mat');
                Bat_param.Dyn = temp.Bat_param.Dyn;
            case 2
                temp = load('BatPara_97.mat');
                Bat_param.Dyn = temp.Bat_param.Dyn;
            case 3
                temp = load('BatPara_85.mat');
                Bat_param.Dyn = temp.Bat_param.Dyn;
            case 4
                temp = load('BatPara_78.mat');
                Bat_param.Dyn = temp.Bat_param.Dyn;
            case 5
                temp = load('BatPara_49.mat');
                Bat_param.Dyn = temp.Bat_param.Dyn;
        end

        % Set original state to SOC = 100%
        Bat_param.Dyn.Bat_init = [1; 0; 0];

        % Load system and start simulation
        load_system('EKF.slx');
        sim('EKF');

        % Save
        Sim(i).SOC_ref = SOC_ref;
        Sim(i).SOC_est = SOC_est;
        Sim(i).P_est = P_est;
        Sim(i).S_est = S_est;
        Sim(i).theta_est = theta_est;
        Sim(i).theta_ref = theta_ref;    
    end

    % Save to folder
    switch sel_power
        case 1
            save('EKF_LowDyn_HS.mat')
        case 2
            save('EKF_HighDyn_HS.mat')
        case 3
            save('EKF_RealDyn_HS.mat')
    end
end
disp('### This is MATLAB: End of simulation. ###')