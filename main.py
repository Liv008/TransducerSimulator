import math
import numpy as np

def set_globals_vars(nargin, reset):
    # Constants
    global c, f, fs, B, lambdaVar
    global n_x, n_y
    global d_arrspa_x, d_arrspa_y
    global Phas_0_x, Phas_0_y
    global d_padim_x, d_padim_y
    global res_2D

    global hwb_ref
    global pulse_width
    global cancel_button
    global impedance
    global u_0
    global var1
    global var2
    global z_end
    global y_end
    global x_end
    global x_trans_dist_steps
    global y_trans_dist_steps

    global fft_points
    global fft_rect_points

    global FREC, TIME, AMPL, PHAS, POW

    if nargin == 0:
        reset = 0

    if reset == 1:
        c = 1500
        f = 3.0E6
        B = 1.5E6
        fs = 2.5E8

        res_2D = math.pi / 1000

        lambdaVar = c / f


        # patch parameters
        d_padim_x = 300E-6      # z-direction[m] | z
        d_padim_y = 300E-6      # y-direction[m]       0-- y

        # array parameters
        n_x = 3
        d_arrspa_x = 500E-6     # [m] Distance middle of element to middle of element  (element / 2 + distance + element / 2)
        Phas_0_x = 0            # [rad]

        n_y = 3
        d_arrspa_y = 500E-6     # [m] Distance middle of element to middle of element  (element / 2 + distance + element / 2)
        Phas_0_y = 0            # [rad]

        fft_points = 200
        fft_rect_points = 400
        pulse_width = 200

        cancel_button = 0

        impedance = 1500000     # Ohm
        u_0 = 1
        var1 = 100
        var2 = 100
        z_end = 0.015           # m
        y_end = 0               # m
        x_end = 0.005           # m
        x_trans_dist_steps = 20
        y_trans_dist_steps = 20

        FREC = 1
        TIME = 1
        AMPL = 2
        PHAS = 3
        POW = 4

set_globals_vars(2, 1)
def visualize_transducer_array():
    n_x_count = 1
    n_y_count = 1


    unten_x = ((n_x_count - 1) * d_arrspa_x) - (0.5 * d_padim_x)
    oben_x = ((n_x_count - 1) * d_arrspa_x) + (0.5 * d_padim_x)

    unten_y = ((n_y_count - 1) * d_arrspa_y) - (0.5 * d_padim_y)
    oben_y = ((n_y_count - 1) * d_arrspa_y) + (0.5 * d_padim_y)

    res_vis_x = (oben_x - unten_x) / 10
    res_vis_y = (oben_y - unten_y) / 10

    TRAN_SURF_X = np.zeros((n_x, 11))
    TRAN_SURF_Y = np.zeros((n_y, 11))

    while n_x_count < n_x + 1:
        unten_x = ((n_x_count - 1) * d_arrspa_x) - (0.5 * d_padim_x)
        oben_x = ((n_x_count - 1) * d_arrspa_x) + (0.5 * d_padim_x)

        TRAN_SURF_X[n_x_count-1] = np.arange(unten_x, oben_x + res_vis_x/2, res_vis_x)

        n_x_count += 1

    while n_y_count < n_y + 1:
        unten_y = ((n_y_count - 1) * d_arrspa_y) - (0.5 * d_padim_y)
        oben_y = ((n_y_count - 1) * d_arrspa_y) + (0.5 * d_padim_y)

        TRAN_SURF_Y[n_y_count-1] = np.arange(unten_y, oben_y + res_vis_y/2, res_vis_y)

        n_y_count += 1

    return TRAN_SURF_X, TRAN_SURF_Y

'''
def calculate_half_power_Beamwidth(C_ALL, INT):
    # Calculate half power beamwidth bzw. half power angle -intensity
    eps = 2.2204e-16
    lambdaVar = c / f

    INT[0] = C_ALL[0]
    INT[1] = C_ALL[1] ^ 2

    Max_Int = sorted(max(INT[1]))
    Max_Int = Max_Int(1, 1)

    INT[2] = abs(INT[1] / Max_Int)
    INT[3] = 10 * np.log10(INT[2])

    if Phas_0_x >= 0 and Phas_0_x <= math.pi: # search from 0° to 180°
        counter_hww_max = 2
        counter_hww = counter_hww_max
        hww = 4                         # 0.6; # define start difference value
        hww_row = counter_hww
        max_row = counter_hww_max

        # find #1 max -> set counter_hww
        while counter_hww_max < len(INT[0]):
            if abs(INT(counter_hww_max, 4) - max(INT[3])) <= eps:
                counter_hww = counter_hww_max       # save counter max
                max_row = counter_hww_max           # save max array position
                counter_hww_max = len(INT[0]) # to end while loop

            counter_hww_max = counter_hww_max + 1

        # find half power beamwidth, search from max to end of array
        while counter_hww < len(INT[0]):

            # to calculate 1 element at 180°
            if np.isnan(INT(counter_hww, 4)):
                counter_hww = counter_hww + 1

                if abs((INT(counter_hww, 4)) - 0) <= eps:
                    counter_hww = counter_hww + 1

            hww_tmp = abs(3 + INT(counter_hww, 4))

            if hww_tmp < hww:        # find half power beamwidth (=0.5)
                hww = hww_tmp
                hww_row = counter_hww
                counter_hww = counter_hww + 1
            else:
                counter_hww = len(INT[0])

        hwb_int = abs(INT(hww_row, 1) - INT(max_row, 1)) * 2 * (180 / math.pi) # half power beamwidth in degree

    # for phase shift > 180° or < 0°: search from 360° to 181°
    else:
        counter_hww_max = len(INT[0])

        counter_hww = counter_hww_max
        max_row = counter_hww_max
        hww_row = counter_hww

        hww = 4 # define start difference value

        # find 1 max -> set counter_hww
        while counter_hww_max > 2:
            if abs(INT(counter_hww_max, 3) - max(INT[2])) <= eps:
                counter_hww = counter_hww_max
                max_row = counter_hww_max
                counter_hww_max = 1

            counter_hww_max = counter_hww_max - 1

        # find half power beamwidth, search from max to end of array
        while counter_hww > 1:
            # to calculate 1 element at 180°
            if np.isnan(INT(counter_hww, 3)):
                counter_hww = counter_hww - 1
                if abs((INT(counter_hww, 3)) - 0) <= eps:
                    counter_hww = counter_hww - 1

            hww_tmp = abs(3 + C_ALL(counter_hww, 3))

            if hww_tmp < hww:
                hww = hww_tmp
                hww_row = counter_hww
                counter_hww = counter_hww - 1
            else:
                counter_hww = 1

        hwb_int = abs(INT(hww_row, 1) - INT(max_row, 1)) * 2 * (180 / math.pi) # half power beamwidth in degree

    # Calculate Halbwertsbreite bzw.Halbwertswinkel - pressure
    if Phas_0_x >= 0 and Phas_0_x <= math.pi:     # search from 0° to 180°
        counter_hww_max = 2
        hww = 0.6                           # define start difference value

        # find 1 max -> set counter_hww
        while counter_hww_max < len(C_ALL[0]):
            if abs(C_ALL(counter_hww_max, 3) - max(C_ALL[2])) <= eps:
                counter_hww = counter_hww_max           # save counter max
                max_row = counter_hww_max               # save max array position
                counter_hww_max = len(C_ALL[0])   # to end while loop

            counter_hww_max = counter_hww_max + 1

        # find halbwert, search from max to end of array
        while counter_hww < len(C_ALL[0]):
            # to calculate 1 element at 180°
            if np.isnan(C_ALL(counter_hww, 3)):
                counter_hww = counter_hww + 1

                if abs((C_ALL(counter_hww, 3)) - 1) <= eps:
                    counter_hww = counter_hww + 1

            hww_tmp = abs(0.5 - C_ALL(counter_hww, 3))
            if hww_tmp < hww:       # find halbwert (=0.5):
                hww = hww_tmp
                hww_row = counter_hww
                counter_hww = counter_hww + 1
            else:
                counter_hww = len(C_ALL[0])

        hwb_pres = abs(C_ALL(hww_row, 1) - C_ALL(max_row, 1)) * 2 * (180 / math.pi) # Halbwertsbreite in degree

    # for phase shift > 180° or < 0°: search from 360° to 181°
    else:
        counter_hww_max = len(C_ALL[0])
        hww = 0.6                   # define start difference value

        # find 1 max -> set counter_hww
        while counter_hww_max > 2:
            if abs(C_ALL(counter_hww_max, 3) - max(C_ALL[2])) <= eps:
                counter_hww = counter_hww_max
                max_row = counter_hww_max
                counter_hww_max = 1
            counter_hww_max = counter_hww_max - 1

        # find halbwert, search from max to end of array
        while counter_hww > 1:
            # to calculate 1 element at 180°
            if np.isnan(C_ALL(counter_hww, 3)):
                counter_hww = counter_hww - 1
                if abs((C_ALL(counter_hww, 3)) - 1) <= eps:
                    counter_hww = counter_hww - 1

            hww_tmp = abs(0.5 - C_ALL(counter_hww, 3))

        if hww_tmp < hww:
            hww = hww_tmp
            hww_row = counter_hww
            counter_hww = counter_hww - 1
        else:
            counter_hww = 1

        hwb_pres = abs(C_ALL(hww_row, 1) - C_ALL(max_row, 1)) * 2 * (180 / math.pi)     # Halbwertsbreite in degree

    return hwb_int, hwb_pres


def calculate_transducer_array_2D_acoustic():
    eps = 2.2204e-16
    lambdaVar = c / f

    # acoustic MONOPOL
    AK_MONOPOL = [2 * math.pi / res_2D, 4]
    col = 1

    # vertical
    for theta in np.arange(theta_min, theta_max + res_2D/3, res_2D):
        AK_MONOPOL[col][0] = theta
        AK_MONOPOL[col][1] = 1
        col = col + 1

    # horizontal
    col = 1
    for phi in np.arange(0, (2 * math.pi) + res_2D/3, res_2D):
        AK_MONOPOL(col, 3) = phi
        AK_MONOPOL(col, 4) = 1
        col = col + 1

    # Rectangular patch - grouping factor
    RECT = [(2 * math.pi) / res_2D, 5]
    col = 1

    # vertical
    phi = 0 - eps

    for theta in np.arange(theta_min, theta_max + res_2D/3, res_2D):
        A_rect = (math.pi * d_padim_x / lambdaVar) * math.cos(phi) * math.sin(theta)
        B_rect = math.sin(A_rect) / A_rect
        C_rect = (math.pi * d_padim_y / lambdaVar) * math.sin(phi) * math.sin(theta)
        D_rect = math.sin(C_rect) / C_rect

        F_Gr_rect_ver = B_rect * D_rect

        RECT(col, 1) = theta
        RECT(col, 2) = abs(F_Gr_rect_ver)

        col = col + 1

    # horizontal
    theta = math.pi / 2 - eps
    col = 1
    for phi in np.arange( 0, 2 * math.pi + res_2D/3, res_2D):
        A_rect = (math.pi * d_padim_x / lambdaVar) * math.cos(phi) * math.sin(theta)
        B_rect = math.sin(A_rect) / A_rect
        C_rect = (math.pi * d_padim_y / lambdaVar) * math.sin(phi) * math.sin(theta)
        D_rect = math.sin(C_rect) / C_rect

        F_Gr_rect_hor = B_rect * D_rect

        RECT(col, 4) = phi
        RECT(col, 5) = abs(F_Gr_rect_hor)

        col = col + 1

    # Normierung
    RECT(:, 3) = RECT(:, 2)./ max(RECT(:, 2))
    RECT(:, 6) = RECT(:, 5)./ max(RECT(:, 5))

    # Grouping factor of multiple elements linear next to each other on x and y - axis
    GRUPPE_XY = [2 * math.pi / res_2D, 5]

    # vertikal
    phi = 0 + eps
    col = 1

    for theta in np.arange(theta_min, theta_max + res_2D/3, res_2D):
        F_Gr_xy_ver = 0
        for dy in range(0, n_y - 1):
            for dx in range(0, n_x - 1):
                F_Gr_xy_ver = F_Gr_xy_ver + en_matrix(dy + 1, dx + 1). * exp(0 + ( (2. * pi. /lambdaVar) * dx. * d_arrspa_x. * cos(phi). * sin(theta) - phase_x_matrix(dy + 1, dx + 1) + (2. * pi. /lambdaVar) * dy. * d_arrspa_y. * sin(phi). * sin(theta) - phase_y_matrix(dy + 1, dx + 1)) * 1i);

        GRUPPE_XY(col, 1) = theta
        GRUPPE_XY(col, 2) = abs(F_Gr_xy_ver)

        col = col + 1

    # horizontal
    col = 1
    theta = math.pi / 2 - eps

    for phi in np.arange(0, 2 * math.pi + res_2D/3, res_2D):
        F_Gr_xy_hor = 0
        for dy in range(0, n_y - 1):
            for dx in range(0, n_x - 1):
                F_Gr_xy_hor = F_Gr_xy_hor + en_matrix(dy + 1, dx + 1). * exp(0 + ((2. * pi. /lambdaVar) * dx. * d_arrspa_x. * cos(phi). * sin(theta) - phase_x_matrix(dy + 1, dx + 1) + (2. * pi. /lambdaVar) * dy. * d_arrspa_y. * sin(phi). * sin(theta) - phase_y_matrix(dy + 1, dx + 1)) * 1i);

        GRUPPE_XY(col, 4) = phi
        GRUPPE_XY(col, 5) = abs(F_Gr_xy_hor)

        col = col + 1

    # Directivity of grouping

    # vertical
    GRUPPE_XY(:, 3) = GRUPPE_XY(:, 2)./ max(GRUPPE_XY(:, 2))

    # horizontal
    GRUPPE_XY(:, 6) = GRUPPE_XY(:, 5)./ max(GRUPPE_XY(:, 5))

    # ALL: xy Array with Rectangular Transducer

    # grouping(without element factor)
    F_ALL = zeros(size(GRUPPE_XY))

    # vertical
    F_ALL(:, 1) = GRUPPE_XY(:, 1)                   # theta
    F_ALL(:, 2) = GRUPPE_XY(:, 2).*RECT(:, 2)       # F_Gr_all_ver
    F_ALL(:, 3) = F_ALL(:, 2)./ max(F_ALL(:, 2))    # normed

    # horizontal
    F_ALL(:, 4) = GRUPPE_XY(:, 4)                   # phi
    F_ALL(:, 5) = GRUPPE_XY(:, 5).*RECT(:, 5)       # F_Gr_all_hor
    F_ALL(:, 6) = F_ALL(:, 5)./ max(F_ALL(:, 5))    # normed

    # Directivity pattern
    # C(theta, phi) = | F_Gr_xy | * | F_Gr_rect | * | F_MONOPOL |

    # grouping(without element factor)
    C_ALL = np.zeros(len(GRUPPE_XY))

    # vertical
    C_ALL(:, 1) = GRUPPE_XY(:, 1)                   # theta
    C_ALL(:, 2) = F_ALL(:, 2).*AK_MONOPOL(:, 2)     # C_all_ver
    C_ALL(:, 3) = C_ALL(:, 2)./ max(C_ALL(:, 2))    # normed

    # horizontal
    C_ALL(:, 4) = GRUPPE_XY(:, 4)                   # phi
    C_ALL(:, 5) = F_ALL(:, 5).*AK_MONOPOL(:, 4)     # C_all_hor
    C_ALL(:, 6) = C_ALL(:, 5)./ max(C_ALL(:, 5))    # normed
    
'''

def calculate_pattern_acoustic_GUI(theta,phi):

    lambda_var  = c / f
    
    # Element = Monopol
    #-------------------
    F_mono = 1 #abs(sin(theta));       
        
    # Rectangular patch
    #-------------------
    A_rect = (math.pi * d_padim_x / lambda_var) * math.cos(phi) * math.sin (theta)
    B_rect = math.sin(A_rect) / A_rect
    C_rect = (math.pi * d_padim_y / lambda_var) * math.sin(phi) * math.sin (theta)
    D_rect = math.sin(C_rect) / C_rect
   
    F_Gr_rect = abs(B_rect * D_rect)
    
    # x-y array
    #-----------
    F_Gr_xy = 0
    for dy in range(0,n_y-1):
        for dx in range(0,n_x-1):               
            F_Gr_xy += en_matrix[dy + 1][dx + 1] * math.exp(0 + ((2.*math.pi /lambda_var)* dx * d_arrspa_x * math.cos(phi) * math.sin(theta) - phase_x_matrix[dy + 1][dx + 1] + (2.*math.pi /lambda_var)* dy * d_arrspa_y * math.sin(phi) * math.sin(theta) - phase_y_matrix[dy + 1][dx + 1])*1j)

    F_Gr_xy = abs(F_Gr_xy)       
        
    # calc F_all
    #------------
    C_all = F_Gr_xy * F_Gr_rect * F_mono

    return C_all, F_Gr_xy, F_Gr_rect, F_mono
