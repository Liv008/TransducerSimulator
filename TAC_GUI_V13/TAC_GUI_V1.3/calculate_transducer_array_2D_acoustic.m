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
function [C_ALL, RECT, GRUPPE_XY, AK_MONOPOL] = calculate_transducer_array_2D_acoustic
%constants: defined in calculate_pattern

%T_A_C_global_variables_GUI();

global lambda;
global c f;
global n_x n_y d_arrspa_x d_arrspa_y;
global d_padim_x d_padim_y;
global res_2D;
global theta_min theta_max;

global en_matrix;
global phase_x_matrix phase_y_matrix;

lambda = c/f;

% acoustic MONOPOL

AK_MONOPOL = [2*pi/res_2D,4];
col =1;

%vertical
for theta = theta_min: res_2D: theta_max
    AK_MONOPOL (col,1) = theta;
    AK_MONOPOL (col,2) = 1;
    col = col+1;
end

%horizontal
col = 1;
for phi = 0 : res_2D: 2*pi
    AK_MONOPOL (col,3) = phi;
    AK_MONOPOL (col,4) = 1;
    col = col+1;
end

%% Rectangular patch - grouping factor

RECT = [2*pi/res_2D,5]; 

col=1;

%vertical
phi = 0-eps;

for theta = theta_min : res_2D : theta_max
         
    A_rect = (pi * d_padim_x / lambda) * cos(phi) * sin (theta);
    B_rect = sin(A_rect) / A_rect;
    C_rect = (pi * d_padim_y / lambda) * sin(phi) * sin (theta);
    D_rect = sin(C_rect) / C_rect;
            
    F_Gr_rect_ver = B_rect * D_rect; 
        
    RECT(col,1) = theta;
    RECT(col,2) = abs(F_Gr_rect_ver) ;
   
    col=col+1;
   
end

%horizontal
theta = pi/2-eps;
col =1;
for phi = 0 : res_2D : 2*pi
        
   A_rect = (pi * d_padim_x / lambda) * cos(phi) * sin(theta);
   B_rect = sin(A_rect) / A_rect;
   C_rect = (pi * d_padim_y / lambda) * sin(phi) * sin(theta);
   D_rect = sin(C_rect) / C_rect;

   F_Gr_rect_hor = B_rect * D_rect;   
   
   RECT(col,4) = phi;
   RECT(col,5) = abs(F_Gr_rect_hor);
   
   col=col+1;
   
end

%Normierung
RECT(:,3) = RECT(:,2) ./ max(RECT(:,2));
RECT(:,6) = RECT(:,5) ./ max(RECT(:,5));

%% Grouping factor of multiple elements linear next to each other on x and y-axis

GRUPPE_XY = [2*pi/res_2D,5];

%vertikal
phi = 0+eps;
col =1;

for theta = theta_min : res_2D : theta_max
     
    F_Gr_xy_ver = 0;      
    for dy=0:n_y-1
        for dx=0:n_x-1               
            F_Gr_xy_ver = F_Gr_xy_ver + en_matrix(dy + 1, dx + 1) .* exp(0 + ((2.*pi ./lambda)* dx .* d_arrspa_x .* cos(phi) .* sin(theta) - phase_x_matrix(dy + 1, dx + 1) + (2.*pi ./lambda)* dy .* d_arrspa_y .* sin(phi) .* sin(theta) - phase_y_matrix(dy + 1, dx + 1))*1i);
        end
    end                       
    GRUPPE_XY (col,1)= theta;
    GRUPPE_XY (col,2) = abs(F_Gr_xy_ver);
    
    col = col+1;
end

%horizontal
col = 1;
theta = pi/2-eps;

for phi = 0 : res_2D : 2*pi
     
    F_Gr_xy_hor = 0;      
    for dy=0:n_y-1
        for dx=0:n_x-1               
            F_Gr_xy_hor = F_Gr_xy_hor + en_matrix(dy + 1, dx + 1) .* exp(0 + ((2.*pi ./lambda)* dx .* d_arrspa_x .* cos(phi) .* sin(theta) - phase_x_matrix(dy + 1, dx + 1) + (2.*pi ./lambda)* dy .* d_arrspa_y .* sin(phi) .* sin(theta) - phase_y_matrix(dy + 1, dx + 1))*1i);
        end
    end                       
    GRUPPE_XY (col,4) = phi;
    GRUPPE_XY (col,5) = abs(F_Gr_xy_hor);
    
    col = col+1;
end

%Directivity of grouping 

%vertical
GRUPPE_XY (:,3) = GRUPPE_XY(:,2)./ max(GRUPPE_XY(:,2));

%horizontal
GRUPPE_XY (:,6) = GRUPPE_XY(:,5)./ max(GRUPPE_XY(:,5));

%% ALL: xy Array with Rectangular Transducer

%grouping (without element factor)
F_ALL = zeros(size(GRUPPE_XY));

%vertical
F_ALL(:,1) = GRUPPE_XY(:,1); %theta
F_ALL(:,2) = GRUPPE_XY(:,2) .* RECT(:,2); % F_Gr_all_ver
F_ALL(:,3) = F_ALL(:,2)./max(F_ALL(:,2)); %normed

%horizontal
F_ALL(:,4) = GRUPPE_XY(:,4); %phi
F_ALL(:,5) = GRUPPE_XY(:,5) .* RECT(:,5); %F_Gr_all_hor
F_ALL(:,6) = F_ALL(:,5)./max(F_ALL(:,5)); %normed

%% Directivity pattern
% C(theta, phi) = |F_Gr_xy| * |F_Gr_rect| * |F_MONOPOL|

%grouping (without element factor)
C_ALL = zeros(size(GRUPPE_XY));

%vertical
C_ALL(:,1) = GRUPPE_XY(:,1); %theta
C_ALL(:,2) = F_ALL(:,2) .* AK_MONOPOL(:,2); % C_all_ver
C_ALL(:,3) = C_ALL(:,2)./max(C_ALL(:,2)); %normed

%horizontal
C_ALL(:,4) = GRUPPE_XY(:,4); %phi
C_ALL(:,5) = F_ALL(:,5) .*AK_MONOPOL(:,4); %C_all_hor
C_ALL(:,6) = C_ALL(:,5)./max(C_ALL(:,5)); %normed

end