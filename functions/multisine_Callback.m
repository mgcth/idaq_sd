% --- Executes on button press in multisine.
function multisine_Callback(hObject, eventdata, handles)
% hObject    handle to monitor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global currentState

% Hint: get(hObject,'Value') returns toggle state of multisine
val = get(hObject,'Value');
if (val)
    set(handles.monitor, 'Value', 0);
    set(handles.dataLogg, 'Value', 0);
    set(handles.impactTest, 'Value', 0);
    set(handles.periodic, 'Value', 0);
    set(handles.steppedSine, 'Value', 0);
    set(handles.multisine, 'Value', 1);
    
    set(handles.fun1,'string',currentState{6,1})
    set(handles.fun2Text,'visible','on')
    set(handles.fun2Text,'string','Frequency list:')
    set(handles.fun2,'visible','on')
    set(handles.fun2,'string',currentState{6,2})
    set(handles.fun3Text,'visible','on')
    set(handles.fun3Text,'string','Amplitude list:')
    set(handles.fun3,'visible','on')
    set(handles.fun3,'string',currentState{6,3})
    set(handles.fun4Text,'visible','on')
    set(handles.fun4Text,'string','Min. # cycles:')
    set(handles.fun4,'visible','on')
    set(handles.fun4,'string',currentState{6,4})
    set(handles.fun5Text,'visible','on')
    set(handles.fun5Text,'string','Distorsion level:')
    set(handles.fun5,'visible','on')
    set(handles.fun5,'string',currentState{6,5})
    set(handles.fun6Text,'visible','on')
    set(handles.fun6Text,'string','Distorsion orders:')
    set(handles.fun6,'visible','on')
    set(handles.fun6,'string',currentState{6,6})
    set(handles.fun7Text,'visible','off')
    set(handles.fun7,'visible','off')
    set(handles.fun8Text,'visible','off')
    set(handles.fun8,'visible','off')
    set(handles.fun9Text,'visible','off')
    set(handles.fun9,'visible','off')
else
    set(handles.multisine, 'Value', 1);
end