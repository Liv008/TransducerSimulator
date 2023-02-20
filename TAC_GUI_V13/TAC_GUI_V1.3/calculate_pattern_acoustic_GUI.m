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
function [C_all F_Gr_xy F_Gr_rect F_mono] = calculate_pattern_acoustic_GUI(theta,phi)

%T_A_C_global_variables_GUI();

%constants
global lambda c f;
global n_x n_y d_arrspa_x d_arrspa_y;
global d_padim_x d_padim_y;

global en_matrix;
global phase_x_matrix phase_y_matrix;

lambda=c/f;

    % Element = Monopol
    %-------------------
    
    F_mono = 1;%abs(sin(theta));        
        
    % Rectangular patch
    %-------------------
    A_rect = (pi .* d_padim_x ./ lambda) .* cos(phi) .* sin (theta);
    B_rect = sin(A_rect) ./ A_rect;
    C_rect = (pi .* d_padim_y ./ lambda) .* sin(phi) .* sin (theta);
    D_rect = sin(C_rect) ./ C_rect;
   
    F_Gr_rect = abs(B_rect .* D_rect);
    
    % x-y array
    %-----------
    F_Gr_xy = 0;      
    for dy=0:n_y-1
        for dx=0:n_x-1               
            F_Gr_xy = F_Gr_xy + en_matrix(dy + 1, dx + 1) .* exp(0 + ((2.*pi ./lambda)* dx .* d_arrspa_x .* cos(phi) .* sin(theta) - phase_x_matrix(dy + 1, dx + 1) + (2.*pi ./lambda)* dy .* d_arrspa_y .* sin(phi) .* sin(theta) - phase_y_matrix(dy + 1, dx + 1))*1i);
        end
    end               
    F_Gr_xy = abs(F_Gr_xy);       
        
    % calc F_all
    %------------
    C_all = F_Gr_xy .* F_Gr_rect .* F_mono;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % The normalization ist made in "T_A_C_GUI.m"
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       
end