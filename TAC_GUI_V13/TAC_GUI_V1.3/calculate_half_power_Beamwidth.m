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
function [hwb_int hwb_pres] = calculate_half_power_Beamwidth(C_ALL)
%% calculate half power beamwidth bzw. half power angle -intensity

%constants: defined in calculate_pattern

%T_A_C_global_variables_GUI();

global lambda;
global c f;
global Phas_0_x;

lambda = c/f;

%  global hwb_int ;
%  global hwb_pres ;

%lambda = c/f;
%res=res_2D/10;

INT (:,1) = C_ALL(:,1);
INT (:,2) = (C_ALL(:,2).^2);
Max_Int = sort (max(INT(:,2)),'descend');
Max_Int = Max_Int (1,1);
INT (:,3) = abs(INT(:,2)./Max_Int);

INT (:,4) = 10*log10(INT(:,3));

% C_ALL(:,7) = 20*log10(C_ALL(:,3));
% 
% figure()
% plot(INT(:,1).*(180/pi),INT(:,4),'r')
% hold on
% plot(C_ALL(:,1).*(180/pi),C_ALL(:,7),'b')


if Phas_0_x >= 0 && Phas_0_x <=pi   %search from 0° to 180°
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    counter_hww_max = 2;
    counter_hww = counter_hww_max;
    hww = 4;%0.6; %define start difference value 
    hww_row = counter_hww;
    max_row = counter_hww_max;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %find #1 max -> set counter_hww
    while counter_hww_max < length(INT(:,1)) 

        if abs(INT(counter_hww_max,4)- max(INT(:,4))) <=eps

            counter_hww = counter_hww_max;  %save counter max
            max_row = counter_hww_max;  %save max array position 
            counter_hww_max = length(INT(:,1)); %%to end while loop
        end

        counter_hww_max = counter_hww_max +1;
    end

    %find half power beamwidth, search from max to end of array
    while counter_hww < length(INT(:,1)) 
        
        %%%%%%%%to calculate 1element at 180°%%%%%
        if isnan (INT(counter_hww,4)) == true 
            
            counter_hww = counter_hww +1;
        
            if  abs((INT(counter_hww,4))-0)<=eps
                counter_hww = counter_hww +1;
            end
            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        hww_tmp = abs (3 + INT(counter_hww,4));

        if hww_tmp < hww    %find half power beamwidth (=0.5)

            hww = hww_tmp;
            hww_row = counter_hww;
                                    
       % end

        counter_hww = counter_hww +1;

        else
       % if C_ALL(counter_hww,3) < C_ALL(counter_hww+1,3)   % steigung wird poitiv -> Ende
            counter_hww = length(INT(:,1)); % end while loop
        end

    end  
    hwb_int= abs(INT(hww_row,1)-INT(max_row,1))*2 *(180/pi); %half power beamwidth in degree

else %for phase shift > 180° or < 0°: search from 360° to 181°
    
    counter_hww_max = length(INT(:,1));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    counter_hww = counter_hww_max;
    max_row = counter_hww_max;
    hww_row = counter_hww;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hww = 4; %define start difference value
    
    %find #1 max -> set counter_hww
    while counter_hww_max > 2

     if abs(INT(counter_hww_max,3)- max(INT(:,3))) <=eps

        counter_hww = counter_hww_max;
        max_row = counter_hww_max;
        counter_hww_max = 1;
     end

       counter_hww_max = counter_hww_max -1;

    end

    %find half power beamwidth, search from max to end of array
    while counter_hww > 1 

        %%%%%%%%to calculate 1element at 180°%%%%%
        if isnan (INT(counter_hww,3)) == true 
            
            counter_hww = counter_hww -1;
        
            if  abs((INT(counter_hww,3))-0)<=eps
                counter_hww = counter_hww -1;
            end
            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        hww_tmp = abs (3 + C_ALL(counter_hww,3));

        if hww_tmp < hww

            hww = hww_tmp;
            hww_row = counter_hww;
        %end

        counter_hww = counter_hww -1;

        else
        %if C_ALL(counter_hww,3) < C_ALL(counter_hww-1,3)
            counter_hww = 1;
        end

    end

 
     hwb_int= abs(INT(hww_row,1)-INT(max_row,1))*2 *(180/pi); %half power beamwidth in degree


end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Calculate Halbwertsbreite bzw. Halbwertswinkel -pressure
if Phas_0_x >= 0 && Phas_0_x <=pi   %search from 0° to 180°
    
    counter_hww_max = 2;
    hww = 0.6; %define start difference value 
    
        %find #1 max -> set counter_hww
    while counter_hww_max < length(C_ALL(:,1)) 

     if abs(C_ALL(counter_hww_max,3)- max(C_ALL(:,3))) <=eps

        counter_hww = counter_hww_max;  %save counter max
        max_row = counter_hww_max;  %save max array position 
        counter_hww_max = length(C_ALL(:,1)); %%to end while loop
     end

       counter_hww_max = counter_hww_max +1;

    end

    %find halbwert, search from max to end of array
    while counter_hww < length(C_ALL(:,1)) 
        
        %%%%%%%%to calculate 1element at 180°%%%%%
        if isnan (C_ALL(counter_hww,3)) == true 
            
            counter_hww = counter_hww +1;
        
            if  abs((C_ALL(counter_hww,3))-1)<=eps
                counter_hww = counter_hww +1;
            end
            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        hww_tmp = abs (0.5 - C_ALL(counter_hww,3));

        if hww_tmp < hww    %find halbwert (=0.5)

            hww = hww_tmp;
            hww_row = counter_hww;                                  
       % end

        counter_hww = counter_hww +1;

        else
       % if C_ALL(counter_hww,3) < C_ALL(counter_hww+1,3)   % steigung wird poitiv -> Ende
            counter_hww = length(C_ALL(:,1)); % end while loop
        end

    end
    
     hwb_pres= abs(C_ALL(hww_row,1)-C_ALL(max_row,1))*2 *(180/pi); %Halbwertsbreite in degree

else %for phase shift > 180° or < 0°: search from 360° to 181°
    
    counter_hww_max = length(C_ALL(:,1));
    hww = 0.6; %define start difference value
    
    %find #1 max -> set counter_hww
    while counter_hww_max > 2

        if abs(C_ALL(counter_hww_max,3)- max(C_ALL(:,3))) <=eps
            counter_hww = counter_hww_max;
            max_row = counter_hww_max;
            counter_hww_max = 1;
        end
        counter_hww_max = counter_hww_max -1;

    end

    %find halbwert, search from max to end of array
    while counter_hww > 1 

        %%%%%%%%to calculate 1element at 180°%%%%%
        if isnan (C_ALL(counter_hww,3)) == true 
            
            counter_hww = counter_hww -1;
        
            if  abs((C_ALL(counter_hww,3))-1)<=eps
                counter_hww = counter_hww -1;
            end
            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        hww_tmp = abs (0.5 - C_ALL(counter_hww,3));

        if hww_tmp < hww

            hww = hww_tmp;
            hww_row = counter_hww;
        %end

        counter_hww = counter_hww -1;

        else
        %if C_ALL(counter_hww,3) < C_ALL(counter_hww-1,3)
            counter_hww = 1;
        end

    end

     hwb_pres= abs(C_ALL(hww_row,1)-C_ALL(max_row,1))*2 *(180/pi); %Halbwertsbreite in degree

end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




