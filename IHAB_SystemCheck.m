
classdef IHAB_SystemCheck < handle
    
    properties
        
        vScreenSize;
        nGUIWidth = 600;
        nGUIHeight = 400;
        nLeftWidth;
        nUpperHeight;
        nInterval_Vertical;
        nInterval_Horizontal = 30;
        nButtonHeight = 30;
        nButtonWidth = 76;
        nBottomSpace;
        nSpread_Lights_Horizontal;
        nSpread_Lights_Vertical = 20;
        nLampHeight = 15;
        nLampInterval_Vertical;
        nPanelTitleHeight = 18;
        nDropDownInterval;
        nDropDownWidth = 200;
        nDropDownHeight = 20;
        nTextHeight = 20;
        
        nPanelHeight_SaveResult;
        nPanelHeight_Measurement;
        nPanelHeight_MobileDevice;
        
        prefix;
        stAudioInput;
        cAudioInput;
        stAudioOutput;
        cAudioOutput;
        nAudioInput;
        nAudioOutput;
        sAudioError = '';
        
        mColors;
        sTitleFig_Main = 'IHAB_SystemCheck';
        
        hFig_Main;
        hPanel_Graph;
        hPanel_MobileDevice;
        hPanel_Measurement;
        hPanel_SaveResult;
        hPanel_Lamps;
        hPanel_Hardware;
        
        hLabel_CheckDevice;
        hButton_CheckDevice;
        hLabel_CloseApp
        hButton_CloseApp
        hLabel_Calibrate;
        hButton_Calibration;
        hLabel_Start;
        hButton_Start;
        hLabel_Constant;
        hEdit_Constant;
        hLabel_SaveToPhone;
        hButton_SaveToPhone;
        hLabel_SaveInfo;
        hButton_SaveInfo;
        
        hAxes;
        hLabel_Message;
        hHotspot;
        
        hLabel_Device;
        hLamp_Device;
        hLabel_Calibration;
        hLamp_Calibration;
        hLabel_Measurement;
        hLamp_Measurement;
        hLabel_Saved;
        hLamp_Saved;
        
        hLabel_Input;
        hDropDown_Input;
        hLabel_Output;
        hDropDown_Output;
        
        nSamplerate = 48000;
        nBlockSize = 1024*2;
        nDurationCalibration_s = 1;
        nCalibConstant_Mic_FS_SPL;
        nSystemCalibConstant;
        nLevel_Calib_dBSPL;
        nLevel_Calib_dBFS;
        nCalibConstant_System;
        nDurationMeasurement_s = 2;
        vTransferFunction;
        vOriginal_rec;
        vRefMic_rec;
        vRefMic;
        
        sFileName_Calib = 'calib.txt';
        
        bMobileDevice = false;
        bAudioDevice = false;
        bCalib = false;
        bMeasurement = false;
        bEnableButtons = false;
        
        
    end
    
    
    methods
        
        function obj = IHAB_SystemCheck()
            
            addpath('functions');
            addpath('msound');
            
            msound('close');
            
            if ismac
                obj.prefix = '/usr/local/bin/';
            else
                obj.prefix = '';
            end
            
            set(0,'Units','Pixels') ;
            obj.vScreenSize = get(0, 'ScreenSize');
            
            obj.nLeftWidth = obj.nGUIWidth - obj.nButtonWidth - ...
                2 * obj.nInterval_Horizontal;
            
            obj.nInterval_Vertical = ((obj.nGUIHeight - ...
                3*obj.nPanelTitleHeight - 7*obj.nButtonHeight)/10);
            
            obj.nPanelHeight_MobileDevice = obj.nPanelTitleHeight + 2*obj.nButtonHeight + 3*obj.nInterval_Vertical;
            obj.nPanelHeight_Measurement = obj.nPanelTitleHeight + 3*obj.nButtonHeight + 4*obj.nInterval_Vertical + 1;
            obj.nPanelHeight_SaveResult = obj.nPanelTitleHeight + 2*obj.nButtonHeight + 3*obj.nInterval_Vertical;
            
            obj.nUpperHeight = obj.nGUIHeight - obj.nPanelHeight_SaveResult;
            
            obj.nLampInterval_Vertical = (obj.nGUIHeight - obj.nPanelTitleHeight - ...
                obj.nUpperHeight - 4*obj.nLampHeight)/5;
            obj.nDropDownInterval = (obj.nGUIHeight - obj.nPanelTitleHeight - ...
                obj.nUpperHeight - 2*obj.nDropDownHeight - 2*obj.nTextHeight)/3;
            
            % Interval between progress lights;
            obj.nSpread_Lights_Horizontal = (obj.nLeftWidth - 3 * obj.nButtonHeight) / 4;
            
            obj.mColors = getColors();
            
            obj.checkPrerequisites();
            obj.buildGUI();
            obj.checkDevice();
            obj.checkAudioHardware();
            
            obj.bEnableButtons = true;
            
        end
        
        function [] = buildGUI(obj)
            
            % Main Figure
            
            obj.hFig_Main = uifigure();
            obj.hFig_Main.Position = [ ...
                (obj.vScreenSize(3)-obj.nGUIWidth)/2, ...
                (obj.vScreenSize(4)-obj.nGUIHeight)/2, ...
                obj.nGUIWidth, ...
                obj.nGUIHeight];
            obj.hFig_Main.Name = obj.sTitleFig_Main;
            obj.hFig_Main.Resize = 'Off';
            obj.hFig_Main.ToolBar = 'None';
            obj.hFig_Main.MenuBar = 'None';
            obj.hFig_Main.Units = 'Pixels';
            
            
            % Panel: Graph
            
            
            obj.hPanel_Graph = uipanel(obj.hFig_Main);
            obj.hPanel_Graph.Position = [ ...
                1, ...
                obj.nGUIHeight - obj.nUpperHeight, ...
                obj.nLeftWidth + 1, ...
                obj.nUpperHeight + 1];
            obj.hPanel_Graph.Title = 'Graph';
            
            obj.hAxes = uiaxes(obj.hPanel_Graph);
            obj.hAxes.Units = 'Pixels';
            obj.hAxes.Position = [0,0,obj.hPanel_Graph.Position(3), obj.hPanel_Graph.Position(4)-20];
            obj.hAxes.Visible = 'Off';
            disableDefaultInteractivity(obj.hAxes);
            obj.hAxes.Box = 'On';
            obj.hAxes.Layer = 'Top';
            
            obj.hHotspot = patch(obj.hAxes, [0,0,1,1],[0,1,1,0], [1,1,1], 'FaceAlpha', 0.91, 'EdgeColor', 'none');
            obj.hHotspot.ButtonDownFcn = @obj.doNothing;
            
            
            % Panel: Mobile Device
            
            
            obj.hPanel_MobileDevice = uipanel(obj.hFig_Main);
            obj.hPanel_MobileDevice.Position = [ ...
                obj.nLeftWidth, ...
                obj.nPanelHeight_SaveResult + obj.nPanelHeight_Measurement, ...
                obj.nGUIWidth - obj.nLeftWidth + 1, ...
                obj.nPanelHeight_MobileDevice];
            obj.hPanel_MobileDevice.Title = 'Mobile Device';
           
            % Button: CheckDevice
            obj.hButton_CheckDevice = uibutton(obj.hPanel_MobileDevice);
            obj.hButton_CheckDevice.Position = [ ...
                obj.nInterval_Horizontal, ...
                2 * obj.nInterval_Vertical + 1 * obj.nButtonHeight, ...
                obj.nButtonWidth, ...
                obj.nButtonHeight];
            obj.hButton_CheckDevice.Text = 'Reset';
            obj.hButton_CheckDevice.ButtonPushedFcn = @obj.callbackCheckDevice;
            
            % Button: Close App
            obj.hButton_CloseApp = uibutton(obj.hPanel_MobileDevice);
            obj.hButton_CloseApp.Position = [ ...
                obj.nInterval_Horizontal, ...
                1 * obj.nInterval_Vertical + 0 * obj.nButtonHeight, ...
                obj.nButtonWidth, ...
                obj.nButtonHeight];
            obj.hButton_CloseApp.Text = 'Close';
            obj.hButton_CloseApp.ButtonPushedFcn = @obj.callbackCloseApp;
            
            
            % Panel: Measurement
            
            
            obj.hPanel_Measurement = uipanel(obj.hFig_Main);
            obj.hPanel_Measurement.Position = [ ...
                obj.nLeftWidth, ...
                obj.nPanelHeight_SaveResult, ...
                obj.nGUIWidth - obj.nLeftWidth + 1, ...
                obj.nPanelHeight_Measurement + 1];
            obj.hPanel_Measurement.Title = 'Measurement';
 
            % Button: Calibrate
            obj.hButton_Calibration = uibutton(obj.hPanel_Measurement);
            obj.hButton_Calibration.Position = [ ...
                obj.nInterval_Horizontal, ...
                3 * obj.nInterval_Vertical + 2 * obj.nButtonHeight, ...
                obj.nButtonWidth, ...
                obj.nButtonHeight];
            obj.hButton_Calibration.Text = 'Calibration';
            obj.hButton_Calibration.ButtonPushedFcn = @obj.callbackPerformCalibration;
            
            % Button: Start
            obj.hButton_Start = uibutton(obj.hPanel_Measurement);
            obj.hButton_Start.Position = [ ...
                obj.nInterval_Horizontal, ...
                2 * obj.nInterval_Vertical + 1 * obj.nButtonHeight, ...
                obj.nButtonWidth, ...
                obj.nButtonHeight];
            obj.hButton_Start.Text = 'Start';
            obj.hButton_Start.ButtonPushedFcn = @obj.callbackPerformTFMeasurement;
            
            % Edit: Constant
            obj.hEdit_Constant = uieditfield(obj.hPanel_Measurement);
            obj.hEdit_Constant.Position = [ ...
                obj.nInterval_Horizontal, ...
                1 * obj.nInterval_Vertical + 0 * obj.nButtonHeight, ...
                obj.nButtonWidth, ...
                obj.nButtonHeight];
            obj.hEdit_Constant.Editable = 'off';
            obj.hEdit_Constant.HorizontalAlignment = 'Center';
            obj.hEdit_Constant.Value = '-';
            
            
            % Panel: Save Result
            
            
            obj.hPanel_SaveResult = uipanel(obj.hFig_Main);
            obj.hPanel_SaveResult.Position = [ ...
                obj.nLeftWidth, ...
                1, ...
                obj.nGUIWidth - obj.nLeftWidth + 1, ...
                obj.nPanelHeight_SaveResult];
            obj.hPanel_SaveResult.Title = 'Save Result';
            
            % Button: SaveToPhone
            obj.hButton_SaveToPhone = uibutton(obj.hPanel_SaveResult);
            obj.hButton_SaveToPhone.Position = [ ...
                obj.nInterval_Horizontal, ...
                2 * obj.nInterval_Vertical + 1 * obj.nButtonHeight, ...
                obj.nButtonWidth, ...
                obj.nButtonHeight];
            obj.hButton_SaveToPhone.Text = 'Phone';
            obj.hButton_SaveToPhone.ButtonPushedFcn = @obj.callbackSaveToPhone;
                         
            % Button: SaveInfo
            obj.hButton_SaveInfo = uibutton(obj.hPanel_SaveResult);
            obj.hButton_SaveInfo.Position = [ ...
                obj.nInterval_Horizontal, ...
                obj.nInterval_Vertical, ...
                obj.nButtonWidth, ...
                obj.nButtonHeight];
            obj.hButton_SaveInfo.Text = 'Disk';
            obj.hButton_SaveInfo.ButtonPushedFcn = @obj.callbackSaveToDisk;
            
            
            % Panel: Lamps
            
            
            obj.hPanel_Lamps = uipanel(obj.hFig_Main);
            obj.hPanel_Lamps.Position = [ ...
                1, ...
                1, ...
                obj.nLeftWidth/3, ...
                obj.nGUIHeight - obj.nUpperHeight];
            obj.hPanel_Lamps.Title = 'Progress';
            
            % Label: Device
            obj.hLabel_Device = uilabel(obj.hPanel_Lamps);
            obj.hLabel_Device.Position  = [ ...
                obj.nInterval_Horizontal + obj.nLampHeight + 5, ...
                4 * obj.nLampInterval_Vertical + 3 * obj.nLampHeight, ...
                80, ...
                obj.nLampHeight];
            obj.hLabel_Device.Text = 'Mobile Device';
            
            % Lamp: Device
            obj.hLamp_Device = uilamp(obj.hPanel_Lamps);
            obj.hLamp_Device.Position = [ ...
                obj.nInterval_Horizontal, ...
                4 * obj.nLampInterval_Vertical + 3 * obj.nLampHeight, ...
                obj.nLampHeight, ...
                obj.nLampHeight];
            obj.hLamp_Device.Color = obj.mColors(2, :);
            
            % Label: Calibration
            obj.hLabel_Calibration = uilabel(obj.hPanel_Lamps);
            obj.hLabel_Calibration.Position  = [ ...
                obj.nInterval_Horizontal + obj.nLampHeight + 5, ...
                3 * obj.nLampInterval_Vertical + 2 * obj.nLampHeight, ...
                80, ...
                obj.nLampHeight];
            obj.hLabel_Calibration.Text = 'Calibration';
            
            % Lamp: Calibration
            obj.hLamp_Calibration = uilamp(obj.hPanel_Lamps);
            obj.hLamp_Calibration.Position = [ ...
                obj.nInterval_Horizontal, ...
                3 * obj.nLampInterval_Vertical + 2 * obj.nLampHeight, ...
                obj.nLampHeight, ...
                obj.nLampHeight];
            obj.hLamp_Calibration.Color = obj.mColors(2, :);
            
            % Label: Measurement
            obj.hLabel_Measurement = uilabel(obj.hPanel_Lamps);
            obj.hLabel_Measurement.Position  = [ ...
                obj.nInterval_Horizontal + obj.nLampHeight + 5, ...
                2 * obj.nLampInterval_Vertical + obj.nLampHeight, ...
                80, ...
                obj.nLampHeight];
            obj.hLabel_Measurement.Text = 'Measurement';
            
            % Lamp: Measurement
            obj.hLamp_Measurement = uilamp(obj.hPanel_Lamps);
            obj.hLamp_Measurement.Position = [ ...
                obj.nInterval_Horizontal, ...
                2 * obj.nLampInterval_Vertical + obj.nLampHeight, ...
                obj.nLampHeight, ...
                obj.nLampHeight];
            obj.hLamp_Measurement.Color = obj.mColors(2, :);
            
            % Label: Saved
            obj.hLabel_Saved = uilabel(obj.hPanel_Lamps);
            obj.hLabel_Saved.Position = [ ...
                obj.nInterval_Horizontal + obj.nLampHeight + 5, ...
                obj.nLampInterval_Vertical - 1, ...
                80, ...
                obj.nLampHeight];
            obj.hLabel_Saved.Text = 'Saved';
            
            % Lamp: Saved
            obj.hLamp_Saved = uilamp(obj.hPanel_Lamps);
            obj.hLamp_Saved.Position = [ ...
                obj.nInterval_Horizontal, ...
                obj.nLampInterval_Vertical, ...
                obj.nLampHeight, ...
                obj.nLampHeight];
            obj.hLamp_Saved.Color = obj.mColors(2, :);
            
            
            % Panel: Hardware
            
            
            obj.hPanel_Hardware = uipanel(obj.hFig_Main);
            obj.hPanel_Hardware.Position = [ ...
                obj.nLeftWidth/3, ...
                1, ...
                obj.nLeftWidth/3*2 + 1, ...
                obj.nGUIHeight - obj.nUpperHeight];
            obj.hPanel_Hardware.Title = 'Hardware';
            
            % Label: Output
            obj.hLabel_Output = uilabel(obj.hPanel_Hardware);
            obj.hLabel_Output.Position = [ ...
                obj.nInterval_Horizontal, ...
                2 * obj.nDropDownInterval + 2 * obj.nDropDownHeight + obj.nTextHeight, ...
                obj.nDropDownWidth, ...
                obj.nDropDownHeight];
            obj.hLabel_Output.Text = 'Audio Output';
            
            % DropDown: Output
            obj.hDropDown_Output = uidropdown(obj.hPanel_Hardware);
            obj.hDropDown_Output.Position = [ ...
                obj.nInterval_Horizontal, ...
                2 * obj.nDropDownInterval + obj.nDropDownHeight + obj.nTextHeight, ...
                obj.nDropDownWidth, ...
                obj.nDropDownHeight];
            obj.hDropDown_Output.ValueChangedFcn = @obj.callback_DropDownAudioOutput;
            obj.hDropDown_Output.Items = {''};
            obj.hDropDown_Output.Enable = 'Off';
            
            % Label: Input
            obj.hLabel_Input = uilabel(obj.hPanel_Hardware);
            obj.hLabel_Input.Position = [ ...
                obj.nInterval_Horizontal, ...
                obj.nDropDownInterval + obj.nDropDownHeight, ...
                obj.nDropDownWidth, ...
                obj.nDropDownHeight];
            obj.hLabel_Input.Text = 'Audio Input';
            
            % DropDown: Input
            obj.hDropDown_Input = uidropdown(obj.hPanel_Hardware);
            obj.hDropDown_Input.Position = [ ...
                obj.nInterval_Horizontal, ...
                obj.nDropDownInterval, ...
                obj.nDropDownWidth, ...
                obj.nDropDownHeight];
            obj.hDropDown_Input.ValueChangedFcn = @obj.callback_DropDownAudioInput;
            obj.hDropDown_Input.Items = {''};
            obj.hDropDown_Input.Enable = 'Off';
            
            drawnow;
            
        end
        
        function [] = checkPrerequisites(obj)
            
            warning('backtrace', 'off');
            
            [~, tmp] = system('adb devices');
            if ~contains(tmp, 'List')
                warning('ADB is not properly installed on your system.');
            end
            
            if verLessThan('matlab', '9.5')
                warning('Matlab version upgrade is recommended.');
            end
            
            warning('backtrace', 'on');
            
        end
        
        function [] = checkAudioHardware(obj)
            
            % Get an overview o all connected audio hardware and fill in
            % the dropdown menus
            
            stDevices = msound('deviceInfo');
            obj.stAudioInput = [];
            obj.stAudioOutput = [];
            
            for stDev = stDevices'
                
                if (stDev.inputs > 0 && stDev.outputs == 0)
                    if (isempty(obj.stAudioInput))
                        obj.stAudioInput = stDev;
                        obj.cAudioInput = {stDev.name};
                    else
                        obj.stAudioInput(end+1) = stDev;
                        obj.cAudioInput{end+1} = stDev.name;
                    end
                elseif (stDev.inputs == 0 && stDev.outputs > 0)
                    if (isempty(obj.stAudioOutput))
                        obj.stAudioOutput = stDev;
                        obj.cAudioOutput = {stDev.name};
                    else
                        obj.stAudioOutput(end+1) = stDev;
                        obj.cAudioOutput{end+1} = stDev.name;
                    end
                end
            end
            
            obj.bAudioDevice = false;
            if (isempty(obj.cAudioInput) && isempty(obj.cAudioOutput))
                obj.sAudioError = 'No audio device found.';
                errordlg(obj.sAudioError);
            elseif (isempty(obj.cAudioInput) && ~isempty(obj.cAudioOutput))
                obj.sAudioError = 'No audio input device found.';
                errordlg(obj.sAudioError);
                obj.hDropDown_Output.Items = obj.cAudioOutput;
                obj.hDropDown_Output.Enable = 'On';
            elseif (isempty(obj.cAudioOutput) && ~isempty(obj.cAudioInput))
                obj.sAudioError = 'No audio input device found.';
                errordlg(obj.sAudioError);
                obj.hDropDown_Input.Items = obj.cAudioInput;
                obj.hDropDown_Input.Enable = 'On';
            else
                obj.hDropDown_Input.Items = obj.cAudioInput;
                obj.hDropDown_Output.Items = obj.cAudioOutput;
                obj.hDropDown_Input.Enable = 'On';
                obj.hDropDown_Output.Enable = 'On';
                obj.bAudioDevice = true;
            end
            
            obj.showImage('');
            
        end
        
        function [] = callback_DropDownAudioOutput(obj, ~ , val)
            
            for iDevice = 1 : length(obj.stAudioOutput)
                if strcmp(obj.stAudioOutput(iDevice).name, val.Value)
                    obj.nAudioOutput = obj.stAudioOutput(iDevice).id;
                    break;
                end
            end
        end
        
        function [] = callback_DropDownAudioInput(obj, ~ , val)
            
            for iDevice = 1 : length(obj.stAudioInput)
                if strcmp(obj.stAudioInput(iDevice).name, val.Value)
                    obj.nAudioInput = obj.stAudioInput(iDevice).id;
                    break;
                end
            end
        end
        
        function [] = showImage(obj, sImage)
            
            switch sImage
                case 'connectDevice'
                    obj.hLamp_Measurement.Color = obj.mColors(3, :);
                    mImage = imread(['images', filesep, 'img_connectDevice.jpg']);
                case 'setUpCalibrator'
                    obj.hLamp_Calibration.Color = obj.mColors(3, :);
                    % Reset color of saved lamp
                    obj.hLamp_Saved.Color = obj.mColors(2, :);
                    % Reset color of measurement lamp
                    obj.hLamp_Measurement.Color = obj.mColors(2, :);
                    mImage = imread(['images', filesep, 'img_setUpCalibrator.jpg']);
                case 'setUpMeasurement'
                    obj.hEdit_Constant.Value = '';
                    obj.hLamp_Measurement.Color = obj.mColors(3, :);
                    % Reset color of saved lamp
                    obj.hLamp_Saved.Color = obj.mColors(2, :);
                    mImage = imread(['images', filesep, 'img_setUpMeasurement.jpg']);
                case ''
                    mImage = [];
            end
            
            obj.hAxes.Visible = 'On';
            obj.hAxes.NextPlot = 'replace';
            
            image(obj.hAxes, mImage);
            obj.hAxes.XLim = [1, 464];
            obj.hAxes.YLim = [1, 280];
            obj.hAxes.XTickLabel = {};
            obj.hAxes.XTick = [];
            obj.hAxes.YTickLabel = {};
            obj.hAxes.YTick = [];
            
            obj.hAxes.Box = 'On';
            obj.hAxes.Layer = 'Top';
            
            obj.hHotspot = patch(obj.hAxes, [0,0,464,464],[0,280,280,0], [1,1,1], 'FaceAlpha', 0.91, 'EdgeColor', 'none');
            
            switch sImage
                case 'connectDevice'
                    obj.hHotspot.ButtonDownFcn = @obj.checkDevice;
                case 'setUpCalibrator'
                    obj.hHotspot.ButtonDownFcn = @obj.performCalibration;
                case 'setUpMeasurement'
                    obj.hHotspot.ButtonDownFcn = @obj.phoneStartRecording;
                case ''
                    obj.hHotspot.ButtonDownFcn = @obj.doNothing;
            end
            
            drawnow;
            
        end
        
        function [] = callbackCheckDevice(obj, ~, ~)
           
            if obj.bEnableButtons
               obj.checkDevice(); 
            end
            
        end
       
        function [bMobileDevice] = checkDevice(obj, ~, ~)
            
            obj.bEnableButtons = false;
            obj.bMobileDevice = false;
            bMobileDevice = false;
            
            % make sure only one device is connected
            sTestDevices = [obj.prefix,'adb devices'];
            [~, sList] = system(sTestDevices);
            if (length(splitlines(sList)) > 4)
                errordlg('Too many devices connected.', 'Error');
                obj.bMobileDevice = 0;
                obj.hLamp_Device.Color = obj.mColors(2, :);
            elseif (length(splitlines(sList)) < 4)
                errordlg('No device connected.', 'Error');
                obj.bMobileDevice = 0;
                obj.hLamp_Device.Color = obj.mColors(2, :);
            elseif (contains(sList, 'List'))
                obj.bMobileDevice = true;
                obj.hLamp_Device.Color = obj.mColors(5, :);
                obj.bMobileDevice = true;
                bMobileDevice = true;
            end
            
            % Check if activity is running. if not: start, if it does:
            % restart
            [~, temp] = system('adb shell dumpsys activity com.example.IHABSystemCheck');
            if contains(temp, 'Bad activity command')
                system('adb shell am start -n com.example.IHABSystemCheck/.MainActivity');
            else
                [~, ~] = system('adb shell am broadcast -a com.example.IHABSystemCheck.intent.TEST --es sms_body "Reset"');

            end
            
            % Wait and check if application is running as expected
            sData = '';
            while ~contains(sData, 'Waiting')
                [~, sData] = system('adb shell dumpsys activity com.example.IHABSystemCheck');
                pause(0.1);
            end
            
            obj.bEnableButtons = true;
            
        end
        
        function [] = callbackPerformCalibration(obj, ~, ~)
            
            if ~obj.bEnableButtons
               return; 
            end
           
            if ~obj.bCalib
               obj.showImage('setUpCalibrator');
            else
               sResult = questdlg('Reference microphone already calibrated. Redo?', ...
                   'Calibration', 'Yes','No', 'No'); 
               if (strcmp(sResult, 'Yes'))
                   obj.showImage('setUpCalibrator');
               end
            end
        end
        
        function [] = performCalibration(obj, ~, ~)
            
            obj.bEnableButtons = false;
            
            obj.bCalib = false;
            obj.bMeasurement = false;
          
            obj.showImage('');
            obj.hAxes.XLim = [0, obj.nBlockSize];
            obj.hAxes.YLim = [-1, 1];
            
            msound('close');
            
            numChannels = 1;
            
            % Open Input Device
            msound('openRead', ...
                obj.nAudioInput, ...
                obj.nSamplerate, ...
                obj.nBlockSize, ...
                numChannels);
            
            nSamples = obj.nDurationCalibration_s * obj.nSamplerate;
            nBlocks = ceil(nSamples/obj.nBlockSize);
            vCalibration = zeros(nSamples, numChannels);
            
            % Pre-recording to supress silence at start
            for iBlock = 1:10
                msound('getSamples');
            end
            
            % Recording the calibration signal
            for iBlock = 1 : nBlocks
                
                iIn = (iBlock-1)*obj.nBlockSize + 1;
                iOut = iIn + obj.nBlockSize - 1;
                
                vCalibration(iIn:iOut) = msound('getSamples');
                plot(obj.hAxes, vCalibration(iIn:iOut), 'Color', obj.mColors(1, :));
                drawnow;
                
            end
            
            % HighPass
            [b, a] = butter(2, 100*2*pi/obj.nSamplerate, 'high');
            vCalibration = filter(b, a, vCalibration);
            
            % Calibrator emits signal 1kHz @ 114dB SPL
            obj.nLevel_Calib_dBSPL = 114; 
            obj.nLevel_Calib_dBFS = 20*log10(rms(vCalibration));
            obj.nCalibConstant_Mic_FS_SPL = obj.nLevel_Calib_dBSPL - obj.nLevel_Calib_dBFS; 
   
            msound('close');
            
            obj.hLamp_Calibration.Color = obj.mColors(5, :);
            obj.showImage('');
            
            % Perform check whether calibration result was okay
            if true
                obj.bCalib = true;
            end
            
            obj.bEnableButtons = true;
            
        end
        
        function [] = callbackPerformTFMeasurement(obj, ~, ~)
            
            if ~obj.bEnableButtons
               return; 
            end
          
            if ~obj.bMeasurement
                obj.showImage('setUpMeasurement');
            else
               sResult = questdlg('Measurement already taken. Redo?', ...
                   'Measurement', 'Yes','No', 'No'); 
               if (strcmp(sResult, 'Yes'))
                   
                   sCommand = 'adb shell am broadcast -a com.example.IHABSystemCheck.intent.TEST --es sms_body "Reset"';
                    [~, ~] = system(sCommand);

                    sData = '';
                    while ~contains(sData, 'Waiting')
                        [~, sData] = system('adb shell dumpsys activity com.example.IHABSystemCheck')
                        pause(0.1);
                    end

                   obj.showImage('setUpMeasurement');
               end
            end
            
        end
        
        function [] = performTFMeasurement(obj, ~, ~)
            
            obj.bEnableButtons = false;
          
            obj.bMeasurement = false;
            
            obj.showImage('');
            
            msound('close');
            
            nNumChannels_In = 1;
            nNumChannels_Out = 1;
           
            msound('openRW', ...
                [obj.nAudioInput, obj.nAudioOutput], ...
                obj.nSamplerate, ...
                obj.nBlockSize, ...
                [nNumChannels_In, nNumChannels_Out]);
            
            nSamples = obj.nDurationMeasurement_s * obj.nSamplerate;
            nBlocks = floor(nSamples/obj.nBlockSize);
            
            vNoise = 2 * rand(nSamples, 1) - 1;
            obj.vRefMic = zeros(nSamples, 1);
            
            obj.vOriginal_rec = zeros(obj.nBlockSize, 1);
            obj.vRefMic_rec = zeros(obj.nBlockSize, 1);
            
            vWindow = hann(obj.nBlockSize);
            nOverlap = 0.5;
            nAlpha = 0.9;
            
            obj.hAxes.Visible = 'On';
            
            % Playback of Noise signal
            for iBlock = 1 : nBlocks
                
                iIn = (iBlock-1)*obj.nBlockSize + 1;
                iOut = iIn + obj.nBlockSize - 1;
                
                msound('putSamples', vNoise(iIn:iOut));
                
                obj.vRefMic(iIn:iOut) = msound('getSamples');
                
                obj.vOriginal_rec = nAlpha*obj.vOriginal_rec + (1-nAlpha)*vNoise(iIn:iOut);
                obj.vRefMic_rec = nAlpha*obj.vRefMic_rec + (1-nAlpha)*obj.vRefMic(iIn:iOut);
                
                vSpec_Original = filter(fspecial('average', [10, 1]), 1,20*log10(abs(fft(obj.vOriginal_rec))));
                vSpec_RefMic = filter(fspecial('average', [10, 1]), 1,20*log10(abs(fft(obj.vRefMic_rec))));
                
                if (iBlock == 1)
                    obj.hAxes.NextPlot = 'replace';
                    hPlot_Orig = semilogx(obj.hAxes, vSpec_Original(1:end/2+1), 'Color', obj.mColors(1, :));
                    obj.hAxes.NextPlot = 'add';
                    hPlot_Ref = semilogx(obj.hAxes, vSpec_RefMic(1:end/2+1), 'Color', obj.mColors(2, :));
                    obj.hAxes.XLim = [1, obj.nBlockSize/2+1];
                else
                    nPlot_Orig.YData = vSpec_Original(1:end/2+1);
                    hPlot_Ref.YData = vSpec_RefMic(1:end/2+1);
                end
                
                obj.hAxes.Box = 'On';
                obj.hAxes.Layer = 'Top';
                obj.hAxes.YLim = [-100, 50];
                obj.hAxes.XTick = [];
                obj.hAxes.YTick = [];
                
                
                drawnow;
                
            end
            
            msound('close');
            
            obj.phoneStopRecording();
            
        end
        
        function [] = finishTFMeasurement(obj) 
           
            vSystem = obj.phoneGetRecording();
            
            nLevel_RefMic_dBFS = 20*log10(rms(obj.vRefMic));
%             nLevel_RefMic_dBSPL = nLevel_RefMic_dBFS + obj.nCalibConstant_Mic_FS_SPL; 
            
            L_IHAB_dBFS = 20*log10(rms(vSystem));

            % Kalibrierkonstante SYS
            obj.nSystemCalibConstant = obj.nCalibConstant_Mic_FS_SPL - (L_IHAB_dBFS - nLevel_RefMic_dBFS);
            
            vPSD_System_Left = fft(vSystem(:, 1), obj.nBlockSize);
            vPSD_System_Right = fft(vSystem(:, 2), obj.nBlockSize);

            vPSD_System_Left = 20*log10(abs(vPSD_System_Left));
            vPSD_System_Right = 20*log10(abs(vPSD_System_Right));
           
            obj.hAxes.Visible = 'On';
            obj.hAxes.NextPlot = 'add';
            
            semilogx(obj.hAxes, filter(fspecial('average', [10, 1]), 1, vPSD_System_Left), 'Color', obj.mColors(3, :));
            semilogx(obj.hAxes, filter(fspecial('average', [10, 1]), 1, vPSD_System_Right), 'Color', obj.mColors(4, :));
            
            obj.hAxes.XLim = [0, obj.nBlockSize/2+1];
            obj.hAxes.YLim = [-100, 50];
            obj.hAxes.XTickLabel = {};
            obj.hAxes.XTick = [];
            obj.hAxes.YTickLabel = {};
            obj.hAxes.YTick = [];
            
            obj.hAxes.Box = 'On';
            obj.hAxes.Layer = 'Top';
            
            % Check whether calibration result is valid
            if diff(obj.nSystemCalibConstant) < 2
                
                obj.writeCalibrationToFile(mean(obj.nSystemCalibConstant));
                
                obj.hEdit_Constant.Value = num2str(mean(obj.nSystemCalibConstant));
                obj.hLamp_Measurement.Color = obj.mColors(5, :);
                obj.bMeasurement = true;
            end
            
            obj.bEnableButtons = true;
            
        end
        
        
        function [] = writeCalibrationToFile(obj, nLevel)
            hFid = fopen([pwd, filesep, 'calibration', filesep, obj.sFileName_Calib], 'w');
            fprintf(hFid, '%f', nLevel);
            fclose(hFid);
        end
        
        function [] = doNothing(obj)
            return;
        end
        
        function [] = phoneStartRecording(obj, ~, ~)
            
            sCommand = 'adb shell am broadcast -a com.example.IHABSystemCheck.intent.TEST --es sms_body "Start"';
            [~, ~] = system(sCommand);
            
            sData = '';
            while ~contains(sData, 'Measuring')
                [~, sData] = system('adb shell dumpsys activity com.example.IHABSystemCheck');
                pause(0.1);
            end
           
            obj.performTFMeasurement();
            
        end
        
        function [] = phoneStopRecording(obj)
            
            sCommand = 'adb shell am broadcast -a com.example.IHABSystemCheck.intent.TEST --es sms_body "Stop"';
            [~, ~] = system(sCommand);
            
            sData = '';
            while ~contains(sData, 'Finished')
                [~, sData] = system('adb shell dumpsys activity com.example.IHABSystemCheck');
                pause(0.1); 
            end
            
            sCommand = 'adb shell am broadcast -a com.example.IHABSystemCheck.intent.TEST --es sms_body "Finished"';
            [~, ~] = system(sCommand);
            
            obj.finishTFMeasurement();
            
        end
        
        function [vRecording] = phoneGetRecording(obj)
            vRecording = 2*rand(obj.nDurationMeasurement_s * obj.nSamplerate, 2) - 1;
        end
        
        function [] = callbackSaveToDisk(obj, ~, ~)
            
            if ~obj.bEnableButtons
               return; 
            end
            
            if obj.bMeasurement
               obj.saveToDisk(); 
            else
               errordlg('No measurement data available.') 
            end
        end
        
        function [] = saveToDisk(obj, ~, ~)
            sFolder = uigetdir('Please select directory to store calibration data.');
            
            if ~isempty(sFolder)
               copyfile([pwd, filesep, 'calibration', filesep, obj.sFileName_Calib], sFolder); 
            end
            
        end
        
        function [] = callbackSaveToPhone(obj, ~, ~)
            
            if ~obj.bEnableButtons
               return; 
            end
            
            if obj.bMeasurement
               obj.saveToPhone();
            else
               errordlg('No measurement data available.') 
            end
        end
        
        function [] = saveToPhone(obj, ~, ~)
            
            obj.bEnableButtons = false;
            
            vStatus = [];
            
            % Erase folder
            sCommand_erase_quest = [obj.prefix, 'adb shell rm -r /sdcard/ihab/calibration'];
            [status, ~] = system(sCommand_erase_quest);
            vStatus = [vStatus, status];
            
            % Make new folder
            sCommand_erase_quest = [obj.prefix, 'adb shell mkdir /sdcard/IHAB/calibration'];
            [status, ~] = system(sCommand_erase_quest);
            vStatus = [vStatus, status];
            
            % Copy calibration data to phone
            sCommand_log = [obj.prefix, 'adb push calibration/', obj.sFileName_Calib,' sdcard/ihab/calibration/'];
            [status, ~] = system(sCommand_log);
            vStatus = [vStatus, status];
            
            % Check-in new folder
            sCommand_erase_quest = [obj.prefix, 'adb -d shell "am broadcast -a android.intent.action.MEDIA_MOUNTED -d file:///sdcard/IHAB/calibration'];
            [status, ~] = system(sCommand_erase_quest);
            vStatus = [vStatus, status];
            
            %TODO: Check whether file is there
            if true
                % Announce all is good
                obj.hLamp_Saved.Color = obj.mColors(5, :);
            end
            
            obj.bEnableButtons = true;
            
        end
        
        function [] = callbackCloseApp(obj, ~, ~)
            
            if obj.bEnableButtons
               obj.closeApp(); 
            end
            
        end
        
        function [] = closeApp(obj)
           system('adb shell am force-stop com.example.IHABSystemCheck'); 
        end
          
    end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
end