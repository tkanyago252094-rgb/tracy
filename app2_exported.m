classdef app2_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        TabGroup                        matlab.ui.container.TabGroup
        newtonraphsonTab                matlab.ui.container.Tab
        FunctionLabel                   matlab.ui.control.Label
        FunctionEditFieldLabel          matlab.ui.control.Label
        FunctionEditField               matlab.ui.control.EditField
        InitialGuessLabel               matlab.ui.control.Label
        InitialGuessEditFieldLabel      matlab.ui.control.Label
        InitialGuessEditField           matlab.ui.control.NumericEditField
        ToleranceLabel                  matlab.ui.control.Label
        ToleranceEditFieldLabel         matlab.ui.control.Label
        ToleranceEditField              matlab.ui.control.NumericEditField
        MaxiterationLabel               matlab.ui.control.Label
        MaxIterationsEditFieldLabel     matlab.ui.control.Label
        MaxIterationsEditField          matlab.ui.control.NumericEditField
        solveNewtonButton               matlab.ui.control.Button
        Label                           matlab.ui.control.Label
        UITable                         matlab.ui.control.Table
        bisectionTab                    matlab.ui.container.Tab
        FunctioninputfieldEditFieldLabel  matlab.ui.control.Label
        FunctioninputfieldEditField     matlab.ui.control.EditField
        lowerlimitaEditFieldLabel       matlab.ui.control.Label
        lowerlimitaEditField            matlab.ui.control.NumericEditField
        upperlimitbEditFieldLabel       matlab.ui.control.Label
        upperlimitbEditField            matlab.ui.control.NumericEditField
        maximumiterationEditFieldLabel  matlab.ui.control.Label
        maximumiterationEditField       matlab.ui.control.NumericEditField
        ToleranceEditField_2Label       matlab.ui.control.Label
        ToleranceEditField_2            matlab.ui.control.NumericEditField
        solvebuttonButton               matlab.ui.control.Button
        Label2                          matlab.ui.control.Label
        UITable2                        matlab.ui.control.Table
        rk4Tab                          matlab.ui.container.Tab
        differentialequationinputEditFieldLabel  matlab.ui.control.Label
        differentialequationinputEditField  matlab.ui.control.EditField
        initialxEditFieldLabel          matlab.ui.control.Label
        initialxEditField               matlab.ui.control.NumericEditField
        initialyEditFieldLabel          matlab.ui.control.Label
        initialyEditField               matlab.ui.control.NumericEditField
        finalxEditFieldLabel            matlab.ui.control.Label
        finalxEditField                 matlab.ui.control.NumericEditField
        EditFieldLabel                  matlab.ui.control.Label
        EditField                       matlab.ui.control.NumericEditField
        Button                          matlab.ui.control.Button
        UITable3                        matlab.ui.control.Table
        UIAxes                          matlab.ui.control.UIAxes
        interpolationTab                matlab.ui.container.Tab
        xvaluesTextAreaLabel            matlab.ui.control.Label
        xvaluesTextArea                 matlab.ui.control.TextArea
        yvaluesTextAreaLabel            matlab.ui.control.Label
        yvaluesTextArea                 matlab.ui.control.TextArea
        targetxinputvalueEditFieldLabel  matlab.ui.control.Label
        targetxinputvalueEditField      matlab.ui.control.NumericEditField
        interpolationbuttonButton       matlab.ui.control.Button
        ResultlabelLabel                matlab.ui.control.Label
        UIAxes2                         matlab.ui.control.UIAxes
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: solveNewtonButton
        function solveNewtonButtonPushed(app, event)
% Button pushed callback: solveNewtonButton
function solveNewtonButtonPushed(app, event)
    try
        % 1. Read Inputs and Clean Equation String
        funcStr = app.FunctionEditField.Value;
        
        % Automatically remove '=0' if the user typed it in the field
        funcStr = regexprep(funcStr, '\s*=\s*0$', '');
        f = str2func(['@(x) ' funcStr]);
        
        % Numerical derivative approximation (central difference)
        h = 1e-5;
        df = @(x) (f(x + h) - f(x - h)) / (2 * h);
        
        x0 = app.InitialGuessEditField.Value;
        tol = app.ToleranceEditField.Value;
        maxIter = app.MaxIterationsEditField.Value;
        
        % 2. Initialize Loop Variables
        x = x0;
        tableData = {};
        
        % 3. Newton-Raphson Algorithm Loop
        for i = 1:maxIter
            fx = f(x);
            dfx = df(x);
            
            % Prevent division by zero if derivative is flat
            if abs(dfx) < 1e-12
                uialert(app.UIFigure, 'Derivative is too close to zero. Method stalled.', 'Math Error');
                return;
            end
            
            x_new = x - fx / dfx;
            error = abs(x_new - x);
            
            % Log iteration data: [Iteration, x, f(x), Error]
            tableData{i, 1} = i;
            tableData{i, 2} = x;
            tableData{i, 3} = fx;
            tableData{i, 4} = error;
            
            % Check convergence condition
            if error < tol
                x = x_new;
                break;
            end
            
            x = x_new;
        end
        
        % 4. Update the UITable Display
        app.UITable.Data = tableData;
        app.UITable.ColumnName = {'Iteration', 'x', 'f(x)', 'Error'};
        
        % 5. Display Final Summary in the Label
        app.Label.Text = sprintf('Root found: %.6f after %d iterations', x, i);
        
    catch ME
        % Handle syntax or computation errors smoothly
        uialert(app.UIFigure, ['Error evaluating function: ' ME.message], 'Input Error');
    end
end
           
           
        end

        % Button pushed function: Button, solvebuttonButton
        function ButtonPushed(app, event)
            % Button pushed callback: solvebutton
function solvebuttonPushed(app, event)
    try
        % 1. Read Inputs from UI Components
        funcStr = app.Functioninputfield.Value;
        f = str2func(['@(x) ' funcStr]); % Convert string expression to anonymous function handle
        
        a = app.lowerlimita.Value;
        b = app.upperlimitb.Value;
        tol = app.Tolerance.Value;
        maxIter = app.maximumiteration.Value;
        
        % 2. Validate Initial Bracket [a, b]
        fa = f(a);
        fb = f(b);
        
        if fa * fb > 0
            uialert(app.UIFigure, 'The function must have opposite signs at the lower and upper limits (f(a)*f(b) < 0).', 'Bracket Error');
            return;
        end
        
        % 3. Initialize Variables for Bisection Loop
        tableData = {};
        c = a; % initialize root variable
        
        for i = 1:maxIter
            c_prev = c;
            c = (a + b) / 2;
            fc = f(c);
            
            % Calculate error (absolute difference between successive approximations)
            if i == 1
                error = abs(b - a);
            else
                error = abs(c - c_prev);
            end
            
            % Store iteration data in cell array: [Iteration, a, b, c, f(c), Error]
            tableData{i, 1} = i;
            tableData{i, 2} = c;
            tableData{i, 3} = fc;
            tableData{i, 4} = error;
            
            % Check convergence condition
            if abs(fc) < 1e-12 || error < tol
                break;
            end
            
            % Update brackets
            if f(a) * fc < 0
                b = c;
            else
                a = c;
            end
        end
        
        % 4. Update the UITable Display
        app.UITable.Data = tableData;
        app.UITable.ColumnName = {'Iteration', 'Root (c)', 'f(c)', 'Error'};
        
        % 5. Update Label2 with the final result summary
        app.Label2.Text = sprintf('Root found: %.6f after %d iterations', c, i);
        
    catch ME
        % Handle syntax or computation errors smoothly
        uialert(app.UIFigure, ['Error: ' ME.message], 'Execution Error');
    end
end
        end

        % Size changed function: bisectionTab
        function bisectionTabSizeChanged(app, event)
            position = app.bisectionTab.Position;
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [19 -130 715 654];

            % Create newtonraphsonTab
            app.newtonraphsonTab = uitab(app.TabGroup);
            app.newtonraphsonTab.Title = 'newton raphson';

            % Create FunctionLabel
            app.FunctionLabel = uilabel(app.newtonraphsonTab);
            app.FunctionLabel.Position = [24 593 81 22];
            app.FunctionLabel.Text = 'FunctionLabel';

            % Create FunctionEditFieldLabel
            app.FunctionEditFieldLabel = uilabel(app.newtonraphsonTab);
            app.FunctionEditFieldLabel.HorizontalAlignment = 'right';
            app.FunctionEditFieldLabel.Position = [15 572 98 22];
            app.FunctionEditFieldLabel.Text = 'FunctionEditField';

            % Create FunctionEditField
            app.FunctionEditField = uieditfield(app.newtonraphsonTab, 'text');
            app.FunctionEditField.Position = [128 572 100 22];
            app.FunctionEditField.Value = 'x^3-x-2';

            % Create InitialGuessLabel
            app.InitialGuessLabel = uilabel(app.newtonraphsonTab);
            app.InitialGuessLabel.Position = [24 543 98 22];
            app.InitialGuessLabel.Text = 'InitialGuessLabel';

            % Create InitialGuessEditFieldLabel
            app.InitialGuessEditFieldLabel = uilabel(app.newtonraphsonTab);
            app.InitialGuessEditFieldLabel.HorizontalAlignment = 'right';
            app.InitialGuessEditFieldLabel.Position = [6 520 115 22];
            app.InitialGuessEditFieldLabel.Text = 'InitialGuessEditField';

            % Create InitialGuessEditField
            app.InitialGuessEditField = uieditfield(app.newtonraphsonTab, 'numeric');
            app.InitialGuessEditField.Position = [136 520 100 22];
            app.InitialGuessEditField.Value = 1.5;

            % Create ToleranceLabel
            app.ToleranceLabel = uilabel(app.newtonraphsonTab);
            app.ToleranceLabel.Position = [18 487 87 22];
            app.ToleranceLabel.Text = 'ToleranceLabel';

            % Create ToleranceEditFieldLabel
            app.ToleranceEditFieldLabel = uilabel(app.newtonraphsonTab);
            app.ToleranceEditFieldLabel.HorizontalAlignment = 'right';
            app.ToleranceEditFieldLabel.Position = [12 461 104 22];
            app.ToleranceEditFieldLabel.Text = 'ToleranceEditField';

            % Create ToleranceEditField
            app.ToleranceEditField = uieditfield(app.newtonraphsonTab, 'numeric');
            app.ToleranceEditField.Position = [131 461 100 22];
            app.ToleranceEditField.Value = 1e-06;

            % Create MaxiterationLabel
            app.MaxiterationLabel = uilabel(app.newtonraphsonTab);
            app.MaxiterationLabel.Position = [32 440 100 22];
            app.MaxiterationLabel.Text = 'MaxiterationLabel';

            % Create MaxIterationsEditFieldLabel
            app.MaxIterationsEditFieldLabel = uilabel(app.newtonraphsonTab);
            app.MaxIterationsEditFieldLabel.HorizontalAlignment = 'right';
            app.MaxIterationsEditFieldLabel.Position = [1 408 124 22];
            app.MaxIterationsEditFieldLabel.Text = 'MaxIterationsEditField';

            % Create MaxIterationsEditField
            app.MaxIterationsEditField = uieditfield(app.newtonraphsonTab, 'numeric');
            app.MaxIterationsEditField.Position = [140 408 100 22];
            app.MaxIterationsEditField.Value = 100;

            % Create solveNewtonButton
            app.solveNewtonButton = uibutton(app.newtonraphsonTab, 'push');
            app.solveNewtonButton.ButtonPushedFcn = createCallbackFcn(app, @solveNewtonButtonPushed, true);
            app.solveNewtonButton.Position = [15 374 119 22];
            app.solveNewtonButton.Text = 'solveNewtonButton';

            % Create Label
            app.Label = uilabel(app.newtonraphsonTab);
            app.Label.Position = [18 342 35 22];

            % Create UITable
            app.UITable = uitable(app.newtonraphsonTab);
            app.UITable.ColumnName = {'NewtonTable'; 'Column 2'; 'Column 3'; 'Column 4'};
            app.UITable.RowName = {};
            app.UITable.Position = [149 233 302 131];

            % Create bisectionTab
            app.bisectionTab = uitab(app.TabGroup);
            app.bisectionTab.SizeChangedFcn = createCallbackFcn(app, @bisectionTabSizeChanged, true);
            app.bisectionTab.Title = 'bisection';

            % Create FunctioninputfieldEditFieldLabel
            app.FunctioninputfieldEditFieldLabel = uilabel(app.bisectionTab);
            app.FunctioninputfieldEditFieldLabel.HorizontalAlignment = 'right';
            app.FunctioninputfieldEditFieldLabel.Position = [18 572 106 22];
            app.FunctioninputfieldEditFieldLabel.Text = 'Function input field';

            % Create FunctioninputfieldEditField
            app.FunctioninputfieldEditField = uieditfield(app.bisectionTab, 'text');
            app.FunctioninputfieldEditField.Position = [139 572 100 22];
            app.FunctioninputfieldEditField.Value = 'x^2 -4=0';

            % Create lowerlimitaEditFieldLabel
            app.lowerlimitaEditFieldLabel = uilabel(app.bisectionTab);
            app.lowerlimitaEditFieldLabel.HorizontalAlignment = 'right';
            app.lowerlimitaEditFieldLabel.Position = [32 541 69 22];
            app.lowerlimitaEditFieldLabel.Text = 'lower limit a';

            % Create lowerlimitaEditField
            app.lowerlimitaEditField = uieditfield(app.bisectionTab, 'numeric');
            app.lowerlimitaEditField.Position = [116 541 100 22];
            app.lowerlimitaEditField.Value = 1;

            % Create upperlimitbEditFieldLabel
            app.upperlimitbEditFieldLabel = uilabel(app.bisectionTab);
            app.upperlimitbEditFieldLabel.HorizontalAlignment = 'right';
            app.upperlimitbEditFieldLabel.Position = [29 508 71 22];
            app.upperlimitbEditFieldLabel.Text = 'upper limit b';

            % Create upperlimitbEditField
            app.upperlimitbEditField = uieditfield(app.bisectionTab, 'numeric');
            app.upperlimitbEditField.Position = [115 508 100 22];
            app.upperlimitbEditField.Value = 3;

            % Create maximumiterationEditFieldLabel
            app.maximumiterationEditFieldLabel = uilabel(app.bisectionTab);
            app.maximumiterationEditFieldLabel.HorizontalAlignment = 'right';
            app.maximumiterationEditFieldLabel.Position = [7 432 104 22];
            app.maximumiterationEditFieldLabel.Text = 'maximum iteration';

            % Create maximumiterationEditField
            app.maximumiterationEditField = uieditfield(app.bisectionTab, 'numeric');
            app.maximumiterationEditField.Position = [126 432 100 22];
            app.maximumiterationEditField.Value = 100;

            % Create ToleranceEditField_2Label
            app.ToleranceEditField_2Label = uilabel(app.bisectionTab);
            app.ToleranceEditField_2Label.HorizontalAlignment = 'right';
            app.ToleranceEditField_2Label.Position = [29 466 58 22];
            app.ToleranceEditField_2Label.Text = 'Tolerance';

            % Create ToleranceEditField_2
            app.ToleranceEditField_2 = uieditfield(app.bisectionTab, 'numeric');
            app.ToleranceEditField_2.Position = [102 466 100 22];
            app.ToleranceEditField_2.Value = 1e-06;

            % Create solvebuttonButton
            app.solvebuttonButton = uibutton(app.bisectionTab, 'push');
            app.solvebuttonButton.ButtonPushedFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.solvebuttonButton.Position = [37 395 100 22];
            app.solvebuttonButton.Text = 'solve button';

            % Create Label2
            app.Label2 = uilabel(app.bisectionTab);
            app.Label2.Position = [52 353 42 22];
            app.Label2.Text = 'Label2';

            % Create UITable2
            app.UITable2 = uitable(app.bisectionTab);
            app.UITable2.ColumnName = {'Column 1'; 'Column 2'; 'Column 3'; 'Column 4'};
            app.UITable2.RowName = {};
            app.UITable2.Position = [24 232 403 111];

            % Create rk4Tab
            app.rk4Tab = uitab(app.TabGroup);
            app.rk4Tab.Title = 'rk4';

            % Create differentialequationinputEditFieldLabel
            app.differentialequationinputEditFieldLabel = uilabel(app.rk4Tab);
            app.differentialequationinputEditFieldLabel.HorizontalAlignment = 'right';
            app.differentialequationinputEditFieldLabel.Position = [7 593 139 22];
            app.differentialequationinputEditFieldLabel.Text = 'differential equation input';

            % Create differentialequationinputEditField
            app.differentialequationinputEditField = uieditfield(app.rk4Tab, 'text');
            app.differentialequationinputEditField.Position = [161 593 100 22];

            % Create initialxEditFieldLabel
            app.initialxEditFieldLabel = uilabel(app.rk4Tab);
            app.initialxEditFieldLabel.HorizontalAlignment = 'right';
            app.initialxEditFieldLabel.Position = [37 551 42 22];
            app.initialxEditFieldLabel.Text = 'initial x';

            % Create initialxEditField
            app.initialxEditField = uieditfield(app.rk4Tab, 'numeric');
            app.initialxEditField.Position = [94 551 100 22];

            % Create initialyEditFieldLabel
            app.initialyEditFieldLabel = uilabel(app.rk4Tab);
            app.initialyEditFieldLabel.HorizontalAlignment = 'right';
            app.initialyEditFieldLabel.Position = [37 520 42 22];
            app.initialyEditFieldLabel.Text = 'initial y';

            % Create initialyEditField
            app.initialyEditField = uieditfield(app.rk4Tab, 'numeric');
            app.initialyEditField.Position = [94 520 100 22];

            % Create finalxEditFieldLabel
            app.finalxEditFieldLabel = uilabel(app.rk4Tab);
            app.finalxEditFieldLabel.HorizontalAlignment = 'right';
            app.finalxEditFieldLabel.Position = [51 482 37 22];
            app.finalxEditFieldLabel.Text = 'final x';

            % Create finalxEditField
            app.finalxEditField = uieditfield(app.rk4Tab, 'numeric');
            app.finalxEditField.Position = [103 482 100 22];

            % Create EditFieldLabel
            app.EditFieldLabel = uilabel(app.rk4Tab);
            app.EditFieldLabel.HorizontalAlignment = 'right';
            app.EditFieldLabel.Position = [39 445 56 22];
            app.EditFieldLabel.Text = 'Edit Field';

            % Create EditField
            app.EditField = uieditfield(app.rk4Tab, 'numeric');
            app.EditField.Position = [110 445 100 22];

            % Create Button
            app.Button = uibutton(app.rk4Tab, 'push');
            app.Button.ButtonPushedFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.Button.Position = [41 405 100 22];

            % Create UITable3
            app.UITable3 = uitable(app.rk4Tab);
            app.UITable3.ColumnName = {'Column 1'; 'Column 2'; 'Column 3'; 'Column 4'};
            app.UITable3.RowName = {};
            app.UITable3.Position = [38 298 302 98];

            % Create UIAxes
            app.UIAxes = uiaxes(app.rk4Tab);
            title(app.UIAxes, 'Title')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            app.UIAxes.PlotBoxAspectRatio = [24.8888888888889 1 1];
            app.UIAxes.YTickLabel = {'0'; ''; '1'};
            app.UIAxes.Position = [41 155 300 125];

            % Create interpolationTab
            app.interpolationTab = uitab(app.TabGroup);
            app.interpolationTab.Title = 'interpolation';

            % Create xvaluesTextAreaLabel
            app.xvaluesTextAreaLabel = uilabel(app.interpolationTab);
            app.xvaluesTextAreaLabel.HorizontalAlignment = 'right';
            app.xvaluesTextAreaLabel.Position = [24 587 50 22];
            app.xvaluesTextAreaLabel.Text = 'x-values';

            % Create xvaluesTextArea
            app.xvaluesTextArea = uitextarea(app.interpolationTab);
            app.xvaluesTextArea.Position = [89 551 150 60];

            % Create yvaluesTextAreaLabel
            app.yvaluesTextAreaLabel = uilabel(app.interpolationTab);
            app.yvaluesTextAreaLabel.HorizontalAlignment = 'right';
            app.yvaluesTextAreaLabel.Position = [21 518 50 22];
            app.yvaluesTextAreaLabel.Text = 'y-values';

            % Create yvaluesTextArea
            app.yvaluesTextArea = uitextarea(app.interpolationTab);
            app.yvaluesTextArea.Position = [86 482 150 60];

            % Create targetxinputvalueEditFieldLabel
            app.targetxinputvalueEditFieldLabel = uilabel(app.interpolationTab);
            app.targetxinputvalueEditFieldLabel.HorizontalAlignment = 'right';
            app.targetxinputvalueEditFieldLabel.Position = [4 440 108 22];
            app.targetxinputvalueEditFieldLabel.Text = 'target x-input value';

            % Create targetxinputvalueEditField
            app.targetxinputvalueEditField = uieditfield(app.interpolationTab, 'numeric');
            app.targetxinputvalueEditField.Position = [127 440 100 22];

            % Create interpolationbuttonButton
            app.interpolationbuttonButton = uibutton(app.interpolationTab, 'push');
            app.interpolationbuttonButton.Position = [32 395 118 22];
            app.interpolationbuttonButton.Text = 'interpolation button';

            % Create ResultlabelLabel
            app.ResultlabelLabel = uilabel(app.interpolationTab);
            app.ResultlabelLabel.Position = [43 363 68 22];
            app.ResultlabelLabel.Text = 'Result label';

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.interpolationTab);
            title(app.UIAxes2, 'Title')
            xlabel(app.UIAxes2, 'X')
            ylabel(app.UIAxes2, 'Y')
            app.UIAxes2.Position = [1 233 300 121];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = app2_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end