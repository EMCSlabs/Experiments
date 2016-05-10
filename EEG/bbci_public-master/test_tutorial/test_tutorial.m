function varargout = test_tutorial(varargin)
% TEST_TUTORIAL MATLAB code for test_tutorial.fig
%      TEST_TUTORIAL, by itself, creates a new TEST_TUTORIAL or raises the existing
%      singleton*.
%
%      H = TEST_TUTORIAL returns the handle to a new TEST_TUTORIAL or the handle to
%      the existing singleton*.
%
%      TEST_TUTORIAL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEST_TUTORIAL.M with the given input arguments.
%
%      TEST_TUTORIAL('Property','Value',...) creates a new TEST_TUTORIAL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before test_tutorial_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to test_tutorial_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help test_tutorial

% Last Modified by GUIDE v2.5 15-May-2015 17:51:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @test_tutorial_OpeningFcn, ...
                   'gui_OutputFcn',  @test_tutorial_OutputFcn, ...
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


% --- Executes just before test_tutorial is made visible.
function test_tutorial_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to test_tutorial (see VARARGIN)

% Choose default command line output for test_tutorial
handles.output = hObject;
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
unix('say Welcome to the Test tutorial. This tutorial is for korean subjects who will take a visual word recognition test. Please import the text file and press the start button when you are ready')
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes test_tutorial wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = test_tutorial_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in start.
function start_Callback(hObject, eventdata, handles)
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Importing TutorialText
pfile = get(handles.Text,'string');
%psnt = importdata(pfile);
fid = fopen(pfile,'r','n','UTF-8');
TT = textscan(fid,'%s','delimiter','\t');
fclose(fid);

kc_right_arrow = KbName('RightArrow');
kc_left_arrow = KbName('LeftArrow');
fid = fopen('sample_RL_result.txt','w');

set(handles.title,'visible','off');
set(handles.start,'visible','off');

con = 0;
for i = 1:length(TT{1})
    if i < 20
        set(handles.main,'string',TT{1}{i});
        pause(6);
    elseif i == 20
        for j = 20:29
            set(handles.main,'string','#######');
            pause(0.500);
            set(handles.main,'FontName','Times');
            set(handles.main,'FontAngle','italic');
            set(handles.main,'string',TT{1}{j+(2*con)-con});
            pause(0.050);
            set(handles.main,'string','#######');
            pause(0.020);
            set(handles.main,'FontAngle','normal');
            set(handles.main,'FontName','Arial');
            set(handles.main,'string',TT{1}{j+(2*con)-con});
            tic
            pause(0.1);
                  while 1
                    KbWait();
                    [keyIsDown secs keycodes] = KbCheck();
                        if keycodes(kc_right_arrow)
                           time = toc;
                           fprintf(fid,'%s %f\n','R',time);
                        break
                        elseif keycodes(kc_left_arrow)
                               time = toc;
                               fprintf(fid,'%s %f\n','L',time);
                        break
                        end
                    end

            set(handles.main,'string','');
            pause(0.900);
            set(handles.main,'string','-------');
            pause(2.000);
            set(handles.main,'string','');
            % Jittering
            jitter = randi([0 8])*0.1;
            pause(0.100+jitter);
              con = con+1;
        end

    elseif i >39
        set(handles.main,'string',TT{1}{i});
        pause(6);       
    end
end
fclose(fid);

set(handles.main,'string','Test Tutorial has been finished. Please let your director know you are ready to do the test.');
pause(0.1)
unix('say Test Tutorial has been finished. Please let your director know you are ready to do the test.')

% --- Executes on button press in Text.
function Text_Callback(hObject, eventdata, handles)
% hObject    handle to Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
unix('say Please import Korean tutorial text file, otherwise it wont work properly')
tutorialName = uigetfile({'*.txt';'*.*'},'File Selector');
set(handles.Text, 'string', tutorialName);
