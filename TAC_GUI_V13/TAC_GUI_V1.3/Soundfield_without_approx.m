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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Calculate soundfield without approximation Function for array of 
%   rectangular transducer elements
%
%   Parameters IN:
%
%       -   input_signal (in frequency unit)
%       -   attenuation  (in Np/m unit)
%       -   waitbar (handle of waitbar)
%
%   Parameters OUT:
%
%       -   axis_var1
%       -   axis_var2
%       -   Plane
%       -   elapsed_time
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Explanation of geometry of transducer configuration:
%                    l_x
%           |___________________|
%           |                   |
%           |         |         |
%    ______  ______   |   ______
%     |     |      |  |  |      |
%     |     |      |  |  |   x <|----- (x_n = 0, y_n = 0)
%     |     |______|  |  |______|
% l_y | ______________|(0,0,0)_______
%     |      ______   |   ______
%     |     |      |  |  |      |
%     |     |      |  |  |      |
%    _|____ |______|  |  |______|
%                     |
%                     |
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [axis_var1 axis_var2 Plane elapsed_time] = Soundfield_without_approx(input_signal, attenuation, wait_bar)
% Time measure
tic

% Constants
global c;                               % Speed of sound
global n_x n_y d_arrspa_x d_arrspa_y    % Transducer characteristics
global d_padim_x d_padim_y;             % Transducer characteristics
global en_matrix;                       % Enable/amplitude matrix
global phase_x_matrix phase_y_matrix;

global FREC;                            % Input_signal vector component
global AMPL;                            % Input_signal vector component

% Position of observator vectors
XX = 1;
YY = 2;
ZZ = 3;

global impedance;                       % Ohms
global u_0;
global var1;
global var2;
global z_end;
global y_end;
global x_end;
global x_trans_dist_steps;
global y_trans_dist_steps;
global surface_nf;

global var1_count var2_count;               % To Cancel button

% Init Parameters
Z = impedance;              % Acoustic impedance of transducer [Rayl]

rho_0 = Z/c;                % Aproximation of the end of ultrasound signal
 
x_dim = d_padim_x;          % Large of x transducer side
y_dim = d_padim_y;          % Large of y transducer side 

x_spa = d_arrspa_x;         % Spacing between transducer x
y_spa = d_arrspa_y;         % Spacing between transducer y 

% X-transducer dimensions values for each transducer
start_x_dim = -x_dim/2;
end_x_dim = x_dim/2;
steps_x_dim = x_trans_dist_steps;
disc_x_dim = (end_x_dim + abs(start_x_dim)) / steps_x_dim;

% Y-transducer dimensions values for each transducer
start_y_dim = -y_dim/2;
end_y_dim = y_dim/2;
steps_y_dim = y_trans_dist_steps;
disc_y_dim = (end_y_dim + abs(start_y_dim)) / steps_y_dim;

% Centre of transducer configuration, when it ist considered a point
l_x = (n_x - 1) * x_spa;
l_y = (n_y - 1) * y_spa;
if n_x > 1
    disc_l_x = l_x / (n_x - 1);
else
    disc_l_x = 1;
end
if n_y > 1
    disc_l_y = l_y / (n_y - 1);
else
    disc_l_y = 1;
end

% Calculate of transducer relative position
x_positions = -l_x/2:disc_l_x:l_x/2;
y_positions = -l_y/2:disc_l_y:l_y/2;

% Position of observer point in global coordinate system
% Reset values
var_obs_start = -1*ones(1,3);
var_obs_end = -1*ones(1,3);
steps_var_obs = -1*ones(1,3);
disc_var_obs = -1*ones(1,3);
var_obs = -1*ones(1,3);

switch surface_nf
    case 1          % Surface X-Z
        pos1 = XX;   % Set pos1 = X axis
        pos2 = ZZ;   % Set pos2 = Z axis
                     %     pos3 = Y axis
        
        var_obs_start(XX) = -x_end;
        var_obs_end(XX) = x_end;
        steps_var_obs(XX) = var1;
        disc_var_obs(XX) = (var_obs_end(XX) - var_obs_start(XX)) / steps_var_obs(XX); 
      
        var_obs_end(ZZ) = z_end;
        steps_var_obs(ZZ) = var2;      %steps_r;
        disc_var_obs(ZZ) = var_obs_end(ZZ) / steps_var_obs(ZZ);
        var_obs_start(ZZ) = disc_var_obs(ZZ);
        
        % Static axis       
        var_obs_start(YY) = y_end;
        
    case 2          % Surface Y-Z
        pos1 = YY;   % Set pos1 = Y axis
        pos2 = ZZ;   % Set pos2 = Z axis
                     %     pos3 = X axis
        
        var_obs_start(YY) = -y_end;
        var_obs_end(YY) = y_end;
        steps_var_obs(YY) = var1;
        disc_var_obs(YY) = (var_obs_end(YY) - var_obs_start(YY)) / steps_var_obs(YY); 
      
        var_obs_end(ZZ) = z_end;
        steps_var_obs(ZZ) = var2;      %steps_r;
        disc_var_obs(ZZ) = var_obs_end(ZZ) / steps_var_obs(ZZ);
        var_obs_start(ZZ) = disc_var_obs(ZZ);
        
        % Static axis       
        var_obs_start(XX) = x_end;
        
    case 3          % Surface X-Y
        pos1 = XX;   % Set pos1 = X axis
        pos2 = YY;   % Set pos2 = Y axis
                     %     pos3 = Z axis
        
        var_obs_start(XX) = -x_end;
        var_obs_end(XX) = x_end;
        steps_var_obs(XX) = var1;
        disc_var_obs(XX) = (var_obs_end(XX) - var_obs_start(XX)) / steps_var_obs(XX); 
      
        var_obs_start(YY) = -y_end;
        var_obs_end(YY) = y_end;
        steps_var_obs(YY) = var2;
        disc_var_obs(YY) = (var_obs_end(YY) - var_obs_start(YY)) / steps_var_obs(YY); 
        
        % Static axis       
        var_obs_start(ZZ) = z_end;               

end
% Remove the null values from input signal and attenuation
aux_values = find(input_signal(AMPL,:) > eps);
input_signal = input_signal(:,aux_values);
attenuation = attenuation(:,aux_values);

% Some initialization
x_0 = start_x_dim:disc_x_dim:end_x_dim;  %integration #1 (dx)    
y_0 = start_y_dim:disc_y_dim:end_y_dim;  %integration #2 (dy)
[x_0_matrix y_0_matrix] = meshgrid(x_0, y_0);
Plane = zeros([var2, var1 + 1,size(input_signal,2)]);
Plane_GF = zeros([var2, var1 + 1,size(input_signal,2)]);

axis_var1 = zeros((var2)*(var1 + 1),1);
axis_var2 = zeros((var2)*(var1 + 1),1);

% Steps for waitbar
total_loops = (var2)*(var1 + 1);

% Parameters
f = input_signal(FREC,:);       % Frequency of signal component
lambda = c ./ f;                % Wavelength of this component
k = 2*pi ./ lambda;
omega = 2 * pi .* f;
t = 0;                          % Time

% Sweep in x axes
var_obs(XX) = var_obs_start(XX);
var_obs(YY) = var_obs_start(YY);
var_obs(ZZ) = var_obs_start(ZZ);
var1_count = 1;                 % X position in array
loop = 1;                       % Number of loops


% With transducer enable matrix and frequency amplitude
A = (1j .* omega .* rho_0 .* u_0 .*input_signal(AMPL,:) / (2*pi));                                  
B = exp(1j .* omega * t);

%x_pos=var_obs_start(pos1):disc_var_obs(pos1):var_obs_start(pos1)+disc_var_obs(pos1)*var1;
%y_pos=var_obs_start(pos2):disc_var_obs(pos2):var_obs_start(pos2)+disc_var_obs(pos2)*var2;

phi_arr=[];
theta_arr=[];
while var1_count <= var1 + 1
    var_obs(pos2) = var_obs_start(pos2);
    var2_count = 1;             

    while var2_count <= var2           
        % XY Characteristics variables
        phi = atan2(var_obs(YY),var_obs(XX));%atan(var_obs(YY)/var_obs(XX));%%;% ;
        theta = pi/2-atan(var_obs(ZZ)/sqrt((var_obs(XX))^2 + (var_obs(YY))^2));
        %phi_arr=[phi_arr; phi];
        %theta_arr=[theta_arr;theta];
        
        xy_char = 0;

        % Calculate Group Factor for the current transducer configuration
        % Surface integral:
        % Transducer sweep
        for y_trans_position = 1:1:length(y_positions)
            for x_trans_position = 1:1:length(x_positions)
                % If transducer amplitude greater than 0        
                if en_matrix(y_trans_position, x_trans_position) ~= 0
                    xy_char =   xy_char + en_matrix(y_trans_position, x_trans_position) .* ...
                                input_signal(AMPL,:) .* exp(0 + ((2.*pi ./lambda)*...
                                (((x_trans_position - 1) .* d_arrspa_x) -...
                                x_positions(1)).* cos(phi) .* sin(theta) -...
                                phase_x_matrix(y_trans_position, x_trans_position) + ...
                                (2.*pi ./lambda)* (((y_trans_position - 1) .* d_arrspa_y) - ...
                                y_positions(1)) .* sin(phi) .* sin(theta) - ...
                                phase_y_matrix(y_trans_position, x_trans_position))*1i);
                end
            end
        end


        % Calculate Surface Characteristic for 1 transducer %%%%%%%%%%%
        % Some resets
        r_distance = 0;
        p_num = zeros(length(k),1);
        % Relative Axes of tranducer
        x_n = 0;
        y_n = 0;        
        % Calculation of distance transducer-observer
        r_distance =    sqrt((var_obs(ZZ)*ones(size(x_0_matrix))).^2 + ...
                        (var_obs(XX)*ones(size(x_0_matrix)) - x_n*ones(size(x_0_matrix)) - x_0_matrix).^2 + ...
                        (var_obs(YY)*ones(size(y_0_matrix)) - y_n*ones(size(y_0_matrix)) - y_0_matrix).^2);    
        %geometrical damping
        D = (1./r_distance);          
        
        % XY Array 
        %%%% blocked freq-calc
        %     C = exp(repmat(reshape(-attenuation(AMPL,:),[1 1 length(attenuation(AMPL,:))]),[size(r_distance) 1]).* repmat(r_distance,[1 1 length(k)])) .* exp(-1j * repmat(reshape(k,[1 1 length(k)]),[size(r_distance) 1]) .* repmat(r_distance,[1 1 length(k)]));
             % Double integral
        %     p_num = squeeze(sum(sum(repmat(reshape(A,[1 1 length(A)]),[size(r_distance) 1]).*repmat(reshape(B,[1 1 length(B)]),[size(r_distance) 1]).*C.*repmat(D,[1 1 length(k)]).*disc_x_dim.*disc_y_dim)));

            % Frequency loop
            for n_comp = 1:1:length(k)
                %C = exp(-1j * k(n_comp) .* r_distance);
                C = exp(-attenuation(AMPL,n_comp).* r_distance).*exp(-1j * k(n_comp) .* r_distance);
                % Double integral
                p_num(n_comp) = p_num(n_comp) + sum(sum(A(n_comp)*B(n_comp).*C.*D*disc_x_dim*disc_y_dim));
            end
                
        % Position arrays
        axis_var1(loop,1) = var_obs(pos1);
        axis_var2(loop,1) = var_obs(pos2);

        % Surface of Group Factor for the current transducer configuration
        Plane_GF(var2_count, var1_count,:) = xy_char; 
        
        % Surface for 1 transducer
        Plane(var2_count, var1_count,:) = p_num;            

        % Waitbar Update (buggy formula?) 
        if mod(loop,100)==1
            waitbar((4+(3*loop/total_loops))/8,wait_bar,sprintf('Calculating spatial characteristics step %d of %.0f...',loop, total_loops));
        end
        loop = loop + 1;

        % One more Z step
        var_obs(pos2) = var_obs(pos2) + disc_var_obs(pos2);
        var2_count = var2_count + 1;
    end
    % One more X step
    var_obs(pos1) = var_obs(pos1) + disc_var_obs(pos1);
    var1_count = var1_count + 1;
end

% Time measuring
elapsed_time = toc;
% Final Surface
Plane = Plane .* Plane_GF;

end