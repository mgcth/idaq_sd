% --- Executes on button press in scanButton.
function scanButton_Callback(hObject, eventdata, handles)
% hObject    handle to scanButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

COLUMNSinINPUTTABLE = 13;
COLUMNSinOUTPUTTABALE = 1;

% Waitbar
WB=waitbar(0);
set(WB,'Name','Scanning channels');
WB.Children.Title.String='Preparing ...';

% Get old data
oldData = get(handles.channelsTable, 'data');

[oldN, oldM] = size(oldData);

set(handles.statusStr, 'String', 'Scanning hardware for avaible channels and sensors...');
guidata(hObject, handles);
drawnow();

% Get state of monitor if existing and close it
preview = getappdata(0, 'previewStruct');

try     running = ~isempty(preview) && preview.session.IsRunning;
catch,  running = false;
end

if (running)
    closePreview (hObject, eventdata, handles);
end

%   Load TEDS Parser DLL
%     loadlibrary('tedsLib', 'tedsLib.h');

% Get available devices
daq.reset;
devices = daq.getDevices;

%   Calculate size of cell
m = COLUMNSinINPUTTABLE; n = 0;
for i = 1:length(devices)
    %         calllib('tedsLib', 'resetDevice', devices(i).ID); % Reset device
    for j = 1:length(devices(i).Subsystems)
        if (strcmp(devices(i).Subsystems(j).SubsystemType, 'AnalogInput'))
            n = n + devices(i).Subsystems(j).NumberOfChannelsAvailable;
        end
    end
end

%   If number of channels corresponds to the current number of channels
%   then dont delete colums LABEL, DOF og DIR
if (oldN == n)
    keepColumns = true;
    data = oldData;
else
    keepColumns = false;
    data = cell(n, m);
end

%disp([num2str(n), '    ', num2str(m)])
%disp(['Keep columns: ', num2str(keepColumns)]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   Scan all channels on all devices
%   Check devices

% ----- TA 2015-02-27 (mod start)
Nch=0;
for currentDevice = 1:length(devices)
    if (devices(currentDevice).isvalid)
        for subsys = 1:length(devices(currentDevice).Subsystems)
            for channel = 1:devices(currentDevice).Subsystems(subsys).NumberOfChannelsAvailable
                Nch=Nch+1;
            end
        end
    end
end
% ----- TA (mod end)


i = 1;Ich=0;
for currentDevice = 1:length(devices)
    %         disp(['Scanning device: ', devices(currentDevice).ID, ' ...']);
    resetDevice(devices(currentDevice).ID);
    
    if (devices(currentDevice).isvalid)
        for subsys = 1:length(devices(currentDevice).Subsystems)
            
            %   Get input
            if (strcmp(devices(currentDevice).Subsystems(subsys).SubsystemType, 'AnalogInput'))
                %   Get input channels
                for channel = 0:devices(currentDevice).Subsystems(subsys).NumberOfChannelsAvailable - 1
                    %                         fprintf(['Scanning channel: ai', num2str(channel), ' on device: ', devices(currentDevice).ID ,' ... ']);
                    Ich=Ich+1;waitbar(Ich/Nch,WB);WB.Children.Title.String=['Scanning: ' devices(currentDevice).ID];
                    
                    chanStr = [devices(currentDevice).ID, '/ai', num2str(channel)];
                    s = getTEDS(chanStr);
                    
                    if (s.ErrorCode == 0)
                        %                             fprintf('Sensor found.\n');
                        %   Loop through manufactures
                        manufacturer = '';
                        for manId = 1:length(handles.pubListId)
                            if (handles.pubListId(manId) == s.ManufacturerId)
                                manufacturer = handles.pubListCompany(manId);
                            end
                        end
                        
                        %                             sens = calllib('tedsLib', 'getSens', chanStr);
                        
                        %   Extract unit
                        unit = s.Unit;  %   Extract unit
                        
                        if strcmp(unit(1:2), 'V/')
                            if strcmp(unit(3), '(')
                                unit = unit(4:length(unit)-1);
                            else
                                unit = unit(3:length(unit));
                            end
                        end
                        
                        if (keepColumns)
                            data(i, 1) = {false};
                            data(i, 2) = {false};
                            data(i, 3) = {chanStr};
                            %%data(i, 4) = {'Input'};
                            data(i, 4) = oldData(i, 3);
                            data(i, 5) = {'IEPE'};
                            %data(i, 6) = {max(devices(currentDevice).Subsystems.RangesAvailable.Max)};
                            data(i, 6) = {max(max(devices(currentDevice).Subsystems(1).RangesAvailable.double))};
                            %vpa(devices(currentDevice).Subsystems.RangesAvailable.Max);
                            %%data(i, 8) = {'IEPE'};
                            data(i, 7) = {char(manufacturer)};
                            data(i, 8) = {num2str(s.ModelNumber)};
                            data(i, 9) = {num2str(s.SerialNumber)};
                            data(i, 10) = {(s.Sensitivity) * 1000};
                            data(i, 11) = {unit};
                            data(i, 12) = oldData(i, 11);
                            data(i, 13) = oldData(i, 12);
                        else
                            %                                 data(i, :) = {false, chanStr, ' ', 'AC', devices(currentDevice).Subsystems.RangesAvailable.Max, char(manufacturer), s.ModelNumber, s.SerialNumber, s.Sensitivity, {''}, NaN, ' '};
                            data(i, 1) = {false};
                            data(i, 2) = {false};
                            data(i, 3) = {chanStr};
                            %%data(i, 4) = {'Input'};
                            data(i, 4) = {' '};
                            data(i, 5) = {'IEPE'};
                            %data(i, 6) = {10};%max(devices(currentDevice).Subsystems.RangesAvailable.Max)};
                            data(i, 6) = {max(max(devices(currentDevice).Subsystems(1).RangesAvailable.double))};
                            %vpa(devices(currentDevice).Subsystems.RangesAvailable.Max);
                            %%data(i, 8) = {'IEPE'};
                            data(i, 7) = {char(manufacturer)};
                            data(i, 8) = {num2str(s.ModelNumber)};
                            data(i, 9) = {num2str(s.SerialNumber)};
                            data(i, 10) = {(s.Sensitivity) * 1000};
                            data(i, 11) = {unit};
                            data(i, 12) = {NaN};
                            data(i, 13) = {' '};
                        end
                    else
                        %                             fprintf('Sensor not found!\n');
                        
                        if (keepColumns)
                            data(i, 1) = {false};
                            data(i, 2) = {false};
                            data(i, 3) = {chanStr};
                            %data(i, 4) = {'Input'};
                            data(i, 4) = oldData(i, 3);
                            data(i, 5) = {' '};
                            data(i, 6) = {NaN};
                            %data(i, 8) = {'Voltage'};
                            data(i, 7) = {' '};
                            data(i, 8) = {num2str(NaN)};
                            data(i, 9) = {num2str(NaN)};
                            data(i, 10) = {NaN};
                            data(i, 11) = {' '};
                            data(i, 12) = oldData(i, 11);
                            data(i, 13) = oldData(i, 12);
                        else
                            data(i, :) = {false, false, chanStr, ' ', ' ', NaN, ' ', NaN, NaN, NaN, ' ', NaN, ' '};
                        end
                    end
                    
                    i = i + 1;
                    set(handles.channelsTable, 'data', data);   %   Experimental
                    guidata(hObject, handles);                  %   Experimental
                    drawnow();                                  %   Experimental
                end
            end
            
            %   Get output channels
        end
    else
        fprintf('No devices found\n ');
    end
    % ----- TA 2015-02-27 (mod start)
    %         handles.channelsTable.CellSelectionCallback='disp(''CellSelect'')';
    %         handles.channelsTable.KeyPressFcn='disp(''Press'')';
    %         handles.channelsTable.ButtonDownFcn='disp(''ButtonDown'')';
    %         handles.channelsTable.KeyReleaseFcn='disp(''Release'')';
    
    % ----- TA 2015-02-27 (end)
    
end
tic
    SensorsInLabFile=which('SensorsInLab.xlsx');
    if ~isempty(SensorsInLabFile)
        [CLL,rawCells]=xls2cell(SensorsInLabFile,5);
        CLL{1}(1,1)={' '};% Replace column header with blank
        handles.channelsTable.ColumnFormat{8}=CLL{:};
    end
    handles.channelsTable.CellEditCallback={@celleditcallback,rawCells};
    toc
try,delete(WB),catch,end;% TA 2015-02-28

%   Unload TEDS Parser DLL
%     unloadlibrary('tedsLib');





% %   Calculate size of cell
% m = COLUMNSinOUTPUTTABLE; n = 0;
% for i = 1:length(devices)
%     %         calllib('tedsLib', 'resetDevice', devices(i).ID); % Reset device
%     for j = 1:length(devices(i).Subsystems)
%         if (strcmp(devices(i).Subsystems(j).SubsystemType, 'AnalogOutput'))
%             n = n + devices(i).Subsystems(j).NumberOfChannelsAvailable;
%         end
%     end
% end
% 
% %   If number of channels corresponds to the current number of channels
% %   then dont delete colums LABEL, DOF og DIR
% if (oldN == n)
%     keepColumns = true;
%     data = oldData;
% else
%     keepColumns = false;
%     data = cell(n, m);
% end
% 
% %disp([num2str(n), '    ', num2str(m)])
% %disp(['Keep columns: ', num2str(keepColumns)]);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% %   Scan all channels on all devices
% %   Check devices
% 
% % ----- TA 2015-02-27 (mod start)
% Nch=0;
% for currentDevice = 1:length(devices)
%     if (devices(currentDevice).isvalid)
%         for subsys = 1:length(devices(currentDevice).Subsystems)
%             for channel = 1:devices(currentDevice).Subsystems(subsys).NumberOfChannelsAvailable
%                 Nch=Nch+1;
%             end
%         end
%     end
% end
% % ----- TA (mod end)
% 
% 
% i = 1;Ich=0;
% for currentDevice = 1:length(devices)
%     %         disp(['Scanning device: ', devices(currentDevice).ID, ' ...']);
%     resetDevice(devices(currentDevice).ID);
%     
%     if (devices(currentDevice).isvalid)
%         for subsys = 1:length(devices(currentDevice).Subsystems)
%             
%             %   Get input
%             if (strcmp(devices(currentDevice).Subsystems(subsys).SubsystemType, 'AnalogInput'))
%                 %   Get input channels
%                 for channel = 0:devices(currentDevice).Subsystems(subsys).NumberOfChannelsAvailable - 1
%                     %                         fprintf(['Scanning channel: ai', num2str(channel), ' on device: ', devices(currentDevice).ID ,' ... ']);
%                     Ich=Ich+1;waitbar(Ich/Nch,WB);WB.Children.Title.String=['Scanning: ' devices(currentDevice).ID];
%                     
%                     chanStr = [devices(currentDevice).ID, '/ai', num2str(channel)];
%                     s = getTEDS(chanStr);
%                     
%                     if (s.ErrorCode == 0)
%                         %                             fprintf('Sensor found.\n');
%                         %   Loop through manufactures
%                         manufacturer = '';
%                         for manId = 1:length(handles.pubListId)
%                             if (handles.pubListId(manId) == s.ManufacturerId)
%                                 manufacturer = handles.pubListCompany(manId);
%                             end
%                         end
%                         
%                         %                             sens = calllib('tedsLib', 'getSens', chanStr);
%                         
%                         %   Extract unit
%                         unit = s.Unit;  %   Extract unit
%                         
%                         if strcmp(unit(1:2), 'V/')
%                             if strcmp(unit(3), '(')
%                                 unit = unit(4:length(unit)-1);
%                             else
%                                 unit = unit(3:length(unit));
%                             end
%                         end
%                         
%                         if (keepColumns)
%                             data(i, 1) = {false};
%                             data(i, 2) = {chanStr};
%                             %%data(i, 3) = {'Input'};
%                             data(i, 3) = oldData(i, 3);
%                             data(i, 4) = {'IEPE'};
%                             %data(i, 5) = {max(devices(currentDevice).Subsystems.RangesAvailable.Max)};
%                             data(i, 5) = {max(max(devices(currentDevice).Subsystems(1).RangesAvailable.double))};
%                             %vpa(devices(currentDevice).Subsystems.RangesAvailable.Max);
%                             %%data(i, 7) = {'IEPE'};
%                             data(i, 6) = {char(manufacturer)};
%                             data(i, 7) = {num2str(s.ModelNumber)};
%                             data(i, 8) = {num2str(s.SerialNumber)};
%                             data(i, 9) = {(s.Sensitivity) * 1000};
%                             data(i, 10) = {unit};
%                             data(i, 11) = oldData(i, 11);
%                             data(i, 12) = oldData(i, 12);
%                         else
%                             %                                 data(i, :) = {false, chanStr, ' ', 'AC', devices(currentDevice).Subsystems.RangesAvailable.Max, char(manufacturer), s.ModelNumber, s.SerialNumber, s.Sensitivity, {''}, NaN, ' '};
%                             data(i, 1) = {false};
%                             data(i, 2) = {chanStr};
%                             %%data(i, 3) = {'Input'};
%                             data(i, 3) = {' '};
%                             data(i, 4) = {'IEPE'};
%                             %data(i, 5) = {10};%max(devices(currentDevice).Subsystems.RangesAvailable.Max)};
%                             data(i, 5) = {max(max(devices(currentDevice).Subsystems(1).RangesAvailable.double))};
%                             %vpa(devices(currentDevice).Subsystems.RangesAvailable.Max);
%                             %%data(i, 7) = {'IEPE'};
%                             data(i, 6) = {char(manufacturer)};
%                             data(i, 7) = {num2str(s.ModelNumber)};
%                             data(i, 8) = {num2str(s.SerialNumber)};
%                             data(i, 9) = {(s.Sensitivity) * 1000};
%                             data(i, 10) = {unit};
%                             data(i, 11) = {NaN};
%                             data(i, 12) = {' '};
%                         end
%                     else
%                         %                             fprintf('Sensor not found!\n');
%                         
%                         if (keepColumns)
%                             data(i, 1) = {false};
%                             data(i, 2) = {chanStr};
%                             %data(i, 3) = {'Input'};
%                             data(i, 3) = oldData(i, 3);
%                             data(i, 4) = {' '};
%                             data(i, 5) = {NaN};
%                             %data(i, 7) = {'Voltage'};
%                             data(i, 6) = {' '};
%                             data(i, 7) = {num2str(NaN)};
%                             data(i, 8) = {num2str(NaN)};
%                             data(i, 9) = {NaN};
%                             data(i, 10) = {' '};
%                             data(i, 11) = oldData(i, 11);
%                             data(i, 12) = oldData(i, 12);
%                         else
%                             data(i, :) = {false, chanStr, ' ', ' ', NaN, ' ', NaN, NaN, NaN, ' ', NaN, ' '};
%                         end
%                     end
%                     
%                     i = i + 1;
%                     set(handles.channelsTable, 'data', data);   %   Experimental
%                     guidata(hObject, handles);                  %   Experimental
%                     drawnow();                                  %   Experimental
%                 end
%             end
%             
%             %   Get output channels
%         end
%     else
%         fprintf('No devices found\n ');
%     end
%     % ----- TA 2015-02-27 (mod start)
%     %         handles.channelsTable.CellSelectionCallback='disp(''CellSelect'')';
%     %         handles.channelsTable.KeyPressFcn='disp(''Press'')';
%     %         handles.channelsTable.ButtonDownFcn='disp(''ButtonDown'')';
%     %         handles.channelsTable.KeyReleaseFcn='disp(''Release'')';
% %     SensorsInLabFile=which('SensorsInLab.xlsx');
% %     if ~isempty(SensorsInLabFile)
% %         [CLL,rawCells]=xls2cell(SensorsInLabFile,5);
% %         CLL{1}(1,1)={' '};% Replace column header with blank
% %         handles.channelsTable.ColumnFormat{8}=CLL{:};
% %     end
% %     handles.channelsTable.CellEditCallback={@celleditcallback,rawCells};
%     % ----- TA 2015-02-27 (end)
%     
% end






%   Clear DAQ
daq.reset;

set(handles.channelsTable, 'data', data);
set(handles.statusStr, 'String', 'Scanning hardware complete - READY');
guidata(hObject, handles);