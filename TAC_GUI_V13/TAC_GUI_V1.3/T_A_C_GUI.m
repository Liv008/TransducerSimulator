%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2012, Benedikt Kohout
% 
% All rights reserved.
% Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
% 
% •	Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
% 
% •	Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation
% 	and/or other materials provided with the distribution.
% 
% •	Neither the name of the Karlsruhe Institue of Technology (KIT) nor the names of its contributors may be used to endorse or promote products derived from this
% 	software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT
%  NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
%  COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
%  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
%  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
%   Developed by Benedikt Kohout and Luciano Palacios, friendly supported by Robin Dapp
%   at the Karlsruhe Institute of Technology, Institute for Data Processing and Electronics, Karlsruhe, Germany.
%   benedikt.kohout@kit.edu
%                                                                                                      03/2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

function varargout = T_A_C_GUI(varargin)
% T_A_C_GUI M-file for T_A_C_GUI.fig
%      T_A_C_GUI, by itself, creates a new T_A_C_GUI or raises the existing
%      singleton*.
%
%      H = T_A_C_GUI returns the handle to a new T_A_C_GUI or the handle to
%      the existing singleton*.
%
%      T_A_C_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in T_A_C_GUI.M with the given input arguments.
%
%      T_A_C_GUI('Property','Value',...) creates a new T_A_C_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before T_A_C_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to T_A_C_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help T_A_C_GUI

% Last Modified by GUIDE v2.5 23-Apr-2012 14:01:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @T_A_C_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @T_A_C_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before T_A_C_GUI is made visible.
function T_A_C_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to T_A_C_GUI (see VARARGIN)
% Choose default command line output for T_A_C_GUI

handles.output = hObject;

set(hObject,'toolbar','figure');

global currentFileFolder;

% Disable SaveFigure and NewFigure
set(findall(gcf,'tag','Standard.SaveFigure'),'enable','off');
set(findall(gcf,'tag','figMenuFileSave'),'enable','off');
set(findall(gcf,'tag','Standard.NewFigure'),'enable','off');
set(findall(gcf,'tag','figMenuNew'),'enable','off');

% Group radio buttons
set(handles.sphere_buttongroup,'SelectionChangeFcn',@sphere_buttongroup_SelectionChangeFcn);
set(handles.reference_buttongroup,'SelectionChangeFcn',@reference_buttongroup_SelectionChangeFcn);
set(handles.waves_buttongroup,'SelectionChangeFcn',@waves_buttongroup_SelectionChangeFcn);
set(handles.unit_buttongroup,'SelectionChangeFcn',@unit_buttongroup_SelectionChangeFcn);

% Icons for Buttons
if exist('Icons/Fotoaparat_grau.bmp','file') ~= 0
    image_pic = imread('Icons/Fotoaparat_grau.bmp');
    set(handles.save_img_entire_arrangement_button,'cdata',image_pic);           %axes1
    set(handles.save_img_xy_button,'cdata',image_pic);                          %axes2
    set(handles.save_img_rect_patch_button,'cdata',image_pic);                  %axes3
    set(handles.save_img_c_all_vertical_button,'cdata',image_pic);              %axes5
    set(handles.save_img_c_all_horizontal_button,'cdata',image_pic);            %axes6
    set(handles.save_img_transducer_array_surface_button,'cdata',image_pic);    %axes7
    set(handles.save_img_traveling_wave_button,'cdata',image_pic);              %axes9
    set(handles.save_img_frequency_angle_diagram_button,'cdata',image_pic);     %axes10
    set(handles.save_img_pressure_middle_x_axis_button,'cdata',image_pic);      %axes11
    set(handles.save_img_spatial_trans_characteristics_button,'cdata',image_pic); %axes12
end
if exist('Icons/Fotoaparat_grau_all.bmp','file') ~= 0
    image_pic = imread('Icons/Fotoaparat_grau_all.bmp');
    set(handles.save_all_images_button,'cdata',image_pic);                      %save all images
end
if exist('Icons/En_dis_ampl_trans_change.bmp','file') ~= 0
    image_pic = imread('Icons/En_dis_ampl_trans_change.bmp');
    set(handles.en_dis_ampl_trans_change_button,'cdata',image_pic);
end
if exist('Icons/Active_all.bmp','file') ~= 0
    image_pic = imread('Icons/Active_all.bmp');
    set(handles.active_all_button,'cdata',image_pic);
end
if exist('Icons/Inactive_all.bmp','file') ~= 0
    image_pic = imread('Icons/Inactive_all.bmp');
    set(handles.inactive_all_button,'cdata',image_pic);
end
if exist('Icons/Open_input_config.bmp','file') ~= 0
    image_pic = imread('Icons/Open_input_config.bmp');
    set(handles.open_input_signal_config_button,'cdata',image_pic);
end
if exist('Icons/Save_input_config.bmp','file') ~= 0
    image_pic = imread('Icons/Save_input_config.bmp');
    set(handles.save_input_signal_config_button,'cdata',image_pic);
end
if exist('Icons/Open_impedance_characteristic.bmp','file') ~= 0
    image_pic = imread('Icons/Open_impedance_characteristic.bmp');
    set(handles.open_impedance_characteristic_button,'cdata',image_pic);
end
if exist('Icons\Open_attenuation.bmp','file') ~= 0
    image_pic = imread('Icons\Open_attenuation.bmp');
    set(handles.open_attenuation_button,'cdata',image_pic);
end
if exist('Icons/Show_graphic.bmp','file') ~= 0
    image_pic = imread('Icons/Show_graphic.bmp');
    set(handles.impedance_graphic_button,'cdata',image_pic);
    set(handles.attenuation_graphic_button,'cdata',image_pic);
end

% Folder path of currently running function
currentFileFolder = mfilename('fullpath');
currentFileFolder = currentFileFolder(1:(find(currentFileFolder == filesep,1,'last') - 1));
% Create "Graficos" Folder
graficosFolder = sprintf('%s/Graficos',currentFileFolder);
if exist(graficosFolder,'dir') == 0
    % Doesn't exist Folder, I'll create it
    mkdir(graficosFolder);
end   

T_A_C_global_variables_GUI(1);

global c f B fs;
global n_x n_y d_arrspa_x d_arrspa_y Phas_0_x Phas_0_y;
global d_padim_x d_padim_y;

global c0 f0 B0 fs0;
global n_x0 n_y0 d_arrspa_x0 d_arrspa_y0 Phas_0_x0 Phas_0_y0;
global old_n_x old_n_y;
global d_padim_x0 d_padim_y0;

global theta_min theta_max res;

global check_norm;
global en_matrix sel_matrix;
global phase_x_matrix phase_y_matrix;

global type_of_wave;
global type_of_unit;

global fft_points0 fft_points;
global fft_rect_points0 fft_rect_points;
global pulse_width0 pulse_width;

global pathname filename;

global impedance0 impedance;
global u_00 u_0;
global var10 var1;
global var20 var2;
global z_end0 z_end;
global y_end0 y_end;
global x_end0 x_end;
global x_trans_dist_steps0 x_trans_dist_steps;
global y_trans_dist_steps0 y_trans_dist_steps;
global surface_nf0 surface_nf;

global check_impedance_ideal;
global impedance_array;
global check_attenuation_ideal;
global attenuation_array;



theta_min =0;
theta_max=2*pi;
res=pi/50;

c0 = c; 
f0 = f;
B0 = B;
fs0 = fs;
n_x0 = n_x;
n_y0 = n_y;
old_n_x = n_x;
old_n_y = n_y;
d_arrspa_x0 = d_arrspa_x;
d_arrspa_y0 = d_arrspa_y;
Phas_0_x0 = Phas_0_x;
Phas_0_y0 = Phas_0_y;
d_padim_x0 = d_padim_x;
d_padim_y0 = d_padim_y;

pulse_width0 = pulse_width;
fft_points0 = fft_points;
fft_rect_points0 = fft_rect_points;

impedance0 = impedance;
u_00 = u_0;
var10 = var1;
var20 = var2;
z_end0 = z_end;
y_end0 = y_end;
x_end0 = x_end;
x_trans_dist_steps0 = x_trans_dist_steps;
y_trans_dist_steps0 = y_trans_dist_steps;
surface_nf0 = surface_nf;

check_norm = true;
en_matrix = ones(n_y, n_x);
[xx yy] = meshgrid(0:n_x-1, 0:n_y-1);
phase_x_matrix = Phas_0_x0 * xx;
phase_y_matrix = Phas_0_y0 * yy;
sel_matrix = zeros(n_y, n_x);
type_of_wave = 0;
type_of_unit = 0;

pathname = '0';
filename = '0';

set(handles.input_speed_of_sound_edit,'String',num2str(c))
set(handles.input_frequency_edit,'String',num2str(f));
set(handles.input_sample_freq_edit,'String',num2str(fs));

set(handles.input_number_of_x_element_edit,'String',num2str(n_x));
set(handles.input_x_element_spacing_edit,'String',num2str(d_arrspa_x));
set(handles.input_x_phase_shift_edit,'String',num2str(Phas_0_x));

set(handles.input_number_of_y_element_edit,'String',num2str(n_y));
set(handles.input_y_element_spacing_edit,'String',num2str(d_arrspa_y));
set(handles.input_y_phase_shift_edit,'String',num2str(Phas_0_y));

set(handles.input_x_dimensions_edit,'String',num2str(d_padim_x));
set(handles.input_y_dimensions_edit,'String',num2str(d_padim_y));

set(handles.checkbox_normalize,'Value',true);
set(handles.frequency_angle_diagram_button,'enable','off');
set(handles.frequency_angle_diagram_panel,'visible','off');

set(handles.near_field_characteristics_button,'enable','on');
set(handles.near_field_characteristics_panel,'visible','off');

set(handles.en_dis_ampl_trans_change_button,'value', 0);
set(handles.trans_ampl_panel,'visible','off');

% Near field
set(handles.surface_popupmenu,'value', 1);

% Transducer impedance
check_impedance_ideal = true;
impedance_array = -1*ones(1,1);
set(handles.impedance_control_panel,'Visible','on'); 
set(handles.open_impedance_characteristic_button,'Visible','off');
set(handles.impedance_status_text,'Visible','off');
set(handles.impedance_panel,'Visible','off');
set(handles.impedance_status_text,'foregroundcolor', 'black');
set(handles.impedance_status_text,'string', 'No file selected');
set(handles.impedance_status_text,'Visible','off');
set(handles.impedance_graphic_button,'Value',0);
set(handles.impedance_graphic_button,'enable', 'off');
set(handles.impedance_graphic_button,'Visible','off');
set(handles.checkbox_impedance_ideal,'Value',true);

% Attenuation
check_attenuation_ideal = true;
attenuation_array = -1*ones(1,1);
set(handles.attenuation_control_panel,'Visible','on'); 
set(handles.open_attenuation_button,'Visible','off');
set(handles.attenuation_status_text,'Visible','off');
set(handles.attenuation_panel,'Visible','off');
set(handles.attenuation_status_text,'foregroundcolor', 'black');
set(handles.attenuation_status_text,'string', 'No file selected');
set(handles.impedance_status_text,'Visible','off');
set(handles.attenuation_graphic_button,'Value',0);
set(handles.attenuation_graphic_button,'enable', 'off');
set(handles.attenuation_graphic_button,'Visible','off');
set(handles.checkbox_attenuation_ideal,'Value',true);

cla(handles.axes1);
cla(handles.axes2);
cla(handles.axes3);
 
cla(handles.axes5);
cla(handles.axes6);
cla(handles.axes7);

cla(handles.axes9);
cla(handles.axes10);
cla(handles.axes11);
cla(handles.axes12);
cla(handles.axes13);
cla(handles.axes14);

visualize_transducer_array_surfaces(hObject);

guidata(hObject, handles);

% UIWAIT makes T_A_C_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = T_A_C_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
guidata(hObject, handles)


function input_speed_of_sound_edit_Callback(hObject, eventdata, handles)
% hObject    handle to input_speed_of_sound_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of input_speed_of_sound_edit as text
%        str2double(get(hObject,'String')) returns contents of input_speed_of_sound_edit as a double


% --- Executes during object creation, after setting all properties.
function input_speed_of_sound_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_speed_of_sound_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function input_frequency_edit_Callback(hObject, eventdata, handles)
% hObject    handle to input_frequency_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of input_frequency_edit as text
%        str2double(get(hObject,'String')) returns contents of input_frequency_edit as a double


% --- Executes during object creation, after setting all properties.
function input_frequency_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_frequency_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function input_number_of_x_element_edit_Callback(hObject, eventdata, handles)
% hObject    handle to input_number_of_x_element_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of input_number_of_x_element_edit as text
%        str2double(get(hObject,'String')) returns contents of input_number_of_x_element_edit as a double


% --- Executes during object creation, after setting all properties.
function input_number_of_x_element_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_number_of_x_element_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function input_x_element_spacing_edit_Callback(hObject, eventdata, handles)
% hObject    handle to input_x_element_spacing_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of input_x_element_spacing_edit as text
%        str2double(get(hObject,'String')) returns contents of input_x_element_spacing_edit as a double


% --- Executes during object creation, after setting all properties.
function input_x_element_spacing_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_x_element_spacing_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function input_x_phase_shift_edit_Callback(hObject, eventdata, handles)
% hObject    handle to input_x_phase_shift_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_x_phase_shift_edit as text
%        str2double(get(hObject,'String')) returns contents of input_x_phase_shift_edit as a double
%store the contents of input1_editText as a string. if the string
%is not a number then input will be empty
global n_x n_y;
global Phas_0_x;
global phase_x_matrix;

% Get the value
Phas_0_x = str2double(get(handles.input_x_phase_shift_edit,'String'))* (pi/180);

% Udate the phase_x_matrix
[xx yy] = meshgrid(0:n_x-1, 0:n_y-1);
phase_x_matrix = Phas_0_x * xx;

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function input_x_phase_shift_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_x_phase_shift_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function input_number_of_y_element_edit_Callback(hObject, eventdata, handles)
% hObject    handle to input_number_of_y_element_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of input_number_of_y_element_edit as text
%        str2double(get(hObject,'String')) returns contents of input_number_of_y_element_edit as a double


% --- Executes during object creation, after setting all properties.
function input_number_of_y_element_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_number_of_y_element_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function input_y_element_spacing_edit_Callback(hObject, eventdata, handles)
% hObject    handle to input_y_element_spacing_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of input_y_element_spacing_edit as text
%        str2double(get(hObject,'String')) returns contents of input_y_element_spacing_edit as a double


% --- Executes during object creation, after setting all properties.
function input_y_element_spacing_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_y_element_spacing_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function input_y_phase_shift_edit_Callback(hObject, eventdata, handles)
% hObject    handle to input_y_phase_shift_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_y_phase_shift_edit as text
%        str2double(get(hObject,'String')) returns contents of input_y_phase_shift_edit as a double
%store the contents of input1_editText as a string. if the string
%is not a number then input will be empty
global n_x n_y;
global Phas_0_y;
global phase_y_matrix;

% Get the value
Phas_0_y = str2double(get(handles.input_y_phase_shift_edit,'String'))* (pi/180);

% Udate the phase_y_matrix
[xx yy] = meshgrid(0:n_x-1, 0:n_y-1);
phase_y_matrix = Phas_0_y * yy;

%checks to see if input is empty. if so, default input1_editText to zero
% if (isempty(input))
%      set(hObject,'String','0')
% end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function input_y_phase_shift_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_y_phase_shift_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function input_x_dimensions_edit_Callback(hObject, eventdata, handles)
% hObject    handle to input_x_dimensions_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of input_x_dimensions_edit as text
%        str2double(get(hObject,'String')) returns contents of input_x_dimensions_edit as a double


% --- Executes during object creation, after setting all properties.
function input_x_dimensions_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_x_dimensions_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function input_y_dimensions_edit_Callback(hObject, eventdata, handles)
% hObject    handle to input_y_dimensions_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of input_y_dimensions_edit as text
%        str2double(get(hObject,'String')) returns contents of input_y_dimensions_edit as a double


% --- Executes during object creation, after setting all properties.
function input_y_dimensions_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_y_dimensions_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in calc_plot_pushbotton.
function calc_plot_pushbotton_Callback(hObject, eventdata, handles)
% hObject    handle to calc_plot_pushbotton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global c f fs B lambda;
global n_x n_y d_arrspa_x d_arrspa_y Phas_0_x Phas_0_y;
global old_n_x old_n_y;
global d_padim_x d_padim_y;
global res res_2D;
global theta_min theta_max;
global hwb_ref hwb_int hwb_pres;
global pulse_width;
global hwb;

global en_matrix sel_matrix;
global phase_x_matrix phase_y_matrix;
global flag_sel;
global type_of_wave;
global check_norm;
global type_of_unit;
global waves_frec waves_time;
global FREC TIME AMPL POW;

global impedance;
global u_0;
global var1;
global var2;
global var1_axis;
global var2_axis;
global z_end;
global y_end;
global x_end;
global x_trans_dist_steps;
global y_trans_dist_steps;
global surface_nf;

flag_sel = 0;

global n_loop size_waves_frec_x;
global cancel_button;
cancel_button = 0;
error = 0;

global check_impedance_ideal;
global impedance_array;
global check_attenuation_ideal;
global attenuation_array;
global waves_frec_to_calc;

global plane %for use of callbacks...

% Create Waitbar
if exist('wait_bar','var') && ~isempty(wait_bar)
    delete(wait_bar);
end

wait_bar = waitbar(0,'Please wait...','Name','T A C GUI Processing...',...
                    'windowstyle', 'modal',...    
                    'CreateCancelBtn',...
                    {@waitbar_cancel_button, handles});
steps = 8;  % Steps of the waitbar

%%
    dbstop if error

%try

    % Reading of parameters
    c = str2double(get(handles.input_speed_of_sound_edit,'String'));
    f = str2double(get(handles.input_frequency_edit,'String'));
    fs = str2double(get(handles.input_sample_freq_edit,'String'));
    B = str2double(get(handles.input_bw_edit,'String'));

    n_x = str2double(get(handles.input_number_of_x_element_edit,'String'));
    d_arrspa_x = str2double(get(handles.input_x_element_spacing_edit,'String'));
    Phas_0_x = str2double(get(handles.input_x_phase_shift_edit,'String'))* (pi/180);

    n_y = str2double(get(handles.input_number_of_y_element_edit,'String'));
    d_arrspa_y = str2double(get(handles.input_y_element_spacing_edit,'String'));
    Phas_0_y = str2double(get(handles.input_y_phase_shift_edit,'String'))* (pi/180);

    d_padim_x = str2double(get(handles.input_x_dimensions_edit,'String'));
    d_padim_y = str2double(get(handles.input_y_dimensions_edit,'String'));

    % Is the type of wave Rectangular_Pulse?
    if type_of_wave ~= 2
        fft_points = str2double(get(handles.input_fft_points_edit,'String'));
    else
        fft_points = str2double(get(handles.input_rect_fft_points_edit,'String'));    
        pulse_width = str2double(get(handles.input_pulse_width_edit,'String'));
        % Comparation between the fft_points and pulse_with values, if
        % fft_points <= pulse_width means, that there aren't enough fft_points
        % and so the main graphics will be empty.
        if fft_points <= pulse_width
            % Set value: xext power of 2 from length of "pulse_width"
            fft_points = 2^nextpow2(pulse_width);
            % Update the fft_pointa value
            set(handles.input_rect_fft_points_edit,'String', fft_points);
        end
    end

    %%%%%check element dimensions and spacing%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (d_arrspa_x - d_padim_x) <= eps && n_x > 1
        set(handles.input_x_element_spacing_edit,'BackgroundColor',[1 0 0]);
        set(handles.input_x_dimensions_edit,'BackgroundColor',[1 0 0]);
        set(handles.output_alarm_warning_edit,'visible','on');
        set(handles.output_alarm_warning_edit,'String','! Single patch elements may touch !');
        error = error + 1;
    else
        set(handles.input_x_element_spacing_edit,'BackgroundColor',[1 1 1]);
        set(handles.input_x_dimensions_edit,'BackgroundColor',[1 1 1]);
    end   

    if (d_arrspa_y - d_padim_y) <= eps && n_y > 1
        set(handles.input_y_element_spacing_edit,'BackgroundColor',[1 0 0]);
        set(handles.input_y_dimensions_edit,'BackgroundColor',[1 0 0]);
        set(handles.output_alarm_warning_edit,'visible','on');
        set(handles.output_alarm_warning_edit,'String','! Single Patch elements may touch !');
        error = error + 1;
    else
        set(handles.input_y_element_spacing_edit,'BackgroundColor',[1 1 1]);
        set(handles.input_y_dimensions_edit,'BackgroundColor',[1 1 1]);
    end  

    if (d_arrspa_x - d_padim_x) > eps && (d_arrspa_y - d_padim_y) > eps && n_x >0 && n_y >0 && error == 0 
        set(handles.output_alarm_warning_edit,'visible','off')
    end

    % Waitbar Update
    waitbar(1/steps,wait_bar,'Checking errors...');

    %%%%%check element number%%%%%%%%%%%%%%%%%%%%%%%%%%
    if n_x <= 0
        set(handles.input_number_of_x_element_edit,'BackgroundColor',[1 0 0]);
        set(handles.output_alarm_warning_edit,'visible','on');
        set(handles.output_alarm_warning_edit,'String','! # of x elements <= 0 !') ;
        error = error + 1;
    else
        set(handles.input_number_of_x_element_edit,'BackgroundColor',[1 1 1])
    end   

    if n_y <= 0
        set(handles.input_number_of_y_element_edit,'BackgroundColor',[1 0 0])
        set(handles.output_alarm_warning_edit,'visible','on')
        set(handles.output_alarm_warning_edit,'String','! # of y elements <= 0 !')
        error = error + 1;
    else
        set(handles.input_number_of_y_element_edit,'BackgroundColor',[1 1 1])
    end   

    if n_x >0 && n_y >0 && (d_arrspa_x - d_padim_x) > eps && (d_arrspa_y - d_padim_y) > eps && error == 0
        set(handles.output_alarm_warning_edit,'visible','off')
    end

    %%%%%check change in numbers of X and Y elements%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (old_n_x ~= n_x) || (old_n_y ~= n_y)
        en_matrix = ones(n_y, n_x);
        [xx yy] = meshgrid(0:n_x-1, 0:n_y-1);
        phase_x_matrix = Phas_0_x * xx;
        phase_y_matrix = Phas_0_y * yy;
        old_n_x = n_x;
        old_n_y = n_y;    
    end
    % Reset transducer selected matrix
    sel_matrix = zeros(size(en_matrix));

    % Check if there are errors
    if error == 0
        %%%% sphericial 2 cartesian %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%Visualisierung Transducer Array%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        visualize_transducer_array_surfaces(hObject);
        %%end Visualisierung%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

        % Waitbar Update
        waitbar(2/steps,wait_bar,'Generating input signal...');

        %Disable Frequency-Angle Diagram Panel and Button
        if strcmp(get(handles.near_field_characteristics_panel,'visible'),'off')
            set(handles.frequency_angle_diagram_panel,'visible','off');
            set(handles.frequency_angle_diagram_button,'value',0);
            pause(0.01);
            set(handles.axes3,'visible','on');
            set(allchild(handles.axes3),'visible','on');
            set(handles.save_img_rect_patch_button,'visible','on');
        end

        % Is the ideal impedance of transducer active?
        if check_impedance_ideal == false
            % Check errors
            if length(impedance_array) ~= 1 && impedance_array(1) ~= -1
                % If Checkbox "Adjust steps" is checked
                if get(handles.checkbox_adjust_steps, 'value') == 1
                    % Set the input signal parameter
                    impedance_array_step = impedance_array(FREC,2) - impedance_array(FREC,1);
                    fft_points = 2*(length(impedance_array(FREC,length(impedance_array(FREC,:))):-impedance_array_step:0)+1);            
                    fs = impedance_array_step * fft_points;
                end
                % If no errors...
                set(handles.output_alarm_warning_edit,'visible','off');
            else
                % If errors... Set alarma warning
                set(handles.output_alarm_warning_edit,'visible','on');
                set(handles.output_alarm_warning_edit,'String','! Impedance file error !');
                cancel_button = 1;
            end        
        end

        % Is the attenuation of signal active?
        if check_attenuation_ideal == false
            % Check errors
            if length(attenuation_array) ~= 1 && attenuation_array(1) ~= -1
                % If no errors...
                set(handles.output_alarm_warning_edit,'visible','off');
            else
                % If errors... Set alarma warning
                set(handles.output_alarm_warning_edit,'visible','on');
                set(handles.output_alarm_warning_edit,'String','! Attenuation file error !');
                cancel_button = 1;
            end    
        end    

        % Has someone pushed the cancel button? Are there errors?    
        if cancel_button == 0
            % Input Signal
            use_fft = 1;
            switch type_of_wave
                case 0    % Sine %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    f_0 = f;             % Signal Frequence
                    T = 1/f_0;           % Signal Periode
                    f_s = fs;            % Sampling Frequency

                    % Check the fft_points
                    if rem(f_0,(f_s/fft_points)) ~= 0
                        if rem(f_s,f_0) == 0;
                            fft_points = f_s/f_0;
                            set(handles.input_fft_points_edit,'String',fft_points);
                        else
                            fft_points = 100;
                            f_s = f_0 * fft_points;
                            fs = f_s;
                            set(handles.input_sample_freq_edit,'String',f_s);
                        end
                    end

                    T_s = 1/f_s;         % Sample Time
                    L_s = round(2*T*f_s);     % Length of time signal = 2 T
                    time = (0:L_s-1) * T_s;     % Time vector                

                    % Time signal
                    signal_time = sin(2*pi*f_0*time);
                    % Frequency
                    frec = 0:f_s/fft_points:((f_s/2)-(f_s/fft_points));    
                    %frec = round(0:f_s/fft_points:((f_s/2)-(f_s/fft_points))); 

                    signal_frec = abs(fft(signal_time, fft_points)/L_s);  % Normalize
                    signal_frec = signal_frec(frec < f_s/2);
                    signal_frec = signal_frec + [0 signal_frec(2:length(signal_frec))];

                    % for Plotting
                    waves_time = zeros(2, length(time));
                    waves_time(TIME,:) = time;
                    waves_time(AMPL,:) = signal_time;        
                    waves_frec = zeros(2, length(frec));
                    waves_frec(FREC,:) = frec;
                    waves_frec(AMPL,:) = signal_frec; 
                    % If the sine frequency in the frequency component array...
                    frec_aux = find(waves_frec(FREC,:) == f_0);
                    if size(frec_aux)
                        waves_frec(AMPL,:) = 0;
                        waves_frec(AMPL,frec_aux) = 1;
                        use_fft = 0;
                    end                

                case 1    % Pulse %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    f_0 = f;             % Signal Frequence (Middle)
                    f_s = fs;         % Sampling Frequency
                    cutofffreq=0.001;
                    bwwidthfactor=1000;
                    integralenergy=0.99;
                    
                    if 4*B+f_0>f_s 
                        f_s=4*B+f_0; 
                        disp('Warning: guessing F_s');
                    end                    
                    
                    pulseLength = (2/B*f_s);
                    T = pulseLength/f_s; % Signal Periode
                    L_s = round(pulseLength*2);     % Length of time signal = 2 T
                    t = 0:T/pulseLength:T*(1-1/pulseLength);     % Time vector

                    % Time signal
                    signal_time = sin(pi*t/T) .* sin(2*pi*t*f_0);   % Pulsform Calculation
                    
                    %%%analyse
                    temp=(fft(signal_time,length(signal_time)*100));
                    idx=find(abs(temp)>(cutofffreq*max(abs(temp))));
                    frec = 0:f_s/(length(temp)-1):f_s;
                    idx(idx>length(temp)/2)=[];
                    idx=min(idx+1,length(temp)/2);
                    
                    energ=0;
                    maxenerg=sum(abs(temp(1:length(temp)/2)))*integralenergy;
                    i=0;
                    while i<=ceil(length(temp)/2)
                        i=i+1;
                        energ=energ+abs(temp(i));
                        if energ>= maxenerg
                            idx2=i;
                            break;
                        end
                    end
                    f_s=2*frec(max(idx(end),idx2));
                          
                    %%%second try with new FS
                    pulseLength = (2/B*f_s);
                    T = pulseLength/f_s; % Signal Periode
                    L_s = ceil(pulseLength*2);     % Length of time signal = 2 T
                    t = 0:T/pulseLength:T*(1-1/pulseLength);     % Time vector

                    % Time signal
                    signal_time = sin(pi*t/T) .* sin(2*pi*t*f_0);   % Pulsform Calculation
                    signal_time = [signal_time zeros(1, L_s-length(signal_time))];     % Zero Padding
                    
                    %Eliminate DC Component
                    dc_component = (sum(sum(signal_time))/length(signal_time)) * ones(size(signal_time));
                    signal_time = signal_time - dc_component;
                    time = (0:length(signal_time)-1).* 1/f_s;        % Abtastintervall-Zeit

                    % Frequency signal
                    frec = 0:f_s/fft_points:((f_s/2)-(f_s/fft_points));
                    signal_frec = abs(fft(signal_time, fft_points)/L_s);  % Normalize
                    signal_frec = signal_frec(frec < f_s/2);
                    signal_frec = signal_frec + [0 signal_frec(2:length(signal_frec))];

                    % for Plotting
                    waves_time = zeros(2, length(time));
                    waves_time(TIME,:) = time;
                    waves_time(AMPL,:) = signal_time;        
                    waves_frec = zeros(2, length(frec));
                    waves_frec(FREC,:) = frec;
                    waves_frec(AMPL,:) = signal_frec;  

                case 2    % Rectangular wave %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % The Sample Frequency can be:
                    %       1. 1GHz   -> t_s = 1ns
                    %       2. 100MHz -> t_s = 10ns
                    %       3. 10MHz  -> t_s = 100ns                
                    %       4. fs     -> When the steps are adjusted between 
                    %                    input and impedance signals
                    if check_impedance_ideal == 1 || get(handles.checkbox_adjust_steps, 'value') == 0
                        % Check of base time
                        if strcmp(get(handles.pulse_width_base_time_text, 'string'), 'ns') == 1
                            f_s = 1e9;
                        else
                            if strcmp(get(handles.pulse_width_base_time_text, 'string'), 'x 10ns') == 1
                                f_s = 100e6;
                            else
                                if strcmp(get(handles.pulse_width_base_time_text, 'string'), 'x 100ns') == 1
                                    f_s = 10e6;       
                                end
                            end
                        end
                    else
                        f_s = fs;
                    end

                    %Time
                    signal_time = [ones(1,pulse_width) zeros(1,pulse_width)];
   
                    %Eliminate DC Component
                    dc_component = (sum(sum(signal_time))/length(signal_time)) * ones(size(signal_time));
                    signal_time = signal_time - dc_component;            
                    L_s = length(signal_time);
                    time = (0:L_s-1) / f_s;

                    %Frequency
                    frec = 0:f_s/fft_points:((f_s/2)-(f_s/fft_points));
                    signal_frec = abs(fft(signal_time, fft_points)/L_s);  % Normalize
                    signal_frec = signal_frec(frec < f_s/2);
                    signal_frec = signal_frec + [0 signal_frec(2:length(signal_frec))];

                    % for Plotting
                    waves_time = zeros(2, length(time));
                    waves_time(TIME,:) = time;
                    waves_time(AMPL,:) = signal_time;        
                    waves_frec = zeros(2, length(frec));
                    waves_frec(FREC,:) = frec;
                    waves_frec(AMPL,:) = signal_frec;

                case 3    % Other wave %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %Check Filename
                    aux_string = get(handles.open_file_edit,'String');
                    if (length(aux_string) <= 4) || (strcmp(aux_string, 'No file selected...'))
                        set(handles.open_file_edit, 'String', 'No file selected...');
                        % Set alarm
                        set(handles.output_alarm_warning_edit,'visible','on')
                        set(handles.output_alarm_warning_edit,'String','No file selected !')
                        error = error + 1;   
                      waves_frec(AMPL,:) = signal_frec;
                     end               
             end

            % Check errors und enable/disble Frequency-Angle Diagram button
            if error > 0
                cancel_button = 1;
                % Waitbar Update
                waitbar(2/steps,wait_bar, 'Canceling...');
                % Disable Frequency-Angle Diagram Button
                set(handles.frequency_angle_diagram_button,'enable','off');           
            else
                % Plot input signal (time or frequency)
                 if type_of_unit == 0
                    DrawWaveForm(type_of_unit,waves_time(:,:),handles);
                 else
                    DrawWaveForm(type_of_unit,waves_frec(:,:),handles);
                 end              
            end   

            % Multiply impendace array with signal array in frequency unit
            waves_frec_to_calc = waves_frec;
            if check_impedance_ideal == 0
                % Calculation of amplitude of impedance array
               % new_imp_amplitude = abs(((impedance_array(POW,:)-min(impedance_array(POW,:)))./max((impedance_array(POW,:)-min(impedance_array(POW,:)))))-1);
               new_imp_amplitude = ((impedance_array(POW,:)-min(impedance_array(POW,:)))./max((impedance_array(POW,:)-min(impedance_array(POW,:)))));

                % Interpolation
                aux_impedance_ampl = interp1(impedance_array(FREC,:),new_imp_amplitude,waves_frec_to_calc(FREC,:),'pchip',0); 
                aux_impedance_ampl(isnan(aux_impedance_ampl)) = 0;  
                aux_impedance_ampl =  aux_impedance_ampl/max( aux_impedance_ampl);

                % Set the new amplitude of input signal
                waves_frec_to_calc(AMPL,:) = waves_frec_to_calc(AMPL,:).* aux_impedance_ampl;
                % Plot?
                if type_of_unit == 1
                    hold on;
                    plot(waves_frec_to_calc(FREC,:), waves_frec_to_calc(AMPL,:), 'r');
                    hold off;
                end            
            end

            % Is the attenuation of signal active?
            if check_attenuation_ideal == false
                % Interpolation            
                aux_attenuation_ampl = interp1(attenuation_array(FREC,:),attenuation_array(AMPL,:),waves_frec_to_calc(FREC,:),'pchip',0); 
                aux_attenuation_ampl(isnan(aux_attenuation_ampl) == 1) = 0;
                % Copy data in array
                attenuation = [waves_frec_to_calc(FREC,:); aux_attenuation_ampl];
            else
               attenuation = zeros(2,length(waves_frec_to_calc)); 
            end         

        else
            % Waitbar Update
            waitbar(2/steps,wait_bar, 'Canceling...');
            pause(1);
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % What does the program calculate? WITH or WITHOUT approximation?
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if strcmp(get(handles.near_field_characteristics_panel,'visible'),'off')           
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % If the program must calculate WITH approximation, it will take this way 
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
            % Has someone pushed the cancel button?
            if cancel_button == 0

                % Waitbar Update
                waitbar(3/steps,wait_bar,'Calculating acoustic pattern...');

                %some resets
                C_all = 0;
                F_Gr_xy = 0;
                F_Gr_rect = 0;

                [size_waves_frec_x] = size(waves_frec_to_calc, 2);
                [theta phi] = meshgrid(theta_min : res : theta_max, 0 : res: 2*pi);

                % Calculate pattern acustic GUI for all frenquency %%%%%%%%%%%%%%%%
                if use_fft == 1
                    % Frecuency loop
                    n_loop = 2;
                    %n_loop = 1;
                    while n_loop <= size_waves_frec_x
                        f = waves_frec_to_calc(FREC, n_loop);
                        [C_all_aux F_Gr_xy_aux F_Gr_rect_aux F_mono_aux] = calculate_pattern_acoustic_GUI(theta,phi);
                        C_all = C_all +  C_all_aux .*(waves_frec_to_calc(AMPL, n_loop));
                        F_Gr_xy = F_Gr_xy +  F_Gr_xy_aux.* (waves_frec_to_calc(AMPL, n_loop));
                        F_Gr_rect = F_Gr_rect + F_Gr_rect_aux.* (waves_frec_to_calc(AMPL, n_loop));
                        
                        % Waitbar Update
                        waitbar((3 + n_loop/size_waves_frec_x)/steps,wait_bar);
                        n_loop = n_loop + 1;
                    end
                else
                    % When the type of wave is a Sine (to do that faster!)
                    [C_all F_Gr_xy F_Gr_rect F_mono] = calculate_pattern_acoustic_GUI(theta,phi);
                end
            else
                % Waitbar Update
                waitbar(3/steps,wait_bar, 'Canceling...');
                pause(1);
            end

            if cancel_button == 0
                % Waitbar Update
                waitbar(4/steps,wait_bar,'Plotting graphics...');

                %Normalize
                if check_norm == false
                    Max_value = 1;
                else %check_norm == true or init = []
                    MAX = sort(max(C_all),'descend'); 
                    if isnan(MAX(1,1))
                        Max_value = MAX(1,2); 
                    else
                        Max_value = MAX(1,1); 
                    end
                end       
                C_all = abs(C_all./Max_value); 

                % Waitbar Update
                waitbar(5/steps,wait_bar,'Calculating and plotting transducer array in 3D...');

                X_C_all = C_all .* cos(phi) .* sin(theta);
                Y_C_all = C_all .* sin(phi) .* sin(theta);
                Z_C_all = C_all .* cos(theta);

                X_F_Gr_xy = F_Gr_xy .* cos(phi) .* sin(theta);
                Y_F_Gr_xy = F_Gr_xy .* sin(phi) .* sin(theta);
                Z_F_Gr_xy = F_Gr_xy .* cos(theta);

                X_F_Gr_rect = F_Gr_rect .* cos(phi) .* sin(theta);
                Y_F_Gr_rect = F_Gr_rect .* sin(phi) .* sin(theta);
                Z_F_Gr_rect = F_Gr_rect .* cos(theta);

                %3D-Plot
                %figure (111)
                axes(handles.axes1)
                surf(real(X_C_all), real(Y_C_all), real(Z_C_all));
                %hold on
                %mesh (4*xx,4*yy,4*zz)
                h=surf(real(X_C_all), real(Y_C_all), real(Z_C_all));
                set(h,'EdgeAlpha',0.3);
                axis equal
                title('Directivity pattern of entire arrangement') %not normed
                xlabel('x');ylabel('y');zlabel('z');

                axes(handles.axes2)
                surf(real(X_F_Gr_xy), real(Y_F_Gr_xy), real(Z_F_Gr_xy));
                %hold on
                %mesh (4*xx,4*yy,4*zz)
                h=surf(real(X_F_Gr_xy), real(Y_F_Gr_xy), real(Z_F_Gr_xy));
                set(h,'EdgeAlpha',0.3);
                axis equal
                title('Directivity pattern XY-ARRAY (= grouping)') %not normed
                xlabel('x');ylabel('y');zlabel('z');

                axes(handles.axes3)
                surf(real(X_F_Gr_rect), real(Y_F_Gr_rect), real(Z_F_Gr_rect));
                % hold on
                % mesh (xx,yy,zz)
                h=surf(real(X_F_Gr_rect), real(Y_F_Gr_rect), real(Z_F_Gr_rect));
                set(h,'EdgeAlpha',0.3);
                axis equal
                title('Directivity pattern RECT. PATCH (= surface of single element)') %not normed
                xlabel('x');ylabel('y');zlabel('z');

                guidata(hObject, handles); %updates the handles            
            else
                % Waitbar Update
                waitbar(5/steps,wait_bar,'Canceling...');
                pause(1);
            end
            % Waitbar Update
            waitbar(6/steps,wait_bar,'Calculating transducer array in 2D...');

            % Calculate transducer array 2D acoustic %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Has someone pushed the cancel button?
            if cancel_button == 0 
                C_ALL = 0;
                RECT = 0;
                GRUPPE_XY = 0;
                AK_MONOPOL = 0;
                flag = 1;

                if use_fft == 1
                    % Frecuency loop
                    n_loop = 2;
                    %n_loop = 1;
                    while n_loop <= size_waves_frec_x
                        f = waves_frec_to_calc(FREC, n_loop);
                        [C_ALL_aux RECT_aux GRUPPE_XY_aux AK_MONOPOL_aux] = calculate_transducer_array_2D_acoustic;                               

                        if flag == 0
                            C_ALL(:,2) = C_ALL(:,2) + (waves_frec_to_calc(AMPL, n_loop) .* C_ALL_aux(:,2));
                            C_ALL(:,3) = C_ALL(:,3) + (waves_frec_to_calc(AMPL, n_loop) .* C_ALL_aux(:,3));
                            C_ALL(:,5) = C_ALL(:,5) + (waves_frec_to_calc(AMPL, n_loop) .* C_ALL_aux(:,5));
                            C_ALL(:,6) = C_ALL(:,6) + (waves_frec_to_calc(AMPL, n_loop) .* C_ALL_aux(:,6));
                            RECT(:,2) = RECT(:,2) + RECT_aux(:,2);
                            RECT(:,3) = RECT(:,3) + RECT_aux(:,3);    
                            RECT(:,5) = RECT(:,6) + RECT_aux(:,5);
                            RECT(:,6) = RECT(:,6) + RECT_aux(:,6);
                            GRUPPE_XY(:,2) = GRUPPE_XY(:,2) + (waves_frec_to_calc(AMPL, n_loop) .* GRUPPE_XY_aux(:,2));
                            GRUPPE_XY(:,3) = GRUPPE_XY(:,3) + (waves_frec_to_calc(AMPL, n_loop) .* GRUPPE_XY_aux(:,3));
                            GRUPPE_XY(:,5) = GRUPPE_XY(:,5) + (waves_frec_to_calc(AMPL, n_loop) .* GRUPPE_XY_aux(:,5));
                            GRUPPE_XY(:,6) = GRUPPE_XY(:,6) + (waves_frec_to_calc(AMPL, n_loop) .* GRUPPE_XY_aux(:,6));
                            % To do the Frequency-Angle Diagram graphic
                            C_ALL_graphic(n_loop,:) = C_ALL_aux(:,3) .* waves_frec_to_calc(AMPL, n_loop);
                        else
                            % First loop
                            C_ALL = C_ALL_aux;
                            RECT = RECT_aux;
                            GRUPPE_XY = GRUPPE_XY_aux;
                            AK_MONOPOL = AK_MONOPOL_aux;
                            flag = 0;
                            C_ALL_graphic = zeros(size_waves_frec_x, length(C_ALL_aux(:,3)));
                        end
                        % Waitbar Update        
                        waitbar((6 + n_loop/size_waves_frec_x)/steps,wait_bar);
                        n_loop = n_loop + 1;
                    end           
                else
                    % When the signal is Sine I do it to get faster
                    [C_ALL RECT GRUPPE_XY AK_MONOPOL] = calculate_transducer_array_2D_acoustic;
                    % Sine Frequency-Angle Diagram
                    C_ALL_graphic = zeros(size_waves_frec_x,length(C_ALL(:,3)));
                    C_ALL_graphic(find(waves_frec_to_calc(FREC,:) == f_0),:) = C_ALL(:,3) .* waves_frec_to_calc(AMPL, find(waves_frec_to_calc(FREC,:) == f_0));
                end       

                % Waitbar Update
                waitbar(7/steps,wait_bar,'Calculating and plotting Frequency-Angle Diagram...');

                % Frequency-Angle Diagram Plot
                axes(handles.axes10);
                %Ask for the angle range of theta
                if theta_min*180/pi == 0
                    %Full sphere 360°
                    imagesc((theta_min/2*180/pi)-90:res_2D*180/pi:(theta_max/2*180/pi)-90, waves_frec_to_calc(FREC,:),abs(C_ALL_graphic(:,round(length(C_ALL_graphic)*1/4-1:length(C_ALL_graphic)*3/4)-1)));
                else
                    %Semi sphere 180°
                    imagesc(theta_min*180/pi:res_2D*180/pi:(theta_max*180/pi), waves_frec_to_calc(FREC,:),abs(C_ALL_graphic(:,round(1:round(length(C_ALL_graphic)/2)))));
                end    
                xlabel('Angle [Grad]');ylabel('Frequency [Hz]');
                title('Simulation of frequency and angle dependent pressure');
                colorbar('location','EastOutside');
                %Enable Frequency-Angle Diagram Button
                set(handles.frequency_angle_diagram_button,'enable','on');
            else
                % Waitbar Update
                waitbar(7/steps,wait_bar,'Canceling...');
                pause(1);
            end

            % Has someone pushed the cancel button?
            if cancel_button == 0
                % Waitbar Update
                waitbar(7/steps,wait_bar,'Plotting transducer array in 2D...');       

                % Normalize
                %Rectangular Patch
                RECT(:,3) = RECT(:,2) ./ max(RECT(:,2));
                RECT(:,6) = RECT(:,5) ./ max(RECT(:,5));
                % grouping-factor XY
                %vertikal
                GRUPPE_XY(:,3) = GRUPPE_XY(:,2)./ max(GRUPPE_XY(:,2));
                %horizontal
                GRUPPE_XY(:,6) = GRUPPE_XY(:,5)./ max(GRUPPE_XY(:,5));
                %All
                C_ALL(:,3) = C_ALL(:,2)./max(C_ALL(:,2)); %normiert
                C_ALL(:,6) = C_ALL(:,5)./max(C_ALL(:,5)); %normiert

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %[C_ALL RECT GRUPPE_XY AK_MONOPOL hwb_int hwb_pres] = calculate_transducer_array_2D_acoustic_GUI ; 

                % [C_ALL ] = calculate_transducer_array_2D_acoustic_GUI ;
                % [tmp RECT ] = calculate_transducer_array_2D_acoustic_GUI ;
                % [tmp tmp GRUPPE_XY ] = calculate_transducer_array_2D_acoustic_GUI ;
                % [tmp tmp tmp AK_MONOPOL] = calculate_transducer_array_2D_acoustic_GUI ;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                % Plot Vertical
                axes(handles.axes5)
                polar(C_ALL(:,1), AK_MONOPOL(:,2),'c--')
                hold on
                polar(C_ALL(:,1),RECT(:,3),'g')
                hold on
                polar(real(C_ALL(:,1)),real(GRUPPE_XY(:,3)),'b')
                hold on
                h=polar(real(C_ALL(:,1)),real(C_ALL(:,3))); 
                view(90,-90)

                hold off
                title(sprintf('Directivity pattern C_{all} vertical (phi = azimuth = 0°)\n'))  
                set(h,'color','r','linewidth',1);

                % Plot Vertical
                axes(handles.axes6)
                polar(real(C_ALL(:,4)), real(AK_MONOPOL(:,4)),'c--')
                hold on
                polar(real(C_ALL(:,4)),real(RECT(:,6)),'g')
                hold on
                polar(real(C_ALL(:,4)),real(GRUPPE_XY(:,6)),'b')
                hold on
                h=polar(real(C_ALL(:,4)),real(C_ALL(:,6)));
                view(-90,90)

                %legend('FGR_y horizontal')
                hold off
                %legend('Rect(patch)','XY(array)','gesamt','MONOPOL')
                title(sprintf('Directivity pattern C_{all} horizontal (theta = elevation = 90°)\n'))
                set(h,'color','r','linewidth',1);        

                % Full width at half maximum = Halbwertsbreite
                [hwb_int hwb_pres] = calculate_half_power_Beamwidth(C_ALL);
                %global hwb;
                if hwb_ref == true;
                    hwb = hwb_int;
                end
                if hwb_ref == false;
                    hwb = hwb_pres;
                end
                % Halbwertsbreite update
                set(handles.output_halbwertsbreite_edit,'String',num2str(hwb))
            else
                % Waitbar Update
                waitbar(7/steps,wait_bar,'Canceling...');
                pause(1);
            end
        else
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % If the program must calculate WITHOUT approximation, it will take this way
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
            % Has someone pushed the cancel button?
            if cancel_button == 0
                % Waitbar Update  
                waitbar(3/steps,wait_bar,'Check errors in input parameters...');
                % Check the inputs parameters
                error = 0;
                lambda = c/f;
                impedance = str2double(get(handles.input_impedance_edit,'String'));
                if impedance <= 0;
                    set(handles.input_impedance_edit,'BackgroundColor',[1 0 0]);
                    set(handles.output_alarm_warning_edit,'visible','on');
                    set(handles.output_alarm_warning_edit,'String','! Impedance <= 0 !');
                    error = error + 1;
                else
                    set(handles.input_impedance_edit,'BackgroundColor',[1 1 1]);
                end
                u_0 = str2double(get(handles.input_u_0_edit,'String'));
                if u_0 <= 0;
                    set(handles.input_u_0_edit,'BackgroundColor',[1 0 0]);
                    set(handles.output_alarm_warning_edit,'visible','on');
                    set(handles.output_alarm_warning_edit,'String','! u_0 <= 0 !');
                    error = error + 1;
                else
                    set(handles.input_u_0_edit,'BackgroundColor',[1 1 1]);
                end
                surface_nf = get(handles.surface_popupmenu,'value');
                if surface_nf <= 0 || surface_nf > 3
                    set(handles.surface_popupmenu,'BackgroundColor',[1 0 0]);
                    set(handles.output_alarm_warning_edit,'visible','on');
                    set(handles.output_alarm_warning_edit,'String','! Surface out of range !');
                    error = error + 1;
                else
                    set(handles.surface_popupmenu,'BackgroundColor',[1 1 1]);
                end
                var1 = str2double(get(handles.input_var1_steps_edit,'String'));
                if var1 <= 0;
                    set(handles.input_var1_steps_edit,'BackgroundColor',[1 0 0]);
                    set(handles.output_alarm_warning_edit,'visible','on');
                    set(handles.output_alarm_warning_edit,'String','! Steps of Var1 distance <= 0 !');
                    error = error + 1;
                else
                    set(handles.input_var1_steps_edit,'BackgroundColor',[1 1 1]);                
                end
                x_end = str2double(get(handles.input_x_end_edit,'String'));
                if strcmp(get(handles.unit_x_distance_from_observer_text, 'string'), 'lambda') == 1
                    % If the unit is "lambda", it is converted to "m"
                    x_end = x_end * lambda;
                end
                % Check "x_end" value
                if (x_end <=  0 && surface_nf == 1)                 % Surface X-Z
                    set(handles.input_x_end_edit,'BackgroundColor',[1 0 0]);
                    set(handles.output_alarm_warning_edit,'visible','on');
                    set(handles.output_alarm_warning_edit,'String','! X must be greater than 0 !');
                    error = error + 1;
                else
                    set(handles.input_x_end_edit,'BackgroundColor',[1 1 1]);            
                end
                if (x_end <=  0 && surface_nf == 3)                 % Surface X-Y
                    set(handles.input_x_end_edit,'BackgroundColor',[1 0 0]);
                    set(handles.output_alarm_warning_edit,'visible','on');
                    set(handles.output_alarm_warning_edit,'String','! X must be greater than 0 !');
                    error = error + 1;
                else
                    set(handles.input_x_end_edit,'BackgroundColor',[1 1 1]);            
                end
                y_end = str2double(get(handles.input_y_end_edit,'String'));
                if strcmp(get(handles.unit_y_distance_from_observer_text, 'string'), 'lambda') == 1
                    % If the unit is "lambda", it is converted to "m"
                    y_end = y_end * lambda;
                end
                % Check "y_end" value
                if (y_end <= 0 && surface_nf == 2)                   % Surface Y-Z
                    set(handles.input_y_end_edit,'BackgroundColor',[1 0 0]);
                    set(handles.output_alarm_warning_edit,'visible','on');
                    set(handles.output_alarm_warning_edit,'String','! Y must be greater than 0 !');
                    error = error + 1;
                else
                    set(handles.input_y_end_edit,'BackgroundColor',[1 1 1]);            
                end             
                if (y_end <= 0 && surface_nf == 3)                   % Surface X-Y
                    set(handles.input_y_end_edit,'BackgroundColor',[1 0 0]);
                    set(handles.output_alarm_warning_edit,'visible','on');
                    set(handles.output_alarm_warning_edit,'String','! Y must be greater than 0 !');
                    error = error + 1;
                else
                    set(handles.input_y_end_edit,'BackgroundColor',[1 1 1]);            
                end            
                var2 = str2double(get(handles.input_var2_steps_edit,'String'));
                if var2 < 0;
                    set(handles.input_var2_steps_edit,'BackgroundColor',[1 0 0]);
                    set(handles.output_alarm_warning_edit,'visible','on');
                    set(handles.output_alarm_warning_edit,'String','! Steps of Var2 distance <= 0 !');
                    error = error + 1;
                else
                    set(handles.input_var2_steps_edit,'BackgroundColor',[1 1 1]);            
                end
                z_end = str2double(get(handles.input_z_end_edit,'String'));
                if strcmp(get(handles.unit_z_distance_from_observer_text, 'string'), 'lambda') == 1
                    % If the unit is "lambda", it is converted to "m"
                    z_end = z_end * lambda;
                end 
                % Check "z_end" value
                if (z_end <= 0 && surface_nf == 1)                  % Surface X-Z
                    set(handles.input_z_end_edit,'BackgroundColor',[1 0 0]);
                    set(handles.output_alarm_warning_edit,'visible','on');
                    set(handles.output_alarm_warning_edit,'String','! Z must be greater than 0 !');                 
                    error = error + 1;
                else
                    set(handles.input_z_end_edit,'BackgroundColor',[1 1 1]);            
                end
                if (z_end <= 0 && surface_nf == 2)                  % Surface Y-Z
                    set(handles.input_z_end_edit,'BackgroundColor',[1 0 0]);
                    set(handles.output_alarm_warning_edit,'visible','on');
                    set(handles.output_alarm_warning_edit,'String','! Z must be greater than 0 !');                 
                    error = error + 1;
                else
                    set(handles.input_z_end_edit,'BackgroundColor',[1 1 1]);            
                end
                if (z_end < 0 && surface_nf == 3)                  % Surface X-Y
                    set(handles.input_z_end_edit,'BackgroundColor',[1 0 0]);
                    set(handles.output_alarm_warning_edit,'visible','on');
                    set(handles.output_alarm_warning_edit,'String','! Z must be positive !');                 
                    error = error + 1;
                else
                    set(handles.input_z_end_edit,'BackgroundColor',[1 1 1]);            
                end             
                x_trans_dist_steps = str2double(get(handles.input_x_rect_patch_dim_steps_edit,'String'));                     
                if x_trans_dist_steps < 0;
                    set(handles.input_x_rect_patch_dim_steps_edit,'BackgroundColor',[1 0 0]);
                    set(handles.output_alarm_warning_edit,'visible','on');
                    set(handles.output_alarm_warning_edit,'String','! Steps of X rect. patch dim. <= 0 !');                                 
                    error = error + 1;
                else
                    set(handles.input_x_rect_patch_dim_steps_edit,'BackgroundColor',[1 1 1]);            
                end
                y_trans_dist_steps = str2double(get(handles.input_y_rect_patch_dim_steps_edit,'String'));                     
                if y_trans_dist_steps < 0;
                    set(handles.input_y_rect_patch_dim_steps_edit,'BackgroundColor',[1 0 0]);
                    set(handles.output_alarm_warning_edit,'visible','on');
                    set(handles.output_alarm_warning_edit,'String','! Steps of Y rect. patch dim. <= 0 !');
                    error = error + 1;
                else
                    set(handles.input_y_rect_patch_dim_steps_edit,'BackgroundColor',[1 1 1]);            
                end

                % Are there some errors?
                if error == 0
                    % Visible off the arlarm warning
                    set(handles.output_alarm_warning_edit,'visible','off')
                    % Waitbar Update
                    waitbar(4/steps,wait_bar,'Calculating spatial characteristics...');

                    % Main function of Calculation WITHOUT approximation
                    [var1_axis var2_axis plane elapsed_time] = Soundfield_without_approx(waves_frec_to_calc, attenuation, wait_bar);
         
                    if cancel_button == 0
                        % Update of proceess time
                        set(handles.proc_time, 'String', sprintf('processing time [min]: %f', elapsed_time/60));

                        % Waitbar Update  
                        waitbar(8/steps,wait_bar,'Plotting spatial characteristics...');

                        % Plot Pressure images
                        pressurePlane = sum(abs(plane),3);
                        axes(handles.axes12);
                        imagesc(var1_axis, var2_axis, pressurePlane);
                        if get(handles.checkbox_axis_adjust,'value') == 1
                            axis image;
                        end
                        switch surface_nf
                            case 1          % Surface X-Z
                               visxx='x'; visyy='z'; viszz='y'; viszzend=y_end;%                              
                            case 2          % Surface Y-Z
                               visxx='y'; visyy='z'; viszz='y'; viszzend=x_end;%                             
                            case 3          % Surface X-Y
                               visxx='x'; visyy='y'; viszz='y'; viszzend=z_end;%                               
                        end
                        xlabel ([visxx ' in [m]']); ylabel ([visyy ' in [m]']);
                        title(sprintf(['Calculated pressure\n ' num2str(visxx) '-' num2str(visyy) ' plane with ' num2str(viszz) ' = %f [m]'], viszzend));
                        colorbar;

                        % Find middle of x-axis
                        [row] = size(pressurePlane,1);
                        [col_plane] = size(pressurePlane,2);
                        middle_axis_plane = ceil(col_plane / 2);
                        var1_location = var1_axis(middle_axis_plane*var2, 1); 

                        % Calc end of near field (last maximum)
                        try 
                          max_array = imregionalmax(pressurePlane(:,middle_axis_plane))';
                        catch %if imregionalmax is not existing (matalb 2007)
                          max_array = length(pressurePlane(:,middle_axis_plane));
                        end
%                       
%                         for i=0:1:length(pressurePlane(:,middle_axis_plane))-1
%                             pressurePlane(i,middle_axis_plane)
%                         end
                        pos_of_enf = find(max_array,1,'last');
                        end_near_field = var2_axis(pos_of_enf,1);            

                        % Create plot
                        axes(handles.axes11);
                        plot(var2_axis(1:(var2),1),pressurePlane(:,middle_axis_plane));
                        switch surface_nf
                            case 1          % Surface X-Z
                                xlabel ('z in [m]');
                                ylabel ('abs (Pressure)');
                                title(sprintf('Pressure on middle of x axis (x = %1.2E [m]) - End of near field = %1.2E [m]',var1_location,end_near_field));
                            case 2          % Surface Y-Z
                                xlabel ('z in [m]');
                                ylabel ('abs (Pressure)');
                                title(sprintf('Pressure on middle of y axis (y = %1.2E [m]) - End of near field = %1.2E [m]',var1_location,end_near_field));
                            case 3          % Surface X-Y
                                xlabel ('y in [m]');
                                ylabel ('abs (Pressure)');
                                title(sprintf('Pressure on middle of x axis (x = %1.2E [m]) - End of near field = %1.2E [m]',var1_location,end_near_field));
                        end                    
                    else
                        % Waitbar Update
                        set(handles.proc_time, 'String', 'processing time [min]: canceled');
                        waitbar(8/steps,wait_bar,'Canceling...');
                        pause(1);
                    end
                else
                    % Waitbar Update
                    waitbar(8/steps,wait_bar,'Error... Canceling...');
                    pause(1);                
                end
            else
                % Waitbar Update
                waitbar(8/steps,wait_bar,'Canceling...');
                pause(1);
            end
        end
    else
        % If errors
        waitbar(9/steps,wait_bar,'Errors... Canceling...');
        pause(1);
    end

    % Delete Waitbar
    if ~isempty(wait_bar)
    try delete(wait_bar); catch, end
    end
    
%catch err
    % If errors
 %   waitbar(9/steps,wait_bar,'Errors... Canceling...');
 %   pause(2);
%    % Delete Waitbar
%    delete(wait_bar);
%    % Set Error
%    set(handles.output_alarm_warning_edit,'visible','on');
%    set(handles.output_alarm_warning_edit,'String',err.message);    
%end

guidata(hObject, handles);


% --- Executes on button press in reset_pushbutton.
function reset_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to reset_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

T_A_C_global_variables_GUI(1);

global c f fs B;
global n_x n_y d_arrspa_x d_arrspa_y Phas_0_x Phas_0_y;
global d_padim_x d_padim_y;

global c0 f0 fs0 B0;
global n_x0 n_y0 d_arrspa_x0 d_arrspa_y0 Phas_0_x0 Phas_0_y0;
global d_padim_x0 d_padim_y0;

global check_norm;
global en_matrix sel_matrix;
global phase_x_matrix phase_y_matrix;
global type_of_wave;

global pulse_width pulse_width0;
global fft_points fft_points0;
global fft_rect_points fft_rect_points0;

global impedance impedance0;
global u_0 u_00;
global var1 var10;
global var2 var20;
global z_end z_end0;
global y_end y_end0;
global x_end x_end0;
global x_trans_dist_steps x_trans_dist_steps0;
global y_trans_dist_steps y_trans_dist_steps0;
global surface_nf surface_nf0;

global check_impedance_ideal;
global check_attenuation_ideal;

c = c0; 
f = f0;
fs = fs0;
B = B0;
n_x = n_x0;
n_y = n_y0;
d_arrspa_x = d_arrspa_x0;
d_arrspa_y = d_arrspa_y0;
Phas_0_x = Phas_0_x0;
Phas_0_y = Phas_0_y0;
d_padim_x = d_padim_x0;
d_padim_y = d_padim_y0;

check_norm = true;
en_matrix = ones(n_y, n_x);
[xx yy] = meshgrid(0:n_x-1, 0:n_y-1);
phase_x_matrix = Phas_0_x * xx;
phase_y_matrix = Phas_0_y * yy;
sel_matrix = zeros(n_y, n_x);

set(handles.input_speed_of_sound_edit,'String',num2str(c))
set(handles.input_frequency_edit,'String',num2str(f));
set(handles.input_sample_freq_edit,'String',num2str(fs));
set(handles.input_bw_edit,'String',num2str(B));
set(handles.input_number_of_x_element_edit,'String',num2str(n_x));
set(handles.input_x_element_spacing_edit,'String',num2str(d_arrspa_x));
set(handles.input_x_phase_shift_edit,'String',num2str(Phas_0_x));
set(handles.input_number_of_y_element_edit,'String',num2str(n_y));
set(handles.input_y_element_spacing_edit,'String',num2str(d_arrspa_y));
set(handles.input_y_phase_shift_edit,'String',num2str(Phas_0_y));
set(handles.input_x_dimensions_edit,'String',num2str(d_padim_x));
set(handles.input_y_dimensions_edit,'String',num2str(d_padim_y));

set(handles.slider_speed_of_sound,'Value',0);
set(handles.slider_frequency,'Value',0);
set(handles.slider_sample_freq,'Value',0);
set(handles.slider_bw,'Value',0);
set(handles.slider_x_elements,'Value',0);
set(handles.slider_x_element_spacing,'Value',0);
set(handles.slider_x_phase_shift,'Value',0);
set(handles.slider_y_elements,'Value',0);
set(handles.slider_y_element_spacing,'Value',0);
set(handles.slider_y_phase_shift,'Value',0);
set(handles.slider_x_dimensions,'Value',0);
set(handles.slider_y_dimensions,'Value',0);
set(handles.slider_fft_points,'Value',0);

set(handles.rect_wave_parameters_panel,'Visible','off');
set(handles.bw_panel,'Visible','off');
set(handles.wave_parameters_panel,'Visible','on');

pulse_width = pulse_width0;
fft_points = fft_points0;
fft_rect_points = fft_rect_points0;

set(handles.input_pulse_width_edit,'String',num2str(pulse_width));
set(handles.input_fft_points_edit,'String',num2str(fft_points));
set(handles.input_rect_fft_points_edit,'String',num2str(fft_rect_points));

set(handles.slider_pulse_width,'Value',0);
set(handles.slider_fft_points,'Value',0);
set(handles.slider_rect_fft_points,'Value',0);

set(handles.other_wave_radiobutton, 'Value', 0);
set(handles.rectangular_radiobutton, 'Value', 0);
set(handles.pulse_radiobutton, 'Value', 0);
set(handles.sine_radiobutton, 'Value', 1);

type_of_wave = 0;

if strcmp(get(handles.near_field_characteristics_panel,'Visible'),'on') == 0
    set(handles.calc_plot_pushbotton,'Enable', 'On');
end

if exist('Icons/En_dis_ampl_trans_change.bmp','file') ~= 0
    image_pic = imread('Icons/En_dis_ampl_trans_change.bmp');
    set(handles.en_dis_ampl_trans_change_button,'cdata',image_pic);
end
set(handles.en_dis_ampl_trans_change_button,'value', 0);
set(handles.trans_ampl_panel,'visible','off');

% Reset transducer impedance
check_impedance_ideal = true;
set(handles.open_impedance_characteristic_button,'Visible','off');
set(handles.impedance_graphic_button,'Visible','off');
set(handles.impedance_status_text,'Visible','off');
if strcmp(get(handles.impedance_panel,'Visible'),'on') == 1
    set(handles.impedance_panel,'Visible','off');
    set(handles.config_panel,'Visible','on');
    set(handles.impedance_graphic_button,'Value',0);
end
set(handles.checkbox_impedance_ideal,'Value',true);

% Reset attenuation
check_attenuation_ideal = true;
set(handles.open_attenuation_button,'Visible','off');
set(handles.attenuation_graphic_button,'Visible','off');
set(handles.attenuation_status_text,'Visible','off');
if strcmp(get(handles.attenuation_panel,'Visible'),'on') == 1
    set(handles.attenuation_panel,'Visible','off');
    set(handles.config_panel,'Visible','on');
    set(handles.attenuation_graphic_button,'Value',0);
end
set(handles.checkbox_attenuation_ideal,'Value',true);

visualize_transducer_array_surfaces(hObject);

% Near Field
impedance  = impedance0;
u_0 = u_00;
var1 = var10;
var2 = var20;
z_end = z_end0;
y_end = y_end0;
x_end = x_end0;
x_trans_dist_steps = x_trans_dist_steps0;
y_trans_dist_steps = y_trans_dist_steps0;
surface_nf = surface_nf0;

set(handles.input_impedance_edit,'String',num2str(impedance));
set(handles.input_u_0_edit,'String',num2str(u_0));
set(handles.input_z_end_edit,'String',num2str(z_end));
set(handles.input_var2_steps_edit,'String',num2str(var2));
set(handles.input_x_end_edit,'String',num2str(x_end));
set(handles.input_var1_steps_edit,'String',num2str(var1));
set(handles.input_y_end_edit,'String',num2str(y_end));
set(handles.input_x_rect_patch_dim_steps_edit,'String',num2str(x_trans_dist_steps));
set(handles.input_y_rect_patch_dim_steps_edit,'String',num2str(y_trans_dist_steps));
set(handles.surface_popupmenu,'value', surface_nf);

set(handles.slider_impedance,'Value',0);
set(handles.slider_u_0,'Value',0);
set(handles.slider_z_end,'Value',0);
set(handles.slider_var2_steps,'Value',0);
set(handles.slider_x_end,'Value',0);
set(handles.slider_var1_steps,'Value',0);
set(handles.slider_x_rect_patch_dim_steps,'Value',0);
set(handles.slider_y_rect_patch_dim_steps,'Value',0);

guidata(hObject, handles);


% --- Executes on slider movement.
function slider_speed_of_sound_Callback(hObject, eventdata, handles)
% hObject    handle to slider_speed_of_sound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

%obtains the slider value from the slider component
sliderValue_speed_of_sound = get(handles.slider_speed_of_sound,'Value');

global c0;
%puts the slider value into the edit text component
set(handles.input_speed_of_sound_edit,'String', num2str(c0 + sliderValue_speed_of_sound*100));
 
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider_speed_of_sound_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_speed_of_sound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_frequency_Callback(hObject, eventdata, handles)
% hObject    handle to slider_frequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

%obtains the slider value from the slider component
sliderValue_Frequency = get(handles.slider_frequency,'Value');

global f0;
%puts the slider value into the edit text component
set(handles.input_frequency_edit,'String', num2str(f0+sliderValue_Frequency*100E3));
  
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider_frequency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_frequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_y_dimensions_Callback(hObject, eventdata, handles)
% hObject    handle to slider_y_dimensions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

%obtains the slider value from the slider component
sliderValue_y_dimensions = get(handles.slider_y_dimensions,'Value');
 
global d_padim_y0;
%puts the slider value into the edit text component
set(handles.input_y_dimensions_edit,'String', num2str(d_padim_y0 + sliderValue_y_dimensions*50E-6));
 
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider_y_dimensions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_y_dimensions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_x_dimensions_Callback(hObject, eventdata, handles)
% hObject    handle to slider_x_dimensions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

%obtains the slider value from the slider component
sliderValue_x_dimensions = get(handles.slider_x_dimensions,'Value');

global d_padim_x0;
%puts the slider value into the edit text component
set(handles.input_x_dimensions_edit,'String', num2str(d_padim_x0 + sliderValue_x_dimensions*50E-6));
 
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider_x_dimensions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_x_dimensions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_y_phase_shift_Callback(hObject, eventdata, handles)
% hObject    handle to slider_y_phase_shift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

%obtains the slider value from the slider component
sliderValue_y_phase_shift = get(handles.slider_y_phase_shift,'Value');

global n_x n_y;
global Phas_0_y0 Phas_0_y;
global phase_y_matrix;
% Puts the slider value into the edit text component
set(handles.input_y_phase_shift_edit,'String', num2str(Phas_0_y0 + sliderValue_y_phase_shift*100));
% Get the value
Phas_0_y = str2double(get(handles.input_y_phase_shift_edit,'String'))* (pi/180);

% Udate the phase_x_matrix
[xx yy] = meshgrid(0:n_x-1, 0:n_y-1);
phase_y_matrix = Phas_0_y * yy;

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider_y_phase_shift_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_y_phase_shift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_y_element_spacing_Callback(hObject, eventdata, handles)
% hObject    handle to slider_y_element_spacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

%obtains the slider value from the slider component
sliderValue_y_element_spacing = get(handles.slider_y_element_spacing,'Value');
 
global d_arrspa_y0;
%puts the slider value into the edit text component
set(handles.input_y_element_spacing_edit,'String', num2str(d_arrspa_y0 + sliderValue_y_element_spacing*50E-6));
 
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider_y_element_spacing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_y_element_spacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_x_phase_shift_Callback(hObject, eventdata, handles)
% hObject    handle to slider_x_phase_shift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

%obtains the slider value from the slider component
sliderValue_x_phase_shift = get(handles.slider_x_phase_shift,'Value');

global n_x n_y; 
global Phas_0_x0 Phas_0_x;
global phase_x_matrix;
% Puts the slider value into the edit text component
set(handles.input_x_phase_shift_edit,'String', num2str(Phas_0_x0 + sliderValue_x_phase_shift*100));
% Get the value
Phas_0_x = str2double(get(handles.input_x_phase_shift_edit,'String'))* (pi/180);

% Udate the phase_x_matrix
[xx yy] = meshgrid(0:n_x-1, 0:n_y-1);
phase_x_matrix = Phas_0_x * xx;

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider_x_phase_shift_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_x_phase_shift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_x_element_spacing_Callback(hObject, eventdata, handles)
% hObject    handle to slider_x_element_spacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

%obtains the slider value from the slider component
sliderValue_x_element_spacing = get(handles.slider_x_element_spacing,'Value');
 
global d_arrspa_x0;
%puts the slider value into the edit text component
set(handles.input_x_element_spacing_edit,'String', num2str(d_arrspa_x0 + sliderValue_x_element_spacing*50E-6));
 
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider_x_element_spacing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_x_element_spacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_x_elements_Callback(hObject, eventdata, handles)
% hObject    handle to slider_x_elements (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

%obtains the slider value from the slider component
sliderValue_x_elements = get(handles.slider_x_elements,'Value');

global n_x0; 
%puts the slider value into the edit text component
set(handles.input_number_of_x_element_edit,'String', num2str(n_x0 + sliderValue_x_elements*10));
 
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider_x_elements_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_x_elements (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_y_elements_Callback(hObject, eventdata, handles)
% hObject    handle to slider_y_elements (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

%obtains the slider value from the slider component
sliderValue_y_elements = get(handles.slider_y_elements,'Value');
 
global n_y0;
%puts the slider value into the edit text component
set(handles.input_number_of_y_element_edit,'String', num2str(n_y0 + sliderValue_y_elements*10));
 
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider_y_elements_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_y_elements (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function output_halbwertsbreite_edit_Callback(hObject, eventdata, handles)
% hObject    handle to output_halbwertsbreite_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of output_halbwertsbreite_edit as text
%        str2double(get(hObject,'String')) returns contents of output_halbwertsbreite_edit as a double


% --- Executes during object creation, after setting all properties.
function output_halbwertsbreite_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to output_halbwertsbreite_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function output_alarm_warning_edit_Callback(hObject, eventdata, handles)
% hObject    handle to output_alarm_warning_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of output_alarm_warning_edit as text
%        str2double(get(hObject,'String')) returns contents of output_alarm_warning_edit as a double


% --- Executes during object creation, after setting all properties.
function output_alarm_warning_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to output_alarm_warning_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(hObject,'BackgroundColor',defaultBackground);
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    
end


function sphere_buttongroup_SelectionChangeFcn(hObject, eventdata)
 
global theta_min theta_max;
global res;

%retrieve GUI data, i.e. the handles structure
handles = guidata(hObject); 
 
switch get(eventdata.NewValue,'Tag')   % Get Tag of selected object
    case 'full_sphere_radiobutton'
      %execute this code when fontsize08_radiobutton is selected
      theta_min = 0;
      theta_max = 2*pi;
      res=pi/50;  
      
    case 'semi_sphere_radiobutton'
      %execute this code when fontsize12_radiobutton is selected
      theta_min = -pi/2;
      theta_max = pi/2;
      res=pi/75;
    
end
%updates the handles structure
guidata(hObject, handles);


% --- Executes on button press in checkbox_normalize.
function checkbox_normalize_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_normalize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox_normalize

%checkboxStatus = 0, if the box is unchecked, 
%checkboxStatus = 1, if the box is checked

global check_norm;

checkboxStatus = get(handles.checkbox_normalize,'Value');
if(checkboxStatus)
    %if box is checked,
    check_norm = true;
else
    %if box is unchecked, 
    check_norm = false;
end


function reference_buttongroup_SelectionChangeFcn(hObject, eventdata)

global hwb_ref hwb_int hwb_pres;
%retrieve GUI data, i.e. the handles structure
handles = guidata(hObject); 
 
switch get(eventdata.NewValue,'Tag')   % Get Tag of selected object
    case 'intensity_radiobutton'
      %execute this code when fontsize08_radiobutton is selected
       hwb_ref = true; 
       set(handles.output_halbwertsbreite_edit,'String',num2str(hwb_int));
      
    case 'pressure_radiobutton'
      %execute this code when fontsize12_radiobutton is selected
        hwb_ref = false;
        set(handles.output_halbwertsbreite_edit,'String',num2str(hwb_pres));
     
end
%updates the handles structure
guidata(hObject, handles);


function waves_buttongroup_SelectionChangeFcn(hObject, eventdata)

%global hwb_ref hwb_int hwb_pres;
%retrieve GUI data, i.e. the handles structure
global type_of_wave;
handles = guidata(hObject); 
 
switch get(eventdata.NewValue,'Tag')   % Get Tag of selected object
    case 'sine_radiobutton'
        type_of_wave = 0;
        set(handles.open_file_edit,'Visible','off');
        set(handles.open_file_button, 'Visible','off');
        set(handles.rect_wave_parameters_panel, 'Visible','off');
        set(handles.bw_panel, 'Visible','off');
        pause(0.01);
        set(handles.wave_parameters_panel, 'Visible','on');
        
    case 'pulse_radiobutton'
        type_of_wave = 1;
        set(handles.open_file_edit,'Visible','off');
        set(handles.open_file_button, 'Visible','off');
        set(handles.rect_wave_parameters_panel, 'Visible','off');
        pause(0.01);
        set(handles.wave_parameters_panel, 'Visible','on');
        set(handles.bw_panel, 'Visible','on');
        
    case 'rectangular_radiobutton'
        type_of_wave = 2;
        set(handles.open_file_edit,'Visible','off');
        set(handles.open_file_button, 'Visible','off');
        set(handles.wave_parameters_panel, 'Visible','off');
        set(handles.bw_panel, 'Visible','off');
        pause(0.01);
        set(handles.rect_wave_parameters_panel, 'Visible','on');
        
    case 'other_wave_radiobutton'
        type_of_wave = 3;
        set(handles.rect_wave_parameters_panel, 'Visible','off');
        set(handles.bw_panel, 'Visible','off');
        pause(0.01);
        set(handles.wave_parameters_panel, 'Visible','on');
        pause(0.01);
        set(handles.open_file_edit,'Visible','on');
        set(handles.open_file_button, 'Visible','on');
end

% Turn on/off the TooltipString of chance of unit
if type_of_wave == 0
    % Turn on
    set(handles.unit_x_distance_from_observer_text, 'TooltipString', 'Click with the right button to change the unit');
    set(handles.unit_y_distance_from_observer_text, 'TooltipString', 'Click with the right button to change the unit');
    set(handles.unit_z_distance_from_observer_text, 'TooltipString', 'Click with the right button to change the unit');    
else
    % Turn off
    set(handles.unit_x_distance_from_observer_text, 'TooltipString', '');
    set(handles.unit_y_distance_from_observer_text, 'TooltipString', '');
    set(handles.unit_z_distance_from_observer_text, 'TooltipString', '');
end    
%updates the handles structure
guidata(hObject, handles);


% --- Executes on mouse press over axes7 mesh.
function en_dis_transducers_ButtonDownFcn(hObject, eventdata, varargin)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global en_matrix sel_matrix;
global phase_x_matrix phase_y_matrix;
global flag_sel;
handles = guidata(hObject);

%Which one is the selected transducer?
pos_yx = varargin{1};
x = pos_yx(1);
y = pos_yx(2);

en_dis_ampl_trans_change = get(handles.en_dis_ampl_trans_change_button,'value');
%If Change in amplitude of transducer enabled?
if en_dis_ampl_trans_change == 0
    if en_matrix(y, x) == 1
        en_matrix(y, x) = 0;
    else
        en_matrix(y, x) = 1;    
    end
    % Display Amplitude
    aux_text = sprintf('Trans. N° (y,x): [%d,%d]',y,x);
    set(handles.trans_n_txt,'string',aux_text);
    aux_text = sprintf('%.2f',en_matrix(y, x)*100);
    set(handles.ampl_trans_edit,'foregroundcolor','black');
    set(handles.ampl_trans_edit,'string',aux_text);     
    flag_sel = 0;
else
    % Mouse buttons:
    %   Left:   'normal'
    %   Right:  'alt'
    %   Middle: 'extend'
    
    % Enable  |  Mouse    | Key      | SelectionType | SelectionType |
    % Status  |  Button   | Modifier | on First      | on Second     |
    %         |  Pressed  |	Pressed	 | Click         | Click         |
    % ________|___________|__________|_______________|_______________|
    %   on    |    left   |	 	     |   'normal'	 |   'normal'*   |
    %   on    |    right  |	 	     |   'alt'	     |   'open'      |
    %   on    |    left	  |   Ctrl	 |   'normal'	 |   'normal'*   |
    %   on    |    right  |   Ctrl	 |   'alt'	     |   'open'      |
    %   on    |    left	  |   Shift	 |   'normal'	 |   'normal'*   |
    %   on    |    right  |	  Shift	 |   'extend'	 |   'open'      |
    %   off   |    left	  |	         |   'normal'	 |   'open'      |
    %   off   |    right  |	 	     |   'alt'	     |   'open'      |
    %   off   |    left	  |   Ctrl	 |   'alt'	     |   'open'      |
    %   off   |    right  |	  Ctrl	 |   'alt'	     |   'open'      |
    %   off   |    left	  |   Shift	 |   'extend'	 |   'open'      |
    %   off   |    right  |	  Shift	 |   'extend'	 |   'open'      |    
    %_________|___________|__________|_______________|_______________|
    %
    % So, to use Ctrl + Click I have to read a 'alt' in off enable status.
    % It'll work too when someone clicks on the right button
    switch get(gcf,'SelectionType')
        case 'normal'
            flag_sel = 0;
            if sel_matrix(y, x) == 0
                sel_matrix = zeros(size(sel_matrix));
                sel_matrix(y, x) = 1;
            else
                sel_matrix = zeros(size(sel_matrix));
            end
        case 'alt'
            if sel_matrix(y, x) == 0
                sel_matrix(y, x) = 1;
            else
                sel_matrix(y, x) = 0;
            end
            if sum(sum(sel_matrix > 0)) > 1;
                flag_sel = 1;
            else
                flag_sel = 0;
            end
        case 'extend'
            flag_sel = 0;
            if sel_matrix(y, x) == 0
                sel_matrix = zeros(size(sel_matrix));
                sel_matrix(y, x) = 1;
            else
                sel_matrix = zeros(size(sel_matrix));
            end
            en_matrix(y, x) = en_matrix(y, x) + 0.1;
            if en_matrix(y, x) > 1
                en_matrix(y, x) = 0;
            end       
    end
% Display Amplitude / Number of Transducer Selected + Reset values of Selection matrix
    if sum(sum(sel_matrix > 0)) <= 1
        set(handles.trans_n_txt,'foregroundcolor','black');
        aux_text = sprintf('Trans. N° (y,x): [%d,%d]',y,x);
        set(handles.trans_n_txt,'string',aux_text);
    else
        set(handles.trans_n_txt,'foregroundcolor','blue');        
        aux_text = sprintf('N° selected trans.: %d',sum(sum(sel_matrix > 0)));        
        set(handles.trans_n_txt,'string',aux_text);        
    end
    set(handles.ampl_trans_edit,'foregroundcolor','black');
    aux_text = sprintf('%.2f',en_matrix(y, x)*100);
    set(handles.ampl_trans_edit,'string',aux_text);   
end

% Display Phase X and Y
aux_text = sprintf('%.2f',phase_x_matrix(y, x)*180/pi);
%    set(handles.ampl_sel_text,'string','Ampl [%]:');
set(handles.phase_x_trans_edit,'foregroundcolor','black');
set(handles.phase_x_trans_edit,'string',aux_text);    
aux_text = sprintf('%.2f',phase_y_matrix(y, x)*180/pi);
%    set(handles.ampl_sel_text,'string','Ampl [%]:');
set(handles.phase_y_trans_edit,'foregroundcolor','black');
set(handles.phase_y_trans_edit,'string',aux_text);  

visualize_transducer_array_surfaces(hObject);


% --- Executes on button press in active_all_button.
function active_all_button_Callback(hObject, eventdata, handles)
% hObject    handle to active_all_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global en_matrix sel_matrix;
en_matrix = ones(size(en_matrix));
sel_matrix = zeros(size(sel_matrix));
visualize_transducer_array_surfaces(hObject);


% --- Executes on button press in inactive_all_button.
function inactive_all_button_Callback(hObject, eventdata, handles)
% hObject    handle to inactive_all_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global en_matrix sel_matrix;
en_matrix = zeros(size(en_matrix));
sel_matrix = zeros(size(sel_matrix));
visualize_transducer_array_surfaces(hObject);


function visualize_transducer_array_surfaces(hObject)
% hObject    handle to active_all_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global n_x n_y;
global en_matrix sel_matrix phase_x_matrix phase_y_matrix;

%retrieve GUI data, i.e. the handles structure
handles = guidata(hObject);
    
[TRAN_SURF_X TRAN_SURF_Y] = visualize_transducer_array_GUI;
    
axes(handles.axes7)
n_x_count = 1;
n_y_count = 1;
    
grid on;
while n_x_count < n_x+1 && n_y_count < n_y+1
    
    [xx, yy]=  meshgrid(TRAN_SURF_X(n_x_count,:), TRAN_SURF_Y(n_y_count,:));
    zz = ones(size([xx]));
    %Color selection
    if(sel_matrix(n_y_count, n_x_count) == 1)
        %When transducer selection functions is active  
        color = 'y';
    else
        if (en_matrix(n_y_count, n_x_count) <= 1 + eps) && (en_matrix(n_y_count, n_x_count) >= 1 - eps);
            %Transducer 100% active
            color = 'g';
        else
            if en_matrix(n_y_count, n_x_count) == 0;
                %Transducer 0% active
                color = 'r';
            else
                %Transducer active
                color = 'c';
            end
        end
    end
    %Mesh the surface with a function
    mesh(xx, yy, zz, ...
        'EdgeColor', color, ...
        'ButtonDownFcn', {@en_dis_transducers_ButtonDownFcn, [n_x_count n_y_count]});
    hold on;
    %Counters update  
    if n_x_count == n_x      
            n_y_count = n_y_count+1;
            n_x_count = 0;
    end
    n_x_count = n_x_count +1;   
end

view(2);
axis equal;
xlabel('x');ylabel('y');zlabel('z');
hold off

%Update TooltipString of the "trans_array_surfaces_text"
aux_str = sprintf('Y X   AMPL    PHASE-X  PHASE-Y\n');
for y=1:1:n_y
    for x=1:1:n_x
        aux_str = sprintf('%s%d %d   = %03.0f   = %03.0f    = %03.0f\n',aux_str,y,x,en_matrix(y,x)*100,phase_x_matrix(y,x)*180/pi,phase_y_matrix(y,x)*180/pi);
    end
end
set(handles.trans_array_surfaces_text,'TooltipString',aux_str);

% --- Executes on button press in wave_options_button.
function wave_options_button_Callback(hObject, eventdata, handles)
% hObject    handle to wave_options_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(handles.wave_options_panel,'visible'),'off')
    set(handles.config_panel,'visible', 'off');
    set(handles.attenuation_panel,'Visible','off');
    set(handles.attenuation_control_panel,'Visible','off');    
    set(handles.impedance_panel,'Visible','off');
    set(handles.impedance_control_panel,'Visible','off');    
    pause(0.01);
    set(handles.wave_options_panel,'visible', 'on');
else
    if strcmp(get(handles.wave_options_panel,'visible'),'on')
        set(handles.wave_options_panel,'visible', 'off');
        pause(0.01);
        set(handles.config_panel,'visible', 'on');
        set(handles.attenuation_control_panel,'Visible','on');
        set(handles.attenuation_graphic_button,'Value',0);
        set(handles.impedance_control_panel,'Visible','on');
        set(handles.impedance_graphic_button,'Value',0);
    end
end


function unit_buttongroup_SelectionChangeFcn(hObject, eventdata)
%retrieve GUI data, i.e. the handles structure
global type_of_unit;
global waves_frec waves_time;
global FREC TIME AMPL;
global waves_frec_to_calc;

handles = guidata(hObject); 
% Ask if the vectors are empty
if isempty(waves_time) == 0 && isempty(waves_frec_to_calc) == 0 && isempty(waves_frec) == 0
    switch get(eventdata.NewValue,'Tag')   % Get Tag of selected object
        case 'time_radiobutton'
            type_of_unit = 0;
            wave=waves_time(:,:);            
        case 'frequency_radiobutton'
            type_of_unit = 1;             
            wave=waves_frec(:,:);
    end
    DrawWaveForm(type_of_unit,wave,handles);
   
end
%updates the handles structure
guidata(hObject, handles);


function input_sample_freq_edit_Callback(hObject, eventdata, handles)
% hObject    handle to input_sample_freq_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of input_sample_freq_edit as text
%        str2double(get(hObject,'String')) returns contents of input_sample_freq_edit as a double


% --- Executes during object creation, after setting all properties.
function input_sample_freq_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_sample_freq_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_sample_freq_Callback(hObject, eventdata, handles)
% hObject    handle to slider_sample_freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

sliderValue_Bandwidth = get(handles.slider_sample_freq,'Value');

global fs;
%puts the slider value into the edit text component
set(handles.input_sample_freq_edit,'String', num2str(fs+sliderValue_Bandwidth*100E3));
  
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider_sample_freq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_sample_freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function input_fft_points_edit_Callback(hObject, eventdata, handles)
% hObject    handle to input_fft_points_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of input_fft_points_edit as text
%        str2double(get(hObject,'String')) returns contents of input_fft_points_edit as a double


% --- Executes during object creation, after setting all properties.
function input_fft_points_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_fft_points_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_fft_points_Callback(hObject, eventdata, handles)
% hObject    handle to slider_fft_points (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliderValue_fft_points = get(handles.slider_fft_points,'Value');

global fft_points0;
%puts the slider value into the edit text component
set(handles.input_fft_points_edit,'String', num2str(fft_points0+sliderValue_fft_points*10))

% Update handles structure
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function slider_fft_points_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_fft_points (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function open_file_edit_Callback(hObject, eventdata, handles)
% hObject    handle to open_file_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of open_file_edit as text
%        str2double(get(hObject,'String')) returns contents of open_file_edit as a double


% --- Executes during object creation, after setting all properties.
function open_file_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to open_file_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in open_file_button.
function open_file_button_Callback(hObject, eventdata, handles)
% hObject    handle to open_file_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pathname filename check_impedance_ideal;

global fft_points;
global waves_frec waves_time;
global TIME;
global AMPL FREC;
global type_of_unit;

[filename, pathname] = uigetfile('*.mat', 'Select a MAT-files (*.mat)');

if (length(filename) <= 1) || (length(pathname) <= 1)
    set(handles.open_file_edit, 'String', 'No file selected...');
else
    %Open a ".mat" File
    set(handles.open_file_edit, 'String', [pathname filename]);
    
    %Open a ".mat" File
    %NOTE:  the first Field is "matchedFilter_AScan"
    %       the second Field is "matchedFilter_SampFreq"
    signal = open([pathname filename]);
    
    % Sample Frequency is fixed in the Smaple Frequency of the saved signal
    % or fs when the steps are adjusted between input and impedance signals
    if check_impedance_ideal == 1 || get(handles.checkbox_adjust_steps, 'value') == 0
        f_s = signal.matchedFilter_SampFreq;
    else
        f_s = fs;
    end
    
    %Time
    signal_time = signal.matchedFilter_AScan';
    %Eliminate DC Component
    dc_component = (sum(sum(signal_time))/length(signal_time)) * ones(size(signal_time));
    signal_time = signal_time - dc_component;
    L_s = length(signal_time);
    time = (0:L_s-1) / f_s;
    
    %Frequency
    frec = 0:f_s/fft_points:((f_s/2)-(f_s/fft_points));
    signal_frec = fft(signal_time, fft_points)/L_s;  % Normalize
    signal_frec = signal_frec(frec < f_s/2);
    signal_frec = signal_frec + [0 signal_frec(2:length(signal_frec))];
    
    % for Plotting
    waves_time = zeros(2, length(time));
    waves_time(TIME,:) = time;
    waves_time(AMPL,:) = signal_time;
    waves_frec = zeros(2, length(frec));
    waves_frec(FREC,:) = frec;
    waves_frec(AMPL,:) = signal_frec;    
    
    % Plot input signal (time or frequency)
    if type_of_unit == 0
        DrawWaveForm(type_of_unit,waves_time(:,:),handles);
    else
        DrawWaveForm(type_of_unit,waves_frec(:,:),handles);
    end
 end
    
% --- Executes on button press in frequency_angle_diagram_button.
function frequency_angle_diagram_button_Callback(hObject, eventdata, handles)
% hObject    handle to frequency_angle_diagram_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of frequency_angle_diagram_button
if strcmp(get(handles.frequency_angle_diagram_panel,'visible'),'off')
    % Hide the Graphic 3
    set(handles.save_img_rect_patch_button,'visible','off');
    set(handles.axes3,'visible', 'off');
    set(allchild(handles.axes3),'visible','off');
    pause(0.01);
    set(handles.frequency_angle_diagram_panel,'visible', 'on');
else
    if strcmp(get(handles.frequency_angle_diagram_panel,'visible'),'on')
        set(handles.frequency_angle_diagram_panel,'visible', 'off');
        pause(0.01);
        % To see the Graphic 3
        set(handles.axes3,'visible', 'on');
        set(allchild(handles.axes3),'visible','on');
        set(handles.save_img_rect_patch_button,'visible','on');        
    end
end


% --- Executes on button press in save_img_button.
function save_img_button_Callback(hObject, eventdata, handles, axes_num)
% hObject    handle to save_img_xy_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Description of "axes_num":
%   The function has an extra parameter that says the image number to be
%   saved by the program.
%       = 0     ->  Save all images
%       = 1     ->  Save Directivity pattern of entire arrangement
%       = 2     ->  Save Directivity pattern XY - Array
%       = 3     ->  Save Directivity pattern of Rectangular Patch
%       = 5     ->  Save Directivity pattern C_all Vertical
%       = 6     ->  Save Directivity pattern C_all Horizontal
%       = 7     ->  Save Transducer Array Surface
%       = 9     ->  Save Traveling Wave
%       = 10    ->  Save Frequency-Angle Diagram
%       = 11    ->  Save Pressure on middle of x axis
%       = 12    ->  Save Spatial transducer characteristics
%       = 13    ->  Save Transducer Impedance
%       = 14    ->  Save Attenuation
%
%   Note: Axes 4 and 8 are not used

global n_x n_y;
global en_matrix;
global currentFileFolder;
global waves_frec waves_time waves_frec_to_calc;
global FREC TIME AMPL;

% Get date and time
date = clock;   %It returns [year month day hour minute second]
position_axes = [0.1300 0.1100 0.7750 0.8150];

% Ask if it has to save all images (axes_num = 0)
if axes_num == 0;
    flag_save_all = 1;
    % Which graphics has it to save? with or without approximation?
    if strcmp(get(handles.near_field_characteristics_panel,'Visible'), 'off')
        % Set the first image to save WITH approximation
        axes_num = 1;
        % Waitbar title and steps
        waitbar_title = 'Save Image...';
        steps = 10;       
        % Folder name
        graficosFolder = sprintf('%s/Graficos/%02d%02d%02d/%02d.%02d.%02d',currentFileFolder, (date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));
    else
        % Set the first image to save WITHOUT approximation       
        axes_num = 11;
        % Waitbar title and steps
        waitbar_title = 'Save Near Field Image...';
        steps = 2;
        % Folder name
        graficosFolder = sprintf('%s/Graficos/%02d%02d%02d/%02d.%02d.%02d_Near_Field',currentFileFolder, (date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));
    end
    % Create "Graficos" Folder
    if exist(graficosFolder,'dir') == 0
        % Doesn't exist Folder, I'll create it
        mkdir(graficosFolder);
    end  
else
    flag_save_all = 0;
    % Waitbar title and steps
    waitbar_title = 'Save Image...';
    steps = 2;
end

% Create Waitbar
wait_bar = waitbar(0,waitbar_title,'Name', 'T A C GUI Processing...',...
                    'windowstyle', 'modal');

% Start to save
flag_end_save = 1;
while flag_end_save
    switch axes_num
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Graphics WITH approximation (Far Field)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        case 1
            axes(handles.axes1);
            orignalAxes = gca;
            if flag_save_all == 0
                file_name = sprintf('%s/Graficos/%02d%02d%02d-%02d.%02d.%02d-D_P_entire_arrangement.fig', currentFileFolder, (date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));
                flag_end_save = 0;
                % Waitbar Update
                waitbar(2/steps,wait_bar);
            else
                file_name = sprintf('%s/%02d%02d%02d-%02d.%02d.%02d-D_P_entire_arrangement.fig',graficosFolder, (date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));
                % Change the image number to save
                next_axes_num = 2;
                % Waitbar Update
                waitbar(1/steps,wait_bar);
            end
            figure_name = sprintf('%02d%02d%02d-%02d.%02d.%02d - Directivity pattern of entire arrangement',(date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));
        case 2
            axes(handles.axes2);
            orignalAxes = gca;
            if flag_save_all == 0                
                file_name = sprintf('%s/Graficos/%02d%02d%02d-%02d.%02d.%02d-D_P_XY-Array.fig', currentFileFolder, (date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));
                flag_end_save = 0;
                % Waitbar Update
                waitbar(2/steps,wait_bar);
            else
                file_name = sprintf('%s/%02d%02d%02d-%02d.%02d.%02d-D_P_XY-Array.fig',graficosFolder, (date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));                
                % Change the image number to save
                next_axes_num = 3;
                % Waitbar Update
                waitbar(2/steps,wait_bar);
            end            
            figure_name = sprintf('%02d%02d%02d-%02d.%02d.%02d - Directivity pattern XY - Array',(date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));
        case 3
            axes(handles.axes3);
            orignalAxes = gca;
            if flag_save_all == 0
                file_name = sprintf('%s/Graficos/%02d%02d%02d-%02d.%02d.%02d-D_P_Rect-Patch.fig', currentFileFolder, (date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));
                flag_end_save = 0;
                % Waitbar Update
                waitbar(2/steps,wait_bar);
            else
                file_name = sprintf('%s/%02d%02d%02d-%02d.%02d.%02d-D_P_Rect-Patch.fig',graficosFolder, (date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));
                % Change the image number to save
                next_axes_num = 5;
                % Waitbar Update
                waitbar(3/steps,wait_bar);
            end                            
            figure_name = sprintf('%02d%02d%02d-%02d.%02d.%02d - Directivity pattern of Rectangular Patch',(date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));        
        case 5
            axes(handles.axes5);
            orignalAxes = gca;
            if flag_save_all == 0
                file_name = sprintf('%s/Graficos/%02d%02d%02d-%02d.%02d.%02d-D_P_C_all_Vertical.fig', currentFileFolder, (date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));
                flag_end_save = 0;
                % Waitbar Update
                waitbar(2/steps,wait_bar);
            else
                file_name = sprintf('%s/%02d%02d%02d-%02d.%02d.%02d-D_P_C_all_Vertical.fig',graficosFolder, (date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));
                % Change the image number to save
                next_axes_num = 6;
                % Waitbar Update
                waitbar(4/steps,wait_bar);
            end                 
            figure_name = sprintf('%02d%02d%02d-%02d.%02d.%02d - Directivity pattern C_all Vertical',(date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));        
        case 6
            axes(handles.axes6);
            orignalAxes = gca;
            if flag_save_all == 0
                file_name = sprintf('%s/Graficos/%02d%02d%02d-%02d.%02d.%02d-D_P_C_all_Horizontal.fig', currentFileFolder, (date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));
                flag_end_save = 0;
                % Waitbar Update
                waitbar(2/steps,wait_bar);
            else   
                file_name = sprintf('%s/%02d%02d%02d-%02d.%02d.%02d-D_P_C_all_Horizontal.fig',graficosFolder, (date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));
                % Change the image number to save
                next_axes_num = 7; % Not here because it bring problems
                % Waitbar Update
                waitbar(5/steps,wait_bar);
            end                            
            figure_name = sprintf('%02d%02d%02d-%02d.%02d.%02d - Directivity pattern C_all Horizontal',(date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));                
        case 7
            axes(handles.axes7);
            orignalAxes = gca;
            if flag_save_all == 0
                file_name = sprintf('%s/Graficos/%02d%02d%02d-%02d.%02d.%02d-Transducer_array_surface.fig', currentFileFolder, (date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));
                flag_end_save = 0;
                % Waitbar Update
                waitbar(2/steps,wait_bar);
            else
                file_name = sprintf('%s/%02d%02d%02d-%02d.%02d.%02d-Transducer_array_surface.fig',graficosFolder, (date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));
                % Change the image number to save
                next_axes_num = 9;
                % Waitbar Update
                waitbar(6/steps,wait_bar);
            end                
            figure_name = sprintf('%02d%02d%02d-%02d.%02d.%02d - Transducer Array Surface',(date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));
        case 9
            axes(handles.axes9);
            orignalAxes = gca;
            if flag_save_all == 0
                file_name = sprintf('%s/Graficos/%02d%02d%02d-%02d.%02d.%02d-Traveling_wave.fig', currentFileFolder, (date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));
                flag_end_save = 0;
                % Waitbar Update
                waitbar(2/steps,wait_bar);
            else
                file_name = sprintf('%s/%02d%02d%02d-%02d.%02d.%02d-Traveling_wave.fig',graficosFolder, (date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));
                % Change the image number to save
                next_axes_num = 10;
                % Waitbar Update
                waitbar(8/steps,wait_bar);
            end                
            figure_name = sprintf('%02d%02d%02d-%02d.%02d.%02d - Traveling Wave',(date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));                                
        case 10
            axes(handles.axes10);
            orignalAxes = gca;
            if flag_save_all == 0
                file_name = sprintf('%s/Graficos/%02d%02d%02d-%02d.%02d.%02d-F-A_Diagram.fig', currentFileFolder, (date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));
                flag_end_save = 0;
                % Waitbar Update
                waitbar(2/steps,wait_bar);
            else
                file_name = sprintf('%s/%02d%02d%02d-%02d.%02d.%02d-F-A_Diagram.fig',graficosFolder, (date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));
                % Change the image number to save
                % next_axes_num = 11;
                flag_end_save = 0;
                % Waitbar Update
                waitbar(9/steps,wait_bar);
            end                
            figure_name = sprintf('%02d%02d%02d-%02d.%02d.%02d - Frequency-Angle Diagram',(date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Graphics WITHOUT approximation (Near Field)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 11
            axes(handles.axes11);
            orignalAxes = gca;
            if flag_save_all == 0
                file_name = sprintf('%s/Graficos/%02d%02d%02d-%02d.%02d.%02d-Pressure_middle_x_axis.fig', currentFileFolder, (date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));
                flag_end_save = 0;
                % Waitbar Update
                waitbar(2/steps,wait_bar);
            else
                file_name = sprintf('%s/%02d%02d%02d-%02d.%02d.%02d-Pressure_middle_x_axis.fig',graficosFolder, (date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));
                % Change the image number to save
                next_axes_num = 12;
                % End of save image
                % flag_end_save = 0;
                % Waitbar Update
                waitbar(1/steps,wait_bar);
            end                
            figure_name = sprintf('%02d%02d%02d-%02d.%02d.%02d - Pressure on middle of x axis',(date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));            
        case 12
            axes(handles.axes12);
            orignalAxes = gca;
            if flag_save_all == 0
                file_name = sprintf('%s/Graficos/%02d%02d%02d-%02d.%02d.%02d-Spatial_trans_characteristics.fig', currentFileFolder, (date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));
                flag_end_save = 0;
                % Waitbar Update
                waitbar(2/steps,wait_bar);
            else
                file_name = sprintf('%s/%02d%02d%02d-%02d.%02d.%02d-Spatial_trans_characteristics.fig',graficosFolder, (date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));
                % Change the image number to save
                % next_axes_num = 13;
                % End of save image
                flag_end_save = 0;
                % Waitbar Update
                waitbar(2/steps,wait_bar);
            end                
            figure_name = sprintf('%02d%02d%02d-%02d.%02d.%02d - Spatial transducer characteristics',(date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Extra-Graphics, which are not saved with "Save all images"
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 13
            axes(handles.axes13);
            orignalAxes = gca;
            if flag_save_all == 0
                file_name = sprintf('%s/Graficos/%02d%02d%02d-%02d.%02d.%02d-T_Impedance.fig', currentFileFolder, (date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));
                flag_end_save = 0;
                % Waitbar Update
                waitbar(2/steps,wait_bar);
            end                
            figure_name = sprintf('%02d%02d%02d-%02d.%02d.%02d - Transducer Impedance',(date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));
        case 14
            axes(handles.axes14);
            orignalAxes = gca;
            if flag_save_all == 0
                file_name = sprintf('%s/Graficos/%02d%02d%02d-%02d.%02d.%02d-Attenuation.fig', currentFileFolder, (date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));
                flag_end_save = 0;
                % Waitbar Update
                waitbar(2/steps,wait_bar);
            end                
            figure_name = sprintf('%02d%02d%02d-%02d.%02d.%02d - Attenuation',(date(1)-2000), date(2), date(3), date(4), date(5), round(date(6)));            
    end

    %Create a new figure
    newFig = figure('Name', figure_name, 'NumberTitle', 'off');
    if axes_num ~= 7 && axes_num ~= 9
        %Create a copy of the axes
        newA = copyobj(orignalAxes, newFig);
        %Position adjust with default values previous to save
        set(newA, 'position', position_axes);
        if flag_end_save == 0
            % Waitbar Update
            waitbar(7/steps,wait_bar);
        end
        % Does the graphic have a Colorbar?
        if (axes_num == 10) || (axes_num == 12)
            colorbar;
        end
    else
        % If the graphic is input signal
        if axes_num == 9
            % Plot input signal in time and frequency
            subplot(2,1,1);
            plot(waves_time(TIME,:), waves_time(AMPL,:));
            xlabel('Time [s]');
            ylabel('Amplitude');    
            title('Wave - Time');
            subplot(2,1,2);
            plot(waves_frec_to_calc(FREC,:), waves_frec_to_calc(AMPL,:), 'r');
            hold on;
            plot(waves_frec(FREC,:), waves_frec(AMPL,:));
            hold off;
            xlabel('Frequency [Hz]');
            ylabel('Amplitude');
            title('Wave - Frequency');           
        end
        % If the graphic is transducer array
        if axes_num == 7
            %New axes in new figure
            axes
            [TRAN_SURF_X TRAN_SURF_Y] = visualize_transducer_array_GUI;
            n_x_count = 1;
            n_y_count = 1;

            grid on;
            while n_x_count < n_x+1 && n_y_count < n_y+1
                [xx, yy]=  meshgrid(TRAN_SURF_X(n_x_count,:), TRAN_SURF_Y(n_y_count,:));
                zz = ones(size([xx]));
                if en_matrix(n_y_count, n_x_count) == 1;
                    color = 'g';
                else           
                    if en_matrix(n_y_count, n_x_count) == 0;
                        color = 'r';
                    else
                        color = 'c';
                    end
                end

                mesh(xx, yy, zz, ...
                    'EdgeColor', color);
                hold on;

                if n_x_count == n_x      
                        n_y_count = n_y_count+1;
                        n_x_count = 0;
                end
                n_x_count = n_x_count +1;   

                % Waitbar Update
                waitbar(7/steps,wait_bar);
            end
            view(2);
            axis equal;
            xlabel('x');ylabel('y');zlabel('z');
            hold off
        end
    end
    %Save figure to file
    saveas(newFig, file_name);
    file_name = '';
    %Close the new figure
    close(newFig);
    %Update of axes number to save
    if flag_save_all == 1
        axes_num = next_axes_num;
    end
end
% Waitbar Update
waitbar(steps/steps,wait_bar);
delete(wait_bar);


function input_pulse_width_edit_Callback(hObject, eventdata, handles)
% hObject    handle to input_pulse_width_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of input_pulse_width_edit as text
%        str2double(get(hObject,'String')) returns contents of input_pulse_width_edit as a double


% --- Executes during object creation, after setting all properties.
function input_pulse_width_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_pulse_width_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_pulse_width_Callback(hObject, eventdata, handles)
% hObject    handle to slider_pulse_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliderValue_pulse_width = get(handles.slider_pulse_width,'Value');
 
global pulse_width0;
%puts the slider value into the edit text component
set(handles.input_pulse_width_edit,'String', num2str(pulse_width0 + sliderValue_pulse_width*10));
 
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider_pulse_width_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_pulse_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function input_rect_fft_points_edit_Callback(hObject, eventdata, handles)
% hObject    handle to input_rect_fft_points_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of input_rect_fft_points_edit as text
%        str2double(get(hObject,'String')) returns contents of input_rect_fft_points_edit as a double


% --- Executes during object creation, after setting all properties.
function input_rect_fft_points_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_rect_fft_points_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_rect_fft_points_Callback(hObject, eventdata, handles)
% hObject    handle to slider_rect_fft_points (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliderValue_rect_fft_points = get(handles.slider_rect_fft_points,'Value');

global fft_rect_points0;
%puts the slider value into the edit text component
set(handles.input_rect_fft_points_edit,'String', num2str(fft_rect_points0 + sliderValue_rect_fft_points*10))
 
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider_rect_fft_points_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_rect_fft_points (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_bw_Callback(hObject, eventdata, handles)
% hObject    handle to slider_bw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliderValue_bw = get(handles.slider_bw,'Value');

global B0;
%puts the slider value into the edit text component
set(handles.input_bw_edit,'String', num2str(B0 + sliderValue_bw*100000))
 
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider_bw_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_bw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function input_bw_edit_Callback(hObject, eventdata, handles)
% hObject    handle to input_bw_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_bw_edit as text
%        str2double(get(hObject,'String')) returns contents of input_bw_edit as a double


% --- Executes during object creation, after setting all properties.
function input_bw_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_bw_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in en_dis_ampl_trans_change_button.
function en_dis_ampl_trans_change_button_Callback(hObject, eventdata, handles)
% hObject    handle to en_dis_ampl_trans_change_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of en_dis_ampl_trans_change_button
global sel_matrix;

if get(handles.en_dis_ampl_trans_change_button,'value') == 0  
    if (exist('Icons\En_dis_ampl_trans_change.bmp','file') ~= 0)
        image_pic = imread('Icons\En_dis_ampl_trans_change.bmp');
        set(handles.en_dis_ampl_trans_change_button,'cdata',image_pic);
    end
    % Panel Visible off
    set(handles.trans_ampl_panel,'visible','off');
    % Reset sel_matrix and display
    if sum(sum(sel_matrix)) >= 1
        sel_matrix = zeros(size(sel_matrix));
        visualize_transducer_array_surfaces(hObject);
    end
else
    if (exist('Icons\En_dis_ampl_trans_change_s&w.bmp','file') ~= 0)
        image_pic = imread('Icons\En_dis_ampl_trans_change_s&w.bmp');
        set(handles.en_dis_ampl_trans_change_button,'cdata',image_pic);
    end
    % Panel Visible on
    set(handles.trans_ampl_panel,'visible','on');    
end

    
function ampl_trans_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ampl_trans_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ampl_trans_edit as text
%        str2double(get(hObject,'String')) returns contents of ampl_trans_edit as a double
global en_matrix sel_matrix;
global flag_sel;

text = get(handles.ampl_trans_edit,'string');
num = str2double(text);
if num <= 100 && num >= 0
    % All right
    en_matrix(find(sel_matrix > 0)) = num/100;
    % Modify done
    set(handles.ampl_trans_edit,'foregroundcolor', 'g');
    % Visualisierung
    visualize_transducer_array_surfaces(hObject);            
else
    % We have a invalid number
    set(handles.ampl_trans_edit,'foregroundcolor', 'r');
end


% --- Executes during object creation, after setting all properties.
function ampl_trans_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ampl_trans_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Cancel button in Waitbar.
function waitbar_cancel_button(hObject, eventdata, handles)
global cancel_button n_loop size_waves_frec_x;
global var1_count var2_count var1 var2;
cancel_button = 1;
%handles = guidata(hObject);

if isfield(handles.near_field_characteristics_panel,'visible')
    if strcmp(get(handles.near_field_characteristics_panel,'visible'),'off')
        % WITH Approximation
        n_loop = size_waves_frec_x + 1;
    else
        % WITHOUT Approximation
        var1_count = var1 + 1;
        var2_count = var2 + 1;
    end
else
    
    %%%KILL them ALL!!!
    h=get(hObject,'Parent');
    if strcmp(lower(get(h,'Type')),'figure')
        delete(h);
    else
         if strcmp(lower(get(hObject,'Type')),'figure')
            delete(hObject);
         end
    end
end



% --- Executes on button press in near_field_characteristics_button.
function near_field_characteristics_button_Callback(hObject, eventdata, handles)
% hObject    handle to near_field_characteristics_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of near_field_characteristics_button
if strcmp(get(handles.near_field_characteristics_panel,'visible'),'off')
    % Visible = Off
    % Axes
    set(handles.axes1,'visible', 'off');
    set(allchild(handles.axes1),'visible','off');
    set(handles.axes2,'visible', 'off');
    set(allchild(handles.axes2),'visible','off');
    % Is the frequency-angle-diagram panel visible?
    if strcmp(get(handles.frequency_angle_diagram_panel,'visible'),'on')
        set(handles.frequency_angle_diagram_panel,'visible', 'off');
        set(handles.frequency_angle_diagram_button,'value', 0);
        pause(0.01);
        % To see the Graphic 3
        set(handles.axes3,'visible', 'on');
        set(allchild(handles.axes3),'visible','on');
        set(handles.save_img_rect_patch_button,'visible','on');        
    end    
    set(handles.axes3,'visible', 'off');
    set(allchild(handles.axes3),'visible','off');
    set(allchild(handles.axes5),'visible','off');    
    set(allchild(handles.axes6),'visible','off');    
    % Buttons   
    set(handles.save_img_entire_arrangement_button,'visible','off');
    set(handles.save_img_xy_button,'visible','off');
    set(handles.save_img_rect_patch_button,'visible','off');
    set(handles.save_img_c_all_vertical_button,'visible','off');
    set(handles.save_img_c_all_horizontal_button,'visible','off');
    set(handles.frequency_angle_diagram_button,'visible','off');
    % Extras
    set(handles.axes5_text,'visible','off');
    set(handles.axes6_text,'visible','off');
    set(handles.checkbox_normalize,'visible','off');    
    pause(0.01);
    % Near field characteristics panel = on
    set(handles.near_field_characteristics_panel,'visible', 'on');
    set(handles.calc_plot_pushbotton,'enable','off');
else
    if strcmp(get(handles.near_field_characteristics_panel,'visible'),'on')
        set(handles.near_field_characteristics_panel,'visible', 'off');
        set(handles.calc_plot_pushbotton,'enable','on');      
        pause(0.01);
        % Visible = On
        set(handles.axes1,'visible', 'on');
        set(allchild(handles.axes1),'visible','on');
        set(handles.axes2,'visible', 'on');
        set(allchild(handles.axes2),'visible','on');
        set(handles.axes3,'visible', 'on');
        set(allchild(handles.axes3),'visible','on');
        set(allchild(handles.axes5),'visible','on');
        set(allchild(handles.axes6),'visible','on');
        set(handles.save_img_entire_arrangement_button,'visible','on');        
        set(handles.checkbox_normalize,'visible','on');
        % Buttons   
        set(handles.save_img_entire_arrangement_button,'visible','on');
        set(handles.save_img_xy_button,'visible','on');
        set(handles.save_img_rect_patch_button,'visible','on');
        set(handles.save_img_c_all_vertical_button,'visible','on');
        set(handles.save_img_c_all_horizontal_button,'visible','on');
        set(handles.frequency_angle_diagram_button,'visible','on');
        % Extras
        set(handles.axes5_text,'visible','on');
        set(handles.axes6_text,'visible','on');
        set(handles.checkbox_normalize,'visible','on');        
    end
end


function input_u_0_edit_Callback(hObject, eventdata, handles)
% hObject    handle to input_u_0_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of input_u_0_edit as text
%        str2double(get(hObject,'String')) returns contents of input_u_0_edit as a double


% --- Executes during object creation, after setting all properties.
function input_u_0_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_u_0_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_u_0_Callback(hObject, eventdata, handles)
% hObject    handle to slider_u_0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliderValue = get(handles.slider_u_0,'Value');
 
global u_00;
%puts the slider value into the edit text component
set(handles.input_u_0_edit,'String', num2str(u_00 + sliderValue*1));
 
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider_u_0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_u_0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function input_var1_steps_edit_Callback(hObject, eventdata, handles)
% hObject    handle to input_var1_steps_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of input_var1_steps_edit as text
%        str2double(get(hObject,'String')) returns contents of input_var1_steps_edit as a double


% --- Executes during object creation, after setting all properties.
function input_var1_steps_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_var1_steps_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_var1_steps_Callback(hObject, eventdata, handles)
% hObject    handle to slider_var1_steps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliderValue = get(handles.slider_var1_steps,'Value');
 
global var10;
%puts the slider value into the edit text component
set(handles.input_var1_steps_edit,'String', num2str(var10 + sliderValue*10));
 
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider_var1_steps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_var1_steps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function input_impedance_edit_Callback(hObject, eventdata, handles)
% hObject    handle to input_impedance_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of input_impedance_edit as text
%        str2double(get(hObject,'String')) returns contents of input_impedance_edit as a double


% --- Executes during object creation, after setting all properties.
function input_impedance_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_impedance_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_impedance_Callback(hObject, eventdata, handles)
% hObject    handle to slider_impedance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliderValue = get(handles.slider_impedance,'Value');
 
global impedance0;
%puts the slider value into the edit text component
set(handles.input_impedance_edit,'String', num2str(impedance0 + sliderValue*100000));
 
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider_impedance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_impedance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function input_z_end_edit_Callback(hObject, eventdata, handles)
% hObject    handle to input_var1_steps_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of input_var1_steps_edit as text
%        str2double(get(hObject,'String')) returns contents of input_var1_steps_edit as a double


% --- Executes during object creation, after setting all properties.
function input_z_end_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_var1_steps_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_z_end_Callback(hObject, eventdata, handles)
% hObject    handle to slider_var1_steps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
% Get slider value
sliderValue = get(handles.slider_z_end,'Value');
 
global lambda z_end0;
if strcmp(get(handles.unit_z_distance_from_observer_text, 'string'), 'm') == 1
    %puts the slider value into the edit text component
    set(handles.input_z_end_edit,'String', num2str(z_end0 + sliderValue*0.001));
else
    if strcmp(get(handles.unit_z_distance_from_observer_text, 'string'), 'lambda') == 1
        f = str2double(get(handles.input_frequency_edit,'String'));         % Frequency
        c = str2double(get(handles.input_speed_of_sound_edit,'String'));    % Speed of sound
        lambda = c/f;
        z_end_value = (z_end0/lambda) + sliderValue*0.5;     
        set(handles.input_z_end_edit,'String', num2str(z_end_value));
    end
end

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider_z_end_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_var1_steps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function input_x_end_edit_Callback(hObject, eventdata, handles)
% hObject    handle to input_var1_steps_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of input_var1_steps_edit as text
%        str2double(get(hObject,'String')) returns contents of input_var1_steps_edit as a double


% --- Executes during object creation, after setting all properties.
function input_x_end_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_var1_steps_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_x_end_Callback(hObject, eventdata, handles)
% hObject    handle to slider_var1_steps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
% Get slider value
sliderValue = get(handles.slider_x_end,'Value');
 
global lambda x_end0;
if strcmp(get(handles.unit_x_distance_from_observer_text, 'string'), 'm') == 1
    %puts the slider value into the edit text component
    set(handles.input_x_end_edit,'String', num2str(x_end0 + sliderValue*0.001));
else
    if strcmp(get(handles.unit_x_distance_from_observer_text, 'string'), 'lambda') == 1
        f = str2double(get(handles.input_frequency_edit,'String'));         % Frequency
        c = str2double(get(handles.input_speed_of_sound_edit,'String'));    % Speed of sound
        lambda = c/f;
        x_end_value = (x_end0/lambda) + sliderValue*0.5;        
        set(handles.input_x_end_edit,'String', num2str(x_end_value));
    end
end

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider_x_end_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_var1_steps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function input_var2_steps_edit_Callback(hObject, eventdata, handles)
% hObject    handle to input_var2_steps_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of input_var2_steps_edit as text
%        str2double(get(hObject,'String')) returns contents of input_var2_steps_edit as a double


% --- Executes during object creation, after setting all properties.
function input_var2_steps_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_var2_steps_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_var2_steps_Callback(hObject, eventdata, handles)
% hObject    handle to slider_var2_steps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliderValue = get(handles.slider_var2_steps,'Value');
 
global var20;
%puts the slider value into the edit text component
set(handles.input_var2_steps_edit,'String', num2str(var20 + sliderValue*10));
 
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider_var2_steps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_var2_steps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function input_x_rect_patch_dim_steps_edit_Callback(hObject, eventdata, handles)
% hObject    handle to input_x_rect_patch_dim_steps_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of input_x_rect_patch_dim_steps_edit as text
%        str2double(get(hObject,'String')) returns contents of input_x_rect_patch_dim_steps_edit as a double


% --- Executes during object creation, after setting all properties.
function input_x_rect_patch_dim_steps_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_x_rect_patch_dim_steps_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_x_rect_patch_dim_steps_Callback(hObject, eventdata, handles)
% hObject    handle to slider_x_rect_patch_dim_steps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliderValue = get(handles.slider_x_rect_patch_dim_steps,'Value');
 
global x_trans_dist_steps0;
%puts the slider value into the edit text component
set(handles.input_x_rect_patch_dim_steps_edit,'String', num2str(x_trans_dist_steps0 + sliderValue*10));
 
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider_x_rect_patch_dim_steps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_x_rect_patch_dim_steps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function input_y_rect_patch_dim_steps_edit_Callback(hObject, eventdata, handles)
% hObject    handle to input_y_rect_patch_dim_steps_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of input_y_rect_patch_dim_steps_edit as text
%        str2double(get(hObject,'String')) returns contents of input_y_rect_patch_dim_steps_edit as a double


% --- Executes during object creation, after setting all properties.
function input_y_rect_patch_dim_steps_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_y_rect_patch_dim_steps_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_y_rect_patch_dim_steps_Callback(hObject, eventdata, handles)
% hObject    handle to slider_y_rect_patch_dim_steps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliderValue = get(handles.slider_y_rect_patch_dim_steps,'Value');
 
global y_trans_dist_steps0;
%puts the slider value into the edit text component
set(handles.input_y_rect_patch_dim_steps_edit,'String', num2str(y_trans_dist_steps0 + sliderValue*10));
 
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider_y_rect_patch_dim_steps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_y_rect_patch_dim_steps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in save_input_signal_config_button.
function save_input_signal_config_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_input_signal_config_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global en_matrix;
global phase_x_matrix phase_y_matrix;
[filename, pathname] = uiputfile('*.tac','Save the current input signal configuration file (*.tac)');

if (length(filename) > 1) || (length(pathname) > 1)
    % If there are a valid path so it save the configuration
    fid =  fopen(sprintf('%s%s',pathname,filename),'wt');
    fprintf(fid,'*** TRAVELING WAVE ***\n');
    fprintf(fid,'speed of sound = %s\n', get(handles.input_speed_of_sound_edit,'String'));
    fprintf(fid,'*** XY - ARRAY PARAMETERS ***\n');
    fprintf(fid,'# x-elements = %s\n',get(handles.input_number_of_x_element_edit,'String'));
    fprintf(fid,'x element spacing = %s\n', get(handles.input_x_element_spacing_edit,'String'));
    fprintf(fid,'x phase shift = %s\n', get(handles.input_x_phase_shift_edit,'String'));
    fprintf(fid,'# y-elements = %s\n',get(handles.input_number_of_y_element_edit,'String'));
    fprintf(fid,'y element spacing = %s\n', get(handles.input_y_element_spacing_edit,'String'));
    fprintf(fid,'y phase shift = %s\n', get(handles.input_y_phase_shift_edit,'String'));
    fprintf(fid,'*** RECT. PATCH PARAMETERS ***\n');
    fprintf(fid,'x dimensions = %s\n', get(handles.input_x_dimensions_edit,'String'));
    fprintf(fid,'y dimensions = %s\n', get(handles.input_y_dimensions_edit,'String'));
    fprintf(fid,'*** TRANSDUCER ARRAY SURFACES ***\n');
    fprintf(fid,'Y   X   AMPLITUDE   PHASE-X   PHASE-Y\n');
    for y=1:1:str2double(get(handles.input_number_of_y_element_edit,'String'))
        for x=1:1:str2double(get(handles.input_number_of_x_element_edit,'String'))
            fprintf(fid,'%d   %d   = %1.6f  = %3.0f       = %3.0f\n',y,x,en_matrix(y,x),(phase_x_matrix(y,x)*180/pi),(phase_y_matrix(y,x)*180/pi));
        end
    end
    fclose(fid);
end


% --- Executes on button press in open_input_signal_config_button.
function open_input_signal_config_button_Callback(hObject, eventdata, handles)
% hObject    handle to open_input_signal_config_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global n_x n_y old_n_x old_n_y;
global en_matrix sel_matrix;
global phase_x_matrix phase_y_matrix;
global d_arrspa_x d_arrspa_y Phas_0_x Phas_0_y;
global d_padim_x d_padim_y;

error = 0;
[filename, pathname] = uigetfile('*.tac', 'Select a input signal configuration file (*.tac)');

if (length(filename) > 1) || (length(pathname) > 1)
    % If there are a valid file so it opens and loads the configuration
    fid =  fopen(sprintf('%s%s',pathname,filename),'rt');
    if strcmp(fgetl(fid), '*** TRAVELING WAVE ***') == 1
        tline = fgetl(fid);       
        set(handles.input_speed_of_sound_edit, 'String', tline(strfind(tline,'=')+1:length(tline)));
    else
        error = error + 1;
    end
    if strcmp(fgetl(fid), '*** XY - ARRAY PARAMETERS ***') == 1 && error == 0
        tline = fgetl(fid);
        n_x = str2double(tline(strfind(tline,'=')+1:length(tline)));
        set(handles.input_number_of_x_element_edit,'String', n_x);
        tline = fgetl(fid);
        d_arrspa_x = str2double(tline(strfind(tline,'=')+1:length(tline)));
        set(handles.input_x_element_spacing_edit,'String',d_arrspa_x);
        tline = fgetl(fid);
        Phas_0_x = str2double(tline(strfind(tline,'=')+1:length(tline)));
        set(handles.input_x_phase_shift_edit,'String',Phas_0_x);
        tline = fgetl(fid);
        n_y = str2double(tline(strfind(tline,'=')+1:length(tline)));
        set(handles.input_number_of_y_element_edit,'String', n_y);
        tline = fgetl(fid);
        d_arrspa_y = str2double(tline(strfind(tline,'=')+1:length(tline)));
        set(handles.input_y_element_spacing_edit,'String',d_arrspa_y);
        tline = fgetl(fid);
        Phas_0_y = str2double(tline(strfind(tline,'=')+1:length(tline)));
        set(handles.input_y_phase_shift_edit,'String',Phas_0_y);
    else    
        error = error + 1;
    end
    if strcmp(fgetl(fid), '*** RECT. PATCH PARAMETERS ***')
        tline = fgetl(fid);
        d_padim_x = str2double(tline(strfind(tline,'=')+1:length(tline)));
        set(handles.input_x_dimensions_edit,'String',d_padim_x);
        tline = fgetl(fid);
        d_padim_y = str2double(tline(strfind(tline,'=')+1:length(tline)));
        set(handles.input_y_dimensions_edit,'String',d_padim_y);    
    else    
        error = error + 1;
    end

    if strcmp(fgetl(fid), '*** TRANSDUCER ARRAY SURFACES ***') == 1 && error == 0
        if strcmp(fgetl(fid), 'Y   X   AMPLITUDE   PHASE-X   PHASE-Y') == 1 && error == 0          
            % Update enable/seleccion matrixs
            old_n_x = n_x;
            old_n_y = n_y;
            en_matrix = ones(n_y,n_x);
            sel_matrix = zeros(n_y,n_x);
            for y=1:1:str2double(get(handles.input_number_of_y_element_edit,'String'))
                for x=1:1:str2double(get(handles.input_number_of_x_element_edit,'String'))
                    tline = fgetl(fid);
                    equals = strfind(tline,'=');
                    en_matrix(y,x) = str2double(tline(equals(1)+1:equals(1)+9));
                    phase_x_matrix(y,x) = str2double(tline(equals(2)+1:equals(2)+4))*pi/180;
                    phase_y_matrix(y,x) = str2double(tline(equals(3)+1:equals(3)+4))*pi/180;
                end
            end
            fclose(fid);
            visualize_transducer_array_surfaces(hObject);
        else
            error = error + 1;
        end
    else
        error = error + 1;
    end
    % Are there some errors?
    if error ~= 0
        set(handles.output_alarm_warning_edit,'visible','on');
        set(handles.output_alarm_warning_edit,'String','! Input signal config file is not valid !');
    else
        set(handles.output_alarm_warning_edit,'visible','off');
    end           
end


% --- Executes on button press in checkbox_impedance_ideal.
function checkbox_impedance_ideal_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_impedance_ideal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox_impedance_ideal

%checkboxStatus = 0, if the box is unchecked, 
%checkboxStatus = 1, if the box is checked  set(handles.check_impedance_ideal,'Value',true);

global check_impedance_ideal;

checkboxStatus = get(handles.checkbox_impedance_ideal,'Value');
if(checkboxStatus)
    % if box is checked,
    check_impedance_ideal = true;
    set(handles.open_impedance_characteristic_button,'Visible','off');
    set(handles.impedance_graphic_button,'Visible','off');
    set(handles.impedance_status_text,'Visible','off');    
    if strcmp(get(handles.impedance_panel,'Visible'),'on') == 1
        set(handles.impedance_panel,'Visible','off');
        set(handles.config_panel,'Visible','on');
        set(handles.impedance_graphic_button,'Value',0);
        set(handles.attenuation_control_panel,'Visible','on');
    end
else
    % if box is unchecked, 
    check_impedance_ideal = false;
    set(handles.open_impedance_characteristic_button,'Visible','on');
    set(handles.impedance_graphic_button,'Visible','on');
    set(handles.impedance_status_text,'Visible','on');
end

% --- Executes on button press in open_impedance_characteristic_button.
function open_impedance_characteristic_button_Callback(hObject, eventdata, handles)
% hObject    handle to open_impedance_characteristic_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global FREC AMPL PHAS POW;
global impedance_array;

% Reset impedace array
impedance_array = zeros(4,1);
error = 0;

[filename, pathname] = uigetfile('*.txt', 'Select an impedance characteristic file (*.txt)');

if (length(filename) > 1) || (length(pathname) > 1)
    % If there are a valid file so it opens and loads the configuration
    fid =  fopen(sprintf('%s%s',pathname,filename),'rt');

    % Read the first line
    tline = fgetl(fid);
    num_imp = 0;
    % Loking for information
    while strcmp(tline,'X-Achse	A-Daten	B-Daten') ~= 1 && ischar(tline) % End of file
        tline = fgetl(fid);    
    end
    if ischar(tline) == 0
        % This file has no infomation
        error = error + 1;
    else
        % Read information and save in array
        tline = fgetl(fid);
        while ischar(tline) && ~isempty(tline)    % while tline is char I save the information
            num_imp = num_imp + 1;
            aux = str2num(tline);
            impedance_array(:,num_imp) = [aux(1); aux(2); aux(3); 0];
            tline = fgetl(fid);
        end        
    end
    fclose(fid);
    % If we have no errors...
    if error == 0
        % When the information was read       
        % Plot amplitude, phase and active power
        axes(handles.axes13);
        cla(handles.axes13);        
        plot(impedance_array(FREC,:),impedance_array(AMPL,:)/max(impedance_array(AMPL,:)),'b');
        hold on;
        plot(impedance_array(FREC,:),((impedance_array(PHAS,:)-min(impedance_array(PHAS,:)))/max(abs(impedance_array(PHAS,:)-min(impedance_array(PHAS,:))))),'g');       
        % Active Power
        impedance_array(POW,:) = ((cos(pi.*impedance_array(PHAS,:)./180)).*(1./impedance_array(AMPL,:)));
        hold on;
        plot(impedance_array(FREC,:),impedance_array(POW,:)/max(impedance_array(POW,:)),'r');
        ylabel('Amplitude / Phase / Active Power');
        xlabel('Frequency [Hz]');        
        title(sprintf('File: %s\n\nTransducer impedance\nAmplitude: blue - Phase: green - Active Power: red',filename),'Interpreter','none');        
        % Impendace status text update
        set(handles.impedance_status_text,'foregroundcolor', 'g');
        set(handles.impedance_status_text,'string', 'Load successfully');
        set(handles.impedance_graphic_button,'enable', 'on');
    else
        % Set error
        impedance_array = -1*ones(1,1);
        set(handles.impedance_status_text,'foregroundcolor', 'r');
        set(handles.impedance_status_text,'string', 'File error');
        set(handles.impedance_graphic_button,'enable', 'off');
    end
else
    impedance_array = -1*ones(1,1);
    set(handles.impedance_status_text,'foregroundcolor', 'black');
    set(handles.impedance_status_text,'string', 'No file selected');
    set(handles.impedance_graphic_button,'enable', 'off');
end


% --- Executes on button press in impedance_graphic_button.
function impedance_graphic_button_Callback(hObject, eventdata, handles)
% hObject    handle to impedance_graphic_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(handles.impedance_panel,'Visible'),'off') == 1
    set(handles.config_panel,'Visible','off');
    set(handles.attenuation_panel,'Visible','off');
    set(handles.attenuation_graphic_button,'Value',0);
    set(handles.attenuation_control_panel,'Visible','off');
    set(handles.impedance_panel,'Visible','on');
else
    set(handles.impedance_panel,'Visible','off');
    set(handles.config_panel,'Visible','on');
    set(handles.attenuation_control_panel,'Visible','on');    
end


% --- Executes on button press in checkbox_adjust_steps.
function checkbox_adjust_steps_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_adjust_steps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox_adjust_steps


function phase_x_trans_edit_Callback(hObject, eventdata, handles)
% hObject    handle to phase_x_trans_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of phase_x_trans_edit as text
%        str2double(get(hObject,'String')) returns contents of phase_x_trans_edit as a double
global phase_x_matrix sel_matrix;
global flag_sel;

text = get(handles.phase_x_trans_edit,'string');
num = str2double(text);
if num <= 360 && num >= -360
    % All right
    phase_x_matrix(find(sel_matrix > 0)) = num * pi/180;
    % Modify done
    set(handles.phase_x_trans_edit,'foregroundcolor', 'g');
    % Visualisierung
    visualize_transducer_array_surfaces(hObject);            
else
    % We have a invalid number
    set(handles.phase_x_trans_edit,'foregroundcolor', 'r');
end


% --- Executes during object creation, after setting all properties.
function phase_x_trans_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phase_x_trans_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function phase_y_trans_edit_Callback(hObject, eventdata, handles)
% hObject    handle to phase_y_trans_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of phase_y_trans_edit as text
%        str2double(get(hObject,'String')) returns contents of phase_y_trans_edit as a double
global phase_y_matrix sel_matrix;
global flag_sel;

text = get(handles.phase_y_trans_edit,'string');
num = str2double(text);
if num <= 360 && num >= -360
    % All right
    phase_y_matrix(find(sel_matrix > 0)) = num * pi/180;
    % Modify done
    set(handles.phase_y_trans_edit,'foregroundcolor', 'g');
    % Visualisierung
    visualize_transducer_array_surfaces(hObject);            
else
    % We have a invalid number
    set(handles.phase_y_trans_edit,'foregroundcolor', 'r');
end

% --- Executes during object creation, after setting all properties.
function phase_y_trans_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phase_y_trans_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over unit_x_distance_from_observer_text.
function unit_x_distance_from_observer_text_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to unit_x_distance_from_observer_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global lambda;

% Get slider value and the current lambda value
currentValue = str2double(get(handles.input_x_end_edit,'string'));  % Current value
f = str2double(get(handles.input_frequency_edit,'String'));         % Frequency
c = str2double(get(handles.input_speed_of_sound_edit,'String'));    % Speed of sound
lambda = c/f;

if strcmp(get(handles.unit_x_distance_from_observer_text, 'string'), 'm') == 1 && get(handles.sine_radiobutton, 'value') == 0
    % Update parameter
    set(handles.unit_x_distance_from_observer_text, 'string', 'lambda');
    set(handles.input_x_end_edit,'String', num2str(currentValue/lambda));
else
    if strcmp(get(handles.unit_x_distance_from_observer_text, 'string'), 'lambda') == 1 && get(handles.sine_radiobutton, 'value') == 0
        % Update parameter
        set(handles.unit_x_distance_from_observer_text, 'string', 'm');
        %puts the slider value into the edit text component
        set(handles.input_x_end_edit,'String', num2str(currentValue*lambda));        
    end
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over unit_z_distance_from_observer_text.
function unit_z_distance_from_observer_text_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to unit_z_distance_from_observer_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global lambda;

% Get slider value and the current lambda value
currentValue = str2double(get(handles.input_z_end_edit,'string'));  % Current value
f = str2double(get(handles.input_frequency_edit,'String'));         % Frequency
c = str2double(get(handles.input_speed_of_sound_edit,'String'));    % Speed of sound
lambda = c/f;

if strcmp(get(handles.unit_z_distance_from_observer_text, 'string'), 'm') == 1 && get(handles.sine_radiobutton, 'value') == 0
    % Update parameter
    set(handles.unit_z_distance_from_observer_text, 'string', 'lambda');
    set(handles.input_z_end_edit,'String', num2str(currentValue/lambda));
else
    if strcmp(get(handles.unit_z_distance_from_observer_text, 'string'), 'lambda') == 1 && get(handles.sine_radiobutton, 'value') == 0
        % Update parameter
        set(handles.unit_z_distance_from_observer_text, 'string', 'm');
        %puts the slider value into the edit text component
        set(handles.input_z_end_edit,'String', num2str(currentValue*lambda));        
    end
end



function input_y_end_edit_Callback(hObject, eventdata, handles)
% hObject    handle to input_y_end_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_y_end_edit as text
%        str2double(get(hObject,'String')) returns contents of input_y_end_edit as a double


% --- Executes during object creation, after setting all properties.
function input_y_end_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_y_end_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_y_end_Callback(hObject, eventdata, handles)
% hObject    handle to slider_y_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
% Get slider value
sliderValue = get(handles.slider_y_end,'Value');
 
global lambda y_end0;
if strcmp(get(handles.unit_x_distance_from_observer_text, 'string'), 'lambda') == 1 && get(handles.sine_radiobutton, 'value') == 0
    f = str2double(get(handles.input_frequency_edit,'String'));         % Frequency
    c = str2double(get(handles.input_speed_of_sound_edit,'String'));    % Speed of sound
    lambda = c/f;
    y_end_value = (y_end0/lambda) + sliderValue*0.05;
    set(handles.input_y_end_edit,'String', num2str(y_end_value));
else
    %puts the slider value into the edit text component
    set(handles.input_y_end_edit,'String', num2str(y_end0 + sliderValue*0.001));
end


% --- Executes during object creation, after setting all properties.
function slider_y_end_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_y_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pulse_width_base_time_text.
function pulse_width_base_time_text_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pulse_width_base_time_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(handles.pulse_width_base_time_text, 'string'), 'ns') == 1
    set(handles.pulse_width_base_time_text, 'string', 'x 10ns');
else
    if strcmp(get(handles.pulse_width_base_time_text, 'string'), 'x 10ns') == 1
        set(handles.pulse_width_base_time_text, 'string', 'x 100ns');
    else
        if strcmp(get(handles.pulse_width_base_time_text, 'string'), 'x 100ns') == 1
            set(handles.pulse_width_base_time_text, 'string', 'ns');        
        end
    end
end


% --- Executes on selection change in surface_popupmenu.
function surface_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to surface_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns surface_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from surface_popupmenu
surface = get(handles.surface_popupmenu,'value');

switch surface
    case 1      % Surface X-Z
        set(handles.var1_surface_text,'string','steps of X distance:');
        set(handles.var2_surface_text,'string','steps of Z distance:');
    case 2      % Surface Y-Z
        set(handles.var1_surface_text,'string','steps of Y distance:');
        set(handles.var2_surface_text,'string','steps of Z distance:');
    case 3      % Surface Y-Z
        set(handles.var1_surface_text,'string','steps of X distance:');
        set(handles.var2_surface_text,'string','steps of Y distance:');
end
        
% --- Executes during object creation, after setting all properties.
function surface_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to surface_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_axis_adjust.
function checkbox_axis_adjust_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_axis_adjust (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox_axis_adjust


% --- Executes on button press in checkbox_attenuation_ideal1.
function checkbox_attenuation_ideal_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_attenuation_ideal1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_attenuation_ideal1

%checkboxStatus = 0, if the box is unchecked, 
%checkboxStatus = 1, if the box is checked  set(handles.check_impedance_ideal,'Value',true);

global check_attenuation_ideal;

checkboxStatus = get(handles.checkbox_attenuation_ideal,'Value');
if(checkboxStatus)
    % if box is checked,
    check_attenuation_ideal = true;
    set(handles.open_attenuation_button,'Visible','off');
    set(handles.attenuation_graphic_button,'Visible','off');
    set(handles.attenuation_status_text,'Visible','off');
    if strcmp(get(handles.attenuation_panel,'Visible'),'on') == 1
        set(handles.attenuation_panel,'Visible','off');
        set(handles.config_panel,'Visible','on');
        set(handles.attenuation_graphic_button,'Value',0);
    end    
else
    % if box is unchecked, 
    check_attenuation_ideal = false;
    set(handles.open_attenuation_button,'Visible','on');
    set(handles.attenuation_graphic_button,'Visible','on');
    set(handles.attenuation_status_text,'Visible','on');
end

% --- Executes on button press in open_attenuation_button.
function open_attenuation_button_Callback(hObject, eventdata, handles)
% hObject    handle to open_attenuation_button1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Conversion dB-Np:
%       1[Np] = 20*log10(exp(1))     = 8.685889638 [dB]
%       1[dB] = 1/(20*log10(exp(1))) = 0.115129254 [Np]

global FREC AMPL;
global attenuation_array;

% Reset impedace array
attenuation_array = zeros(2,1);
error = 0;

[filename, pathname] = uigetfile('*.att', 'Select an attenuation file (*.att)');

if (length(filename) > 1) || (length(pathname) > 1)
    % If there are a valid file so it opens and loads the configuration
    fid =  fopen(sprintf('%s%s',pathname,filename),'rt');

    % Loking for the Unit information
    tline = fgetl(fid);
    while strcmp(tline,'Unit:') ~= 1 && ischar(tline) % End of file
        tline = fgetl(fid);    
    end
    if ischar(tline) == 0
        % This file has no infomation
        error = error + 1;
    else    
        % Read the Unit and check errors
        % Example: "dB/(cm*MHZ)"
        % The frequency of file is always in Hz
        tline = fgetl(fid);
        if ischar(tline) && ~isempty(tline)            
            switch tline(1:(strfind(tline,'/')-1))
                case 'dB'
                    conv_to_Np = 1/(20*log10(exp(1)));
                case 'Np'
                    conv_to_Np = 1;
            end
            switch tline((strfind(tline,'(')+1):(strfind(tline,'*')-1))
                case 'm'
                    conv_to_m = 1;
                case 'cm'
                    conv_to_m = 0.01;
                case 'mm'
                    conv_to_m = 0.001;
            end
        else
            error = error + 1;
        end
        % Loking for the information
        tline = fgetl(fid);
        while strcmp(tline,'Freq-Alpha') ~= 1 && ischar(tline) % End of file
            tline = fgetl(fid);    
        end    
        if ischar(tline) == 0
            % This file has no infomation
            error = error + 1;
        else
            % Read information and save in array
            num_imp = 0;
            tline = fgetl(fid);
            while ischar(tline) && ~isempty(tline)    % while tline is char I save the information
                num_imp = num_imp + 1;
                aux = str2num(tline);
                attenuation_array(:,num_imp) = [aux(1); aux(2)*conv_to_Np/conv_to_m];
                tline = fgetl(fid);
            end
        end
    end
    fclose(fid);
    % If we have no errors...
    if error == 0
        % When the information was read       
        % Plot graphic
        axes(handles.axes14);
        plot(attenuation_array(FREC,:),attenuation_array(AMPL,:));
        att_max = attenuation_array(FREC,find(attenuation_array(AMPL,:) == max(attenuation_array(AMPL,:))));
        att_min = attenuation_array(FREC,find(attenuation_array(AMPL,:) == min(attenuation_array(AMPL,:))));
        xlabel('Frequency [Hz]');
        ylabel('Attenuation [Np/m]');
        title(sprintf('File: %s\n\nAttenuation\nMax = %d [Hz] - Min = %d [Hz]',filename,att_max,att_min),'Interpreter','none');        
        % Attenuation status text update
        set(handles.attenuation_status_text,'foregroundcolor', 'g');
        set(handles.attenuation_status_text,'string', 'Load successfully');
        set(handles.attenuation_graphic_button,'enable', 'on');
    else
        % Set error
        attenuation_array = -1*ones(1,1);
        set(handles.attenuation_status_text,'foregroundcolor', 'r');
        set(handles.attenuation_status_text,'string', 'File error');
        set(handles.attenuation_graphic_button,'enable', 'off');
    end
else
    attenuation_array = -1*ones(1,1);
    set(handles.attenuation_status_text,'foregroundcolor', 'black');
    set(handles.attenuation_status_text,'string', 'No file selected');
    set(handles.attenuation_graphic_button,'enable', 'off');
end

% --- Executes on button press in attenuation_graphic_button1.
function attenuation_graphic_button_Callback(hObject, eventdata, handles)
% hObject    handle to attenuation_graphic_button1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of attenuation_graphic_button1
if strcmp(get(handles.attenuation_panel,'Visible'),'off') == 1
    set(handles.config_panel,'Visible','off');
    set(handles.impedance_panel,'Visible','off');
    set(handles.impedance_graphic_button,'Value',0);
    set(handles.attenuation_panel,'Visible','on');
else
    set(handles.attenuation_panel,'Visible','off');
    set(handles.config_panel,'Visible','on');
end


% --- Executes on button press in save_img_rect_patch_button.
function save_img_rect_patch_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_img_rect_patch_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in save_img_xy_button.
function save_img_xy_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_img_xy_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in save_img_c_all_vertical_button.
function save_img_c_all_vertical_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_img_c_all_vertical_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in save_img_entire_arrangement_button.
function save_img_entire_arrangement_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_img_entire_arrangement_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in save_img_c_all_horizontal_button.
function save_img_c_all_horizontal_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_img_c_all_horizontal_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in save_img_transducer_array_surface_button.
function save_img_transducer_array_surface_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_img_transducer_array_surface_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in save_all_images_button.
function save_all_images_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_all_images_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in save_img_frequency_angle_diagram_button.
function save_img_frequency_angle_diagram_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_img_frequency_angle_diagram_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in save_img_spatial_trans_characteristics_button.
function save_img_spatial_trans_characteristics_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_img_spatial_trans_characteristics_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in save_img_pressure_middle_x_axis_button.
function save_img_pressure_middle_x_axis_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_img_pressure_middle_x_axis_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in near_field_calc_plot_pushbotton.
function near_field_calc_plot_pushbotton_Callback(hObject, eventdata, handles)
% hObject    handle to near_field_calc_plot_pushbotton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in save_img_impedance_button.
function save_img_impedance_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_img_impedance_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in save_img_traveling_wave_button.
function save_img_traveling_wave_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_img_traveling_wave_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in save_img_attenuation_button.
function save_img_attenuation_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_img_attenuation_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



 function DrawWaveForm(type_of_unit,wave, handles) 
     global AMPL FREC TIME
    axes(handles.axes9);
    if type_of_unit == 0
        plot(wave(TIME,:), real(wave(AMPL,:)));
        xlabel('Time [s]');
        ylabel('Amplitude');
        title('Wave - Time');
    else
        plotyy(wave(FREC,:), abs(wave(AMPL,:)),wave(FREC,:), angle(wave(AMPL,:)));
        xlabel('Frequency [Hz]');
        ylabel('Amplitude');
        title('Wave - Frequency');
    end


% --- Executes on button press in checkbox18.
function checkbox18_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global plane
global var1_axis;
global var2_axis;
global surface_nf;
global y_end;
global x_end;
global z_end;

 switch surface_nf
      case 1          % Surface X-Z
      visxx='x'; visyy='z'; viszz='y'; viszzend=y_end;%                              
      case 2          % Surface Y-Z
      visxx='y'; visyy='z'; viszz='y'; viszzend=x_end;%                             
      case 3          % Surface X-Y
      visxx='x'; visyy='y'; viszz='y'; viszzend=z_end;%                               
 end


% Hint: get(hObject,'Value') returns toggle state of checkbox18
if get(handles.phase_vis,'Value')==0 %%only for AMP
    if get(hObject,'Value')==1
        axes(handles.axes12);
        imagesc(var1_axis, var2_axis,log(sum(abs(plane),3))); colorbar;
        xlabel ([visxx ' in [m]']); ylabel ([visyy ' in [m]']);
        title(sprintf(['Calculated log. pressure\n ' num2str(visxx) '-' num2str(visyy) ' plane with ' num2str(viszz) ' = %f [m]'], viszzend));
      else
        axes(handles.axes12);
        imagesc(var1_axis, var2_axis,sum(abs(plane),3)); colorbar;
        xlabel ([visxx ' in [m]']); ylabel ([visyy ' in [m]']);
        title(sprintf(['Calculated pressure\n ' num2str(visxx) '-' num2str(visyy) ' plane with ' num2str(viszz) ' = %f [m]'], viszzend));
        %set(get(gca,'Children'),'CData',exp(get(get(gca,'Children'),'CData')))
    end
end


% --- Executes on button press in phase_vis.
function phase_vis_Callback(hObject, eventdata, handles)
% hObject    handle to phase_vis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of phase_vis
global plane;
global var1_axis;
global var2_axis;
global surface_nf;
global y_end;
global x_end;
global z_end;

 switch surface_nf
      case 1          % Surface X-Z
      visxx='x'; visyy='z'; viszz='y'; viszzend=y_end;%                              
      case 2          % Surface Y-Z
      visxx='y'; visyy='z'; viszz='y'; viszzend=x_end;%                             
      case 3          % Surface X-Y
      visxx='x'; visyy='y'; viszz='y'; viszzend=z_end;%                               
 end



if get(hObject,'Value')==1
    axes(handles.axes12);
    temp=sum(angle(plane),3); 
    imagesc(var1_axis, var2_axis, temp);colorbar;
    xlabel ([visxx ' in [m]']); ylabel ([visyy ' in [m]']);
    title(sprintf(['Calculated phase\n ' num2str(visxx) '-' num2str(visyy) ' plane with ' num2str(viszz) ' = %f [m]'], viszzend));
  
else
    axes(handles.axes12);
    imagesc(var1_axis, var2_axis, sum(abs(plane),3)); colorbar;
    xlabel ([visxx ' in [m]']); ylabel ([visyy ' in [m]']);
    title(sprintf(['Calculated pressure\n ' num2str(visxx) '-' num2str(visyy) ' plane with ' num2str(viszz) ' = %f [m]'], viszzend));
     
end
