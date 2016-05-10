function varargout = demo_v2(varargin)
% DEMO_V2 MATLAB code for demo_v2.fig
%      DEMO_V2, by itself, creates a new DEMO_V2 or raises the existing
%      singleton*.
%
%      H = DEMO_V2 returns the handle to a new DEMO_V2 or the handle to
%      the existing singleton*.
%
%      DEMO_V2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DEMO_V2.M with the given input arguments.
%
%      DEMO_V2('Property','Value',...) creates a new DEMO_V2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before demo_v2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to demo_v2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help demo_v2

% Last Modified by GUIDE v2.5 27-Nov-2015 00:36:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @demo_v2_OpeningFcn, ...
                   'gui_OutputFcn',  @demo_v2_OutputFcn, ...
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


% --- Executes just before demo_v2 is made visible.
function demo_v2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to demo_v2 (see VARARGIN)

% Choose default command line output for demo_v2
handles.output = hObject;

ginfo = groot;
set(gcf, 'position', [ 0 0 ginfo.ScreenSize(3:4) ]);
% Update handles structure
guidata(hObject, handles)

% UIWAIT makes demo_v2 wait for user response (see UIRESUME)
% uiwait(handles.fg_demo_v2);


% --- Outputs from this function are returned to the command line.
function varargout = demo_v2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%% initialize the data structure
state = struct();
set(gcf,'userdata',state);
state.scrObjAll = [handles.ed_lastn, handles.ed_firstn, handles.ed_id,...
    handles.txt_pi,handles.txt_lastn, handles.txt_firstn, handles.txt_id,...
    handles.pb_next,...
    handles.txt_inst, handles.pb_next,...
    handles.txt_fix,...
    handles.ed_w1, handles.ed_w2, ...
    handles.txt_w1, handles.txt_w2, handles.txt_conf1, handles.txt_conf2,...
    handles.rb_w1_1, handles.rb_w1_2, handles.rb_w1_3,...
    handles.rb_w2_1, handles.rb_w2_2, handles.rb_w2_3,...
    handles.bg_w1_conf, handles.bg_w2_conf,...
    handles.txt_closing, handles.pb_finish];
    
state.scrObj1 = [handles.ed_lastn, handles.ed_firstn, handles.ed_id,...
    handles.txt_pi,handles.txt_lastn, handles.txt_firstn, handles.txt_id,...
    handles.pb_next];

state.scrObj2 = [handles.txt_inst, handles.pb_next];

state.scrObj3 = [handles.txt_fix];

state.scrObj4 = [handles.ed_w1, handles.ed_w2, ...
    handles.txt_w1, handles.txt_w2, handles.txt_conf1, handles.txt_conf2,...
    handles.rb_w1_1, handles.rb_w1_2, handles.rb_w1_3,...
    handles.rb_w2_1, handles.rb_w2_2, handles.rb_w2_3,...
    handles.bg_w1_conf, handles.bg_w2_conf];

state.scrObj5 = [handles.txt_closing,handles.pb_finish];

state.words = [handles.ed_w1, handles.ed_w2];
state.radiobuttons = [handles.rb_w1_1, handles.rb_w1_2, handles.rb_w1_3,...
    handles.rb_w2_1, handles.rb_w2_2, handles.rb_w2_3];

state.stimuli = load('stim.mat'); % stim.mat as a combination of a wavfiles(1st column: signal, 2nd column: Fs)
state.lastn = []; state.firstn = []; state.id =[]; state.word = []; state.conf = []; 

state.scr = 1;
set(state.scrObjAll,'visible','off')
set(state.scrObj1,'visible','on')    
set(gcf,'userdata',state)


%% last name (lastn)
function ed_lastn_Callback(hObject, eventdata, handles)
% hObject    handle to ed_lastn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_lastn as text
%        str2double(get(hObject,'String')) returns contents of ed_lastn as a double
state = get(gcf,'userdata');
state.lastn = get(hObject,'String');
set(gcf,'userdata',state)


%% first name (firstn)
function ed_firstn_Callback(hObject, eventdata, handles)
% hObject    handle to ed_firstn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_firstn as text
%        str2double(get(hObject,'String')) returns contents of ed_firstn as a double
state = get(gcf,'userdata');
state.firstn = get(hObject,'String');
set(gcf,'userdata',state)
%% student id (id)
function ed_id_Callback(hObject, eventdata, handles)
% hObject    handle to ed_id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_id as text
%        str2double(get(hObject,'String')) returns contents of ed_id as a double
state = get(gcf,'userdata');
state.id = str2double(get(hObject,'String'));
set(gcf,'userdata',state)

%% from the start to the end of the whole task
% --- Executes on button press in pb_next.
function pb_next_Callback(hObject, eventdata, handles)
% hObject    handle to pb_next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
state = get(gcf,'userdata');
state.scr = state.scr+1;

switch state.scr
    case 2
        % the 2nd screen
        set(state.scrObjAll,'visible','off')
        set(state.scrObj2,'visible','on')
        
     case 3
        [num,~] = size(state.stimuli.stim);   
         for k = 1:num   
            % the 3rd screen
            set(state.scrObjAll,'visible','off')
            set(state.scrObj3,'visible','on')
            
            % play the first stimuli
            [y,Fs] = state.stimuli.stim{k,:};
            player = audioplayer(y,Fs);
            playblocking(player)

            % after the pause, go to the next screen (the 4th)
            set(state.scrObjAll,'visible','off')
            set(state.words,'string',[])
            set(state.radiobuttons,'value',0)
            set(state.scrObj4,'visible','on')
                        
            tLimit = 20; %20*n=>n seconds 
            % initializing a progress bar
            hAx = axes('Parent',handles.fg_demo_v2, 'XLim',[0 1], 'YLim',[0 1], ...
                'XTick',[], 'YTick',[], 'Box','on', 'Layer','top', ...
                'Units','pixel', 'Position',[400,750,600,25]); % left, bottom, width, height
            hPatch = patch([0 0 0 0], [0 1 1 0], 'r', 'Parent',hAx, ...
                'FaceColor','b', 'EdgeColor','none');
            %         hText = text(0.5, 0.5, sprintf('%.0f%%',0*100), ...
            %             'Parent',hAx, 'Color','w', 'BackgroundColor',[.9 .5 .5], ...
            %             'HorizontalAlign','center', 'VerticalAlign','middle', ...
            %             'FontSize',16, 'FontWeight','bold');
            
            % update the progress bar
            nStep = 20;
            for k = 1: tLimit*nStep
                set(hPatch, 'XData',[0 0 k/(tLimit*nStep) k/(tLimit*nStep)])
                %             set(hText, 'String',sprintf('%.0f%%',i/tLimit*10))
                pause(1/nStep)
            end
            %         delete(hText)
            delete(hAx)
            delete(findobj('type','patch'))
                                 
            % bring back the response of dictation task
            if ~isempty(get(handles.ed_w1,'String'))
                w1 = cellstr(get(handles.ed_w1,'String'));
            else
                w1 = cellstr('null');
            end
            
            if ~isempty(get(handles.ed_w2,'String'))
                w2 = cellstr(get(handles.ed_w2,'String'));
            else
                w2 = cellstr('null');
            end
            w = [w1 w2];
            
            % get confidence level of the word1
            uic1 = get(handles.bg_w1_conf,'SelectedObject');
            conf1 = get(uic1,'Tag');           
            if ~isempty(conf1)
                num_conf1 = str2double(conf1(end));  
            else
                num_conf1 = 0;
            end
            
            % get confidence level of the word2
            uic2 = get(handles.bg_w2_conf,'SelectedObject');
            conf2 = get(uic2,'Tag');            
            if ~isempty(conf2)
                num_conf2 = str2double(conf2(end));  
            else
                num_conf2 = 0;
            end 
            
            conf = [num_conf1 num_conf2];
            
            % save the responses in the structure 'state'
            state.word = [state.word; w];
            state.conf = [state.conf; conf];
         end 
         
        % the final screen 
        set(state.scrObjAll,'visible','off')
        set(state.scrObj5,'visible','on')
        
        set(gcf,'userdata',state)       
        state = get(gcf,'userdata');
        if isempty(state.lastn)
            state.lastn = 'null';
        end
        if isempty(state.firstn)
            state.firstn = 'null';
        end
        if isempty(state.id)
            state.id = 0;
        end
  
        fn = [state.lastn '_' state.firstn '_' num2str(state.id)]; % get the file name

        % extract the target contents from 'userdata'
        
        data = struct();
        data.word = getfield(state,'word');
        data.conf = getfield(state,'conf');
        data = struct2table(data);

        % rename the data and save it as a mat file
        eval([fn '= data;'])
        eval(['save(' '''' fn '.mat' '''' ',' '''' fn '''' ');'])
        

end
set(gcf,'userdata',state);


% --- Executes on button press in pb_finish.
function pb_finish_Callback(hObject, eventdata, handles)
delete(handles.fg_demo_v2)

%% functions unused
function ed_lastn_CreateFcn(hObject, eventdata, handles)
function ed_firstn_CreateFcn(hObject, eventdata, handles)
function ed_id_CreateFcn(hObject, emendata, handles)
function ed_w1_Callback(hObject, eventdata, handles)
function ed_w1_CreateFcn(hObject, evendata, handles)
function ed_w2_Callback(hObject, eventdata, handles)
function ed_w2_CreateFcn(hObject, eventdata, handles)
function rb_w1_1_Callback(hObject, eventdata, handles)
function rb_w1_2_Callback(hObject, eventdata, handles)
function rb_w1_3_Callback(hObject, eventdata, handles)
function rb_w2_1_Callback(hObject, eventdata, handles)
function rb_w2_2_Callback(hObject, eventdata, handles)
function rb_w2_3_Callback(hObject, eventdata, handles)

 
