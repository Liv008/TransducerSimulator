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

function[TRAN_SURF_X, TRAN_SURF_Y]=visualize_transducer_array_GUI()
%% Visualisierung des Transducer Array

global n_x d_padim_x d_arrspa_x;
global n_y d_padim_y d_arrspa_y;


n_x_count = 1;
n_y_count = 1;

unten_x = ((n_x_count-1) * d_arrspa_x) - 0.5 * d_padim_x;
oben_x = ((n_x_count-1) * d_arrspa_x) + 0.5 * d_padim_x;

unten_y = ((n_y_count-1) * d_arrspa_y) - 0.5 * d_padim_y;
oben_y = ((n_y_count-1) * d_arrspa_y) + 0.5 * d_padim_y;

res_vis_x= (oben_x - unten_x)/10;
res_vis_y= (oben_y - unten_y)/10;

TRAN_SURF_X = zeros(n_x,11);
TRAN_SURF_Y = zeros(n_y,11);

while n_x_count < n_x+1
  
    unten_x = ((n_x_count-1) * d_arrspa_x) - 0.5 * d_padim_x;
    oben_x = ((n_x_count-1) * d_arrspa_x) + 0.5 * d_padim_x;

    TRAN_SURF_X(n_x_count,:) = unten_x : res_vis_x : oben_x;
   
    n_x_count = n_x_count +1;
    
end 
 
while n_y_count < n_y+1
    unten_y = ((n_y_count-1) * d_arrspa_y) - 0.5 * d_padim_y;
    oben_y = ((n_y_count-1) * d_arrspa_y) + 0.5 * d_padim_y;

    TRAN_SURF_Y(n_y_count,:) = unten_y : res_vis_y : oben_y;
   
       
    n_y_count = n_y_count +1;
end








