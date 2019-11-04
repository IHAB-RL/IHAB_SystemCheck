
classdef IHAB_SystemCheck < handle

    properties
        
        vScreenSize;
        nGUIWidth = 600;
        nGUIHeight = 400;
        nLeftWidth;
        nUpperHeight = 280;
        nInterval_Vertical = 60;
        nInterval_Horizontal = 30;
        nButtonHeight = 30; 
        nButtonWidth = 76;
        nBottomSpace;
        nSpread_Lights_Horizontal;
        nSpread_Lights_Vertical = 20;
        
        mColors;
        sTitleFig_Main = 'IHAB_SystemCheck';
        
        hFig_Main;
        hPanel_Graph;
        hPanel_Controls;
        hPanel_Lamps;
        hLabel_Start;
        hButton_Start;
        hLabel_Constant;
        hEdit_Constant;
        hLabel_SaveToPhone;
        hButton_SaveToPhone;
        hLabel_SaveInfo;
        hButton_SaveInfo;
        hLabel_Calibration;
        hLamp_Calibration;
        hLabel_Test;
        hLamp_Test;
        hLabel_Finished;
        hLamp_Finished;

        
        
    end


    methods
        
        function obj = IHAB_SystemCheck()
            
            addpath('functions');
            
            set(0,'Units','Pixels') ;
            obj.vScreenSize = get(0, 'ScreenSize');
            
            obj.nLeftWidth = obj.nGUIWidth - obj.nButtonWidth - ...
                2 * obj.nInterval_Horizontal;
            obj.nBottomSpace = obj.nGUIHeight - 5 * obj.nInterval_Vertical - ...
                4 * obj.nButtonHeight;
            
            % Interval between progress lights;
            obj.nSpread_Lights_Horizontal = (obj.nLeftWidth - 3 * obj.nButtonHeight) / 4;
            
            obj.mColors = getColors();
            
            obj.buildGUI();
            
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
                obj.nGUIHeight - obj.nUpperHeight + 1, ...
                obj.nLeftWidth, ...
                obj.nUpperHeight];
            obj.hPanel_Graph.Title = 'Graph';
            
            
            % Panel: Controls
            
            
            obj.hPanel_Controls = uipanel(obj.hFig_Main);
            obj.hPanel_Controls.Position = [ ...
                obj.nLeftWidth + 1, ...
                1, ...
                obj.nGUIWidth - obj.nLeftWidth, ...
                obj.nGUIHeight];
            obj.hPanel_Controls.Title = 'Controls';
            
            % Label: Start
            obj.hLabel_Start = uilabel(obj.hPanel_Controls);
            obj.hLabel_Start.Position = [ ...
                obj.nInterval_Horizontal, ...
                obj.nBottomSpace + 4.5 * obj.nInterval_Vertical + 3 * obj.nButtonHeight, ...
                2 * obj.nButtonWidth, ...
                obj.nButtonHeight];
            obj.hLabel_Start.Text = 'Start Experiment';
            
            % Button: Start
            obj.hButton_Start = uibutton(obj.hPanel_Controls);
            obj.hButton_Start.Position = [ ...
                obj.nInterval_Horizontal, ...
                obj.nBottomSpace + 4 * obj.nInterval_Vertical + 3 * obj.nButtonHeight, ...
                obj.nButtonWidth, ...
                obj.nButtonHeight];
            obj.hButton_Start.Text = 'Start';
          
            % Label: Constant
            obj.hLabel_Constant = uilabel(obj.hPanel_Controls);
            obj.hLabel_Constant.Position = [ ...
                obj.nInterval_Horizontal, ...
                obj.nBottomSpace + 3.5 * obj.nInterval_Vertical + 2 * obj.nButtonHeight, ...
                2 * obj.nButtonWidth, ...
                obj.nButtonHeight];
            obj.hLabel_Constant.Text = 'Calibration';
            
            % Edit: Constant
            obj.hEdit_Constant = uieditfield(obj.hPanel_Controls);
            obj.hEdit_Constant.Position = [ ...
                obj.nInterval_Horizontal, ...
                obj.nBottomSpace + 3 * obj.nInterval_Vertical + 2 * obj.nButtonHeight, ...
                obj.nButtonWidth, ...
                obj.nButtonHeight];
            obj.hEdit_Constant.Editable = 'off';
            obj.hEdit_Constant.HorizontalAlignment = 'Center';
            obj.hEdit_Constant.Value = '-';
            
            % Label: SaveToPhone
            obj.hLabel_SaveToPhone = uilabel(obj.hPanel_Controls);
            obj.hLabel_SaveToPhone.Position = [ ...
                obj.nInterval_Horizontal, ...
                obj.nBottomSpace + 2.5 * obj.nInterval_Vertical + 1 * obj.nButtonHeight, ...
                2 * obj.nButtonWidth, ...
                obj.nButtonHeight];
            obj.hLabel_SaveToPhone.Text = 'Save to Phone';
            
            % Button: SaveToPhone
            obj.hButton_SaveToPhone = uibutton(obj.hPanel_Controls);
            obj.hButton_SaveToPhone.Position = [ ...
                obj.nInterval_Horizontal, ...
                obj.nBottomSpace + 2 * obj.nInterval_Vertical + 1 * obj.nButtonHeight, ...
                obj.nButtonWidth, ...
                obj.nButtonHeight];
            obj.hButton_SaveToPhone.Text = 'Save';
            
           % Label: SaveInfo
            obj.hLabel_SaveInfo = uilabel(obj.hPanel_Controls);
            obj.hLabel_SaveInfo.Position = [ ...
                obj.nInterval_Horizontal, ...
                obj.nBottomSpace + 1.5 * obj.nInterval_Vertical, ...
                2 * obj.nButtonWidth, ...
                obj.nButtonHeight];
            obj.hLabel_SaveInfo.Text = 'Save to Disk';
            
            % Button: SaveInfo
            obj.hButton_SaveInfo = uibutton(obj.hPanel_Controls);
            obj.hButton_SaveInfo.Position = [ ...
                obj.nInterval_Horizontal, ...
                obj.nBottomSpace + obj.nInterval_Vertical, ...
                obj.nButtonWidth, ...
                obj.nButtonHeight];
            obj.hButton_SaveInfo.Text = 'Save';
            
            
            
            % Panel: Lamps
            
            
            obj.hPanel_Lamps = uipanel(obj.hFig_Main);
            obj.hPanel_Lamps.Position = [ ...
                1, ...
                1, ...
                obj.nLeftWidth, ...
                obj.nGUIHeight - obj.nUpperHeight];
            obj.hPanel_Lamps.Title = 'Progress';
            
            % Label: Calibration
            obj.hLabel_Calibration = uilabel(obj.hPanel_Lamps);
            obj.hLabel_Calibration.Position = [ ...
                obj.nSpread_Lights_Horizontal - 12, ...
                obj.nSpread_Lights_Vertical + obj.nButtonHeight, ...
                obj.nButtonWidth, ...
                obj.nButtonHeight];
            obj.hLabel_Calibration.Text = 'Calibration';
           
            % Lamp: Calibration
            obj.hLamp_Calibration = uilamp(obj.hPanel_Lamps);
            obj.hLamp_Calibration.Position = [ ...
                obj.nSpread_Lights_Horizontal, ...
                obj.nSpread_Lights_Vertical, ...
                obj.nButtonHeight, ...
                obj.nButtonHeight];
            obj.hLamp_Calibration.Color = obj.mColors(2, :);
          
            % Label: Test
            obj.hLabel_Test = uilabel(obj.hPanel_Lamps);
            obj.hLabel_Test.Position = [ ...
                2 * obj.nSpread_Lights_Horizontal + obj.nButtonHeight + 4, ...
                obj.nSpread_Lights_Vertical + obj.nButtonHeight, ...
                obj.nButtonWidth, ...
                obj.nButtonHeight];
            obj.hLabel_Test.Text = 'Test';
           
            % Lamp: Test
            obj.hLamp_Test = uilamp(obj.hPanel_Lamps);
            obj.hLamp_Test.Position = [ ...
                2 * obj.nSpread_Lights_Horizontal + obj.nButtonHeight, ...
                obj.nSpread_Lights_Vertical, ...
                obj.nButtonHeight, ...
                obj.nButtonHeight];
            obj.hLamp_Test.Color = obj.mColors(2, :);
            
            % Label: Finished
            obj.hLabel_Finished = uilabel(obj.hPanel_Lamps);
            obj.hLabel_Finished.Position = [ ...
                3 * obj.nSpread_Lights_Horizontal + 2 * obj.nButtonHeight  - 8, ...
                obj.nSpread_Lights_Vertical + obj.nButtonHeight, ...
                obj.nButtonWidth, ...
                obj.nButtonHeight];
            obj.hLabel_Finished.Text = 'Finished';
           
            % Lamp: Finished
            obj.hLamp_Finished = uilamp(obj.hPanel_Lamps);
            obj.hLamp_Finished.Position = [ ...
                3 * obj.nSpread_Lights_Horizontal + 2 * obj.nButtonHeight, ...
                obj.nSpread_Lights_Vertical, ...
                obj.nButtonHeight, ...
                obj.nButtonHeight];
            obj.hLamp_Finished.Color = obj.mColors(2, :);
           
            
        
            
        end

    end

end