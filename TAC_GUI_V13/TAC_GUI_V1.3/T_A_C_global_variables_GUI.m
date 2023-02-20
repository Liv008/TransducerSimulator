%% TRANSDUCER ARRAY CALCULATION (T_A_C)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This program was developed to calculate and visualize the radiation pattern of
%   ultrasound transducers, especially for 3D Ultrasound Computer Tomography (USCT).
%   
%   To run the program properly, it is necessary to include the following
%   MATLAB files:
%           - T_A_C_GUI.m                                 [= creating GUI and administrating]
%           - T_A_C_GUI.fig                               [= GUI figure]  
%           - calculate_pattern_acoustic_GUI.m            [= calculation of 3D radiation pattern]
%           - calculate_transducer_array_2D_acoustic.m    [= calculation of 2D radiation pattern and -3 dB range]
%           - T_A_C_global_variables_GUI.m                [= init global variables]
%           - visualize_transducer_array_GUI.m            [= visualization of transducer surfaces]
%           - Soundfield_without_approx.m                 [= calculation of Near Field]
%           - calculate_half_power_Beamwidth.m            [= calculation of half power beamwidth]
%   
%   The TAC Package also includes an "Icons" and "Examples" folder. 
%
%   Developed by Benedikt Kohout and Luciano.G. Palacios Folla, friendly supported by Robin Dapp
%   at the Karlsruhe Institute of Technology, Institute for Data Processing and Electronics, Karlsruhe, Germany.
%   benedikt.kohout@kit.edu
%                                                                                                      03/2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function T_A_C_global_variables_GUI(reset)

if nargin == 0;
    reset = 0;
end

%constants
global c f fs B lambda;
global n_x n_y d_arrspa_x d_arrspa_y Phas_0_x Phas_0_y;
global d_padim_x d_padim_y;
global  res_2D;
% global theta_min theta_max;
global hwb_ref;

global pulse_width;

global cancel_button;

global impedance;
global u_0;
global var1;
global var2;
global z_end;
global y_end;
global x_end;
global x_trans_dist_steps;
global y_trans_dist_steps;

global fft_points;
global fft_rect_points;

global FREC TIME AMPL PHAS POW;

hwb_ref = true;

if reset == 1
    
c = 1500;
f = 3.0E6;
B = 1.5E6;
fs = 2.5E8;
%res=pi/50;%0.1        
res_2D=pi/1000;
%res_2D=pi/10000; 
% theta_min = 0;
% theta_max = 2*pi;

%substitutions
%omega = 2 .* pi .* f;
lambda = c / f;
%k = 2 .* pi ./ lambda;

%patch parameters
d_padim_x = 300E-6;    %z-direction [m]       |z     
d_padim_y = 300E-6;    %y-direction [m]       0-- y

%array parameters
n_x = 3;
d_arrspa_x = 500E-6;% [m] Distance middle of element to middle of element  (element/2 + distance + element/2)
Phas_0_x = 0; %[rad]

n_y = 3;
d_arrspa_y = 500E-6;% [m] Distance middle of element to middle of element  (element/2 + distance + element/2)
Phas_0_y = 0; %[rad]

fft_points = 200;
fft_rect_points = 400;
pulse_width = 200;

cancel_button = 0;

impedance = 1500000;        % Ohm
u_0 = 1;
var1 = 100;
var2 = 100;
z_end = 0.015;              %  m
y_end = 0;                  %  m
x_end = 0.005;              %  m
x_trans_dist_steps = 20;
y_trans_dist_steps = 20;

FREC = 1;
TIME = 1;
AMPL = 2;
PHAS = 3;
POW = 4;
end
end
