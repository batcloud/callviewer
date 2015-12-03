function varargout = callViewer18(varargin)
% CALLVIEWER18 M-file for callViewer18.fig
%      CALLVIEWER18, by itself, creates a new CALLVIEWER18 or raises the existing
%      singleton*.
%
%      H = CALLVIEWER18 returns the handle to a new CALLVIEWER18 or the handle to
%      the existing singleton*.
%
%      CALLVIEWER18('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CALLVIEWER18.M with the given input arguments.
%
%      CALLVIEWER18('Property','Value',...) creates a new CALLVIEWER18 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before callViewer14_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to callViewer18_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE'spectrogram_View Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help callViewer18

% Last Modified by GUIDE v2.5 07-May-2008 10:34:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @callViewer18_OpeningFcn, ...
                   'gui_OutputFcn',  @callViewer18_OutputFcn, ...
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


% --- Executes just before callViewer18 is made visible.
function callViewer18_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to callViewer18 (see VARARGIN)

% Choose default command line output for callViewer18
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes callViewer18 wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Set interuptible status for various callback functions:
%set(handles.figure1,'interruptible','off');

% Turn of log-of-zero warnings:
warning off MATLAB:log:logOfZero;

% Create default parameters:
parameters = struct([]);
parameters(1).spectrogram = struct([]);
parameters.spectrogram(1).fftSize = 256; % pts
parameters.spectrogram.windowSize = 1; % ms
parameters.spectrogram.windowType = 'Blackman'; % 'Hamming', 'Hanning', 'Blackman', or 'Rectangle'
parameters.spectrogram.backgroundThreshold = 10; % dB, pixels below threshold are truncated to threshold
parameters.spectrogram.colormap = 'Color 1'; % color1=jet(default),color2=hot,color3=bone,grayscale=gray
parameters.detection = struct([]);
parameters.detection(1).windowSize = 0.3; % ms
parameters.detection.frameRate = 10000; % fps
parameters.detection.chunkSize = 1; % sec
parameters.detection.LPFcutoff = inf; % kHz, used in Quick Summary only (at least 5 kHz above HPFcutoff)
parameters.detection.HPFcutoff = 20; % kHz
parameters.detection.windowType = 'Blackman'; % 'Hamming', 'Hanning', 'Blackman', or 'Rectangle'
parameters.detection.deltaSize = 1; % +/- frames
parameters.detection.SMS = 0; % 1==use spectral mean subtraction; 0==use median scaling
parameters.play = struct([]);
parameters.play(1).timeExpansionFactor = 10; % 10x time expansion
parameters.play.heterodyneFreq = 40; % kHz
parameters.play.freqDivisionFactor = 10; % frequency-divide-by factor
parameters(1).links = struct([]);
parameters.links(1).linkLengthMinFrames = 6; % frames
parameters.links.baselineThreshold = 5; % dB, echo filter threshold
parameters.links.trimThreshold = 10; % dB, local peak threshold
handles.parameters = parameters;
handles.defaultParameters = parameters; % Copy to store defaults

% Create state control flags:
state = struct([]);
state(1).fileOpen = 0; % 0==no file open; 1==file open
state.mouseButton = 0; % 0==up ; 1==down
state.buttonName = 'normal'; % 'normal'==left; 'extend'==middle; 'alt'==right; 'open'==double
handles.state = state;

% Define custom pointers (hotspot: [10 9] for hands, [6 6] for zoom):
handles.openHand = [2   2   NaN   NaN   NaN   NaN   NaN     1     1   NaN   NaN   NaN   NaN   NaN   NaN   NaN;   2   NaN   NaN     1     1   NaN     1     2     2     1     1     1   NaN   NaN   NaN   NaN;   NaN   NaN     1     2     2     1     1     2     2     1     2     2     1   NaN   NaN   NaN;   NaN   NaN     1     2     2     1     1     2     2     1     2     2     1   NaN     1   NaN;   NaN   NaN   NaN     1     2     2     1     2     2     1     2     2     1     1     2     1;   NaN   NaN   NaN     1     2     2     1     2     2     1     2     2     1     2     2     1;   NaN     1     1   NaN     1     2     2     2     2     2     2     2     1     2     2     1;     1     2     2     1     1     2     2     2     2     2     2     2     2     2     2     1;     1     2     2     2     1     2     2     2     2     2     2     2     2     2     1   NaN;   NaN     1     2     2     2     2     2     2     2     2     2     2     2     2     1   NaN;   NaN   NaN     1     2     2     2     2     2     2     2     2     2     2     2     1   NaN;   NaN   NaN     1     2     2     2     2     2     2     2     2     2     2     1   NaN   NaN;   NaN   NaN   NaN     1     2     2     2     2     2     2     2     2     2     1   NaN   NaN;   NaN   NaN   NaN   NaN     1     2     2     2     2     2     2     2     1   NaN   NaN   NaN;   NaN   NaN   NaN   NaN   NaN     1     2     2     2     2     2     2     1   NaN   NaN   NaN;   NaN   NaN   NaN   NaN   NaN     1     2     2     2     2     2     2     1   NaN   NaN   NaN];
handles.closedHand = [NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN;   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN;   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN;   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN;   NaN   NaN   NaN   NaN     1     1   NaN     1     1   NaN     1     1   NaN   NaN   NaN   NaN;   NaN   NaN   NaN     1     2     2     1     2     2     1     2     2     1     1   NaN   NaN;   NaN   NaN   NaN     1     2     2     2     2     2     2     2     2     1     2     1   NaN;   NaN   NaN   NaN   NaN     1     2     2     2     2     2     2     2     2     2     1   NaN;   NaN   NaN   NaN     1     1     2     2     2     2     2     2     2     2     2     1   NaN;   NaN   NaN     1     2     2     2     2     2     2     2     2     2     2     2     1   NaN;   NaN   NaN     1     2     2     2     2     2     2     2     2     2     2     2     1   NaN;   NaN   NaN     1     2     2     2     2     2     2     2     2     2     2     1   NaN   NaN;   NaN   NaN   NaN     1     2     2     2     2     2     2     2     2     2     1   NaN   NaN;   NaN   NaN   NaN   NaN     1     2     2     2     2     2     2     2     1   NaN   NaN   NaN;   NaN   NaN   NaN   NaN   NaN     1     2     2     2     2     2     2     1   NaN   NaN   NaN;   NaN   NaN   NaN   NaN   NaN     1     2     2     2     2     2     2     1   NaN   NaN   NaN];
handles.zoom = [   2   2   NaN   NaN     1     1     1     1   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN;   2   NaN     1     1   NaN     2   NaN     2     1     1   NaN   NaN   NaN   NaN   NaN   NaN;   NaN     1     2   NaN     2     1     1   NaN     2   NaN     1   NaN   NaN   NaN   NaN   NaN;   NaN     1   NaN     2   NaN     1     1     2   NaN     2     1   NaN   NaN   NaN   NaN   NaN;     1   NaN     2   NaN     2     1     1   NaN     2   NaN     2     1   NaN   NaN   NaN   NaN;     1     2     1     1     1     1     1     1     1     1   NaN     1   NaN   NaN   NaN   NaN;     1   NaN     1     1     1     1     1     1     1     1     2     1   NaN   NaN   NaN   NaN;     1     2   NaN     2   NaN     1     1     2   NaN     2   NaN     1   NaN   NaN   NaN   NaN;   NaN     1     2   NaN     2     1     1   NaN     2   NaN     1   NaN   NaN   NaN   NaN   NaN;   NaN     1   NaN     2   NaN     1     1     2   NaN     2     1     2   NaN   NaN   NaN   NaN;   NaN   NaN     1     1     2   NaN     2   NaN     1     1     1     1     2   NaN   NaN   NaN;   NaN   NaN   NaN   NaN     1     1     1     1   NaN     2     1     1     1     2   NaN   NaN;   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN     2     1     1     1     2   NaN;   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN     2     1     1     1     2;   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN     2     1     1     1;   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN     2     1     2];

% Set mouse activity functions for figure1:
set(handles.figure1,'windowButtonDownFcn',@buttonDownFunction);
set(handles.figure1,'windowButtonMotionFcn',@mouseOverFunction);
set(handles.figure1,'windowButtonUpFcn',@buttonUpFunction);

% Create preferences GUI:
handles.figure2 = createPreferencesGUI(parameters);

% Set initial pathname:
handles.pathName = [pwd,'\'];

% Turn off multi-channel menu items:
set(handles.spectrogramMultiChView,'visible','off');
set(handles.spectralPeaksMultiChView,'visible','off');
set(handles.frequenciesMultiChView,'visible','off');
set(handles.energyMultiChWindow,'visible','off');
set(handles.autoDetMultiChWindow,'visible','off');
set(handles.timeExpansionMultiChItem,'visible','off');
set(handles.heterodyneMultiChItem,'visible','off');
set(handles.frequencyDivisionMultiChItem,'visible','off');
set(handles.saveMenuMultiCh,'visible','off');
set(handles.saveMenuRaw,'visible','off');

% Disable save feature:
set(handles.saveMenu,'visible','on','enable','off');

% Turn off spectrum axis, expand spectrogram axis:
set(handles.axes4,'visible','off');
set(handles.axes2,'position',[.03,.042,.94,.8]);

% Save:
guidata(hObject,handles);

% --------------------------------------------------------------------
function figure2 = createPreferencesGUI(parameters)
% This function creates the Preferences GUI which allows for the manipulation
% of callViewer parameters.
% Input: parameters -- struct of parameters.  Defaults created in OpeningFcn.

% Create the GUI figure:
figure2 = figure('Visible','off','units','pixels','Position',[50,50,510,500], ...
   'closeRequestFcn',[],'dockControls','off','menubar','none','numbertitle','off', ...
   'name','Preferences Dialog','pointer','arrow','resize','off','toolbar','none', ...
   'parent',0,'windowstyle','modal','userdata',parameters);

% Create GUI listbox and figure buttons:
hListbox = uicontrol('style','listbox','units','pixels','horizontalAlignment','left', ...
   'listboxtop',1,'max',2,'min',1,'position',[20 350 130 60],'string',{'Spectrogram','Detection','Play'},...
   'parent',figure2,'backgroundcolor',[1 1 1],'tag','hListbox');
hPushButtonLoad = uicontrol('style','pushbutton','parent',figure2,'units','pixels',...
   'position',[5 15 50 25],'string','LOAD');
hPushButtonSave = uicontrol('style','pushbutton','parent',figure2,'units','pixels',...
   'position',[60 15 50 25],'string','SAVE');
hPushButtonCancel = uicontrol('style','pushbutton','parent',figure2,'units','pixels',...
   'position',[115 15 50 25],'string','CANCEL');
hPushButtonDefaults = uicontrol('style','pushbutton','parent',figure2,'units','pixels',...
   'position',[170 15 75 25],'string','DEFAULTS');

% Create spectrogram panel and objects:
hPanel1 = uipanel('parent',figure2,'backgroundcolor',get(figure2,'color'),...
   'units','pixels','position',[170,70,320,340],'visible','on','title','Spectrogram Parameters',...
   'userdata',1);
hEditbackgroundThreshold = uicontrol('style','edit','parent',hPanel1,'units','pixels','position',...
   [180 220 60 25],'backgroundcolor',[1 1 1],'string',num2str(parameters.spectrogram.backgroundThreshold),...
   'tag','hEditbackgroundThreshold','horizontalAlignment','center');
hTextbackgroundThreshold = uicontrol('style','text','parent',hPanel1,'units','pixels','position',...
   [20 220 150 20],'backgroundcolor',get(figure2,'color'),'horizontalAlignment','right',...
   'string','Background threshold [dB]:');
hEditFFTsize = uicontrol('style','edit','parent',hPanel1,'units','pixels','position',...
   [180 185 60 25],'backgroundcolor',[1 1 1],'string',num2str(parameters.spectrogram.fftSize),...
   'tag','hEditFFTsize','horizontalAlignment','center');
hTextFFTsize = uicontrol('style','text','parent',hPanel1,'units','pixels','position',...
   [20 185 150 20],'backgroundcolor',get(figure2,'color'),'horizontalAlignment','right',...
   'string','FFT size [pts]:');
hEditWindowSize = uicontrol('style','edit','parent',hPanel1,'units','pixels','position',...
   [180 150 60 25],'backgroundcolor',[1 1 1],'string',num2str(parameters.spectrogram.windowSize),...
   'tag','hEditWindowSize','horizontalAlignment','center');
hTextWindowSize = uicontrol('style','text','parent',hPanel1,'units','pixels','position',...
   [20 150 150 20],'backgroundcolor',get(figure2,'color'),'horizontalAlignment','right',...
   'string','Window length [ms]:');
hPopupWindowType = uicontrol('style','popupmenu','parent',hPanel1,'units','pixels','position',...
   [180 115 120 25],'backgroundcolor',[1 1 1],'horizontalAlignment','left',...
   'string',{'Hamming','Hanning','Blackman','Rectangle'},'value',1,'tag','hPopupWindowType');
hTextWindowType = uicontrol('style','text','parent',hPanel1,'units','pixels','position',...
   [20 115 150 20],'backgroundcolor',get(figure2,'color'),'horizontalAlignment','right',...
   'string','Window type:');
hPopupcolormap = uicontrol('style','popupmenu','parent',hPanel1,'units','pixels','position',...
   [180 80 120 25],'backgroundcolor',[1 1 1],'horizontalAlignment','left',...
   'string',{'Color 1','Color 2','Color 3','Gray scale'},'value',1,'tag','hPopupcolormap');
hTextcolormap = uicontrol('style','text','parent',hPanel1,'units','pixels','position',...
   [20 80 150 20],'backgroundcolor',get(figure2,'color'),'horizontalAlignment','right',...
   'string','Color map:');

% Create detection panel and objects:
hPanel2 = uipanel('parent',figure2,'backgroundcolor',get(figure2,'color'),...
   'units','pixels','position',[170,70,320,405],'visible','off','title','Automated Detection Parameters',...
   'userdata',2);
hCheckSMS = uicontrol('style','checkbox','parent',hPanel2,'units','pixels','position',...
   [180 355 60 25],'backgroundcolor',get(figure2,'color'),'min',0,'max',1,'value',parameters.detection.SMS,...
   'tag','hCheckSMS','horizontalAlignment','center');
hTextSMS = uicontrol('style','text','parent',hPanel2,'units','pixels','position',...
   [20 355 150 20],'backgroundcolor',get(figure2,'color'),'horizontalAlignment','right',...
   'string','Spectral mean subtraction:');
hEditLinkLengthMinFrames = uicontrol('style','edit','parent',hPanel2,'units','pixels','position',...
   [180 320 60 25],'backgroundcolor',[1 1 1],'string',num2str(parameters.links.linkLengthMinFrames),...
   'tag','hEditLinkLengthMinFrames','horizontalAlignment','center');
hTextLinkLengthMinFrames = uicontrol('style','text','parent',hPanel2,'units','pixels','position',...
   [20 320 150 20],'backgroundcolor',get(figure2,'color'),'horizontalAlignment','right',...
   'string','Minimum link length [frames]:');
hEditWindowSize2 = uicontrol('style','edit','parent',hPanel2,'units','pixels','position',...
   [180 285 60 25],'backgroundcolor',[1 1 1],'string',num2str(parameters.detection.windowSize),...
   'tag','hEditWindowSize2','horizontalAlignment','center');
hTextWindowSize2 = uicontrol('style','text','parent',hPanel2,'units','pixels','position',...
   [20 285 150 20],'backgroundcolor',get(figure2,'color'),'horizontalAlignment','right',...
   'string','Window length [ms]:');
hEditFramerate = uicontrol('style','edit','parent',hPanel2,'units','pixels','position',...
   [180 250 60 25],'backgroundcolor',[1 1 1],'string',num2str(parameters.detection.frameRate),...
   'tag','hEditFramerate','horizontalAlignment','center');
hTextFramerate = uicontrol('style','text','parent',hPanel2,'units','pixels','position',...
   [20 250 150 20],'backgroundcolor',get(figure2,'color'),'horizontalAlignment','right',...
   'string','Frame rate [fps]:');
hEditChunkSize = uicontrol('style','edit','parent',hPanel2,'units','pixels','position',...
   [180 215 60 25],'backgroundcolor',[1 1 1],'string',num2str(parameters.detection.chunkSize),...
   'tag','hEditChunkSize','horizontalAlignment','center');
hTextChunkSize = uicontrol('style','text','parent',hPanel2,'units','pixels','position',...
   [20 215 150 20],'backgroundcolor',get(figure2,'color'),'horizontalAlignment','right',...
   'string','Chunk size [sec]:');
hEditTrimThreshold = uicontrol('style','edit','parent',hPanel2,'units','pixels','position',...
   [180 180 60 25],'backgroundcolor',[1 1 1],'string',num2str(parameters.links.trimThreshold),...
   'tag','hEditTrimThreshold','horizontalAlignment','center');
hTextTrimThreshold = uicontrol('style','text','parent',hPanel2,'units','pixels','position',...
   [20 180 150 20],'backgroundcolor',get(figure2,'color'),'horizontalAlignment','right',...
   'string','Minimum energy [dB]:');
hEditBaselineThreshold = uicontrol('style','edit','parent',hPanel2,'units','pixels','position',...
   [180 145 60 25],'backgroundcolor',[1 1 1],'string',num2str(parameters.links.baselineThreshold),...
   'tag','hEditBaselineThreshold','horizontalAlignment','center');
hTextBaselineThreshold = uicontrol('style','text','parent',hPanel2,'units','pixels','position',...
   [20 145 150 20],'backgroundcolor',get(figure2,'color'),'horizontalAlignment','right',...
   'string','Echo filter threshold [dB]:');
hEditLPFcutoff = uicontrol('style','edit','parent',hPanel2,'units','pixels','position',...
   [180 110 60 25],'backgroundcolor',[1 1 1],'string',num2str(parameters.detection.LPFcutoff),...
   'tag','hEditLPFcutoff','horizontalAlignment','center');
hTextLPFcutoff = uicontrol('style','text','parent',hPanel2,'units','pixels','position',...
   [20 110 150 20],'backgroundcolor',get(figure2,'color'),'horizontalAlignment','right',...
   'string','UPPER cutoff freq. [kHz]:');
hEditHPFcutoff = uicontrol('style','edit','parent',hPanel2,'units','pixels','position',...
   [180 75 60 25],'backgroundcolor',[1 1 1],'string',num2str(parameters.detection.HPFcutoff),...
   'tag','hEditHPFcutoff','horizontalAlignment','center');
hTextHPFcutoff = uicontrol('style','text','parent',hPanel2,'units','pixels','position',...
   [20 75 150 20],'backgroundcolor',get(figure2,'color'),'horizontalAlignment','right',...
   'string','LOWER cutoff freq. [kHz]:');
hPopupWindowType2 = uicontrol('style','popupmenu','parent',hPanel2,'units','pixels','position',...
   [180 40 120 25],'backgroundcolor',[1 1 1],'horizontalAlignment','left',...
   'string',{'Hamming','Hanning','Blackman','Rectangle'},'value',1,'tag','hPopupWindowType2');
hTextWindowType2 = uicontrol('style','text','parent',hPanel2,'units','pixels','position',...
   [20 40 150 20],'backgroundcolor',get(figure2,'color'),'horizontalAlignment','right',...
   'string','Window type:');
hEditDeltaSize = uicontrol('style','edit','parent',hPanel2,'units','pixels','position',...
   [180 10 60 25],'backgroundcolor',[1 1 1],'string',num2str(parameters.detection.deltaSize),...
   'tag','hEditDeltaSize','horizontalAlignment','center');
hTextDeltaSize = uicontrol('style','text','parent',hPanel2,'units','pixels','position',...
   [20 10 150 20],'backgroundcolor',get(figure2,'color'),'horizontalAlignment','right',...
   'string','Delta size [+/-frames]:');

% Create playback panel and objects:
hPanel3 = uipanel('parent',figure2,'backgroundcolor',get(figure2,'color'),...
   'units','pixels','position',[170,70,320,340],'visible','off','title','Audio Playback Parameters',...
   'userdata',3);
hEditTimeExpansionFactor = uicontrol('style','edit','parent',hPanel3,'units','pixels','position',...
   [180 200 60 25],'backgroundcolor',[1 1 1],'string',num2str(parameters.play.timeExpansionFactor),...
   'tag','hEditTimeExpansionFactor','horizontalAlignment','center');
hTextTimeExpansionFactor = uicontrol('style','text','parent',hPanel3,'units','pixels','position',...
   [20 200 150 20],'backgroundcolor',get(figure2,'color'),'horizontalAlignment','right',...
   'string','Time expansion factor:');
hEditHeterodyneFreq = uicontrol('style','edit','parent',hPanel3,'units','pixels','position',...
   [180 165 60 25],'backgroundcolor',[1 1 1],'string',num2str(parameters.play.heterodyneFreq),...
   'tag','hEditHeterodyneFreq','horizontalAlignment','center');
hTextHeterodyneFreq = uicontrol('style','text','parent',hPanel3,'units','pixels','position',...
   [20 165 150 20],'backgroundcolor',get(figure2,'color'),'horizontalAlignment','right',...
   'string','Heterodyne frequency [kHz]:');
hEditFreqDivisionFactor = uicontrol('style','edit','parent',hPanel3,'units','pixels','position',...
   [180 130 60 25],'backgroundcolor',[1 1 1],'string',num2str(parameters.play.freqDivisionFactor),...
   'tag','hEditFreqDivisionFactor','horizontalAlignment','center');
hTextFreqDivisionFactor = uicontrol('style','text','parent',hPanel3,'units','pixels','position',...
   [20 130 150 20],'backgroundcolor',get(figure2,'color'),'horizontalAlignment','right',...
   'string','Frequency division factor:');

% Set all edit box strings to values, set callbacks:
m = who('hEdit*');
for p=1:length(m),
   eval(['mp=',m{p},';']);
   set(mp,'value',str2num(get(mp,'string')));
   
   % Sanity check entered value (positive number):
   set(mp,'callback','x=str2num(get(gcbo,''string''));if ~isempty(x)&x>0,set(gcbo,''string'',num2str(x));set(gcbo,''value'',x);else,set(gcbo,''string'',num2str(get(gcbo,''value'')));end;');
end;

% Min link length can be >=0; link energy and spectrogram background thresholds can be any value:
set(hEditLinkLengthMinFrames,'callback','x=str2num(get(gcbo,''string''));if ~isempty(x)&x>=0,set(gcbo,''string'',num2str(x));set(gcbo,''value'',x);else,set(gcbo,''string'',num2str(get(gcbo,''value'')));end;');
set(hEditTrimThreshold,'callback','x=str2num(get(gcbo,''string''));if ~isempty(x),set(gcbo,''string'',num2str(x));set(gcbo,''value'',x);else,set(gcbo,''string'',num2str(get(gcbo,''value'')));end;');
set(hEditBaselineThreshold,'callback','x=str2num(get(gcbo,''string''));if ~isempty(x),set(gcbo,''string'',num2str(x));set(gcbo,''value'',x);else,set(gcbo,''string'',num2str(get(gcbo,''value'')));end;');
set(hEditbackgroundThreshold,'callback','x=str2num(get(gcbo,''string''));if ~isempty(x),set(gcbo,''string'',num2str(x));set(gcbo,''value'',x);else,set(gcbo,''string'',num2str(get(gcbo,''value'')));end;');

% LPFcutoff must be >= HPFcutoff + 5 kHz, vice versa for HPFcutoff (10k<=HPFcutoff<inf, also):
set(hEditLPFcutoff,'callback','x=str2num(get(gcbo,''string''));y=get(findobj(gcf,''tag'',''hEditHPFcutoff''),''value'');if ~isempty(x)&(x>=y+5),set(gcbo,''string'',num2str(x));set(gcbo,''value'',x);else,set(gcbo,''string'',num2str(get(gcbo,''value'')));errordlg(''ERROR: LPF cutoff must be at least 5 kHz greater than HPF cutoff.'',''Parameter input error'');end;');
set(hEditHPFcutoff,'callback','x=str2num(get(gcbo,''string''));y=get(findobj(gcf,''tag'',''hEditLPFcutoff''),''value'');if ~isempty(x)&(x<=y-5)&~isinf(x)&(x>=10),set(gcbo,''string'',num2str(x));set(gcbo,''value'',x);else,set(gcbo,''string'',num2str(get(gcbo,''value'')));errordlg(''ERROR: HPF cutoff must be at least 5 kHz less than LPF cutoff, at least 10 kHz and finite.'',''Parameter input error'');end;');

% Set callback for listbox:
set(hListbox,'callback','set(findobj(''type'',''uipanel''),''visible'',''off'');set(findobj(''type'',''uipanel'',''userdata'',get(gcbo,''value'')),''visible'',''on'');');

% Set callback for load/save/cancel/defaults buttons:
set(hPushButtonLoad,'callback',@callbackLoadButton);
set(hPushButtonSave,'callback',@callbackSaveButton);
set(hPushButtonCancel,'callback','uiresume(gcf);');
set(hPushButtonDefaults,'callback',@callbackDefaultsButton);

% --------------------------------------------------------------------
function callbackLoadButton(src,eventdata)
% This function handles what to do when the LOAD button in the Preferences GUI is pressed:

% Prompt for file to load:
handles = guidata(findobj('tag','figure1'));
[fileName, pathName] = uigetfile('*.mat','Load Preferences file.',[handles.pathName,'preferences.mat']);

if isequal(lower(fileName),'preferences.mat'),
   % Load preferences:
   load([pathName,fileName],'parameters');
   
   % Update figure2:
   setPreferences(handles,parameters);
end;
drawnow;

% --------------------------------------------------------------------
function callbackDefaultsButton(src,eventdata)
% This function handles what to do when the DEFAULTS button in the Preferences GUI is pressed:

% Get handles:
handles = guidata(findobj('tag','figure1'));
   
% Set parameters:
setPreferences(handles,handles.defaultParameters);
drawnow;


% --------------------------------------------------------------------
function callbackSaveButton(src,eventdata)
% This function handles what to do when the SAVE button in the Preferences GUI is pressed.
% The GUI parameters are read from VALUE fields and saved to disk and figure2 userdata.

% Gather parameters from GUI:
parameters = get(gcf,'userdata'); % Init
parameters.spectrogram.fftSize = get(findobj(gcf,'tag','hEditFFTsize'),'value');
parameters.spectrogram.windowSize = get(findobj(gcf,'tag','hEditWindowSize'),'value');
junk = get(findobj(gcf,'tag','hPopupWindowType'),'value');
junkList = get(findobj(gcf,'tag','hPopupWindowType'),'string');
parameters.spectrogram.windowType = junkList{junk};
junk = get(findobj(gcf,'tag','hPopupcolormap'),'value');
junkList = get(findobj(gcf,'tag','hPopupcolormap'),'string');
parameters.spectrogram.colormap = junkList{junk};
parameters.spectrogram.backgroundThreshold = get(findobj(gcf,'tag','hEditbackgroundThreshold'),'value');
parameters.detection.windowSize = get(findobj(gcf,'tag','hEditWindowSize2'),'value');
parameters.detection.frameRate = get(findobj(gcf,'tag','hEditFramerate'),'value');
parameters.detection.chunkSize = get(findobj(gcf,'tag','hEditChunkSize'),'value');
parameters.detection.SMS = get(findobj(gcf,'tag','hCheckSMS'),'value');
parameters.links.linkLengthMinFrames = get(findobj(gcf,'tag','hEditLinkLengthMinFrames'),'value');
parameters.detection.LPFcutoff = get(findobj(gcf,'tag','hEditLPFcutoff'),'value');
parameters.detection.HPFcutoff = get(findobj(gcf,'tag','hEditHPFcutoff'),'value');
parameters.links.trimThreshold = get(findobj(gcf,'tag','hEditTrimThreshold'),'value');
parameters.links.baselineThreshold = get(findobj(gcf,'tag','hEditBaselineThreshold'),'value');
parameters.detection.deltaSize = get(findobj(gcf,'tag','hEditDeltaSize'),'value');
%parameters.detection.callStartThresh = get(findobj(gcf,'tag','hEditCallStartThresh'),'value');
%parameters.detection.FMEJumpThresh = get(findobj(gcf,'tag','hEditFMEJumpThresh'),'value');
parameters.play.timeExpansionFactor = get(findobj(gcf,'tag','hEditTimeExpansionFactor'),'value');
parameters.play.heterodyneFreq = get(findobj(gcf,'tag','hEditHeterodyneFreq'),'value');
parameters.play.freqDivisionFactor = get(findobj(gcf,'tag','hEditFreqDivisionFactor'),'value');
junk = get(findobj(gcf,'tag','hPopupWindowType2'),'value');
junkList = get(findobj(gcf,'tag','hPopupWindowType2'),'string');
parameters.detection.windowType = junkList{junk};
set(gcf,'userdata',parameters);

% Save to file in same dir as WAV file:
handles = guidata(findobj('tag','figure1'));
save([handles.pathName,'preferences.mat'],'parameters');
uiresume(gcf);



% --- Outputs from this function are returned to the command line.
function varargout = callViewer18_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function openMenu_Callback(hObject, eventdata, handles)
% hObject    handle to openMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Prompt to open WAV file:
[fileName,pathName] = uigetfile([handles.pathName,'*.wav;*.aif;*.aiff;*.raw'],'Select AUDIO file to open.');

% If valid file name, open and save:
if ~isequal(fileName,0),
   % Reset GUI menu items:
   set(get(handles.viewMenu,'children'),'checked','off'); % Turn off all checkmarks in View menu
   set(handles.timeDomain_View,'checked','on'); % Time domain by default
   set([handles.frequencies_View, handles.spectralPeaks_View, ...
      handles.textOutput_View,handles.energyView,handles.quickSummaryView],'enable','off'); % Disable menu bar items
   
   % Save file name info:
   handles.fileName = fileName;
   handles.pathName = pathName;
   
   % Open .wav file:
   set(handles.figure1,'pointer','watch');
   drawnow;
   values = wavreadBat([pathName,fileName]);
   set(handles.figure1,'pointer','arrow');
   x = values.x;
   set(handles.figure1,'userdata',x); % Store raw data in figure userdata
   values.x = []; % free up memory
   handles.values = values; % save
   
   % Load preferences, if they exist in current directory:
   if exist([pathName,'preferences.mat'],'file'),
      % Load prefs, check for updated fields, store:
      load([pathName,'preferences.mat'],'parameters');
      defaultParameters = handles.defaultParameters;
      if ~isfield(parameters,'play'), % add play parameters (added in version 7)
         parameters.play = struct([]);
         parameters.play(1).timeExpansionFactor = defaultParameters.play.timeExpansionFactor; % 10x time expansion
         parameters.play.heterodyneFreq = defaultParameters.play.heterodyneFreq; % kHz
         parameters.play.freqDivisionFactor = defaultParameters.play.freqDivisionFactor; % frequency-divide-by factor
      end;
      if ~isfield(parameters,'links'), % add link parameters (added in version 14)
         parameters(1).links = struct([]);
         parameters.links(1).linkLengthMinFrames = defaultParameters.links.linkLengthMinFrames; % frames
         parameters.links.baselineThreshold = defaultParameters.links.baselineThreshold; % dB
         parameters.links.trimThreshold = defaultParameters.links.trimThreshold; % dB
      end;
      if ~isfield(parameters.detection,'SMS'), % add SMS checkbox (added in version 14)
         parameters.detection.SMS = defaultParameters.detection.SMS;
      end;
      if ~isfield(parameters.detection,'LPFcutoff'), % add LPFcutoff (added in version 16)
         parameters.detection.LPFcutoff = defaultParameters.detection.LPFcutoff; % kHz, used in Quick Summary only
      end;
      if ~isfield(parameters.spectrogram,'backgroundThreshold'), % add background threshold (added in version 17)
         parameters.spectrogram.backgroundThreshold = defaultParameters.spectrogram.backgroundThreshold; % dB, spectrogram pixels below threshold truncated
      end;
      if ~isfield(parameters.spectrogram,'colormap'), % Spectrogram color map (added in version 17)
         parameters.spectrogram.colormap = defaultParameters.spectrogram.colormap; % color1=jet,color2=hot,color3=bone,grayscale=gray
      end;
      handles.parameters = parameters;
      save([pathName,'preferences.mat'],'parameters'); % save new fields to file

      % Update figure2:
      setPreferences(handles,parameters);
      set(handles.figure2,'userdata',parameters);
   end;
   
   % Load model parameters, if they exist in root directory:
   modelParameters = struct([]);
   if exist('.\modelParameters.mat','file'),
      load('.\modelParameters.mat'); % mu1, sig1, w1, A1, prior1 cell arrays, {1} for calls, {2} for background
      % Note: mu{1} is P x Nst x M (P features, Nst number of HMM states, M number of mixtures/state),
      % sig{1} is P x P x Nst x M, w{1} is Nst x M, A{1} is Nst x Nst, and prior{1} is 1 x Nst.
      
      % Store parameters:
      modelParameters(1).mu = mu1;
      modelParameters.sig = sig1;
      modelParameters.w = w1;
      modelParameters.A = A1;
      modelParameters.prior = prior1;
   end;
   handles.modelParameters = modelParameters; % save
   
   % Plot decimated version of x in axes1:
   % Get length of axes1:
   oldUnits = get(handles.axes1,'units');
   set(handles.axes1,'units','pixels');
   axes1Length = get(handles.axes1,'position');
   axes1Length = axes1Length(3); % pixels
   set(handles.axes1,'units',oldUnits); % Restore
   
   % Simple decimate x:
   lenX = size(x,1); % samples
   xDec = x(1:ceil(lenX/axes1Length/25):end,:);
   axes(handles.axes1);
   cla;
   plot(linspace(1,length(x),length(xDec)),xDec,'hittest','off'); % hittest==off for axes context menu
   hold on; % Allows bounding box to also be plotted
   % Note: setting ylim beyond 8-bit resolution only results in ylim = [-128 127].
   set(handles.axes1,'xtick',[],'ytick',[],'xlim',[1 length(x)],'ylim',[min(min(x(50:end,:)))-10, max(max(x(50:end,:)))+10]);
   yLim = get(handles.axes1,'ylim');
   xlabel([pathName,fileName],'interpreter','none');
   
   % Plot bounding box in axes1:
   handles.bb = rectangle('position',[0,yLim(1)+.03*(yLim(2)-yLim(1)),lenX/30,.94*(yLim(2)-yLim(1))],'hittest','off');

   % Change state, enable Analysis menu items:
   handles.state.fileOpen = 1;
   set([handles.analysisMenu,handles.playMenu],'enable','on');
   
   % Clear any results from analysis of previous files:
   set(handles.autoDetectMenu,'userdata',[]);
   set(handles.energyMenu,'userdata',[]);
   set(handles.quickSummaryMenu,'userdata',[]);
   
   % Make pointer text box visible:
   set(handles.textPointer,'visible','on');
   
   % Set spectrogram view:
   if size(x,2)>1,
      % Turn off single-channel menu items:
      set(handles.spectrogram_View,'visible','off');
      set(handles.spectralPeaks_View,'visible','off');
      set(handles.frequencies_View,'visible','off');
      set(handles.energyWindow,'visible','off');
      set(handles.autoDetWindow,'visible','off');
      set(handles.timeExpansionItem,'visible','off');
      set(handles.heterodyneItem,'visible','off');
      set(handles.frequencyDivisionItem,'visible','off');
      
      % Turn on multi-channel menu items:
      set(handles.spectrogramMultiChView,'visible','on');
      set(handles.spectralPeaksMultiChView,'visible','on');
      set(handles.frequenciesMultiChView,'visible','on');
      set(handles.energyMultiChWindow,'visible','on');
      set(handles.autoDetMultiChWindow,'visible','on');
      set(handles.timeExpansionMultiChItem,'visible','on');
      set(handles.heterodyneMultiChItem,'visible','on');
      set(handles.frequencyDivisionMultiChItem,'visible','on');
      
      % Turn on and enable Multi-channel save feature, make other save features invisible:
      set(handles.saveMenuRaw,'visible','off','enable','off');
      set(handles.saveMenuMultiCh,'visible','on','enable','on');
      set(handles.saveMenu,'visible','off','enable','off');
   elseif strcmpi(fileName(end-2:end),'raw'), % 1-ch RAW file
      % Turn off multi-channel menu items:
      set(handles.spectrogramMultiChView,'visible','off');
      set(handles.spectralPeaksMultiChView,'visible','off');
      set(handles.frequenciesMultiChView,'visible','off');
      set(handles.energyMultiChWindow,'visible','off');
      set(handles.autoDetMultiChWindow,'visible','off');
      set(handles.timeExpansionMultiChItem,'visible','off');
      set(handles.heterodyneMultiChItem,'visible','off');
      set(handles.frequencyDivisionMultiChItem,'visible','off');

      % Turn on single-channel menu items:
      set(handles.spectrogram_View,'visible','on');
      set(handles.spectralPeaks_View,'visible','on');
      set(handles.frequencies_View,'visible','on');
      set(handles.energyWindow,'visible','on');
      set(handles.autoDetWindow,'visible','on');
      set(handles.timeExpansionItem,'visible','on');
      set(handles.heterodyneItem,'visible','on');
      set(handles.frequencyDivisionItem,'visible','on');
      
      % Turn on and enable RAW save feature, make other save features invisible:
      set(handles.saveMenuRaw,'visible','on','enable','on');
      set(handles.saveMenuMultiCh,'visible','off','enable','off');
      set(handles.saveMenu,'visible','off','enable','off');
   else % 1-ch WAV/AIFF file
      % Turn off multi-channel menu items:
      set(handles.spectrogramMultiChView,'visible','off');
      set(handles.spectralPeaksMultiChView,'visible','off');
      set(handles.frequenciesMultiChView,'visible','off');
      set(handles.energyMultiChWindow,'visible','off');
      set(handles.autoDetMultiChWindow,'visible','off');
      set(handles.timeExpansionMultiChItem,'visible','off');
      set(handles.heterodyneMultiChItem,'visible','off');
      set(handles.frequencyDivisionMultiChItem,'visible','off');

      % Turn on single-channel menu items:
      set(handles.spectrogram_View,'visible','on');
      set(handles.spectralPeaks_View,'visible','on');
      set(handles.frequencies_View,'visible','on');
      set(handles.energyWindow,'visible','on');
      set(handles.autoDetWindow,'visible','on');
      set(handles.timeExpansionItem,'visible','on');
      set(handles.heterodyneItem,'visible','on');
      set(handles.frequencyDivisionItem,'visible','on');
      
      % Turn on and enable RAW save feature, make other save features invisible:
      set(handles.saveMenuRaw,'visible','off','enable','off');
      set(handles.saveMenuMultiCh,'visible','off','enable','off');
      set(handles.saveMenu,'visible','on','enable','on');
   end;

   % Save:
   guidata(gcbo,handles);
   clear x xDec;
   
   % Update axes2:
   updateAxes2(handles);
end;


% --------------------------------------------------------------------
function timeDomain_View_Callback(hObject, eventdata, handles)
% hObject    handle to timeDomain_View (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update checks in context menu:
set([handles.spectralPeaks_View,handles.frequencies_View,handles.spectrogram_View,...
   handles.timeDomain_View,handles.energyView,handles.quickSummaryView,...
   get(handles.spectrogramMultiChView,'children')'],'checked','off');
set(handles.timeDomain_View,'checked','on');
updateAxes2(handles);


% --------------------------------------------------------------------
function spectrogram_View_Callback(hObject, eventdata, handles)
% hObject    handle to spectrogram_View (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update checks in context menu:
set([handles.spectralPeaks_View,handles.frequencies_View,handles.spectrogram_View,...
   handles.timeDomain_View,handles.energyView,handles.quickSummaryView,...
   get(handles.spectrogramMultiChView,'children')'],'checked','off');
set(handles.spectrogram_View,'checked','on');
updateAxes2(handles);

% --------------------------------------------------------------------
function spectralPeaks_View_Callback(hObject, eventdata, handles)
% hObject    handle to spectralPeaks_View (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update checks in context menu:
set([handles.spectralPeaks_View,handles.frequencies_View,handles.spectrogram_View,...
   handles.timeDomain_View,handles.energyView,handles.quickSummaryView,...
   get(handles.spectrogramMultiChView,'children')'],'checked','off');
set(handles.spectralPeaks_View,'checked','on');
updateAxes2(handles);

% --------------------------------------------------------------------
function frequencies_View_Callback(hObject, eventdata, handles)
% hObject    handle to frequencies_View (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update checks in context menu:
set([handles.spectralPeaks_View,handles.frequencies_View,handles.spectrogram_View,...
   handles.timeDomain_View,handles.energyView,handles.quickSummaryView,...
   get(handles.spectrogramMultiChView,'children')'],'checked','off');
set(handles.frequencies_View,'checked','on');
updateAxes2(handles);

% --------------------------------------------------------------------
function buttonDownFunction(src,eventdata)
% This function handles what to do when any mouse button is pressed.

% Disable mouse motion function temporarily:
oldFunName = get(src,'windowButtonMotionFcn');
set(src,'windowButtonMotionFcn',[]);

% Update button info, save:
handles = guidata(src);
handles.state.mouseButton = 1;
handles.state.buttonName = get(src,'selectionType'); % 'normal'==left; 'extend'==middle; 'alt'==right; 'open'==double click
guidata(src,handles);

if handles.state.fileOpen==1 & strcmp(handles.state.buttonName,'normal'), % File is open, left mouse
   % Determine what is underneath mouse:
   % Get location of pointer:
   [objectIndex,pLoc] = pointerLocation(handles); % pLoc in normalized units wrt axes1 or 2

   % Set pointer according to what is underneath mouse:
   switch objectIndex,
      case 1, % axes 1
         bbFunction(handles); % Move bb to location clicked on axes1, then move until mouse button released
      case 2, % axes 2
         axes2Function(handles,pLoc);
      case 3, % bounding box, left edge
         bbLeftFunction(handles);
      case 4, % bounding box, right edge
         bbRightFunction(handles);
      case 5, % bounding box
         bbFunction(handles);
   end;
end;

% Restore mouse motion function:
set(src,'windowButtonMotionFcn',oldFunName);
mouseOverFunction(src,eventdata); % Update pointer on way out


% --------------------------------------------------------------------
function buttonUpFunction(src,eventdata)
% This function handles what to do when the mouse button is released.

% Update state:
handles = guidata(src);
handles.state.mouseButton = 0;
guidata(src,handles);


% --------------------------------------------------------------------
function mouseOverFunction(src,eventdata)
% This function handles what to do when the mouse moves around the figure.

% Get handles:
handles = guidata(src);

if handles.state.fileOpen==1, % File is open, so continue
   % Get location of pointer:
   [objectIndex,pLoc] = pointerLocation(handles);
   
   % Set pointer according to what is underneath mouse:
   switch objectIndex,
      case 1, % axes 1
         set(src,'pointer','arrow');
      case 2, % axes 2
         set(src,'pointer','custom');
         if strcmp(get(handles.zoomInSubMenu,'checked'),'on'), % zoom
            set(src,'PointerShapeCData',handles.zoom);
            set(src,'pointerShapeHotSpot',[1 1]);
         else % pan
            set(handles.figure1,'PointerShapeCData',handles.openHand);
            set(handles.figure1,'pointerShapeHotSpot',[1 1]);
         end;
         
         % Convert pLoc into appropriate units:
         xLim = get(handles.axes2,'xlim');
         yLim = get(handles.axes2,'ylim');
         xText = sprintf('%8.1f ms',(xLim(1)+diff(xLim)*pLoc(1))*1e3);
         if strcmp(get(handles.timeDomain_View,'checked'),'on'), % time domain
            yText = sprintf('%5.0f a.u.',yLim(1)+diff(yLim)*pLoc(2));
            set(handles.textPointer,'string',[xText,',',yText]);
         elseif strcmp(get(handles.spectralPeaks_View,'checked'),'on') || ...
               strcmp(get(handles.energyView,'checked'),'on') || ...
               strcmp(get(handles.quickSummaryView,'checked'),'on') || ...
               any(strcmp(get(get(handles.spectralPeaksMultiChView,'children'),'checked'),'on')),
            yText = sprintf('%5.1f dB',yLim(1)+diff(yLim)*pLoc(2));
            set(handles.textPointer,'string',[xText,',',yText]);
         elseif strcmp(get(handles.frequencies_View,'checked'),'on') || ...
               any(strcmp(get(get(handles.frequenciesMultiChView,'children'),'checked'),'on')),
            yText = sprintf('%5.1f kHz',yLim(1)+diff(yLim)*pLoc(2));
            set(handles.textPointer,'string',[xText,',',yText]);
         elseif strcmp(get(handles.spectrogram_View,'checked'),'on') || ...
               any(strcmp(get(get(handles.spectrogramMultiChView,'children'),'checked'),'on')),
            yText = sprintf('%5.1f kHz',yLim(1)+diff(yLim)*pLoc(2));
            hImage = findobj('type','image');
            cData = get(hImage,'cdata'); % MxN array of pixels
            [M,N]=size(cData);
            nm = round(([N,M]-1).*pLoc+1);
            zText = sprintf('%5.1f dB',cData(nm(2),nm(1)));
            set(handles.textPointer,'string',[xText,',',yText,',',zText]);
         end;
      case 6, % axes 4
         set(src,'pointer','arrow');
         
         % Convert pLoc into appropriate units:
         xLim = get(handles.axes4,'xlim');
         yLim = get(handles.axes4,'ylim');
         xText = sprintf('%5.1f dB',xLim(1)+diff(xLim)*pLoc(1));
         yText = sprintf('%5.1f kHz',yLim(1)+diff(yLim)*pLoc(2));
         set(handles.textPointer,'string',[xText,',',yText]);
      case 3, % bounding box, left edge
         set(src,'pointer','left');
      case 4, % bounding box, right edge
         set(src,'pointer','right');
      case 5, % bounding box
         set(src,'pointer','fleur');
      otherwise, % over nothing of interest
         set(src,'pointer','arrow');
   end;
end;

% --------------------------------------------------------------------
function [objectIndex,pLoc] = pointerLocation(handles)
% This function finds the location of the mouse pointer with respect to an object of interest.
% Input:
%    handles -- struct of GUI handles
% Output:
%    objectIndex -- index of object under mouse:
%       0==nothing of interest under mouse
%       1==axes 1
%       2==axes 2
%       3==bounding box, left edge
%       4==bounding box, right edge
%       5==bounding box
%       6==axes 4
%    pLoc -- [x,y] pointer location inside object of interest, normalized units

% Pull out handles of interest:
hFigure1 = handles.figure1;
hAxes1 = handles.axes1;
hAxes2 = handles.axes2;
hAxes4 = handles.axes4;

% Find positions of pointer, figure1, axes, and bounding box:
p1 = get(0,'pointerLocation'); % x-y, from lower left, in root units
rootUnits = get(0,'units'); % pixels, most likely

oldFigUnits = get(hFigure1,'units'); % characters, most likely
set(hFigure1,'units',rootUnits);
f1 = get(hFigure1,'position'); % x-y-width-heigth, from lower left, in root units
set(hFigure1,'units',oldFigUnits);

oldAxesUnits = get(hAxes1,'units'); % normalized, most likely
set(hAxes1,'units',rootUnits);
a1 = get(hAxes1,'position'); % x-y-width-height, from lower left, in root units
set(hAxes1,'units',oldAxesUnits);

oldAxesUnits = get(hAxes2,'units'); % normalized, most likely
set(hAxes2,'units',rootUnits);
a2 = get(hAxes2,'position'); % x-y-width-height, from lower left, in root units
set(hAxes2,'units',oldAxesUnits);

oldAxesUnits = get(hAxes4,'units'); % normalized, most likely
set(hAxes4,'units',rootUnits);
a4 = get(hAxes4,'position'); % x-y-width-height, from lower left, in root units
set(hAxes4,'units',oldAxesUnits);

pBB = get(handles.bb,'position'); % x-y-width-height, from lower left, in axes data units
bX = get(handles.axes1,'xlim'); % data units
bY = get(handles.axes1,'ylim'); % data units
pBB = [pBB(1)-bX(1),pBB(2)-bY(1),pBB(3:4)];
pBB([1,3]) = pBB([1,3])/diff(bX)*a1(3); % root units
pBB([2,4]) = pBB([2,4])/diff(bY)*a1(4); % root units

% Determine if p1 is over an object of interest:
if p1(1)>=(f1(1)+a1(1)+pBB(1)-2) & p1(1)<=(f1(1)+a1(1)+pBB(1)+2) & p1(2)>=(f1(2)+a1(2)) & p1(2)<=(f1(2)+a1(2)+a1(4)),
   objectIndex = 3; % bounding box, left edge
   pLoc = [p1(1)-(f1(1)+a1(1)),p1(2)-(f1(2)+a1(2))]; % root units
   pLoc = pLoc./[a1(3),a1(4)]; % normalized units
elseif p1(1)>=(f1(1)+a1(1)+pBB(1)+pBB(3)-2) & p1(1)<=(f1(1)+a1(1)+pBB(1)+pBB(3)+2) & p1(2)>=(f1(2)+a1(2)) & p1(2)<=(f1(2)+a1(2)+a1(4)),
   objectIndex = 4; % bounding box, right edge
   pLoc = [p1(1)-(f1(1)+a1(1)),p1(2)-(f1(2)+a1(2))]; % root units
   pLoc = pLoc./[a1(3),a1(4)]; % normalized units
elseif p1(1)>=(f1(1)+a1(1)+pBB(1)) & p1(1)<=(f1(1)+a1(1)+pBB(1)+pBB(3)) & p1(2)>=(f1(2)+a1(2)) & p1(2)<=(f1(2)+a1(2)+a1(4)),
   objectIndex = 5; % bounding box
   pLoc = [p1(1)-(f1(1)+a1(1)),p1(2)-(f1(2)+a1(2))]; % root units
   pLoc = pLoc./[a1(3),a1(4)]; % normalized units
elseif p1(1)>=(f1(1)+a1(1)) & p1(1)<=(f1(1)+a1(1)+a1(3)) & p1(2)>=(f1(2)+a1(2)) & p1(2)<=(f1(2)+a1(2)+a1(4)),
   objectIndex = 1; % Over axes 1
   pLoc = [p1(1)-(f1(1)+a1(1)),p1(2)-(f1(2)+a1(2))]; % root units
   pLoc = pLoc./[a1(3),a1(4)]; % normalized units
elseif p1(1)>=(f1(1)+a2(1)) & p1(1)<=(f1(1)+a2(1)+a2(3)) & p1(2)>=(f1(2)+a2(2)) & p1(2)<=(f1(2)+a2(2)+a2(4)),
   objectIndex = 2; % Over axes 2
   pLoc = [p1(1)-(f1(1)+a2(1)),p1(2)-(f1(2)+a2(2))]; % root units
   pLoc = pLoc./[a2(3),a2(4)]; % normalized units
elseif p1(1)>=(f1(1)+a4(1)) & p1(1)<=(f1(1)+a4(1)+a4(3)) & p1(2)>=(f1(2)+a4(2)) & p1(2)<=(f1(2)+a4(2)+a4(4)),
   objectIndex = 6; % Over axes 4
   pLoc = [p1(1)-(f1(1)+a4(1)),p1(2)-(f1(2)+a4(2))]; % root units
   pLoc = pLoc./[a4(3),a4(4)]; % normalized units
else
   objectIndex = 0; % Not over anything of interest
   pLoc = [];
end;


% --------------------------------------------------------------------
function bbFunction(handles)
% This function handles what happens when the mouse is used to move the bounding box in axes1.

handles = guidata(handles.figure1);
set(handles.figure1,'pointer','fleur'); % New pointer

% Get locations of figure and axes1, in root units:
rootUnits = get(0,'units'); % pixels, most likely
oldFigUnits = get(handles.figure1,'units'); % characters, most likely
set(handles.figure1,'units',rootUnits);
f1 = get(handles.figure1,'position'); % x-y-width-heigth, from lower left, in root units
set(handles.figure1,'units',oldFigUnits);

oldAxesUnits = get(handles.axes1,'units'); % normalized, most likely
set(handles.axes1,'units',rootUnits);
a1 = get(handles.axes1,'position'); % x-y-width-height, from lower left, in root units
set(handles.axes1,'units',oldAxesUnits);

pBB = get(handles.bb,'position'); % x-y-width-height, from lower left, in axes data units
bX = get(handles.axes1,'xlim'); % data units

while handles.state.mouseButton==1, % While mouse is down, update bb position and axes2 plot:
   % Get updated position:
%   [objectIndex,pLoc] = pointerLocation(handles); % pLoc in normalized units wrt axes1 or 2
   p1 = get(0,'pointerLocation'); % x-y, from lower left, in root units
   
   % Convert p1(x) from root units to data units, update BB:
   pBB(1) = (p1(1)-(f1(1)+a1(1)))/a1(3)*(bX(2)-bX(1))+bX(1)-pBB(3)/2;
   pBB(1) = max(bX(1),pBB(1)); % Clip at left edge of axis
   pBB(1) = min(bX(2)-pBB(3),pBB(1)); % Clip at right edge
   set(handles.bb,'position',pBB);
   
   % Update axes2:
   updateAxes2(handles);
   
   % Update handles:
   handles = guidata(handles.figure1);
end;

% --------------------------------------------------------------------
function axes2Function(handles,pLoc)
% This function handles what happens when the mouse is over axes 2.

% Determine which pointer should be active:
if strcmp(get(handles.zoomInSubMenu,'checked'),'on'), % zoom
   % Get zoom area:
   zoomArea = rbbox; % x-y-width-height wrt figure lower-left corner, figure units
   
   if zoomArea(3)>0, % Must be positive width
      % Convert zoomArea from figure units to normalized units:
      figUnits = get(handles.figure1,'units'); % characters, most likely
      oldAxesUnits = get(handles.axes2,'units'); % normalized, most likely
      set(handles.axes2,'units',figUnits);
      a2 = get(handles.axes2,'position'); % x-y-width-height, from lower left, in figure units
      set(handles.axes2,'units',oldAxesUnits);
      zoomArea([1,3]) = [zoomArea(1)-a2(1),zoomArea(3)]/a2(3); % Normalized
   
      % Update bounding box position using zoomArea:
      pBB = get(handles.bb,'position'); % x-y-width-height, from lower left, in axes data units
      bX = get(handles.axes1,'xlim'); % data units
      pBB(1) = pBB(1)+zoomArea(1)*pBB(3);
      pBB(1) = max(bX(1),pBB(1)); % Clip at first sample of data
      pBB(1) = min(bX(2)-10,pBB(1)); % Clip at 10 samples before end
      pBB(3) = zoomArea(3)*pBB(3);
      pBB(3) = min(bX(2)-pBB(1),pBB(3));
      set(handles.bb,'position',pBB);
   
      % Update axes2:
      updateAxes2(handles);
   end;
else % pan
   % Set pointer to closed hand while panning:
   set(handles.figure1,'pointer','custom');
   set(handles.figure1,'PointerShapeCData',handles.closedHand);
   set(handles.figure1,'pointerShapeHotSpot',[1 1]);

   % Get locations of figure and axes1, in root units:
   rootUnits = get(0,'units'); % pixels, most likely
   oldFigUnits = get(handles.figure1,'units'); % characters, most likely
   set(handles.figure1,'units',rootUnits);
   f1 = get(handles.figure1,'position'); % x-y-width-heigth, from lower left, in root units
   set(handles.figure1,'units',oldFigUnits);

   oldAxesUnits = get(handles.axes2,'units'); % normalized, most likely
   set(handles.axes2,'units',rootUnits);
   a2 = get(handles.axes2,'position'); % x-y-width-height, from lower left, in root units
   set(handles.axes2,'units',oldAxesUnits);

   pBB = get(handles.bb,'position'); % x-y-width-height, from lower left, in axes data units
   bX = get(handles.axes1,'xlim'); % data units
   pBBstart = pBB(1); % Used to find relative offset of pBB(1) in loop
   pLoc = get(0,'pointerLocation'); % root units
   while handles.state.mouseButton==1, % While mouse is down, update bb position and axes2 plot:
      % Get updated position, relative to pLoc:
      p1 = pLoc-get(0,'pointerLocation'); % x-y, from lower left, in root units
   
      % Convert p1(x) from root units to data units, update BB:
      pBB(1) = p1(1)/a2(3)*pBB(3)+pBBstart;
      pBB(1) = max(bX(1),pBB(1)); % Clip at left edge of axis
      pBB(1) = min(bX(2)-pBB(3),pBB(1)); % Clip at right edge
      set(handles.bb,'position',pBB);
   
      % Update axes2:
      updateAxes2(handles);
   
      % Update handles:
      handles = guidata(handles.figure1);
   end;
end;




% --------------------------------------------------------------------
function bbLeftFunction(handles)
% This function handles what happens when the mouse is over the left edge
% of the bounding box.

handles = guidata(handles.figure1);
set(handles.figure1,'pointer','left'); % New pointer

% Get locations of figure and axes1 in root units and bb in data units:
rootUnits = get(0,'units'); % pixels, most likely
oldFigUnits = get(handles.figure1,'units'); % characters, most likely
set(handles.figure1,'units',rootUnits);
f1 = get(handles.figure1,'position'); % x-y-width-heigth, from lower left, in root units
set(handles.figure1,'units',oldFigUnits);

oldAxesUnits = get(handles.axes1,'units'); % normalized, most likely
set(handles.axes1,'units',rootUnits);
a1 = get(handles.axes1,'position'); % x-y-width-height, from lower left, in root units
set(handles.axes1,'units',oldAxesUnits);

pBB = get(handles.bb,'position'); % x-y-width-height, from lower left, in axes data units
bX = get(handles.axes1,'xlim'); % data units
pBBend = pBB(1)+pBB(3); % keep bb end the same

while handles.state.mouseButton==1, % While mouse is down, update bb position and axes2 plot:
   % Get updated position:
   p1 = get(0,'pointerLocation'); % x-y, from lower left, in root units
   
   % Convert p1(x) from root units to data units, update BB:
   pBB(1) = (p1(1)-(f1(1)+a1(1)))/a1(3)*(bX(2)-bX(1))+bX(1);
   pBB(1) = max(bX(1),pBB(1)); % Clip at left edge of axis
   pBB(1) = min(pBBend-10,pBB(1)); % Clip at 10 samples before end
   pBB(3) = pBBend - pBB(1); % Set width
   set(handles.bb,'position',pBB);
   
   % Update axes2:
   updateAxes2(handles);
   
   % Update handles:
   handles = guidata(handles.figure1);
end;


% --------------------------------------------------------------------
function bbRightFunction(handles)
% This function handles what happens when the mouse is over the right edge
% of the bounding box.

handles = guidata(handles.figure1);
set(handles.figure1,'pointer','right'); % New pointer

% Get locations of figure and axes1 in root units and bb in data units:
rootUnits = get(0,'units'); % pixels, most likely
oldFigUnits = get(handles.figure1,'units'); % characters, most likely
set(handles.figure1,'units',rootUnits);
f1 = get(handles.figure1,'position'); % x-y-width-heigth, from lower left, in root units
set(handles.figure1,'units',oldFigUnits);

oldAxesUnits = get(handles.axes1,'units'); % normalized, most likely
set(handles.axes1,'units',rootUnits);
a1 = get(handles.axes1,'position'); % x-y-width-height, from lower left, in root units
set(handles.axes1,'units',oldAxesUnits);

pBB = get(handles.bb,'position'); % x-y-width-height, from lower left, in axes data units
bX = get(handles.axes1,'xlim'); % data units

while handles.state.mouseButton==1, % While mouse is down, update bb position and axes2 plot:
   % Get updated position:
   p1 = get(0,'pointerLocation'); % x-y, from lower left, in root units
   
   % Convert p1(x) from root units to data units, update BB:
   pBBend = (p1(1)-(f1(1)+a1(1)))/a1(3)*(bX(2)-bX(1))+bX(1);
   pBBend = max(pBB(1)+10,pBBend); % Clip at 10 samples after start
   pBBend = min(bX(2),pBBend); % Clip at right edge of axis
   pBB(3) = pBBend - pBB(1); % Set width
   set(handles.bb,'position',pBB);
   
   % Update axes2:
   updateAxes2(handles);
   
   % Update handles:
   handles = guidata(handles.figure1);
end;


% --------------------------------------------------------------------
function updateAxes2(handles)
% This function handles what to do when the mouse button is released.

if handles.state.fileOpen==1,
   % Determine spectrogram colormap and plot colors:
   colorList = ['k','r','b','g','m','c','y']; % color-coded harmonics for frequency/spectral peaks view
   colList = ['b','g','r','c']; % for channels 1..4, time-domain view
   symList = ['.','x','o','^']; % for channels 1..4, frequencies and spectral peaks views
   freqColor = 'g'; % Plot auto-detect frequency in green over white-black spectrograms
   switch handles.parameters.spectrogram.colormap
      case 'Color 1'
         colorMap = jet; % blue-red
         freqColor = 'k'; % Plot auto-detect frequency in black over blue-red spectrograms
      case 'Color 2'
         colorMap = flipud(hot); % white-black
      case 'Color 3'
         colorMap = flipud(bone); % white-black
      case 'Gray scale'
         colorMap = flipud(gray); % white-black
   end;

   % Get fs, x:
   fs = handles.values.fs; % Hz
   x = get(handles.figure1,'userdata');

   % Get length of axes2:
   oldUnits = get(handles.axes2,'units');
   set(handles.axes2,'units','pixels');
   axes2Length = get(handles.axes2,'position');
   axes2Length = ceil(axes2Length(3)); % pixels
   set(handles.axes2,'units',oldUnits); % Restore

   % Get bb position, convert to sample endpoints:
   bP = get(handles.bb,'position'); % bounding box: x-y-width-height, data units
   bP = round([bP(1),bP(1)+bP(3)]); % data units == samples of x
   bP = max(1,bP); % Clip at first sample
   bP = min(size(x,1),bP); % Clip
   lenX = diff(bP)+1; % samples
   
   % Get analysis results:
   detectResults = get(handles.autoDetectMenu,'userdata'); % empty if no auto detect analysis performed
   detectResultsEnergy = get(handles.energyMenu,'userdata'); % empty if no energy function performed
   detectResultsQuick = get(handles.quickSummaryMenu,'userdata'); % empty if no quick summary performed
   
   % Determine if spectrum axis is displayed:
   if strcmp(get(handles.powerSpectrumView,'checked'),'on'),
      % Turn on axes4, adjust axes2:
      set(handles.axes4,'visible','on');
      set(handles.axes2,'position',[.03,.042,.6,.8]);
      
      % Calculate power spectrum, all channels:
      xWindow = double(x(bP(1):bP(2),:));
      fftSize = 2^nextpow2(size(xWindow,1));
      XWindow = fft(xWindow,fftSize);
      XWindow = XWindow(1:fftSize/2+1,:); % Left-half of spectrum only, since x is real, include Nyquist freq
      psdWindow = 10*log10(real(XWindow.*conj(XWindow))); % Faster than abs(XWindow).^2, removes residual imag part
      f = [0:fftSize/2]'*fs*1e-3/fftSize; % kHz
      
      % Plot results in axes4:
      axes(handles.axes4);
      numCh = size(psdWindow,2);
      for p1=1:numCh,
         plot(psdWindow(:,p1),f,[colList(p1),'-']);
         hold on;
      end;
      hold off;
      yLim = [0 fs/2*1e-3]; % kHz
      set(handles.axes4,'ylim',yLim);
      drawnow;
   else
      % Turn off axes4, adjust axes2:
      set(handles.axes4,'visible','off');
      set(handles.axes2,'position',[.03,.042,.94,.8]);
   end;
   
   % Determine which spectrogram channel, if any, to display:
   specCh = 0;
   if strcmp(get(handles.spectrogram_View,'checked'),'on'),
      specCh = 1;
   elseif strcmp(get(handles.spectrogramCh1View,'checked'),'on'),
      specCh = 1;
   elseif strcmp(get(handles.spectrogramCh2View,'checked'),'on'),
      specCh = 2;
   elseif strcmp(get(handles.spectrogramCh3View,'checked'),'on'),
      specCh = 3;
   elseif strcmp(get(handles.spectrogramCh4View,'checked'),'on'),
      specCh = 4;
   end;

   % Determine which frequency channel, if any, to display:
   freqCh = 0;
   if strcmp(get(handles.frequencies_View,'checked'),'on'),
      freqCh = 1;
   elseif strcmp(get(handles.frequenciesCh1View,'checked'),'on'),
      freqCh = 1;
   elseif strcmp(get(handles.frequenciesCh2View,'checked'),'on'),
      freqCh = 2;
   elseif strcmp(get(handles.frequenciesCh3View,'checked'),'on'),
      freqCh = 3;
   elseif strcmp(get(handles.frequenciesCh4View,'checked'),'on'),
      freqCh = 4;
   end;

   % Determine which spectral peak channel, if any, to display:
   specPeakCh = 0;
   if strcmp(get(handles.spectralPeaks_View,'checked'),'on'),
      specPeakCh = 1;
   elseif strcmp(get(handles.spectralPeaksCh1View,'checked'),'on'),
      specPeakCh = 1;
   elseif strcmp(get(handles.spectralPeaksCh2View,'checked'),'on'),
      specPeakCh = 2;
   elseif strcmp(get(handles.spectralPeaksCh3View,'checked'),'on'),
      specPeakCh = 3;
   elseif strcmp(get(handles.spectralPeaksCh4View,'checked'),'on'),
      specPeakCh = 4;
   end;
   
   if strcmp(get(handles.timeDomain_View,'checked'),'on'), % time domain
      % Simple decimate x, plot:
      xDec = x(bP(1):ceil(lenX/axes2Length/25):bP(2),:);
      axes(handles.axes2);
      plot(linspace(bP(1)/fs,bP(2)/fs,size(xDec,1)),xDec,'hittest','off'); % hittest==off for axes context menu
      yLim = get(handles.axes1,'ylim');
      set(handles.axes2,'xlim',[bP(1)/fs,bP(2)/fs],'ylim',yLim);
      
      % Plot auto-detection results, if any:
      if ~isempty(detectResults),
         hold on;
         for p=1:length(detectResults),
            endpoints = detectResults(p).endpoints; % sec
            if ~isempty(endpoints),
               endpoints1 = endpoints((endpoints(:,1)>=bP(1)/fs & endpoints(:,1)<=bP(2)/fs),1); % Start points
               endpoints3 = endpoints((endpoints(:,2)>=bP(1)/fs & endpoints(:,2)<=bP(2)/fs),2); % End points
            else
               endpoints1 = [];
               endpoints3 = [];
            end;
            
            if ~isempty(endpoints1),
               plot([endpoints1(:),endpoints1(:)]',yLim,[colList(p),'>-'],'hittest','off');
            end;
            if ~isempty(endpoints3),
               plot([endpoints3(:),endpoints3(:)]',yLim,[colList(p),'<-'],'hittest','off');
            end;
         end; % for each channel
         hold off;
      end;
      drawnow;

      % Clean up memory:
      clear x xDec;
   elseif specCh>0,
      % Get windows from x:
      L = floor(handles.parameters.spectrogram.windowSize/1000*fs); % samples
      q1 = max(1,bP(1)-L); % start sample of spectrogram window for x
      q2 = min(size(x,1),bP(2)+L); % end sample of spectrogram window for x
      switch handles.parameters.spectrogram.windowType
         case 'Hamming'
            hamWindow = hamming(L);
         case 'Hanning'
            hamWindow = hanning(L);
         case 'Blackman'
            hamWindow = blackman(L);
         case 'Rectangle'
            hamWindow = ones(L,1);
      end;
      xIncrement = fs/handles.parameters.detection.frameRate; % samples/frame, fractional
      numFrames = min(axes2Length,max(1,floor((q2-q1+1-L)/xIncrement+1))); % Between 1 and axes2Length frames
      if numFrames==axes2Length,
         xIncrement = (q2-q1+1-L)/(numFrames-1); % Recalculate xIncrement if numFrames limited
      end;
      x1 = zeros(L,numFrames); % init windows
      for p=1:numFrames,
         xIndex = [1:L]+floor((p-1)*xIncrement)+q1-1;
         x1(1:L,p) = double(x(xIndex,specCh)).*hamWindow;
      end;

      % Get magnitude spectrum:
      HPFcutoff = handles.parameters.detection.HPFcutoff;
      fftSize = handles.parameters.spectrogram.fftSize;
      hpfRow = round(HPFcutoff*1e3/fs*fftSize); % rows 1..hpfRow zeroed out
      X1 = fft(x1,fftSize,1); % along dimension 1
      s = real(X1(1:fftSize/2+1,1:numFrames).*conj(X1(1:fftSize/2+1,1:numFrames)));
      s(1:hpfRow,1:numFrames) = 0; % HPF
      sPositiveIndex = find(s(:)>0);
      if ~isempty(sPositiveIndex), % will be empty if x1 all zeros
         s(sPositiveIndex) = 10*log10(s(sPositiveIndex));
         sMed = median(s(sPositiveIndex)); % median of non-zero values only, in case s is mostly zeros
         s(s<sMed) = sMed;
         magSpec = s-sMed; % Place noise floor at 0 dB
         magSpec(magSpec<handles.parameters.spectrogram.backgroundThreshold) = handles.parameters.spectrogram.backgroundThreshold;
      else
         magSpec = 0; % dB, arbitrary
      end;
      magSpec(1,:) = magSpec(1,:)+1e-10; % keeps background from turning green when signal is constant in window
      clear s;
      
      % Update axes2:
      axes(handles.axes2);
      xRange = ([0:numFrames-1]*xIncrement+q1+L/2)/fs;
      imagesc(xRange,linspace(0,fs/2000,fftSize/2),magSpec,'hittest','off'); % hittest==off for axes context menu
      colormap(colorMap);
      axis xy;
      
      % Include auto-detection results, if available:
      if specCh<=length(detectResults),
         outputLocal = detectResults(specCh).outputLocal;
      else
         outputLocal = [];
      end;
      if ~isempty(outputLocal),
         hold on;
         for p=1:length(outputLocal),
            t = outputLocal{p};
            if (t(1,2)>=bP(1)/fs && t(1,2)<=bP(2)/fs) || (t(end,2)>=bP(1)/fs && t(end,2)<=bP(2)/fs) || (t(1,2)<=bP(1)/fs && t(end,2)>=bP(2)/fs)
               plot(t(:,2),t(:,1)*1e-3,[freqColor,'.-'],'hittest','off'); % hittest==off for axes context menu
            end;
         end;
         hold off;
      end;
      yLim = [0 fs/2000]; % kHz
      set(handles.axes2,'xlim',[bP(1)/fs,bP(2)/fs],'ylim',yLim);
      drawnow;

      % Clean up memory:
      clear x x1 X1 magSpec;
   elseif freqCh>0, % frequencies from auto-detection output
      % Update axes2:
      axes(handles.axes2);
      if freqCh<=length(detectResults),
         outputLocal = detectResults(freqCh).outputLocal;
         outputGlobal = detectResults(freqCh).outputGlobal;
      else
         outputLocal = [];
      end;
      if ~isempty(outputLocal),
         for p=1:length(outputLocal),
            t = outputLocal{p};
            numHarmonic = min(7,outputGlobal(p).numHarmonic); % Truncate at 7 colors
            if (t(1,2)>=bP(1)/fs && t(1,2)<=bP(2)/fs) || (t(end,2)>=bP(1)/fs && t(end,2)<=bP(2)/fs) || (t(1,2)<=bP(1)/fs && t(end,2)>=bP(2)/fs)
               plot(t(:,2),t(:,1)*1e-3,[colorList(numHarmonic),symList(freqCh),'-'],'hittest','off'); % hittest==off for axes context menu
               hold on;
            end;
         end;
         hold off;
      else
         cla;
      end;
      yLim = [0 fs/2000]; % kHz
      set(handles.axes2,'xlim',[bP(1)/fs,bP(2)/fs],'ylim',yLim);
      drawnow;

      % Clean up memory:
      clear x;
   elseif specPeakCh>0, % spectral peaks from auto-detection output
      axes(handles.axes2);
      if specPeakCh<=length(detectResults),
         outputLocal = detectResults(specPeakCh).outputLocal;
         outputGlobal = detectResults(specPeakCh).outputGlobal;
      else
         outputLocal = [];
      end;
      if ~isempty(outputLocal),
         for p=1:length(outputLocal),
            t = outputLocal{p};
            numHarmonic = min(7,outputGlobal(p).numHarmonic); % Truncate at 7 colors
            if (t(1,2)>=bP(1)/fs & t(1,2)<=bP(2)/fs) | (t(end,2)>=bP(1)/fs & t(end,2)<=bP(2)/fs) | (t(1,2)<=bP(1)/fs & t(end,2)>=bP(2)/fs)
               plot(t(:,2),t(:,3),[colorList(numHarmonic),symList(specPeakCh),'-'],'hittest','off'); % hittest==off for axes context menu
               hold on;
            end;
         end;
         hold off;
      else
         cla;
      end;
      yLim = [0 80];
      set(handles.axes2,'xlim',[bP(1)/fs,bP(2)/fs],'ylim',yLim);
      drawnow;

      % Clean up memory:
      clear x;
   elseif strcmp(get(handles.energyView,'checked'),'on'), % spectral peak energy
      % Plot energy vs. time:
      axes(handles.axes2);
      outputEnergy = detectResultsEnergy.outputEnergy;
      for p=1:length(outputEnergy),
         if ~isempty(outputEnergy(p).sTime),
            plot(outputEnergy(p).sTime,outputEnergy(p).peakEnergy,[colList(p),'-'],'hittest','off'); % hittest==off for axes context menu
            hold on;
         end;
      end;
      hold off;
      yLim = [0 80];
      set(handles.axes2,'xlim',[bP(1)/fs,bP(2)/fs],'ylim',yLim);
      drawnow;

      % Clean up memory:
      clear x xDec;
   elseif strcmp(get(handles.quickSummaryView,'checked'),'on'), % quick summary
      % Plot broadband energy vs. time:
      axes(handles.axes2);
      plot(detectResultsQuick.outputQuick.t,detectResultsQuick.outputQuick.eNorm,'hittest','off'); % hittest==off for axes context menu
      symTable = ['.','x','d','s','+','o','^'];
      colTable = ['b','g','r','c'];
      numCh = size(detectResultsQuick.outputQuick.eNorm,2);
      hold on;
      for p1=1:numCh,
         for p2=1:size(detectResultsQuick.outputQuick.callIndexAll,1),
            c = detectResultsQuick.outputQuick.callIndexAll{p2,p1};
            if ~isempty(c),
               plot(detectResultsQuick.outputQuick.t(c),detectResultsQuick.outputQuick.eNorm(c,p1),[colTable(p1),symTable(p2)]);
            end;
         end;
      end;
      hold off;
      yLim = [-11 80];
      set(handles.axes2,'xlim',[bP(1)/fs,bP(2)/fs],'ylim',yLim);
      drawnow;

      % Clean up memory:
      clear x xDec;
   end;
end;


% --------------------------------------------------------------------
function Reset_Callback(hObject, eventdata, handles)
% hObject    handle to Reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Reset the bounding box in axes1:
if handles.state.fileOpen==1,
   lenX = size(get(handles.figure1,'userdata'),1); % samples
   yLim = get(handles.axes1,'ylim');
   set(handles.bb,'position',[0,yLim(1)+.03*(yLim(2)-yLim(1)),lenX/30,.94*(yLim(2)-yLim(1))]);
   updateAxes2(handles);
end;

% --------------------------------------------------------------------
function PanSubMenu_Callback(hObject, eventdata, handles)
% hObject    handle to PanSubMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update checks in context menu:
set(handles.PanSubMenu,'checked','on');
set(handles.zoomInSubMenu,'checked','off');


% --------------------------------------------------------------------
function zoomInSubMenu_Callback(hObject, eventdata, handles)
% hObject    handle to zoomInSubMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update checks in context menu:
set(handles.zoomInSubMenu,'checked','on');
set(handles.PanSubMenu,'checked','off');

% --------------------------------------------------------------------
function zoomOutSubMenu_Callback(hObject, eventdata, handles)
% hObject    handle to zoomOutSubMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.state.fileOpen==1,
   % Get bb position:
   pBB = get(handles.bb,'position'); % x-y-width-height, from lower left, in axes data units
   bX = get(handles.axes1,'xlim'); % data units
   pBB(1) = pBB(1)-pBB(3)*1.5;
   pBB(1) = max(bX(1),pBB(1)); % Clip at left edge of axis
   pBB(3) = pBB(3)*4;
   pBB(3) = min(bX(2)-pBB(1),pBB(3));
   set(handles.bb,'position',pBB);
   
   % Update axes2:
   updateAxes2(handles);
end;


% --------------------------------------------------------------------
function ResetSubMenu_Callback(hObject, eventdata, handles)
% hObject    handle to ResetSubMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Reset the bounding box in axes1:
if handles.state.fileOpen==1,
   lenX = size(get(handles.figure1,'userdata'),1); % samples
   yLim = get(handles.axes1,'ylim');
   set(handles.bb,'position',[0,yLim(1)+.03*(yLim(2)-yLim(1)),lenX/30,.94*(yLim(2)-yLim(1))]);
   updateAxes2(handles);
end;

% --------------------------------------------------------------------
function fileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to fileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function viewMenu_Callback(hObject, eventdata, handles)
% hObject    handle to viewMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function ResetMenu_Callback(hObject, eventdata, handles)
% hObject    handle to ResetMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Axes2Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Axes2Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function closeMenu_Callback(hObject, eventdata, handles)
% hObject    handle to closeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Disable mouse motion function temporarily:
oldFunName = get(handles.figure1,'windowButtonMotionFcn');
set(handles.figure1,'windowButtonMotionFcn',[]);

% Clear figure axes:
axes(handles.axes1);
cla reset; % Remove plots and bb
axes(handles.axes2);
cla reset; % Remove plots
axes(handles.axes4);
cla reset;
set(handles.figure1,'userdata',[]); % Free memory
handles.state.fileOpen = 0; % clear file open flag
set([handles.analysisMenu,handles.playMenu],'enable','off'); % Disable Analysis menu item
set(get(handles.viewMenu,'children'),'checked','off'); % Turn off all checkmarks in View menu
set(handles.timeDomain_View,'checked','on'); % Time domain by default
set([handles.frequencies_View,handles.spectralPeaks_View,handles.textOutput_View,...
   handles.energyView,handles.quickSummaryView],'enable','off'); % Disable menu bar items
set(handles.textPointer,'visible','off'); % Make pointer text box invisible
guidata(handles.figure1,handles); % save
set(handles.axes4,'visible','off');
set(handles.axes2,'position',[.03,.042,.94,.8]);

% Turn off multi-channel menu items:
set(handles.spectrogramMultiChView,'visible','off');
set(handles.spectralPeaksMultiChView,'visible','off');
set(handles.frequenciesMultiChView,'visible','off');
set(handles.energyMultiChWindow,'visible','off');
set(handles.autoDetMultiChWindow,'visible','off');
set(handles.timeExpansionMultiChItem,'visible','off');
set(handles.heterodyneMultiChItem,'visible','off');
set(handles.frequencyDivisionMultiChItem,'visible','off');

% Disable save menus:
set(handles.saveMenuRaw,'visible','off','enable','off');
set(handles.saveMenuMultiCh,'visible','off','enable','off');
set(handles.saveMenu,'visible','on','enable','off');

% Turn on single-channel menu items:
set(handles.spectrogram_View,'visible','on');
set(handles.spectralPeaks_View,'visible','on');
set(handles.frequencies_View,'visible','on');
set(handles.energyWindow,'visible','on');
set(handles.autoDetWindow,'visible','on');
set(handles.timeExpansionItem,'visible','on');
set(handles.heterodyneItem,'visible','on');
set(handles.frequencyDivisionItem,'visible','on');

% Restore mouse motion function:
set(handles.figure1,'windowButtonMotionFcn',oldFunName);

% --------------------------------------------------------------------
function exitMenu_Callback(hObject, eventdata, handles)
% hObject    handle to exitMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(handles.figure2); % Preferences GUI
delete(handles.figure1); % Main figure


% --------------------------------------------------------------------
function setPreferences(handles,parameters)
% This function takes the values in the struct "parameters" and puts
% them in the appropriate GUI objects in figure2.

set(findobj(handles.figure2,'tag','hEditFFTsize'),'value',parameters.spectrogram.fftSize,'string',num2str(parameters.spectrogram.fftSize));
set(findobj(handles.figure2,'tag','hEditWindowSize'),'value',parameters.spectrogram.windowSize,'string',num2str(parameters.spectrogram.windowSize));
junkList = get(findobj(handles.figure2,'tag','hPopupWindowType'),'string');
junk = strmatch(parameters.spectrogram.windowType,junkList,'exact');
set(findobj(handles.figure2,'tag','hPopupWindowType'),'value',junk);
set(findobj(handles.figure2,'tag','hEditWindowSize2'),'value',parameters.detection.windowSize,'string',num2str(parameters.detection.windowSize)); 
set(findobj(handles.figure2,'tag','hEditFramerate'),'value',parameters.detection.frameRate,'string',num2str(parameters.detection.frameRate));
set(findobj(handles.figure2,'tag','hEditChunkSize'),'value',parameters.detection.chunkSize,'string',num2str(parameters.detection.chunkSize));
if isfield(parameters.detection,'SMS'),
   set(findobj(handles.figure2,'tag','hCheckSMS'),'value',parameters.detection.SMS);
end;
if isfield(parameters.spectrogram,'colormap'),
   junkList = get(findobj(handles.figure2,'tag','hPopupcolormap'),'string');
   junk = strmatch(parameters.spectrogram.colormap,junkList,'exact');
   set(findobj(handles.figure2,'tag','hPopupcolormap'),'value',junk);
end;
if isfield(parameters.spectrogram,'backgroundThreshold'),
   set(findobj(handles.figure2,'tag','hEditbackgroundThreshold'),'value',parameters.spectrogram.backgroundThreshold,'string',num2str(parameters.spectrogram.backgroundThreshold));
end;
if isfield(parameters,'links'),
   set(findobj(handles.figure2,'tag','hEditLinkLengthMinFrames'),'value',parameters.links.linkLengthMinFrames,'string',num2str(parameters.links.linkLengthMinFrames));
   set(findobj(handles.figure2,'tag','hEditBaselineThreshold'),'value',parameters.links.baselineThreshold,'string',num2str(parameters.links.baselineThreshold));
   set(findobj(handles.figure2,'tag','hEditTrimThreshold'),'value',parameters.links.trimThreshold,'string',num2str(parameters.links.trimThreshold));
end;
set(findobj(handles.figure2,'tag','hEditHPFcutoff'),'value',max(10,parameters.detection.HPFcutoff),'string',num2str(max(10,parameters.detection.HPFcutoff)));
set(findobj(handles.figure2,'tag','hEditDeltaSize'),'value',parameters.detection.deltaSize,'string',num2str(parameters.detection.deltaSize));
if isfield(parameters,'play'),
   set(findobj(handles.figure2,'tag','hEditTimeExpansionFactor'),'value',parameters.play.timeExpansionFactor,'string',num2str(parameters.play.timeExpansionFactor));
   set(findobj(handles.figure2,'tag','hEditHeterodyneFreq'),'value',parameters.play.heterodyneFreq,'string',num2str(parameters.play.heterodyneFreq));
   set(findobj(handles.figure2,'tag','hEditFreqDivisionFactor'),'value',parameters.play.freqDivisionFactor,'string',num2str(parameters.play.freqDivisionFactor));
end;
if isfield(parameters.detection,'LPFcutoff'),
   set(findobj(handles.figure2,'tag','hEditLPFcutoff'),'value',parameters.detection.LPFcutoff,'string',num2str(parameters.detection.LPFcutoff));
end;
junkList = get(findobj(handles.figure2,'tag','hPopupWindowType2'),'string');
junk = strmatch(parameters.detection.windowType,junkList,'exact');
set(findobj(handles.figure2,'tag','hPopupWindowType2'),'value',junk);

% Redraw uipanels in Preferences GUI (some panel objects appear regardless of which panel is selected, for some reason):
set(findobj('type','uipanel'),'visible','off');
set(findobj('type','uipanel','userdata',get(findobj('tag','hListbox'),'value')),'visible','on');

%drawnow;


% --------------------------------------------------------------------
function preferencesMenu_Callback(hObject, eventdata, handles)
% hObject    handle to preferencesMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.state.fileOpen==1,
   % Set GUI values from parameters:
   parameters = handles.parameters;
   setPreferences(handles,parameters);

   set(handles.figure2,'visible','on');
   uiwait(handles.figure2); % Wait for user to set parameters before continuing, uiresume in save/cancel callbacks
   set(handles.figure2,'visible','off');
   handles.parameters = get(handles.figure2,'userdata');
   guidata(handles.figure1,handles); % Save
   updateAxes2(handles); % Update axes2
end;

% --------------------------------------------------------------------
function analysisMenu_Callback(hObject, eventdata, handles)
% hObject    handle to analysisMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function autoDetectMenu_Callback(hObject, eventdata, handles)
% hObject    handle to autoDetectMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function outputTXTResults(handles,detectResults)
% This function takes the results from an auto call detection analysis
% and produces a text file report.
% Input: handles -- struct of GUI handles
%        detectResults -- 1xN struct of results, either empty except for channel N or full for all 4 channels

% Get sampling rate:
fs = handles.values.fs;

% Get file name:
if strcmp(lower(handles.fileName(end-2:end)),'wav') | strcmp(lower(handles.fileName(end-2:end)),'aif'),
   fileName = handles.fileName(1:end-3); % include '.'
else % aiff file
   fileName = handles.fileName(1:end-4);
end;

% Open TXT file:
fid=fopen([handles.pathName,fileName,'GF.txt'],'wt');

for p=1:length(detectResults),
   if ~isempty(detectResults(p).lengthX),
      lenX = detectResults(p).lengthX/fs*1000; % ms
   end;
end;

% Write header to file:
fprintf(fid,'%s\n',handles.fileName);
fprintf(fid,'%s\n','callViewer17');
fprintf(fid,'%s\n\n',datestr(clock));

fprintf(fid,'%s\n','WAV FILE INFORMATION');
fprintf(fid,'%s\n',['File length (ms): ',num2str(lenX)]);
fprintf(fid,'%s\n',['Number of channels: ',num2str(handles.values.numChannels)]);
fprintf(fid,'%s\n',['Sampling rate (Hz): ',num2str(fs)]);
fprintf(fid,'%s\n\n',['Resolution (bits): ',num2str(handles.values.bitsPerSample)]);

fprintf(fid,'%s\n','DETECTION PARAMETERS');
fprintf(fid,'%s\n',['SMS: ',num2str(handles.parameters.detection.SMS)]);
fprintf(fid,'%s\n',['Minimum link length (frames): ',num2str(handles.parameters.links.linkLengthMinFrames)]);
fprintf(fid,'%s\n',['Window length (ms): ',num2str(handles.parameters.detection.windowSize)]);
fprintf(fid,'%s\n',['Frame rate (fps): ',num2str(handles.parameters.detection.frameRate)]);
fprintf(fid,'%s\n',['Chunk size (sec): ',num2str(handles.parameters.detection.chunkSize)]);
fprintf(fid,'%s\n',['Minimum energy (dB): ',num2str(handles.parameters.links.trimThreshold)]);
fprintf(fid,'%s\n',['Echo filter threshold (dB): ',num2str(handles.parameters.links.baselineThreshold)]);
fprintf(fid,'%s\n',['LOWER cutoff frequency: (kHz): ',num2str(handles.parameters.detection.HPFcutoff)]);
fprintf(fid,'%s\n',['Window type: ',handles.parameters.detection.windowType]);
fprintf(fid,'%s\n\n',['Delta size (+/-frames): ',num2str(handles.parameters.detection.deltaSize)]);

fprintf(fid,'%s\n',['Glossary:']);
fprintf(fid,'%s\n',['Call/harmonic number -- number of call in sequence and harmonic in call (F0==1, etc.),']);
fprintf(fid,'%s\n',['Start/End -- start and end time of a link, referenced to the beginning of the file,']);
fprintf(fid,'%s\n',['Fmin/Fmax -- minimum/maximum frequency across all frames in a link,']);
fprintf(fid,'%s\n',['E -- maximum energy for a link,']);
fprintf(fid,'%s\n',['FME -- frequency of maximum energy for a link,']);
fprintf(fid,'%s\n',['FME Time -- time to FME, referenced to the beginning of the link,']);
fprintf(fid,'%s\n',['F10th..F90th -- 10th..90th percentile of frequency across all frames in a link,']);
fprintf(fid,'%s\n',['dFmedian/dEmedian -- median of first temporal derivative (slope) of F/E across all frames in a link,']);
fprintf(fid,'%s\n',['ddFmedian/ddEmedian -- median of second temporal derivative (concavity) of F/E across all frames in a link,']);
fprintf(fid,'%s\n\n',['sFmedian/sEmedian -- median of linear regression error (smoothness) of F/E across all frames in a link.']);

fprintf(fid,'%s\n','AUTO-DETECTED CALLS');
fprintf(fid,' %12s','Channel');
fprintf(fid,' %12s','Call #');
fprintf(fid,' %12s','Harmonic #');
fprintf(fid,' %12s','Start(ms)');
fprintf(fid,' %12s','End(ms)');
fprintf(fid,' %12s','Duration(ms)');
fprintf(fid,' %12s','Fmin(Hz)');
fprintf(fid,' %12s','FME(Hz)');
fprintf(fid,' %12s','Fmax(Hz)');
fprintf(fid,' %12s','E(dB)');
fprintf(fid,' %12s','FMETime(ms)');
fprintf(fid,' %12s','F10th(Hz)');
fprintf(fid,' %12s','F20th(Hz)');
fprintf(fid,' %12s','F30th(Hz)');
fprintf(fid,' %12s','F40th(Hz)');
fprintf(fid,' %12s','F50th(Hz)');
fprintf(fid,' %12s','F60th(Hz)');
fprintf(fid,' %12s','F70th(Hz)');
fprintf(fid,' %12s','F80th(Hz)');
fprintf(fid,' %12s','F90th(Hz)');
fprintf(fid,' %20s','dFmedian(kHz/ms)');
fprintf(fid,' %20s','dEmedian(dB/ms)');
fprintf(fid,' %20s','ddFmedian(kHz/ms/ms)');
fprintf(fid,' %20s','ddEmedian(dB/ms/ms)');
fprintf(fid,' %20s','sFmedian(dB)');
fprintf(fid,' %20s','sEmedian(dB)');
fprintf(fid,'\n');

for p1=1:length(detectResults),
   outputGlobal = detectResults(p1).outputGlobal;
   outputLocal = detectResults(p1).outputLocal;

   for p=1:length(outputGlobal),
      % Write features to file:
      fprintf(fid,' %12d',p1);
      fprintf(fid,' %12d',outputGlobal(p).numCall);
      fprintf(fid,' %12d',outputGlobal(p).numHarmonic);
      fprintf(fid,' %12.3f',outputGlobal(p).startTime);
      fprintf(fid,' %12.3f',outputGlobal(p).stopTime);
      fprintf(fid,' %12.3f',outputGlobal(p).duration);
      fprintf(fid,' %12.2f',outputGlobal(p).Fmin);
      fprintf(fid,' %12.2f',outputGlobal(p).FME);
      fprintf(fid,' %12.2f',outputGlobal(p).Fmax);
      fprintf(fid,' %12.2f',outputGlobal(p).E);
      fprintf(fid,' %12.2f',outputGlobal(p).FMETime);
      for p2=1:9,
         fprintf(fid,' %12.2f',outputGlobal(p).FPercentile(p2));
      end;
      fprintf(fid,' %20.2f',outputGlobal(p).dFmed);
      fprintf(fid,' %20.2f',outputGlobal(p).dEmed);
      fprintf(fid,' %20.2f',outputGlobal(p).ddFmed);
      fprintf(fid,' %20.2f',outputGlobal(p).ddEmed);
      fprintf(fid,' %20.2f',outputGlobal(p).sFmed);
      fprintf(fid,' %20.2f',outputGlobal(p).sEmed);
      fprintf(fid,'\n');
   end;
end; % for each channel

% Close file:
fclose(fid);

% Determine which worksheet to write to:
m=dir([handles.pathName,fileName,'GF.xls']);
if isempty(m), % No Excel file, so create:
   sheetNumber = 1;
else % Not empty, so determine sheet number:
   [junk,sheetNames] = xlsfinfo([handles.pathName,fileName,'GF.xls']);
   if isempty(sheetNames),
      sheetNumber = 1;
   else
      % Convert strings to numbers:
      sheetNamesConverted = zeros(1,length(sheetNames));
      for p=1:length(sheetNames),
         k = str2num(sheetNames{p});
         if ~isempty(k),
            sheetNamesConverted(p) = k;
         end;
      end;
      sheetNumber = max(sheetNamesConverted)+1;
   end;
end;
      
% Create header:
warning off MATLAB:xlswrite:AddSheet;
h = [handles.pathName,fileName,'GF.xls'];
header = cell(1,2);
r = 1; % row pointer
[header{r,1},header{r,2}] = deal(handles.fileName,'');r=r+1;
[header{r,1},header{r,2}] = deal('callViewer17','');r=r+1;
[header{r,1},header{r,2}] = deal(['Time: ',datestr(clock)],'');r=r+1;
r=r+1;
[header{r,1},header{r,2}] = deal('WAV FILE INFORMATION','');r=r+1;
[header{r,1},header{r,2}] = deal('File length (ms): ',lenX);r=r+1;
[header{r,1},header{r,2}] = deal('Number of channels: ',handles.values.numChannels);r=r+1;
[header{r,1},header{r,2}] = deal('Sampling rate (Hz): ',fs);r=r+1;
[header{r,1},header{r,2}] = deal('Resolution (bits): ',handles.values.bitsPerSample);r=r+1;
r = r+1;
[header{r,1},header{r,2}] = deal('DETECTION PARAMETERS','');r=r+1;
[header{r,1},header{r,2}] = deal('Window size (ms): ',handles.parameters.detection.windowSize);r=r+1;
[header{r,1},header{r,2}] = deal('Frame rate (fps): ',handles.parameters.detection.frameRate);r=r+1;
[header{r,1},header{r,2}] = deal('Chunk size (sec): ',handles.parameters.detection.chunkSize);r=r+1;
[header{r,1},header{r,2}] = deal('SMS: ',handles.parameters.detection.SMS);r=r+1;
[header{r,1},header{r,2}] = deal('LOWER cutoff frequency: (kHz): ',handles.parameters.detection.HPFcutoff);r=r+1;
[header{r,1},header{r,2}] = deal('Window type: ',handles.parameters.detection.windowType);r=r+1;
[header{r,1},header{r,2}] = deal('Minimum link length (frames): ',handles.parameters.links.linkLengthMinFrames);r=r+1;
[header{r,1},header{r,2}] = deal('Minimum peak energy (dB): ',handles.parameters.links.baselineThreshold);r=r+1;
[header{r,1},header{r,2}] = deal('Minimum endpoint energy (dB): ',handles.parameters.links.trimThreshold);r=r+1;
[header{r,1},header{r,2}] = deal('Delta size (+/-frames): ',handles.parameters.detection.deltaSize);r=r+1;
r=r+1;
[header{r,1},header{r,2}] = deal('Glossary:','');r=r+1;
[header{r,1},header{r,2}] = deal('Call/harmonic number -- number of call in sequence and harmonic in call (F0==1, etc.)','');r=r+1;
[header{r,1},header{r,2}] = deal('Start/End -- start and end time of a link, referenced to the beginning of the file,','');r=r+1;
[header{r,1},header{r,2}] = deal('Fmin/Fmax -- minimum/maximum frequency across all frames in a link,','');r=r+1;
[header{r,1},header{r,2}] = deal('E -- maximum energy for a link,','');r=r+1;
[header{r,1},header{r,2}] = deal('FME -- frequency of maximum energy for a link,','');r=r+1;
[header{r,1},header{r,2}] = deal('FME Time -- time to FME, referenced to the beginning of the link,','');r=r+1;
[header{r,1},header{r,2}] = deal('F10th..F90th -- 10th..90th percentile of frequency across all frames in a link,','');r=r+1;
[header{r,1},header{r,2}] = deal('dFmedian/dEmedian -- median of first temporal derivative (slope) of F/E across all frames in a link,','');r=r+1;
[header{r,1},header{r,2}] = deal('ddFmedian/ddEmedian -- median of second temporal derivative (concavity) of F/E across all frames in a link,','');r=r+1;
[header{r,1},header{r,2}] = deal('sFmedian/sEmedian -- median of linear regression error (smoothness) of F/E across all frames in a link.','');r=r+1;
r=r+1;
[header{r,1},header{r,2}] = deal('AUTO-DETECTED CALLS','');r=r+1;
xlswrite(h,header,num2str(sheetNumber),['A1:B',num2str(size(header,1))]);

% Create tail:
tail = {'Channel number','Call number','Harmonic number','Start(ms)','End(ms)','Duration(ms)','Fmin(Hz)','FME(Hz)','Fmax(Hz)','E(dB)','FMETime(ms)','F10th(Hz)',...
   'F20th(Hz)','F30th(Hz)','F40th(Hz)','F50th(Hz)','F60th(Hz)','F70th(Hz)','F80th(Hz)','F90th(Hz)',...
   'dFmedian(kHz/ms)','dEmedian(dB/ms)','ddFmedian(kHz/ms/ms)','ddEmedian(dB/ms/ms)','sFmedian(dB)','sEmedian(dB)'};
for p1=1:length(detectResults),
   outputGlobal = detectResults(p1).outputGlobal;
   outputLocal = detectResults(p1).outputLocal;

   for p=1:length(outputGlobal),
      % Write features to file:
      c=1;
      tail{end+1,c} = p1;c=c+1;
      tail{end,c} = outputGlobal(p).numCall;c=c+1;
      tail{end,c} = outputGlobal(p).numHarmonic;c=c+1;
      tail{end,c} = outputGlobal(p).startTime;c=c+1;
      tail{end,c} = outputGlobal(p).stopTime;c=c+1;
      tail{end,c} = outputGlobal(p).duration;c=c+1;
      tail{end,c} = outputGlobal(p).Fmin;c=c+1;
      tail{end,c} = outputGlobal(p).FME;c=c+1;
      tail{end,c} = outputGlobal(p).Fmax;c=c+1;
      tail{end,c} = outputGlobal(p).E;c=c+1;
      tail{end,c} = outputGlobal(p).FMETime;c=c+1;
      for p2=1:9,
         tail{end,c} = outputGlobal(p).FPercentile(p2);c=c+1;
      end;
      tail{end,c} = outputGlobal(p).dFmed;c=c+1;
      tail{end,c} = outputGlobal(p).dEmed;c=c+1;
      tail{end,c} = outputGlobal(p).ddFmed;c=c+1;
      tail{end,c} = outputGlobal(p).ddEmed;c=c+1;
      tail{end,c} = outputGlobal(p).sFmed;c=c+1;
      tail{end,c} = outputGlobal(p).sEmed;
   end;
end; % for each channel
xlswrite(h,tail,num2str(sheetNumber),['A',num2str(r),':',char(double('A')+size(tail,2)-1),num2str(r+size(tail,1)-1)]);

% Open file for frame-based features:
fid=fopen([handles.pathName,fileName,'FF.txt'],'wt');

% Write header:
fprintf(fid,'%s\n',handles.fileName);
fprintf(fid,'%s\n','callViewer17');
fprintf(fid,'%s\n\n',datestr(clock));

fprintf(fid,'%s\n','WAV FILE INFORMATION');
fprintf(fid,'%s\n',['File length (ms): ',num2str(lenX)]);
fprintf(fid,'%s\n',['Number of channels: ',num2str(handles.values.numChannels)]);
fprintf(fid,'%s\n',['Sampling rate (Hz): ',num2str(fs)]);
fprintf(fid,'%s\n\n',['Resolution (bits): ',num2str(handles.values.bitsPerSample)]);

fprintf(fid,'%s\n','DETECTION PARAMETERS');
fprintf(fid,'%s\n',['Window size (ms): ',num2str(handles.parameters.detection.windowSize)]);
fprintf(fid,'%s\n',['Frame rate (fps): ',num2str(handles.parameters.detection.frameRate)]);
fprintf(fid,'%s\n',['Chunk size (sec): ',num2str(handles.parameters.detection.chunkSize)]);
fprintf(fid,'%s\n',['SMS: ',num2str(handles.parameters.detection.SMS)]);
fprintf(fid,'%s\n',['LOWER cutoff frequency: (kHz): ',num2str(handles.parameters.detection.HPFcutoff)]);
fprintf(fid,'%s\n',['Window type: ',handles.parameters.detection.windowType]);
fprintf(fid,'%s\n',['Minimum link length (frames): ',num2str(handles.parameters.links.linkLengthMinFrames)]);
fprintf(fid,'%s\n',['Minimum peak energy (dB): ',num2str(handles.parameters.links.baselineThreshold)]);
fprintf(fid,'%s\n',['Minimum endpoint energy (dB): ',num2str(handles.parameters.links.trimThreshold)]);
fprintf(fid,'%s\n\n',['Delta size (+/-frames): ',num2str(handles.parameters.detection.deltaSize)]);

fprintf(fid,'%s\n',['Glossary:']);
fprintf(fid,'%s\n',['Link -- number of link in detected signal,']);
fprintf(fid,'%s\n',['Time -- time to center of current analysis frame, referenced to beginning of file,']);
fprintf(fid,'%s\n',['Freq. -- frequency of link in current frame,']);
fprintf(fid,'%s\n',['Energy -- energy of link in current frame,']);
fprintf(fid,'%s\n',['dF/dE -- first temporal derivative (slope) of F/E in current frame,']);
fprintf(fid,'%s\n',['ddF/ddE -- second temporal derivative (concavity) of F/E in current frame,']);
fprintf(fid,'%s\n\n',['sF/sE -- linear regression error (smoothness) of F/E in current frame.']);

fprintf(fid,'%s\n','AUTO-DETECTED CALLS');
fprintf(fid,' %12s','Channel #');
fprintf(fid,' %12s','Call #');
fprintf(fid,' %12s','Harmonic #');
fprintf(fid,' %12s','Time(ms)');
fprintf(fid,' %12s','Freq.(Hz)');
fprintf(fid,' %12s','Energy(dB)');
fprintf(fid,' %12s','dF(kHz/ms)');
fprintf(fid,' %12s','dE(dB/ms)');
fprintf(fid,' %12s','ddF(kHz/ms)');
fprintf(fid,' %12s','ddE(dB/ms)');
fprintf(fid,' %12s','sF(kHz/ms)');
fprintf(fid,' %12s','sE(dB/ms)');
fprintf(fid,'\n');

for p3=1:length(detectResults),
   outputGlobal = detectResults(p3).outputGlobal;
   outputLocal = detectResults(p3).outputLocal;

   for p=1:length(outputLocal), % for each link
      for p1=1:size(outputLocal{p},1), % for each frame
         % Write features to file:
         fprintf(fid,' %12d',p3);
         fprintf(fid,' %12d',outputGlobal(p).numCall);
         fprintf(fid,' %12d',outputGlobal(p).numHarmonic);
         t = outputLocal{p}(p1,[2 1 3:9]);
         fprintf(fid,' %12.3f',t(1)*1e3);
         for p2=2:9,
            fprintf(fid,' %12.2f',t(p2));
         end;
         fprintf(fid,'\n');
      end;
   end;
end; % for each channel

% Close file:
fclose(fid);

% --------------------------------------------------------------------
function autoDetWindow_Callback(hObject, eventdata, handles, chNum)
% hObject    handle to autoDetWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if nargin<4,
   chNum = 1; % channel 1, default
end;

% Turn pointer into watch, temporarily:
set(handles.figure1,'pointer','watch');
drawnow;

% Get x, fs:
x = get(handles.figure1,'userdata');
fs = handles.values.fs;
lenX = size(x,1); % samples
numChannels = size(x,2);

% Get limits of current window:
bP = get(handles.bb,'position'); % bounding box: x-y-width-height, data units
bP = round([bP(1),bP(1)+bP(3)]); % data units == samples of x
bP = max(1,bP); % Clip at first sample
bP = min(length(x),bP); % Clip
x = x(bP(1):bP(2),chNum); % trim x

detectResults = struct([]);
for p1=1:length(chNum),
   % Auto detect calls using latest version of getCallEndpoints:
   [outputGlobal,outputLocal] = getCallEndpoints18(x(:,p1),fs,handles.parameters);

   % Correct for not starting at beginning of file:
   offsetTime = (bP(1)-1)/fs; % sec
   for p=1:length(outputLocal),
      outputLocal{p}(:,2) = outputLocal{p}(:,2)+offsetTime;
      outputGlobal(p).startTime = outputGlobal(p).startTime+offsetTime*1e3; % ms
      outputGlobal(p).stopTime = outputGlobal(p).stopTime+offsetTime*1e3; % ms
   end;

   % Get call endpoints:
   endpoints = zeros(length(outputLocal),2); % sec, [start,stop]
   for p=1:length(outputLocal),
      endpoints(p,1:2) = [outputGlobal(p).startTime,outputGlobal(p).stopTime]*1e-3;
   end;

   % Store auto detect results in struct:
   detectResults(chNum(p1)).outputGlobal = outputGlobal;
   detectResults(chNum(p1)).outputLocal = outputLocal;
   detectResults(chNum(p1)).lengthX = lenX; % samples
   detectResults(chNum(p1)).endpoints = endpoints;
end; % for each channel in numCh

% Save:
set(handles.autoDetectMenu,'userdata',detectResults);

% Create output TXT file:
outputTXTResults(handles,detectResults);

% Turn pointer back into arrow:
set(handles.figure1,'pointer','arrow');

% Enable extra views in View menu bar:
if numChannels==1,
   set([handles.frequencies_View,handles.spectralPeaks_View,handles.textOutput_View],'enable','on');
else
   set([handles.frequenciesMultiChView,handles.spectralPeaksMultiChView,handles.textOutput_View],'enable','on');
end;

% Update axes2:
updateAxes2(handles);


% --------------------------------------------------------------------
function autoDetFile_Callback(hObject, eventdata, handles)
% hObject    handle to autoDetFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Turn pointer into watch, temporarily:
set(handles.figure1,'pointer','watch');
drawnow;

% Get auto detection parameters, call latest version of getCallEndpoints:
fs = handles.values.fs;
x = get(handles.figure1,'userdata');

detectResults = struct([]);
for pCh=1:size(x,2) % For each channel
   % Auto detect calls using latest version of getCallEndpoints:
   [outputGlobal,outputLocal] = getCallEndpoints18(x(:,pCh),fs,handles.parameters);
%   [outputGlobal,outputLocal] = getCallEndpoints17(x(:,pCh),fs,handles.parameters);

   % Get call endpoints:
   endpoints = zeros(length(outputLocal),2); % sec, [start,stop]
   for p=1:length(outputLocal),
      endpoints(p,1:2) = [outputGlobal(p).startTime,outputGlobal(p).stopTime]*1e-3;
   end;

   % Store auto detect results in struct, save to current object userdata:
   detectResults(pCh).outputGlobal = outputGlobal;
   detectResults(pCh).outputLocal = outputLocal;
   detectResults(pCh).lengthX = size(x,1); % samples
   detectResults(pCh).endpoints = endpoints;
end; % For each channel

set(handles.autoDetectMenu,'userdata',detectResults);

% Save endpoint results to output file:
outputTXTResults(handles,detectResults);

% Turn pointer back into arrow:
set(handles.figure1,'pointer','arrow');

% Enable extra views in View menu bar:
set([handles.frequencies_View,handles.spectralPeaks_View,handles.textOutput_View],'enable','on');

% Update axes2:
updateAxes2(handles);


% --------------------------------------------------------------------
function autoDetDir_Callback(hObject, eventdata, handles)
% hObject    handle to autoDetDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Prompt to confirm action:
proceed = questdlg('Process all WAV files in current directory with current preference settings?','Proceed?','No');
drawnow;

% Change pointer to watch:
set(handles.figure1,'pointer','watch');

if strcmp(proceed,'Yes'), % proceed
   % Get list of WAV files in current directory:
   m = dir([handles.pathName,'*.wav']);
   
   % For each file and each channel, get call endpoints/information:
   for pFile=1:length(m),
      % Open file, update handles fileName:
      values = wavreadBat([handles.pathName,m(pFile).name]);
      val1 = values;
      val1.x=[];
      handles.fileName = m(pFile).name; % Used by outputTXTResults
      handles.values = val1;
      
      detectResults = struct([]);
      for pCh=1:size(values.x,2) % For each channel
         % Get auto detection parameters, call latest version of getCallEndpoints:
         fs = values.fs;
         handles.values.fs = fs; % Used during text output

         % Auto detect calls using latest version of getCallEndpoints:
         [outputGlobal,outputLocal] = getCallEndpoints18(values.x(:,pCh),fs,handles.parameters);
%         [outputGlobal,outputLocal] = getCallEndpoints17(values.x(:,pCh),fs,handles.parameters);

         % Get call endpoints:
         endpoints = zeros(length(outputLocal),2); % sec, [start,stop]
         for p=1:length(outputLocal),
            endpoints(p,1:2) = [outputGlobal(p).startTime,outputGlobal(p).stopTime]*1e-3;
         end;

         % Store auto detect results in struct, save to current object userdata:
         detectResults(pCh).outputGlobal = outputGlobal;
         detectResults(pCh).outputLocal = outputLocal;
         detectResults(pCh).lengthX = size(values.x,1); % samples
         detectResults(pCh).endpoints = endpoints;
      end; % For each channel
      set(handles.autoDetectMenu,'userdata',detectResults);

      % Save endpoint results to output file:
      outputTXTResults(handles,detectResults);
   end; % For each file
end;

% Change pointer back to arrow:
set(handles.figure1,'pointer','arrow');


% --------------------------------------------------------------------
function playMenu_Callback(hObject, eventdata, handles)
% hObject    handle to playMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function timeExpansionItem_Callback(hObject, eventdata, handles, numCh)
% hObject    handle to timeExpansionItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if nargin<4
   numCh = 1; % channel 1, default
end;

% Get time expansion factor, data, and sampling rate:
timeExpansionFactor = handles.parameters.play.timeExpansionFactor;
x = get(handles.figure1,'userdata');
fs = handles.values.fs;

% Get bb position, convert to sample endpoints:
bP = get(handles.bb,'position'); % bounding box: x-y-width-height, data units
bP = round([bP(1),bP(1)+bP(3)]); % data units == samples of x
bP = max(1,bP); % Clip at first sample
bP = min(length(x),bP); % Clip

% Play (non-blocking function call):
soundsc(double(x(bP(1):bP(2),numCh)),fs/timeExpansionFactor);

% --------------------------------------------------------------------
function heterodyneItem_Callback(hObject, eventdata, handles, numCh)
% hObject    handle to heterodyneItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if nargin<4,
   numCh = 1; % channel 1, default
end;

% Get heterodyne frequency, data, and sampling rate:
heterodyneFreq = handles.parameters.play.heterodyneFreq*1000; % Hz
x = get(handles.figure1,'userdata');
fs = handles.values.fs;

% Get bb position, convert to sample endpoints:
bP = get(handles.bb,'position'); % bounding box: x-y-width-height, data units
bP = round([bP(1),bP(1)+bP(3)]); % data units == samples of x
bP = max(1,bP); % Clip at first sample
bP = min(length(x),bP); % Clip

% Get window of x (double precision):
x = double(x(bP(1):bP(2),numCh));
x = x-mean(x); % make sure data is zero mean

% Create modulating frequency, modulate:
hetero = cos(2*pi*[0:length(x)-1]*heterodyneFreq/fs);
zH = x(:).*hetero(:);

% Play (non-blocking function call):
soundsc(zH,fs);


% --------------------------------------------------------------------
function frequencyDivisionItem_Callback(hObject, eventdata, handles, numCh)
% hObject    handle to frequencyDivisionItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if nargin<4,
   numCh = 1; % channel 1, default
end;

% Get frequency division factor, data, and sampling rate:
freqDivisionFactor = handles.parameters.play.freqDivisionFactor;
x = get(handles.figure1,'userdata');
fs = handles.values.fs;

% Get bb position, convert to sample endpoints:
bP = get(handles.bb,'position'); % bounding box: x-y-width-height, data units
bP = round([bP(1),bP(1)+bP(3)]); % data units == samples of x
bP = max(1,bP); % Clip at first sample
bP = min(length(x),bP); % Clip

% Get window of x (double precision):
x = double(x(bP(1):bP(2),numCh));
x = x-mean(x); % make sure data is zero mean

% Find positive-going zero crossings of x:
zc = find(x(1:end-1)<0 & x(2:end)>=0); % index into x, points at sample BEFORE zero crossing

% Construct frequency-divided output, same fs as x:
zFD = zeros(size(x));
for p=1:freqDivisionFactor:length(zc)-freqDivisionFactor-1,
   xRange = [zc(round(p)):zc(round(p+freqDivisionFactor))];
   A = sqrt(mean(x(xRange).^2)); % RMS amplitude
   xRangePos = xRange(1:round(length(xRange)/2));
   xRangeNeg = xRange(round(length(xRange)/2)+1:end);
   zFD(xRangePos) = A;
   zFD(xRangeNeg) = -A;
end;
zFD = zFD + 0.01*randn(size(zFD));

% Play (non-blocking function call):
soundsc(zFD,fs);


% --------------------------------------------------------------------
function textOutput_View_Callback(hObject, eventdata, handles)
% hObject    handle to textOutput_View (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Open TXT file:
if strcmp(lower(handles.fileName(end-2:end)),'wav') | strcmp(lower(handles.fileName(end-2:end)),'aif'), % wav or aif file
   edit([handles.pathName,handles.fileName(1:end-3),'GF.txt']);
else % aiff file
   edit([handles.pathName,handles.fileName(1:end-4),'GF.txt']);
end;


% --------------------------------------------------------------------
function energyMenu_Callback(hObject, eventdata, handles)
% hObject    handle to energyMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function energyView_Callback(hObject, eventdata, handles)
% hObject    handle to energyView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update checks in context menu:
set([handles.spectralPeaks_View,handles.frequencies_View,handles.spectrogram_View,...
   handles.timeDomain_View,handles.energyView,handles.quickSummaryView,...
   get(handles.spectrogramMultiChView,'children')'],'checked','off');
set(handles.energyView,'checked','on');
updateAxes2(handles);


% --------------------------------------------------------------------
function energyWindow_Callback(hObject, eventdata, handles, chNum)
% hObject    handle to energyWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if nargin<4,
   chNum = 1; % channel 1 by default
end;

% Turn pointer into watch, temporarily:
set(handles.figure1,'pointer','watch');
drawnow;

% Get x, fs:
x = get(handles.figure1,'userdata');
fs = handles.values.fs;

% Get limits of current window:
bP = get(handles.bb,'position'); % bounding box: x-y-width-height, data units
bP = round([bP(1),bP(1)+bP(3)]); % data units == samples of x
bP = max(1,bP); % Clip at first sample
bP = min(length(x),bP); % Clip
x = x(bP(1):bP(2),chNum); % trim x, channels in chNum

% Get energy:
temp = getPeakEnergy01(x,fs,handles.parameters);
if length(chNum)==1, % only 1 channel, so adjust struct index
   outputEnergy(chNum) = temp;
else % all channels
   outputEnergy = temp;
end;
   
% Correct for not starting at beginning of file:
offsetTime = (bP(1)-1)/fs; % sec
for p=1:length(chNum),
   outputEnergy(chNum(p)).sTime = outputEnergy(chNum(p)).sTime + offsetTime; % sec
end;

% Store auto detect results in struct, save to current object userdata:
detectResultsEnergy = struct([]);
detectResultsEnergy(1).outputEnergy = outputEnergy;
set(handles.energyMenu,'userdata',detectResultsEnergy);

% Create output TXT file:
outputTXTResultsEnergy(handles,detectResultsEnergy,1);

% Turn pointer back into arrow:
set(handles.figure1,'pointer','arrow');

% Enable extra views in View menu bar:
set([handles.energyView],'enable','on');

% Update axes2:
updateAxes2(handles);


% --------------------------------------------------------------------
function outputTXTResultsEnergy(handles,detectResults,channel)
% This function takes the results the energy analyzer and produces
% an Excel worksheet output.

% Get sampling rate:
fs = handles.values.fs;
outputEnergy = detectResults.outputEnergy; % 1xN struct, data for channel N only or all 4 channels

% Get file name:
if strcmp(lower(handles.fileName(end-2:end)),'wav') | strcmp(lower(handles.fileName(end-2:end)),'aif'),
   fileName = handles.fileName(1:end-3); % include '.'
else % aiff file
   fileName = handles.fileName(1:end-4);
end;

% Determine which worksheet to write to:
m=dir([handles.pathName,fileName,'PE.xls']);
if isempty(m), % No Excel file, so create:
   sheetNumber = 1;
else % Not empty, so determine sheet number:
   [junk,sheetNames] = xlsfinfo([handles.pathName,fileName,'PE.xls']);
   if isempty(sheetNames),
      sheetNumber = 1;
   else
      % Convert strings to numbers:
      sheetNamesConverted = zeros(1,length(sheetNames));
      for p=1:length(sheetNames),
         k = str2num(sheetNames{p});
         if ~isempty(k),
            sheetNamesConverted(p) = k;
         end;
      end;
      sheetNumber = max(sheetNamesConverted)+1;
   end;
end;
      
% Create header:
warning off MATLAB:xlswrite:AddSheet;
h = [handles.pathName,fileName,'PE.xls'];
header = cell(1,2);
r = 1; % row pointer
[header{r,1},header{r,2}] = deal(handles.fileName,'');r=r+1;
[header{r,1},header{r,2}] = deal('callViewer17','');r=r+1;
[header{r,1},header{r,2}] = deal(['Time: ',datestr(clock)],'');r=r+1;
r=r+1;
[header{r,1},header{r,2}] = deal('WAV FILE INFORMATION','');r=r+1;
[header{r,1},header{r,2}] = deal('Number of channels: ',handles.values.numChannels);r=r+1;
[header{r,1},header{r,2}] = deal('Sampling rate (Hz): ',fs);r=r+1;
[header{r,1},header{r,2}] = deal('Resolution (bits): ',handles.values.bitsPerSample);r=r+1;
r = r+1;
[header{r,1},header{r,2}] = deal('SPECTROGRAM PARAMETERS','');r=r+1;
[header{r,1},header{r,2}] = deal('Window size (ms): ',handles.parameters.detection.windowSize);r=r+1;
[header{r,1},header{r,2}] = deal('Frame rate (fps): ',handles.parameters.detection.frameRate);r=r+1;
[header{r,1},header{r,2}] = deal('Chunk size (sec): ',handles.parameters.detection.chunkSize);r=r+1;
[header{r,1},header{r,2}] = deal('SMS: ',handles.parameters.detection.SMS);r=r+1;
[header{r,1},header{r,2}] = deal('High pass filter cutoff: (kHz): ',handles.parameters.detection.HPFcutoff);r=r+1;
[header{r,1},header{r,2}] = deal('Window type: ',handles.parameters.detection.windowType);r=r+1;
for p=1:length(outputEnergy),
   if ~isempty(outputEnergy(p).meanEnergy),
      r=r+1;
      [header{r,1},header{r,2}] = deal(['Channel ',num2str(p)],'');r=r+1;
      [header{r,1},header{r,2}] = deal('Arithmetic mean of peak energy, dB: ',outputEnergy(p).meanEnergy);r=r+1;
      [header{r,1},header{r,2}] = deal('Geometric mean of peak energy, dB: ',outputEnergy(p).meanEnergydB);r=r+1;
      [header{r,1},header{r,2}] = deal('Start time, sec: ',outputEnergy(p).sTime(1));r=r+1;
      [header{r,1},header{r,2}] = deal('End time, sec: ',outputEnergy(p).sTime(end));r=r+1;
   end;
end;
xlswrite(h,header,num2str(sheetNumber),['A1:B',num2str(size(header,1))]);


% --------------------------------------------------------------------
function quickSummaryMenu_Callback(hObject, eventdata, handles)
% hObject    handle to quickSummaryMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function quickSummaryView_Callback(hObject, eventdata, handles)
% hObject    handle to quickSummaryView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update checks in context menu:
set([handles.spectralPeaks_View,handles.frequencies_View,handles.spectrogram_View,...
   handles.timeDomain_View,handles.energyView,handles.quickSummaryView,...
   get(handles.spectrogramMultiChView,'children')',...
   get(handles.spectralPeaksMultiChView,'children')',...
   get(handles.frequenciesMultiChView,'children')'],'checked','off');
set(handles.quickSummaryView,'checked','on');
updateAxes2(handles);


% --------------------------------------------------------------------
function quickSummaryFile_Callback(hObject, eventdata, handles)
% hObject    handle to quickSummaryFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Turn pointer into watch, temporarily:
set(handles.figure1,'pointer','watch');
drawnow;

% Get x, fs:
x = get(handles.figure1,'userdata');
fs = handles.values.fs;

% Get energy:
outputQuick = getQuickSummary01(x,fs,handles.parameters); % x can be single-channel or multi-channel data
outputQuick.fileName = handles.fileName;
outputQuick.fileLength = size(x,1)/fs; % sec

% Store auto detect results in struct, save to current object userdata:
detectResultsQuick = struct([]);
detectResultsQuick(1).outputQuick = outputQuick;
set(handles.quickSummaryMenu,'userdata',detectResultsQuick);

% Write to output file:
outputTXTResultsQuick(handles,outputQuick,1); % 1==create new worksheet

% Turn pointer back into arrow:
set(handles.figure1,'pointer','arrow');

% Enable extra views in View menu bar:
set([handles.quickSummaryView],'enable','on');

% Update axes2:
updateAxes2(handles);


% --------------------------------------------------------------------
function quickSummaryDir_Callback(hObject, eventdata, handles)
% hObject    handle to quickSummaryDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Prompt to confirm action:
proceed = questdlg('Find quick summary for all WAV files in current directory with current preference settings?','Proceed?','No');
drawnow;

% Change pointer to watch:
set(handles.figure1,'pointer','watch');

if strcmp(proceed,'Yes'), % proceed
   % Get list of WAV files in current directory:
   m = dir([handles.pathName,'*.wav']);
   
   % For each file, get quick summary:
   for pFile=1:length(m),
      % Open file:
      values = wavreadBat([handles.pathName,m(pFile).name]);

      % Get energy (x can be single-channel or multi-channel data):
      outputQuickTemp = getQuickSummary01(values.x,values.fs,handles.parameters);
      outputQuickTemp.fileName = m(pFile).name;
      outputQuickTemp.fileLength = size(values.x,1)/values.fs; % sec
      
      % Save:
      if pFile==1,
         outputQuick = outputQuickTemp;
      else
         outputQuick(pFile) = outputQuickTemp;
      end;

      % Write to output file (write after each file to get partial results if crash occurs):
      if pFile==1,
         outputTXTResultsQuick(handles,outputQuick,1); % Create new worksheet for first file
      else
         outputTXTResultsQuick(handles,outputQuick,0); % Append to last worksheet
      end;
   end; % For each file
end;

% Change pointer back to arrow:
set(handles.figure1,'pointer','arrow');


% --------------------------------------------------------------------
function outputTXTResultsQuick(handles,outputQuick,createNewSheet)
% This function takes the results from the quick summary and writes
% them to an Excel file.
% Input:  handles -- struct of GUI handles
%         outputQuick -- 1xN struct output from getQuickSummary01, N files
%         createNewSheet -- 1==create new Excel worksheet; 0==append to last worksheet

fileName = 'quickSummary.xls';

% Determine which worksheet to write to:
m=dir([handles.pathName,fileName]);
if isempty(m), % No Excel file, so create:
   sheetNumber = 1;
else % Not empty, so determine sheet number:
   [junk,sheetNames] = xlsfinfo([handles.pathName,fileName]);
   if isempty(sheetNames),
      sheetNumber = 1;
   else
      % Convert strings to numbers:
      sheetNamesConverted = zeros(1,length(sheetNames));
      for p=1:length(sheetNames),
         k = str2num(sheetNames{p});
         if ~isempty(k),
            sheetNamesConverted(p) = k;
         end;
      end;
      sheetNumber = max(sheetNamesConverted)+createNewSheet;
   end;
end;
      
% Create header:
warning off MATLAB:xlswrite:AddSheet;
h = [handles.pathName,fileName];
header = cell(1,2);
r = 1; % row pointer
[header{r,1},header{r,2}] = deal(handles.pathName,'');r=r+1;
[header{r,1},header{r,2}] = deal('callViewer17','');r=r+1;
[header{r,1},header{r,2}] = deal(['Time: ',datestr(clock)],'');r=r+1;
r=r+1;
[header{r,1},header{r,2}] = deal('WAV FILE INFORMATION','');r=r+1;
[header{r,1},header{r,2}] = deal('Number of channels: ',handles.values.numChannels);r=r+1;
[header{r,1},header{r,2}] = deal('Sampling rate (Hz): ',handles.values.fs);r=r+1;
[header{r,1},header{r,2}] = deal('Resolution (bits): ',handles.values.bitsPerSample);r=r+1;
r = r+1;
[header{r,1},header{r,2}] = deal('QUICK SUMMARY PARAMETERS','');r=r+1;
[header{r,1},header{r,2}] = deal('UPPER cutoff frequency: (kHz): ',num2str(handles.parameters.detection.LPFcutoff));r=r+1;
[header{r,1},header{r,2}] = deal('LOWER cutoff frequency: (kHz): ',num2str(handles.parameters.detection.HPFcutoff));r=r+1;
r=r+1;
[header{r,1},header{r,2}] = deal('QUICK SUMMARY','');r=r+1;
xlswrite(h,header,num2str(sheetNumber),['A1:B',num2str(size(header,1))]);

% Create ROW for each file:
body = {'File name','Length (sec)','Channel','numCalls, 5 dB','10 dB','15 dB','20 dB','30 dB','40 dB','50 dB',...
   'numPasses, 5 dB','10 dB','15 dB','20 dB','30 dB','40 dB','50 dB'};
for p=1:length(outputQuick), % for each file
   for p1=1:size(outputQuick(p).numCalls,2), % for each channel
      body{end+1,1} = outputQuick(p).fileName;
      body{end,2} = outputQuick(p).fileLength;
      body{end,3} = p1;
      for p2=1:size(outputQuick(p).numCalls,1), % for each energy threshold
         body{end,3+p2} = outputQuick(p).numCalls(p2,p1);
      end;
      for p2=1:size(outputQuick(p).numPasses,1), % for each energy threshold
         body{end,10+p2} = outputQuick(p).numPasses(p2,p1);
      end;
   end;
end;
xlswrite(h,body,num2str(sheetNumber),['A',num2str(size(header,1)+1),':Q',num2str(size(header,1)+size(body,1))]);


% --------------------------------------------------------------------
function spectrogramMultiChView_Callback(hObject, eventdata, handles)
% hObject    handle to spectrogramMultiChView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function spectrogramCh1View_Callback(hObject, eventdata, handles)
% hObject    handle to spectrogramCh1View (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update checks in context menu:
set([handles.spectralPeaks_View,handles.frequencies_View,handles.spectrogram_View,...
   handles.timeDomain_View,handles.energyView,handles.quickSummaryView,...
   get(handles.spectrogramMultiChView,'children')',...
   get(handles.frequenciesMultiChView,'children')',...
   get(handles.spectralPeaksMultiChView,'children')',...
   ],'checked','off');
set(handles.spectrogramCh1View,'checked','on');
updateAxes2(handles);


% --------------------------------------------------------------------
function spectrogramCh2View_Callback(hObject, eventdata, handles)
% hObject    handle to spectrogramCh2View (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update checks in context menu:
set([handles.spectralPeaks_View,handles.frequencies_View,handles.spectrogram_View,...
   handles.timeDomain_View,handles.energyView,handles.quickSummaryView,...
   get(handles.spectrogramMultiChView,'children')',...
   get(handles.frequenciesMultiChView,'children')',...
   get(handles.spectralPeaksMultiChView,'children')',...
   ],'checked','off');
set(handles.spectrogramCh2View,'checked','on');
updateAxes2(handles);


% --------------------------------------------------------------------
function spectrogramCh3View_Callback(hObject, eventdata, handles)
% hObject    handle to spectrogramCh3View (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update checks in context menu:
set([handles.spectralPeaks_View,handles.frequencies_View,handles.spectrogram_View,...
   handles.timeDomain_View,handles.energyView,handles.quickSummaryView,...
   get(handles.spectrogramMultiChView,'children')',...
   get(handles.frequenciesMultiChView,'children')',...
   get(handles.spectralPeaksMultiChView,'children')',...
   ],'checked','off');
set(handles.spectrogramCh3View,'checked','on');
updateAxes2(handles);


% --------------------------------------------------------------------
function spectrogramCh4View_Callback(hObject, eventdata, handles)
% hObject    handle to spectrogramCh4View (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update checks in context menu:
set([handles.spectralPeaks_View,handles.frequencies_View,handles.spectrogram_View,...
   handles.timeDomain_View,handles.energyView,handles.quickSummaryView,...
   get(handles.spectrogramMultiChView,'children')',...
   get(handles.frequenciesMultiChView,'children')',...
   get(handles.spectralPeaksMultiChView,'children')',...
   ],'checked','off');
set(handles.spectrogramCh4View,'checked','on');
updateAxes2(handles);


% --------------------------------------------------------------------
function spectralPeaksMultiChView_Callback(hObject, eventdata, handles)
% hObject    handle to spectralPeaksMultiChView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function frequenciesMultiChView_Callback(hObject, eventdata, handles)
% hObject    handle to frequenciesMultiChView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function frequenciesCh1View_Callback(hObject, eventdata, handles)
% hObject    handle to frequenciesCh1View (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update checks in context menu:
set([handles.spectralPeaks_View,handles.frequencies_View,handles.spectrogram_View,...
   handles.timeDomain_View,handles.energyView,handles.quickSummaryView,...
   get(handles.spectrogramMultiChView,'children')',...
   get(handles.frequenciesMultiChView,'children')',...
   get(handles.spectralPeaksMultiChView,'children')',...
   ],'checked','off');
set(handles.frequenciesCh1View,'checked','on');
updateAxes2(handles);


% --------------------------------------------------------------------
function frequenciesCh2View_Callback(hObject, eventdata, handles)
% hObject    handle to frequenciesCh2View (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update checks in context menu:
set([handles.spectralPeaks_View,handles.frequencies_View,handles.spectrogram_View,...
   handles.timeDomain_View,handles.energyView,handles.quickSummaryView,...
   get(handles.spectrogramMultiChView,'children')',...
   get(handles.frequenciesMultiChView,'children')',...
   get(handles.spectralPeaksMultiChView,'children')',...
   ],'checked','off');
set(handles.frequenciesCh2View,'checked','on');
updateAxes2(handles);


% --------------------------------------------------------------------
function frequenciesCh3View_Callback(hObject, eventdata, handles)
% hObject    handle to frequenciesCh3View (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update checks in context menu:
set([handles.spectralPeaks_View,handles.frequencies_View,handles.spectrogram_View,...
   handles.timeDomain_View,handles.energyView,handles.quickSummaryView,...
   get(handles.spectrogramMultiChView,'children')',...
   get(handles.frequenciesMultiChView,'children')',...
   get(handles.spectralPeaksMultiChView,'children')',...
   ],'checked','off');
set(handles.frequenciesCh3View,'checked','on');
updateAxes2(handles);


% --------------------------------------------------------------------
function frequenciesCh4View_Callback(hObject, eventdata, handles)
% hObject    handle to frequenciesCh4View (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update checks in context menu:
set([handles.spectralPeaks_View,handles.frequencies_View,handles.spectrogram_View,...
   handles.timeDomain_View,handles.energyView,handles.quickSummaryView,...
   get(handles.spectrogramMultiChView,'children')',...
   get(handles.frequenciesMultiChView,'children')',...
   get(handles.spectralPeaksMultiChView,'children')',...
   ],'checked','off');
set(handles.frequenciesCh4View,'checked','on');
updateAxes2(handles);


% --------------------------------------------------------------------
function spectralPeaksCh1View_Callback(hObject, eventdata, handles)
% hObject    handle to spectralPeaksCh1View (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update checks in context menu:
set([handles.spectralPeaks_View,handles.frequencies_View,handles.spectrogram_View,...
   handles.timeDomain_View,handles.energyView,handles.quickSummaryView,...
   get(handles.spectrogramMultiChView,'children')',...
   get(handles.frequenciesMultiChView,'children')',...
   get(handles.spectralPeaksMultiChView,'children')',...
   ],'checked','off');
set(handles.spectralPeaksCh1View,'checked','on');
updateAxes2(handles);


% --------------------------------------------------------------------
function spectralPeaksCh2View_Callback(hObject, eventdata, handles)
% hObject    handle to spectralPeaksCh2View (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update checks in context menu:
set([handles.spectralPeaks_View,handles.frequencies_View,handles.spectrogram_View,...
   handles.timeDomain_View,handles.energyView,handles.quickSummaryView,...
   get(handles.spectrogramMultiChView,'children')',...
   get(handles.frequenciesMultiChView,'children')',...
   get(handles.spectralPeaksMultiChView,'children')',...
   ],'checked','off');
set(handles.spectralPeaksCh2View,'checked','on');
updateAxes2(handles);



% --------------------------------------------------------------------
function spectralPeaksCh3View_Callback(hObject, eventdata, handles)
% hObject    handle to spectralPeaksCh3View (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update checks in context menu:
set([handles.spectralPeaks_View,handles.frequencies_View,handles.spectrogram_View,...
   handles.timeDomain_View,handles.energyView,handles.quickSummaryView,...
   get(handles.spectrogramMultiChView,'children')',...
   get(handles.frequenciesMultiChView,'children')',...
   get(handles.spectralPeaksMultiChView,'children')',...
   ],'checked','off');
set(handles.spectralPeaksCh3View,'checked','on');
updateAxes2(handles);


% --------------------------------------------------------------------
function spectralPeaksCh4View_Callback(hObject, eventdata, handles)
% hObject    handle to spectralPeaksCh4View (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update checks in context menu:
set([handles.spectralPeaks_View,handles.frequencies_View,handles.spectrogram_View,...
   handles.timeDomain_View,handles.energyView,handles.quickSummaryView,...
   get(handles.spectrogramMultiChView,'children')',...
   get(handles.frequenciesMultiChView,'children')',...
   get(handles.spectralPeaksMultiChView,'children')',...
   ],'checked','off');
set(handles.spectralPeaksCh4View,'checked','on');
updateAxes2(handles);



% --------------------------------------------------------------------
function autoDetMultiChWindow_Callback(hObject, eventdata, handles)
% hObject    handle to autoDetMultiChWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function energyMultiChWindow_Callback(hObject, eventdata, handles)
% hObject    handle to energyMultiChWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function energyCh1Window_Callback(hObject, eventdata, handles)
% hObject    handle to energyCh1Window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

energyWindow_Callback([],[],handles,1);


% --------------------------------------------------------------------
function energyCh2Window_Callback(hObject, eventdata, handles)
% hObject    handle to energyCh2Window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

energyWindow_Callback([],[],handles,2);


% --------------------------------------------------------------------
function energyCh3Window_Callback(hObject, eventdata, handles)
% hObject    handle to energyCh3Window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

energyWindow_Callback([],[],handles,3);


% --------------------------------------------------------------------
function energyCh4Window_Callback(hObject, eventdata, handles)
% hObject    handle to energyCh4Window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

energyWindow_Callback([],[],handles,4);

% --------------------------------------------------------------------
function energyCh5Window_Callback(hObject, eventdata, handles)
% hObject    handle to energyCh5Window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

energyWindow_Callback([],[],handles,[1 2 3 4]);


% --------------------------------------------------------------------
function autoDetCh1Window_Callback(hObject, eventdata, handles)
% hObject    handle to autoDetCh1Window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

autoDetWindow_Callback([],[],handles,1);

% --------------------------------------------------------------------
function autoDetCh2Window_Callback(hObject, eventdata, handles)
% hObject    handle to autoDetCh2Window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

autoDetWindow_Callback([],[],handles,2);


% --------------------------------------------------------------------
function autoDetCh3Window_Callback(hObject, eventdata, handles)
% hObject    handle to autoDetCh3Window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

autoDetWindow_Callback([],[],handles,3);


% --------------------------------------------------------------------
function autoDetCh4Window_Callback(hObject, eventdata, handles)
% hObject    handle to autoDetCh4Window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

autoDetWindow_Callback([],[],handles,4);


% --------------------------------------------------------------------
function autoDetCh5Window_Callback(hObject, eventdata, handles)
% hObject    handle to autoDetCh5Window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

autoDetWindow_Callback([],[],handles,[1 2 3 4]);


% --------------------------------------------------------------------
function timeExpansionMultiChItem_Callback(hObject, eventdata, handles)
% hObject    handle to timeExpansionMultiChItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function heterodyneMultiChItem_Callback(hObject, eventdata, handles)
% hObject    handle to heterodyneMultiChItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function frequencyDivisionMultiChItem_Callback(hObject, eventdata, handles)
% hObject    handle to frequencyDivisionMultiChItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function frequencyDivisionCh1Item_Callback(hObject, eventdata, handles)
% hObject    handle to frequencyDivisionCh1Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

frequencyDivisionItem_Callback([],[],handles,1);


% --------------------------------------------------------------------
function frequencyDivisionCh2Item_Callback(hObject, eventdata, handles)
% hObject    handle to frequencyDivisionCh2Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

frequencyDivisionItem_Callback([],[],handles,2);


% --------------------------------------------------------------------
function frequencyDivisionCh3Item_Callback(hObject, eventdata, handles)
% hObject    handle to frequencyDivisionCh3Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

frequencyDivisionItem_Callback([],[],handles,3);


% --------------------------------------------------------------------
function frequencyDivisionCh4Item_Callback(hObject, eventdata, handles)
% hObject    handle to frequencyDivisionCh4Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

frequencyDivisionItem_Callback([],[],handles,4);


% --------------------------------------------------------------------
function heterodyneCh1Item_Callback(hObject, eventdata, handles)
% hObject    handle to heterodyneCh1Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

heterodyneItem_Callback([],[],handles,1);

% --------------------------------------------------------------------
function heterodyneCh2Item_Callback(hObject, eventdata, handles)
% hObject    handle to heterodyneCh2Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

heterodyneItem_Callback([],[],handles,2);


% --------------------------------------------------------------------
function heterodyneCh3Item_Callback(hObject, eventdata, handles)
% hObject    handle to heterodyneCh3Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

heterodyneItem_Callback([],[],handles,3);


% --------------------------------------------------------------------
function heterodyneCh4Item_Callback(hObject, eventdata, handles)
% hObject    handle to heterodyneCh4Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

heterodyneItem_Callback([],[],handles,4);


% --------------------------------------------------------------------
function timeExpansionCh1Item_Callback(hObject, eventdata, handles)
% hObject    handle to timeExpansionCh1Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

timeExpansionItem_Callback([],[],handles,1);


% --------------------------------------------------------------------
function timeExpansionCh2Item_Callback(hObject, eventdata, handles)
% hObject    handle to timeExpansionCh2Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

timeExpansionItem_Callback([],[],handles,2);


% --------------------------------------------------------------------
function timeExpansionCh3Item_Callback(hObject, eventdata, handles)
% hObject    handle to timeExpansionCh3Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

timeExpansionItem_Callback([],[],handles,3);


% --------------------------------------------------------------------
function timeExpansionCh4Item_Callback(hObject, eventdata, handles)
% hObject    handle to timeExpansionCh4Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

timeExpansionItem_Callback([],[],handles,4);


% --------------------------------------------------------------------
function powerSpectrumView_Callback(hObject, eventdata, handles)
% hObject    handle to powerSpectrumView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(handles.powerSpectrumView,'checked'),'on'),
   set(handles.powerSpectrumView,'checked','off'); % turn off
else
   set(handles.powerSpectrumView,'checked','on'); % turn on
end;
updateAxes2(handles);


% --------------------------------------------------------------------
function saveMenu_Callback(hObject, eventdata, handles)
% hObject    handle to saveMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get data and file name:
fs = handles.values.fs; % Hz
x = get(handles.figure1,'userdata');
fileName = handles.fileName;
pathName = handles.pathName;

% Get bounding box, clip x:
bP = get(handles.bb,'position'); % bounding box: x-y-width-height, data units
bP = round([bP(1),bP(1)+bP(3)]); % data units == samples of x
bP = max(1,bP); % Clip at first sample
bP = min(size(x,1),bP); % Clip
x = double(x(bP(1):bP(2))); % window only, convert to floating point for scaling
x = x/max(abs(x))*.9999; % scaled between +1/-1

% Append time stamps to file name:
startSampleString = num2str(bP(1)+1e8);
startSampleString(1) = '0';
endSampleString = num2str(bP(2)+1e8);
endSampleString(1) = '0';
if strcmpi(fileName(end-3:end),'aiff'),
   fileName = [fileName(1:end-4),startSampleString,'to',endSampleString,'.wav'];
else
   fileName = [fileName(1:end-3),startSampleString,'to',endSampleString,'.wav'];
end;

% Confirm file name:
[fileName,pathName] = uiputfile('*.wav','Save Window to WAV file.',[pathName,fileName]); % includes trailing \

% Write WAV file:
if fileName(1)~=0, % Equals 0 if user hit Cancel button in dialog interface.
   set(handles.figure1,'pointer','watch'); % may take awhile, so change pointer to hourglass
   drawnow;
   wavwrite(x,fs,16,[pathName,fileName]);
   set(handles.figure1,'pointer','arrow');
   drawnow;
end;

% --------------------------------------------------------------------
function saveMenuMultiCh_Callback(hObject, eventdata, handles)
% hObject    handle to saveMenuMultiCh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function saveMenuRaw_Callback(hObject, eventdata, handles)
% hObject    handle to saveMenuRaw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function saveMenuRaw500_Callback(hObject, eventdata, handles)
% hObject    handle to saveMenuRaw500 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get data and file name:
fs = handles.values.fs; % Hz
x = get(handles.figure1,'userdata');
lenX = size(x,1);
fileName = handles.fileName;
pathName = handles.pathName;

% Get bounding box, clip x:
bP = get(handles.bb,'position'); % bounding box: x-y-width-height, data units
bP = round([bP(1),bP(1)+bP(3)]); % data units == samples of x
bP = max(1,bP); % Clip at first sample
bP = min(size(x,1),bP); % Clip
x = double(x(bP(1):bP(2))); % window only, convert to floating point for scaling
x = x/max(abs(x))*.9999; % scaled between +1/-1

% Append time stamps to file name:
if bP(1)==1 && bP(2)==lenX, % entire file, so don't include time stamps
   fileName = [fileName(1:end-3),'wav'];
else
   startSampleString = num2str(bP(1)+1e8);
   startSampleString(1) = '0';
   endSampleString = num2str(bP(2)+1e8);
   endSampleString(1) = '0';
   fileName = [fileName(1:end-3),startSampleString,'to',endSampleString,'.wav'];
end;

% Confirm file name:
[fileName,pathName] = uiputfile('*.wav','Save Window to WAV file.',[pathName,fileName]); % includes trailing \

% Write WAV file:
if fileName(1)~=0, % Equals 0 if user hit Cancel button in dialog interface.
   set(handles.figure1,'pointer','watch'); % may take awhile, so change pointer to hourglass
   drawnow;
   wavwrite(x,fs,16,[pathName,fileName]);
   set(handles.figure1,'pointer','arrow'); % may take awhile, so change pointer to hourglass
   drawnow;
end;


% --------------------------------------------------------------------
function saveMenuRaw250_Callback(hObject, eventdata, handles)
% hObject    handle to saveMenuRaw250 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get data and file name:
fs = handles.values.fs; % Hz
x = get(handles.figure1,'userdata');
lenX = size(x,1);
fileName = handles.fileName;
pathName = handles.pathName;

% Get bounding box, clip x:
bP = get(handles.bb,'position'); % bounding box: x-y-width-height, data units
bP = round([bP(1),bP(1)+bP(3)]); % data units == samples of x
bP = max(1,bP); % Clip at first sample
bP = min(size(x,1),bP); % Clip
x = double(x(bP(1):bP(2))); % window only, convert to floating point for scaling
x = x/max(abs(x))*.9999; % scaled between +1/-1

% Append time stamps to file name:
if bP(1)==1 && bP(2)==lenX, % entire file, so don't include time stamps
   fileName = [fileName(1:end-3),'wav'];
else
   startSampleString = num2str(bP(1)+1e8);
   startSampleString(1) = '0';
   endSampleString = num2str(bP(2)+1e8);
   endSampleString(1) = '0';
   fileName = [fileName(1:end-3),startSampleString,'to',endSampleString,'.wav'];
end;

% Resample x:
x = resample(x,1,2);
x = x/max(abs(x))*.9999;

% Confirm file name:
[fileName,pathName] = uiputfile('*.wav','Save Window to WAV file.',[pathName,fileName]); % includes trailing \

% Write WAV file:
if fileName(1)~=0, % Equals 0 if user hit Cancel button in dialog interface.
   set(handles.figure1,'pointer','watch'); % may take awhile, so change pointer to hourglass
   drawnow;
   wavwrite(x,250e3,16,[pathName,fileName]);
   set(handles.figure1,'pointer','arrow'); % may take awhile, so change pointer to hourglass
   drawnow;
end;


% --------------------------------------------------------------------
function saveMenuMultiCh1file_Callback(hObject, eventdata, handles)
% hObject    handle to saveMenuMultiCh1file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get data and file name:
fs = handles.values.fs; % Hz
x = get(handles.figure1,'userdata');
lenX = size(x,1);
fileName = handles.fileName;
pathName = handles.pathName;

% Get bounding box, clip x:
bP = get(handles.bb,'position'); % bounding box: x-y-width-height, data units
bP = round([bP(1),bP(1)+bP(3)]); % data units == samples of x
bP = max(1,bP); % Clip at first sample
bP = min(size(x,1),bP); % Clip

% Append time stamps to file name:
if bP(1)==1 && bP(2)==lenX, % entire file, so don't include time stamps
   fileNameOut = [fileName(1:end-3),'wav'];
else
   startSampleString = num2str(bP(1)+1e8);
   startSampleString(1) = '0';
   endSampleString = num2str(bP(2)+1e8);
   endSampleString(1) = '0';
   fileNameOut = [fileName(1:end-3),startSampleString,'to',endSampleString,'.wav'];
end;

xOut = double(x(bP(1):bP(2),:)); % window only, convert to floating point for scaling
for p=1:4,
   xOut(:,p) = xOut(:,p)/max(abs(xOut(:,p)))*.99; % scaled between +1/-1, 8-bit resolution
end;

% Confirm file name:
[fileNameOut,pathNameOut] = uiputfile('*.wav','Save Window to WAV file.',[pathName,fileNameOut]); % includes trailing \
if fileNameOut(1)~=0,
   set(handles.figure1,'pointer','watch'); % may take awhile, so change pointer to hourglass
   drawnow;
   wavwrite(xOut,fs,8,[pathNameOut,fileNameOut]); % only write 8-bit WAV file to save space
   set(handles.figure1,'pointer','arrow'); % may take awhile, so change pointer to hourglass
   drawnow;
end;


% --------------------------------------------------------------------
function saveMenuMultiCh4file_Callback(hObject, eventdata, handles)
% hObject    handle to saveMenuMultiCh4file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get data and file name:
fs = handles.values.fs; % Hz
x = get(handles.figure1,'userdata');
lenX = size(x,1);
fileName = handles.fileName;
pathName = handles.pathName;

% Get bounding box, clip x:
bP = get(handles.bb,'position'); % bounding box: x-y-width-height, data units
bP = round([bP(1),bP(1)+bP(3)]); % data units == samples of x
bP = max(1,bP); % Clip at first sample
bP = min(size(x,1),bP); % Clip

% Append time stamps to file name:
for p=1:size(x,2), % for each channel
   if bP(1)==1 && bP(2)==lenX, % entire file, so don't include time stamps
      fileNameOut = [fileName(1:end-3),'ch',num2str(p),'.wav'];
   else
      startSampleString = num2str(bP(1)+1e8);
      startSampleString(1) = '0';
      endSampleString = num2str(bP(2)+1e8);
      endSampleString(1) = '0';
      fileNameOut = [fileName(1:end-3),'ch',num2str(p),'.',startSampleString,'to',endSampleString,'.wav'];
   end;

   xOut = double(x(bP(1):bP(2),p)); % window only, convert to floating point for scaling
   xOut = xOut/max(abs(xOut))*.99; % scaled between +1/-1, 8-bit resolution

   % Confirm file name:
   if p==1, % allow user to change pathName, use file name convention for channels 2 through 4
      [fileNameOut,pathNameOut] = uiputfile('*.wav','Save Window to WAV file, channel 1.',[pathName,fileNameOut]); % includes trailing \
      if fileNameOut(1)==0,
         return; % user hit cancel, so leave function
      end;
   end;

   % Write WAV file:
   set(handles.figure1,'pointer','watch'); % may take awhile, so change pointer to hourglass
   drawnow;
   wavwrite(xOut,fs,8,[pathNameOut,fileNameOut]); % only write 8-bit WAV file to save space
end;
set(handles.figure1,'pointer','arrow'); % may take awhile, so change pointer to hourglass
drawnow;


% --------------------------------------------------------------------
function saveMenuMultiCh1Channel_Callback(hObject, eventdata, handles)
% hObject    handle to saveMenuMultiCh1Channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function saveMenuMultiChCh1_Callback(hObject, eventdata, handles)
% hObject    handle to saveMenuMultiChCh1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get data and file name:
fs = handles.values.fs; % Hz
x = get(handles.figure1,'userdata');
lenX = size(x,1);
fileName = handles.fileName;
pathName = handles.pathName;

% Get bounding box, clip x:
bP = get(handles.bb,'position'); % bounding box: x-y-width-height, data units
bP = round([bP(1),bP(1)+bP(3)]); % data units == samples of x
bP = max(1,bP); % Clip at first sample
bP = min(size(x,1),bP); % Clip

% Append time stamps to file name:
if bP(1)==1 && bP(2)==lenX, % entire file, so don't include time stamps
   fileNameOut = [fileName(1:end-3),'ch',num2str(1),'.wav'];
else
   startSampleString = num2str(bP(1)+1e8);
   startSampleString(1) = '0';
   endSampleString = num2str(bP(2)+1e8);
   endSampleString(1) = '0';
   fileNameOut = [fileName(1:end-3),'ch',num2str(1),'.',startSampleString,'to',endSampleString,'.wav'];
end;

xOut = double(x(bP(1):bP(2),1)); % window only, convert to floating point for scaling
xOut = xOut/max(abs(xOut))*.99; % scaled between +1/-1, 8-bit resolution

% Confirm file name:
[fileNameOut,pathNameOut] = uiputfile('*.wav','Save Window to WAV file, channel 1.',[pathName,fileNameOut]); % includes trailing \
if fileNameOut(1)~=0,
   set(handles.figure1,'pointer','watch'); % may take awhile, so change pointer to hourglass
   drawnow;
   wavwrite(xOut,fs,8,[pathNameOut,fileNameOut]); % only write 8-bit WAV file to save space
   set(handles.figure1,'pointer','arrow'); % may take awhile, so change pointer to hourglass
   drawnow;
end;



% --------------------------------------------------------------------
function saveMenuMultiChCh2_Callback(hObject, eventdata, handles)
% hObject    handle to saveMenuMultiChCh2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get data and file name:
fs = handles.values.fs; % Hz
x = get(handles.figure1,'userdata');
lenX = size(x,1);
fileName = handles.fileName;
pathName = handles.pathName;

% Get bounding box, clip x:
bP = get(handles.bb,'position'); % bounding box: x-y-width-height, data units
bP = round([bP(1),bP(1)+bP(3)]); % data units == samples of x
bP = max(1,bP); % Clip at first sample
bP = min(size(x,1),bP); % Clip

% Append time stamps to file name:
if bP(1)==1 && bP(2)==lenX, % entire file, so don't include time stamps
   fileNameOut = [fileName(1:end-3),'ch',num2str(2),'.wav'];
else
   startSampleString = num2str(bP(1)+1e8);
   startSampleString(1) = '0';
   endSampleString = num2str(bP(2)+1e8);
   endSampleString(1) = '0';
   fileNameOut = [fileName(1:end-3),'ch',num2str(2),'.',startSampleString,'to',endSampleString,'.wav'];
end;

xOut = double(x(bP(1):bP(2),2)); % window only, convert to floating point for scaling
xOut = xOut/max(abs(xOut))*.99; % scaled between +1/-1, 8-bit resolution

% Confirm file name:
[fileNameOut,pathNameOut] = uiputfile('*.wav','Save Window to WAV file, channel 2.',[pathName,fileNameOut]); % includes trailing \
if fileNameOut(1)~=0,
   set(handles.figure1,'pointer','watch'); % may take awhile, so change pointer to hourglass
   drawnow;
   wavwrite(xOut,fs,8,[pathNameOut,fileNameOut]); % only write 8-bit WAV file to save space
   set(handles.figure1,'pointer','arrow'); % may take awhile, so change pointer to hourglass
   drawnow;
end;



% --------------------------------------------------------------------
function saveMenuMultiChCh3_Callback(hObject, eventdata, handles)
% hObject    handle to saveMenuMultiChCh3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get data and file name:
fs = handles.values.fs; % Hz
x = get(handles.figure1,'userdata');
lenX = size(x,1);
fileName = handles.fileName;
pathName = handles.pathName;

% Get bounding box, clip x:
bP = get(handles.bb,'position'); % bounding box: x-y-width-height, data units
bP = round([bP(1),bP(1)+bP(3)]); % data units == samples of x
bP = max(1,bP); % Clip at first sample
bP = min(size(x,1),bP); % Clip

% Append time stamps to file name:
if bP(1)==1 && bP(2)==lenX, % entire file, so don't include time stamps
   fileNameOut = [fileName(1:end-3),'ch',num2str(3),'.wav'];
else
   startSampleString = num2str(bP(1)+1e8);
   startSampleString(1) = '0';
   endSampleString = num2str(bP(2)+1e8);
   endSampleString(1) = '0';
   fileNameOut = [fileName(1:end-3),'ch',num2str(3),'.',startSampleString,'to',endSampleString,'.wav'];
end;

xOut = double(x(bP(1):bP(2),3)); % window only, convert to floating point for scaling
xOut = xOut/max(abs(xOut))*.99; % scaled between +1/-1, 8-bit resolution

% Confirm file name:
[fileNameOut,pathNameOut] = uiputfile('*.wav','Save Window to WAV file, channel 3.',[pathName,fileNameOut]); % includes trailing \
if fileNameOut(1)~=0,
   set(handles.figure1,'pointer','watch'); % may take awhile, so change pointer to hourglass
   drawnow;
   wavwrite(xOut,fs,8,[pathNameOut,fileNameOut]); % only write 8-bit WAV file to save space
   set(handles.figure1,'pointer','arrow'); % may take awhile, so change pointer to hourglass
   drawnow;
end;



% --------------------------------------------------------------------
function saveMenuMultiChCh4_Callback(hObject, eventdata, handles)
% hObject    handle to saveMenuMultiChCh4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get data and file name:
fs = handles.values.fs; % Hz
x = get(handles.figure1,'userdata');
lenX = size(x,1);
fileName = handles.fileName;
pathName = handles.pathName;

% Get bounding box, clip x:
bP = get(handles.bb,'position'); % bounding box: x-y-width-height, data units
bP = round([bP(1),bP(1)+bP(3)]); % data units == samples of x
bP = max(1,bP); % Clip at first sample
bP = min(size(x,1),bP); % Clip

% Append time stamps to file name:
if bP(1)==1 && bP(2)==lenX, % entire file, so don't include time stamps
   fileNameOut = [fileName(1:end-3),'ch',num2str(4),'.wav'];
else
   startSampleString = num2str(bP(1)+1e8);
   startSampleString(1) = '0';
   endSampleString = num2str(bP(2)+1e8);
   endSampleString(1) = '0';
   fileNameOut = [fileName(1:end-3),'ch',num2str(4),'.',startSampleString,'to',endSampleString,'.wav'];
end;

xOut = double(x(bP(1):bP(2),4)); % window only, convert to floating point for scaling
xOut = xOut/max(abs(xOut))*.99; % scaled between +1/-1, 8-bit resolution

% Confirm file name:
[fileNameOut,pathNameOut] = uiputfile('*.wav','Save Window to WAV file, channel 4.',[pathName,fileNameOut]); % includes trailing \
if fileNameOut(1)~=0,
   set(handles.figure1,'pointer','watch'); % may take awhile, so change pointer to hourglass
   drawnow;
   wavwrite(xOut,fs,8,[pathNameOut,fileNameOut]); % only write 8-bit WAV file to save space
   set(handles.figure1,'pointer','arrow'); % may take awhile, so change pointer to hourglass
   drawnow;
end;






% Bye!