function varargout = DPS_visualizer(varargin)
% DPS_VISUALIZER MATLAB code for DPS_visualizer.fig
%      DPS_VISUALIZER, by itself, creates a new DPS_VISUALIZER or raises the existing
%      singleton*.
%
%      H = DPS_VISUALIZER returns the handle to a new DPS_VISUALIZER or the handle to
%      the existing singleton*.
%
%      DPS_VISUALIZER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPS_VISUALIZER.M with the given input arguments.
%
%      DPS_VISUALIZER('Property','Value',...) creates a new DPS_VISUALIZER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPS_visualizer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPS_visualizer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPS_visualizer

% Last Modified by GUIDE v2.5 10-Apr-2017 19:46:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPS_visualizer_OpeningFcn, ...
                   'gui_OutputFcn',  @DPS_visualizer_OutputFcn, ...
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

% --- Executes just before DPS_visualizer is made visible.
function DPS_visualizer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DPS_visualizer (see VARARGIN)

% Choose default command line output for DPS_visualizer
handles.output = hObject;
handles.latitude  = evalin('base', 'latitude');
handles.longitude = evalin('base', 'longitude');
handles.valid_dates = evalin('base', 'valids');
handles.valid_space = ones(length(handles.latitude), 1);
handles.RI = evalin('base', 'RI');
handles.Img = evalin('base', 'Img');
handles.ccClass = evalin('base', 'ccClass');
handles.summary = evalin('base', 'summary_clean');
handles.CaseNbr = evalin('base', 'CaseNbr');
handles.trueDate = evalin('base', 'trueDate');
handles.current_valids = zeros(length(handles.valid_space), 1);
handles.crimes = [];
handles.truetime = evalin('base', 'truetime');
handles.polyg = [handles.RI.XWorldLimits(1) handles.RI.YWorldLimits(1); handles.RI.XWorldLimits(1) handles.RI.YWorldLimits(2); handles.RI.XWorldLimits(2) handles.RI.YWorldLimits(1); handles.RI.XWorldLimits(1) handles.RI.YWorldLimits(2)];


ClassList = unique(handles.ccClass);
rgbval = jet(length(ClassList));
entries = cell(length(ClassList), 1);
for i=1:length(ClassList)
    rgbstr = ['rgb(' num2str(floor(255*rgbval(i, 1))) ',' num2str(floor(255*rgbval(i, 2))) ',' num2str(floor(255*rgbval(i, 3))) ')'];
    entries{i} = ['<HTML><FONT STYLE="background-color:' rgbstr '">==</FONT>' ClassList{i} '</HTML>'];
end
%set(handles.popupmenu1, 'String', [ClassList; {'ALL'}]);
set(handles.popupmenu1, 'String', [entries; {'ALL'}]);
mdate = min(handles.trueDate(handles.valid_dates));
Mdate = max(handles.trueDate(handles.valid_dates));
set(handles.slider1, 'Value', mdate);
set(handles.slider1, 'Min', mdate);
set(handles.slider1, 'Max', Mdate);
sstep = 1/(Mdate-mdate);
set(handles.slider1, 'SliderStep', [sstep sstep]);

handles.cmap = zeros(length(handles.ccClass), 3);
for k=1:length(ClassList)
    idx = strcmp(handles.ccClass, ClassList{k});
    handles.cmap(idx, :) = repmat(rgbval(k, :), sum(idx), 1);
end

guidata(hObject, handles);

% UIWAIT makes DPS_visualizer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DPS_visualizer_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axes1);
cla;
ax = gca;
% set(handles.axes1, 'NextPlot', 'replacechildren');
ax.NextPlot = 'replacechildren';
hdt = datacursormode;
set(hdt,'UpdateFcn',{@labeldtips,hdt, handles});

popup_idx = get(handles.popupmenu1, 'Value');
popup_str = get(handles.popupmenu1, 'String');
popup_str = regexprep(popup_str, '(<[^>]*>)|=', '');

imshow(handles.Img, handles.RI);

hold on;
getclasses = strcmp(handles.ccClass, popup_str{popup_idx});
time_period = (handles.trueDate >= get(handles.slider1, 'Value')) & (handles.trueDate<(get(handles.slider1, 'Value')+str2num(get(handles.edit1, 'String'))));
if(sum(getclasses)==0)
    handles.current_valids = handles.valid_space;
else
    handles.current_valids = handles.current_valids | getclasses;
end
valids = handles.current_valids & time_period & handles.valid_space;
handles.crimes = scatter3(handles.longitude(valids), -abs(handles.latitude(valids)), handles.CaseNbr(valids), [], handles.cmap(valids, :));

guidata(hObject, handles);
hold off;

% Other statistics
set(handles.axes2, 'NextPlot', 'replacechildren');
set(handles.axes2, 'XtickLabel', {'S', 'M', 'T', 'W', 'Th', 'F', 'S'});
xlim(handles.axes2, [2 8]);
sun = 736794;
xx= mod(handles.trueDate(valids)-sun, 7);
yy = tabulate(xx);
if(~isempty(yy))
    bar(handles.axes2, yy(:, 1)+2, yy(:, 2));
else
    bar(handles.axes2, [1:7], zeros(1, 7));
end
%datetick('x', 'd');

set(handles.axes3, 'NextPlot', 'replacechildren');

xx = handles.truetime(valids);
if(~isempty(yy))
    bar(handles.axes3, [0:23]/24, histc(xx, [0:23]/24));
else
    bar(handles.axes3, [0:23]/24, zeros(1, 24));
end
xlim(handles.axes3, [0 23/24]);
%datetick(handles.axes3, 'x', 'HHPM');
set(handles.axes3, 'Xtick', [0:4/24:23/24], 'XtickLabel', {'12AM', '4AM', '8AM', '12PM', '4PM', '8PM'});

function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
cla;
hdt = datacursormode;
set(hdt,'UpdateFcn',{@labeldtips,hdt, handles});

popup_idx = get(handles.popupmenu1, 'Value');
popup_str = get(handles.popupmenu1, 'String');
imshow(handles.Img, handles.RI);
hold on;
getclasses = strcmp(handles.ccClass, popup_str{popup_idx});
time_period = handles.trueDate >= get(handles.slider1, 'Value') & handles.trueDate<(get(handles.slider1, 'Value')+str2num(get(handles.edit1, 'String')));
if(sum(getclasses)==0)
    handles.current_valids = zeros(length(handles.current_valids), 1);
else
    handles.current_valids = handles.current_valids & ~getclasses;
end
valids = handles.current_valids & time_period;
scatter3(handles.longitude(valids), -abs(handles.latitude(valids)), handles.CaseNbr(valids), [], handles.cmap(valids, :));

guidata(hObject, handles);
hold off;
% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end

function output_txt  = labeldtips_p(obj,event_obj,hdt, handles)
% Display an observation's Y-data and label for a data tip
% obj          Currently not used (empty)
% event_obj    Handle to event object

dcs=hdt.DataCursors;
pos = get(dcs(1),'Position');   %Position of 1st cursor
output_txt{1} = ['DATE: ' datestr(pos(1))];

function output_txt  = labeldtips(obj,event_obj,hdt, handles)
% Display an observation's Y-data and label for a data tip
% obj          Currently not used (empty)
% event_obj    Handle to event object

dcs=hdt.DataCursors;
pos = get(dcs(1),'Position');   %Position of 1st cursor
% SU = evalin('base', 'summary_clean');
% CN = evalin('base', 'CaseNbr');
SU = handles.summary;
CN = handles.CaseNbr;
sum_loc = find(CN==pos(3));

if ~isempty(sum_loc)
String_to_disp = [{['Report:' SU{sum_loc}]}; {['Date: ' datestr(handles.trueDate(sum_loc))]}]; 
set(handles.text1, 'String', String_to_disp);
%output_txt{1} = '';
output_txt{1} = ['Case: ' num2str(pos(3))];
output_txt{2} = ['Class: ' handles.ccClass{sum_loc}];
else
    output_txt = {''};
end



% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
time_period = handles.trueDate >= get(handles.slider1, 'Value') & handles.trueDate<(get(handles.slider1, 'Value')+str2num(get(handles.edit1, 'String')));
valids = handles.current_valids & time_period & handles.valid_space;
mindate = get(handles.slider1, 'Value');
maxdate = (get(handles.slider1, 'Value')+str2num(get(handles.edit1, 'String')))-1;

set(handles.text3, 'String', [datestr(mindate) ' to ' datestr(maxdate)]);

if get(handles.checkbox1, 'Value')
    xx = tabulate(handles.trueDate(valids));
    garbage = xx(:, 1)<mindate | xx(:, 1)>maxdate; xx(garbage, :) = [];
    if(~isempty(xx))
        plot(xx(:, 1), xx(:, 2));
    end
    datetick('x', 'dd-mmm-yyyy');
else
%     hdt = datacursormode;
%     set(handles.text3, 'String', [datestr(mindate) ' to ' datestr(maxdate)])
%     imshow(handles.Img, handles.RI);
    if ~isempty(handles.crimes) && ishandle(handles.crimes)
    delete(handles.crimes);
    end
    hold on;
    handles.crimes = scatter3(handles.longitude(valids), -abs(handles.latitude(valids)), handles.CaseNbr(valids), [], handles.cmap(valids, :));
    hold off;
end
guidata(hObject, handles);

% Other statistics

sun = 736794;
xx= mod(handles.trueDate(valids)-sun, 7);
yy = tabulate(xx);
if(~isempty(yy))
    bar(handles.axes2, yy(:, 1)+2, yy(:, 2));
else
    bar(handles.axes2, [2:8], zeros(1, 7));
end

xx = handles.truetime(valids);
if(~isempty(yy))
    bar(handles.axes3, [0:23]/24, histc(xx, [0:23]/24));
else
    bar(handles.axes3, [0:23]/24, zeros(1, 24));
end
%datetick(handles.axes3, 'x', 'HHPM');
xlim(handles.axes3, [0 23/24]);

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in pushbutton5.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
cla;
hdt = datacursormode;
set(hdt,'UpdateFcn',{@labeldtips,hdt, handles});

popup_idx = get(handles.popupmenu1, 'Value');
popup_str = get(handles.popupmenu1, 'String');
imshow(handles.Img, handles.RI);
hold on;
getclasses = ~cellfun(@isempty, strfind(handles.summary, cell2mat(get(handles.edit2, 'String'))));
time_period = handles.trueDate >= get(handles.slider1, 'Value') & handles.trueDate<(get(handles.slider1, 'Value')+str2num(get(handles.edit1, 'String')));
if(sum(getclasses)==0)
    handles.current_valids = handles.valid_space;
else
    handles.current_valids = handles.current_valids | getclasses;
end
valids = handles.current_valids & time_period & handles.valid_space;
scatter3(handles.longitude(valids), -abs(handles.latitude(valids)), handles.CaseNbr(valids), [], handles.cmap(valids, :));

guidata(hObject, handles);
hold off;


function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
if get(handles.checkbox1, 'Value')
    mindate = get(handles.slider1, 'Value');
    maxdate = (get(handles.slider1, 'Value')+str2num(get(handles.edit1, 'String')));
    time_period = handles.trueDate >= mindate & handles.trueDate<maxdate;
    valids = handles.current_valids & time_period;
    xx = tabulate(handles.trueDate);
    garbage = xx(:, 1)<mindate | xx(:, 1)>maxdate; xx(garbage, :) = [];
    plot(xx(:, 1), xx(:, 2));
    datetick('x', 'dd-mmm-yyyy');
    hdt = datacursormode;
    set(hdt,'UpdateFcn',{@labeldtips_p,hdt, handles});
end

% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
if get(handles.checkbox2, 'Value')
    mindate = get(handles.slider1, 'Value');
    maxdate = (get(handles.slider1, 'Value')+str2num(get(handles.edit1, 'String')));
    hold on;
    % usc_freq = evalin('base', 'usc_freq');
    % week_start = evalin('base', 'week_start');
    % idx = week_start >= mindate & week_start <= maxdate;
    % plot(week_start(idx), usc_freq(idx));
    usc_daily = evalin('base', 'usc_daily');
    mdate = get(handles.slider1, 'Min');
    xx = usc_daily(mindate-mdate+1: min(maxdate-mdate+1, length(usc_daily)));
    plot(mindate:mindate+length(xx)-1, xx, 'g');
    hdt = datacursormode;
    set(hdt,'UpdateFcn',{@labeldtips_p,hdt, handles});
    hold off;
end

% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[lineobj,xs,ys] = freehanddraw(handles.axes1);
handles.polyg = [xs ys];
vs = handles.valid_space;
in = inpolygon(handles.longitude, -abs(handles.latitude), handles.polyg(:, 1), handles.polyg(:, 2));
handles.valid_space = vs & in;
guidata(hObject, handles);


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.polyg = [handles.RI.XWorldLimits(1) handles.RI.YWorldLimits(1); handles.RI.XWorldLimits(1) handles.RI.YWorldLimits(2); handles.RI.XWorldLimits(2) handles.RI.YWorldLimits(1); handles.RI.XWorldLimits(1) handles.RI.YWorldLimits(2)];
handles.valid_space = evalin('base', 'valid_space');
guidata(hObject, handles);
