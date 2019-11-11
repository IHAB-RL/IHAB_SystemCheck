
classdef IHAB_SystemCheck < handle

    properties
        
        vScreenSize;
        nGUIWidth = 600;
        nGUIHeight = 400;
        nLeftWidth;
        nUpperHeight = 280;
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
        
        prefix;
        stAudioInput;
        cAudioInput;
        stAudioOutput;
        cAudioOutput;
        nAudioInput;
        nAudioOutput;
        
        mColors;
        sTitleFig_Main = 'IHAB_SystemCheck';
        
        hFig_Main;
        hPanel_Graph;
        hPanel_Controls;
        hPanel_Lamps;
        hPanel_Hardware;
        
        hLabel_CheckDevice;
        hButton_CheckDevice;
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
        
        hLabel_Device;
        hLamp_Device;
        hLabel_Calibration;
        hLamp_Calibration;
        hLabel_Test;
        hLamp_Test;
        hLabel_Finished;
        hLamp_Finished;
        
        hLabel_Input;
        hDropDown_Input;
        hLabel_Output;
        hDropDown_Output;
        
        nSamplerate = 48000;
        nBlockSize = 1024;
        nDurationCalibration_s = 1;
        nCalibrationLevel;
        
        
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
            obj.nInterval_Vertical = (obj.nGUIHeight - obj.nPanelTitleHeight - ...
                5 * obj.nButtonHeight)/6;
            obj.nLampInterval_Vertical = (obj.nGUIHeight - obj.nPanelTitleHeight - ...
                obj.nUpperHeight - 4*obj.nLampHeight)/5;
            obj.nDropDownInterval = (obj.nGUIHeight - obj.nPanelTitleHeight - ...
                obj.nUpperHeight - 2*obj.nDropDownHeight - 2*obj.nTextHeight)/3;
            
            % Interval between progress lights;
            obj.nSpread_Lights_Horizontal = (obj.nLeftWidth - 3 * obj.nButtonHeight) / 4;
            
            obj.mColors = getColors();
            
            obj.checkPrerequisites();
            obj.buildGUI();
%             obj.checkDevice();
            obj.checkAudioHardware();
            
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
      
            
            % Panel: Controls
            
            
            obj.hPanel_Controls = uipanel(obj.hFig_Main);
            obj.hPanel_Controls.Position = [ ...
                obj.nLeftWidth, ...
                1, ...
                obj.nGUIWidth - obj.nLeftWidth + 1, ...
                obj.nGUIHeight];
            obj.hPanel_Controls.Title = 'Controls';
            
            % Label: CheckDevice
            obj.hLabel_CheckDevice = uilabel(obj.hPanel_Controls);
            obj.hLabel_CheckDevice.Position = [ ...
                obj.nInterval_Horizontal, ...
                5.7 * obj.nInterval_Vertical + 4 * obj.nButtonHeight, ...
                obj.nButtonWidth, ...
                obj.nButtonHeight];
            obj.hLabel_CheckDevice.HorizontalAlignment = 'Center';
            obj.hLabel_CheckDevice.Text = 'Check Device';
            
            % Button: CheckDevice
            obj.hButton_CheckDevice = uibutton(obj.hPanel_Controls);
            obj.hButton_CheckDevice.Position = [ ...
                obj.nInterval_Horizontal, ...
                5 * obj.nInterval_Vertical + 4 * obj.nButtonHeight, ...
                obj.nButtonWidth, ...
                obj.nButtonHeight];
            obj.hButton_CheckDevice.Text = 'Check';
            obj.hButton_CheckDevice.ButtonPushedFcn = @obj.checkDevice;
            
            % Label: Start
            obj.hLabel_Start = uilabel(obj.hPanel_Controls);
            obj.hLabel_Start.Position = [ ...
                obj.nInterval_Horizontal-7, ...
                4.7 * obj.nInterval_Vertical + 3 * obj.nButtonHeight, ...
                2 * obj.nButtonWidth, ...
                obj.nButtonHeight];
            obj.hLabel_Start.Text = 'Start Experiment';
            
            % Button: Start
            obj.hButton_Start = uibutton(obj.hPanel_Controls);
            obj.hButton_Start.Position = [ ...
                obj.nInterval_Horizontal, ...
                4 * obj.nInterval_Vertical + 3 * obj.nButtonHeight, ...
                obj.nButtonWidth, ...
                obj.nButtonHeight];
            obj.hButton_Start.Text = 'Start';
            obj.hButton_Start.ButtonPushedFcn = @obj.callback_StartExperiment;
          
            % Label: Constant
            obj.hLabel_Constant = uilabel(obj.hPanel_Controls);
            obj.hLabel_Constant.Position = [ ...
                obj.nInterval_Horizontal + 7, ...
                3.7 * obj.nInterval_Vertical + 2 * obj.nButtonHeight, ...
                2 * obj.nButtonWidth, ...
                obj.nButtonHeight];
            obj.hLabel_Constant.Text = 'Calibration';
            
            % Edit: Constant
            obj.hEdit_Constant = uieditfield(obj.hPanel_Controls);
            obj.hEdit_Constant.Position = [ ...
                obj.nInterval_Horizontal, ...
                3 * obj.nInterval_Vertical + 2 * obj.nButtonHeight, ...
                obj.nButtonWidth, ...
                obj.nButtonHeight];
            obj.hEdit_Constant.Editable = 'off';
            obj.hEdit_Constant.HorizontalAlignment = 'Center';
            obj.hEdit_Constant.Value = '-';
            
            % Label: SaveToPhone
            obj.hLabel_SaveToPhone = uilabel(obj.hPanel_Controls);
            obj.hLabel_SaveToPhone.Position = [ ...
                obj.nInterval_Horizontal - 1, ...
                2.7 * obj.nInterval_Vertical + 1 * obj.nButtonHeight, ...
                2 * obj.nButtonWidth, ...
                obj.nButtonHeight];
            obj.hLabel_SaveToPhone.Text = 'Save to Phone';
            
            % Button: SaveToPhone
            obj.hButton_SaveToPhone = uibutton(obj.hPanel_Controls);
            obj.hButton_SaveToPhone.Position = [ ...
                obj.nInterval_Horizontal, ...
                2 * obj.nInterval_Vertical + 1 * obj.nButtonHeight, ...
                obj.nButtonWidth, ...
                obj.nButtonHeight];
            obj.hButton_SaveToPhone.Text = 'Save';
            
           % Label: SaveInfo
            obj.hLabel_SaveInfo = uilabel(obj.hPanel_Controls);
            obj.hLabel_SaveInfo.Position = [ ...
                obj.nInterval_Horizontal + 3, ...
                1.7 * obj.nInterval_Vertical, ...
                2 * obj.nButtonWidth, ...
                obj.nButtonHeight];
            obj.hLabel_SaveInfo.Text = 'Save to Disk';
            
            % Button: SaveInfo
            obj.hButton_SaveInfo = uibutton(obj.hPanel_Controls);
            obj.hButton_SaveInfo.Position = [ ...
                obj.nInterval_Horizontal, ...
                obj.nInterval_Vertical, ...
                obj.nButtonWidth, ...
                obj.nButtonHeight];
            obj.hButton_SaveInfo.Text = 'Save';
            
            
            
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
            obj.hLabel_Device.Text = 'Device';
            
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
          
            % Label: Test
            obj.hLabel_Test = uilabel(obj.hPanel_Lamps);
            obj.hLabel_Test.Position  = [ ...
                obj.nInterval_Horizontal + obj.nLampHeight + 5, ...
                2 * obj.nLampInterval_Vertical + obj.nLampHeight, ...
                80, ...
                obj.nLampHeight];
            obj.hLabel_Test.Text = 'Test';
           
            % Lamp: Test
            obj.hLamp_Test = uilamp(obj.hPanel_Lamps);
            obj.hLamp_Test.Position = [ ...
                obj.nInterval_Horizontal, ...
                2 * obj.nLampInterval_Vertical + obj.nLampHeight, ...
                obj.nLampHeight, ...
                obj.nLampHeight];
            obj.hLamp_Test.Color = obj.mColors(2, :);
            
            % Label: Finished
            obj.hLabel_Finished = uilabel(obj.hPanel_Lamps);
            obj.hLabel_Finished.Position = [ ...
                obj.nInterval_Horizontal + obj.nLampHeight + 5, ...
                obj.nLampInterval_Vertical - 1, ...
                80, ...
                obj.nLampHeight];
            obj.hLabel_Finished.Text = 'Finished';
           
            % Lamp: Finished
            obj.hLamp_Finished = uilamp(obj.hPanel_Lamps);
            obj.hLamp_Finished.Position = [ ...
                obj.nInterval_Horizontal, ...
                obj.nLampInterval_Vertical, ...
                obj.nLampHeight, ...
                obj.nLampHeight];
            obj.hLamp_Finished.Color = obj.mColors(2, :);
           
            
            % Panel: Hardware
        
            
            obj.hPanel_Hardware = uipanel(obj.hFig_Main);
            obj.hPanel_Hardware.Position = [ ...
                obj.nLeftWidth/3, ...
                1, ...
                obj.nLeftWidth/3*2 + 1, ...
                obj.nGUIHeight - obj.nUpperHeight];
            obj.hPanel_Hardware.Title = 'Hardware';
            
%             % Label: Output
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
            
        end
        
        function [bCheck] = checkPrerequisites(obj)

            bCheck = true;

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

        function [bDevice] = checkDevice(obj, ~, ~)
            
            % NEED TO ADJUST THIS
            
            % make sure only one device is connected
            sTestDevices = [obj.prefix,'adb devices'];
            [~, sList] = system(sTestDevices);
            if (length(splitlines(sList)) > 4)
                errordlg('Too many devices connected.', 'Error');
                bDevice = 0;
                obj.hLamp_Device.Color = obj.mColors(2, :);
            elseif (length(splitlines(sList)) < 4)
                errordlg('No device connected.', 'Error');
                bDevice = 0;
                obj.hLamp_Device.Color = obj.mColors(2, :);
            else
                bDevice = 1;
                obj.hLamp_Device.Color = obj.mColors(5, :);
            end
            
            bDevice = 1;
            
        end
            
        function [] = checkAudioHardware(obj)
            
            % Get an overview o all connected audio hardware and fill in
            % the dropdown menus
            
            stDevices = msound('deviceInfo');
            obj.stAudioInput = [];
            obj.stAudioOutput = [];
            
            for iDevice = 1 : length(stDevices)
                if (stDevices(iDevice).inputs > 0 && stDevices(iDevice).outputs == 0)
                    if (isempty(obj.stAudioInput))
                        obj.stAudioInput = stDevices(iDevice);
                        obj.cAudioInput = {stDevices(iDevice).name};
                    else
                        obj.stAudioInput(end+1) = stDevices(iDevice);
                        obj.cAudioInput{end+1} = stDevices(iDevice).name;
                    end
                elseif (stDevices(iDevice).inputs == 0 && stDevices(iDevice).outputs > 0)
                    if (isempty(obj.stAudioOutput))
                        obj.stAudioOutput = stDevices(iDevice);
                        obj.cAudioOutput = {stDevices(iDevice).name};
                    else
                        obj.stAudioOutput(end+1) = stDevices(iDevice);
                        obj.cAudioOutput{end+1} = stDevices(iDevice).name;
                    end
                end
            end
            obj.hDropDown_Input.Items = obj.cAudioInput;
            obj.hDropDown_Output.Items = obj.cAudioOutput;
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
        
        function [] = callback_StartExperiment(obj, ~, ~)
            
            if (obj.checkDevice())
                obj.recordCalibration();
            end
            
        end
        
        function [] = recordCalibration(obj)
            
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
                
            end
            
            % HighPass
            [b, a] = butter(2, 100*2*pi/obj.nSamplerate, 'high');
            vCalibration = filter(b, a, vCalibration);
            
            nRMS = rms(vCalibration);
            obj.nCalibrationLevel = 20*log10(nRMS);
            
            % Update Calibration Level
            obj.hEdit_Constant.Value = num2str(obj.nCalibrationLevel);
            
            % Display Graph
            obj.hAxes.Visible = 'On';
            obj.hAxes.NextPlot = 'replace';
            hPlot = plot(obj.hAxes, vCalibration);
            obj.hAxes.XLim = [0, nSamples];
            obj.hAxes.Box = 'On';
            obj.hAxes.Layer = 'Top';
            
            msound('close');
        end
        
        end

    
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
end