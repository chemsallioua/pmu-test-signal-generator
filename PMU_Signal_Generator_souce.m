classdef PMU_Signal_Generator_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        PMUDev                          matlab.ui.Figure
        Image3                          matlab.ui.control.Image
        Image4                          matlab.ui.control.Image
        Image2                          matlab.ui.control.Image
        Tabs                            matlab.ui.container.TabGroup
        SteadyState                     matlab.ui.container.Tab
        StepChangePanel                 matlab.ui.container.Panel
        EnableStep                      matlab.ui.control.CheckBox
        stepinstantslider               matlab.ui.control.Slider
        stepinstant                     matlab.ui.control.NumericEditField
        InstantsLabel                   matlab.ui.control.Label
        kxstep                          matlab.ui.control.NumericEditField
        kxEditFieldLabel_2              matlab.ui.control.Label
        kastep                          matlab.ui.control.NumericEditField
        karadLabel                      matlab.ui.control.Label
        LinearFrequencyRampPanel        matlab.ui.container.Panel
        Enableramp                      matlab.ui.control.CheckBox
        rampfreqslider                  matlab.ui.control.Slider
        rampfreq                        matlab.ui.control.NumericEditField
        RfHzsLabel                      matlab.ui.control.Label
        Initfreq                        matlab.ui.control.NumericEditField
        InitialFrequencyHzLabel         matlab.ui.control.Label
        THD                             matlab.ui.control.NumericEditField
        THDTotalHarmonicDistortionEditFieldLabel  matlab.ui.control.Label
        ModulationPanel                 matlab.ui.container.Panel
        EnableMod                       matlab.ui.control.CheckBox
        modfreqslider                   matlab.ui.control.Slider
        modfreq                         matlab.ui.control.NumericEditField
        FreqHzEditFieldLabel            matlab.ui.control.Label
        kxfield                         matlab.ui.control.NumericEditField
        kxEditFieldLabel                matlab.ui.control.Label
        kafield                         matlab.ui.control.NumericEditField
        kaEditFieldLabel                matlab.ui.control.Label
        GenerateDataPanel               matlab.ui.container.Panel
        GenerateButton                  matlab.ui.control.Button
        NumberofCycles                  matlab.ui.control.NumericEditField
        NCyclesLabel                    matlab.ui.control.Label
        NoisePanel                      matlab.ui.container.Panel
        noisemag                        matlab.ui.control.NumericEditField
        noiseslider                     matlab.ui.control.Slider
        MaxSliderLabel                  matlab.ui.control.Label
        noisemode                       matlab.ui.control.DropDown
        HarmonicsPanel                  matlab.ui.container.Panel
        harmag                          matlab.ui.control.NumericEditField
        MagtitudeEditFieldLabel         matlab.ui.control.Label
        Minfreq                         matlab.ui.control.NumericEditField
        Min10nEditFieldLabel            matlab.ui.control.Label
        Frequencyrange_______________________Label  matlab.ui.control.Label
        Maxfreq                         matlab.ui.control.NumericEditField
        Max10nEditFieldLabel            matlab.ui.control.Label
        orderslider                     matlab.ui.control.Slider
        OrderSliderLabel                matlab.ui.control.Label
        harmorder                       matlab.ui.control.NumericEditField
        harmode                         matlab.ui.control.DropDown
        SignalPanel                     matlab.ui.container.Panel
        fsvalue                         matlab.ui.control.NumericEditField
        SamplesEditFieldLabel           matlab.ui.control.Label
        ampvalue                        matlab.ui.control.NumericEditField
        phasevalue                      matlab.ui.control.NumericEditField
        f0value                         matlab.ui.control.NumericEditField
        amp                             matlab.ui.control.DropDown
        phase                           matlab.ui.control.DropDown
        f0                              matlab.ui.control.DropDown
        UIAxes                          matlab.ui.control.UIAxes
        IEEEIEC6025511812018SteadyStateTab  matlab.ui.container.Tab
        HTML                            matlab.ui.control.HTML
        IEEEIEC6025511812018DynamicTab  matlab.ui.container.Tab
        HTML2                           matlab.ui.control.HTML
    end

    
    properties (Access = private)
        signal_amplitude                       %Signal Amplitude
        signal_frequency                       %Signal frequency
        phase_shift                            %Phase shift
        sampling_rate                          %Sampling rate in Sample per second
        number_samples                         %Total number of samples
        t
        f_mod                                   %Modulation frequency
        ka                                      %Frequency Modulation factor
        kx                                      %Amplitude Modulation factor
        noise_amplitude                         %noise amplitude in Volts
        max_num_harmonics                       %This is the maximum number of Harmonics added to the Signal
        harmonics_Frequency_minim               %minimum harmonics frequency in Hertz
        harmonics_Frequency_maxim               %maximum harmonics frequency in Hertz
        harmonics_amplitude_max                 %Maximum amplitude of the Harmonics
        first_N_harmonics                       %First N Harmonics
        Ramp_rate                               %The rate of frequency linear increase for Frequency Ramp
        step_instant                            %The instant where a step change occurs
        kas                                     %Step change Frequency factor
        kxs                                     %Amplitude Step change factor
        step                                    %Step function used to make step change
        finalsignal                             %Final Signal generated
        
    end
    
    methods (Access = private)
        
        function UpdatePlot(app)
            %Frequency and Amplitude Modulation (Dynamic-Phasor Model)
            ModulatedSignal= app.signal_amplitude*(1 + app.kx*cos(2*pi*app.f_mod*app.t) + app.kxs*app.step).*cos(2*pi*app.signal_frequency*app.t + app.ka*cos(2*pi*app.f_mod*app.t) + app.phase_shift + pi*app.Ramp_rate*(app.t).^2  + app.kas*app.step);
            
            %Adding Gaussian noise to the signal
            sampledNoisySignal = ModulatedSignal + app.noise_amplitude * randn(1, length(ModulatedSignal)); %Signal with Noise
            
            %Adding Harmonics
            
            sampled_harmonics_noise_signal=sampledNoisySignal;
            
            if app.harmode.Value == "One"
                
                app.Minfreq.Enable = false;
                app.Maxfreq.Enable = false;
                app.orderslider.Enable = true;
                app.harmorder.Enable = true;
                app.harmag.Enable=true;
                
                sampled_harmonics_noise_signal = sampled_harmonics_noise_signal + app.harmonics_amplitude_max*cos(2*pi*app.max_num_harmonics*app.signal_frequency*app.t + app.phase_shift);
                
            elseif app.harmode.Value == "Up to"
                
                app.Minfreq.Enable = false;
                app.Maxfreq.Enable = false;
                app.orderslider.Enable = true;
                app.harmorder.Enable = true;
                app.harmag.Enable=true;
                
                for i=2 : app.max_num_harmonics
                    sampled_harmonics_noise_signal = sampled_harmonics_noise_signal + app.harmonics_amplitude_max*cos(2*pi*app.first_N_harmonics(i)*app.signal_frequency*app.t + app.phase_shift);
                end
            elseif app.harmode.Value == "Random"
                
                app.Minfreq.Enable = true;
                app.Maxfreq.Enable = true;
                app.orderslider.Enable = true;
                app.harmorder.Enable = true;
                app.harmag.Enable=true;
                
                for i=2 : randi(app.max_num_harmonics)-1
                    sampled_harmonics_noise_signal = sampled_harmonics_noise_signal + randi(100)*0.01* app.harmonics_amplitude_max*cos(2*pi*randi([round(app.harmonics_Frequency_minim/app.signal_frequency) round(app.harmonics_Frequency_maxim/app.signal_frequency) ])*app.signal_frequency*app.t + randi(100)*0.01*2*pi +app.phase_shift);
                end
            else
                app.Minfreq.Enable = false;
                app.Maxfreq.Enable = false;
                app.orderslider.Enable = false;
                app.harmorder.Enable = false;
                app.harmag.Enable=false;
            end
            
            app.UIAxes.YLim = [min(sampled_harmonics_noise_signal)*1.5 max(sampled_harmonics_noise_signal)*1.5];
            if (app.NumberofCycles.Value/app.signal_frequency) < 0.5
                app.UIAxes.XLim = [0 (app.NumberofCycles.Value/app.signal_frequency)];
            else
                app.UIAxes.XLim = [0 0.5];
                
            if app.step_instant > 0.5
                app.UIAxes.XLim=[0 app.NumberofCycles.Value/app.signal_frequency];
                
            end
            
            end
            plot(app.UIAxes,app.t,sampled_harmonics_noise_signal);
            
            
            app.THD.Value= db2mag(thd(sampled_harmonics_noise_signal))*100;
            app.finalsignal=sampled_harmonics_noise_signal;
            
        end
        
        function UpdateProperties(app)
            
            app.sampling_rate = app.fsvalue.Value;                            %Sampling rate in Sample per second
            app.number_samples = (app.sampling_rate/app.signal_frequency)*app.NumberofCycles.Value;        %total number of samples = samples per cycle * Number of cycles
            
            app.t=0:1/app.sampling_rate:app.number_samples/app.sampling_rate;
            %app.step=heaviside(single(app.t-app.step_instant));   %step function
            app.step=zeros(size(app.t));   %step function
            app.step(app.t >= app.step_instant) = 1;
            %app.step(app.t == app.step_instant) = 0.5;
            app.noise_amplitude = (app.noisemag.Value/100)*app.signal_amplitude;  %noise amplitude
            
            app.max_num_harmonics = app.harmorder.Value ;   %This is the maximum number of Harmonics added to the Signal
            app.harmonics_Frequency_minim =  10^app.Minfreq.Value ;   %minimum harmonics frequency in Hertz
            app.harmonics_Frequency_maxim =  10^app.Maxfreq.Value ;   %maximum harmonics frequency in Hertz
            app.harmonics_amplitude_max = (app.harmag.Value/100)*app.signal_amplitude; %Maximum amplitude of the Harmonics in Volts
            app.first_N_harmonics = 2: app.max_num_harmonics+1;
            
            app.stepinstant.Limits=[0 app.NumberofCycles.Value/app.signal_frequency];
            
            UpdatePlot(app);
            
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            
            app.PMUDev.Name = "PMU Test Signal Generator";
            app.PMUDev.Icon = "Icon32x32.png";
    
            app.signal_amplitude = app.ampvalue.Value*sqrt(2);                        %Signal Amplitude
            app.signal_frequency = app.f0value.Value;                         %Signal frequency
            app.phase_shift = app.phasevalue.Value;                           %Phase shift
            app.sampling_rate = app.fsvalue.Value;                            %Sampling rate in Sample per second
            app.f_mod = app.modfreq.Value;                                                            %Modulation frequency
            app.ka = 0;                                                                %Frequency Modulation factor
            app.kx = 0;                                                               %Amplitude Modulation factor
            app.Ramp_rate = 0;
            app.kas =0;
            app.kxs=0;
            app.step_instant= app.stepinstant.Value;
            
            app.number_samples = (app.sampling_rate/app.signal_frequency)*app.NumberofCycles.Value;        %total number of samples = samples per cycle * Number of cycles
            
            app.t=0:1/app.sampling_rate:app.number_samples/app.sampling_rate;
            app.step=zeros(size(app.t));   %step function
            app.step(app.t >= app.step_instant) = 1;
            %app.step(app.t == app.step_instant) = 0.5;
            
            app.noise_amplitude = (app.noisemag.Value/100)*app.signal_amplitude;  %noise amplitude
            
            app.max_num_harmonics = app.harmorder.Value ;   %This is the maximum number of Harmonics added to the Signal
            app.harmonics_Frequency_minim =  10^app.Minfreq.Value ;   %minimum harmonics frequency in Hertz
            app.harmonics_Frequency_maxim =  10^app.Maxfreq.Value ;   %maximum harmonics frequency in Hertz
            app.harmonics_amplitude_max = (app.harmag.Value/100)*app.signal_amplitude; %Maximum amplitude of the Harmonics in Volts
            app.first_N_harmonics = 2: app.max_num_harmonics;
            
            app.orderslider.Value = app.harmorder.Value;
            app.noiseslider.Value = app.noisemag.Value;
            app.UIAxes.XLim = [0 0.5];
            app.UIAxes.YLim = [-15 15];
            
            app.modfreqslider.Value = app.modfreq.Value;
            app.modfreqslider.Enable=false;
            app.modfreq.Enable=false;
            app.kxfield.Enable=false;
            app.kafield.Enable=false;
            
            app.rampfreqslider.Value= app.rampfreq.Value;
            app.Initfreq.Enable=false;
            app.rampfreq.Enable=false;
            app.rampfreqslider.Enable=false;
            
            
            app.stepinstantslider.Value = app.stepinstant.Value;
            app.stepinstantslider.Enable=false;
            app.stepinstant.Enable=false;
            app.kxstep.Enable=false;
            app.kastep.Enable=false;
            app.stepinstant.Limits=[0 app.NumberofCycles.Value/app.signal_frequency];
            
            
            UpdatePlot(app);
            
        end

        % Value changed function: fsvalue
        function fsvalueValueChanged(app, event)
            UpdateProperties(app);
        end

        % Value changed function: f0value
        function f0valueValueChanged(app, event)
            
            if app.f0.Value == "Frequency (Hz)"
                
                app.signal_frequency = app.f0value.Value;                         %Signal frequency
            end
            if app.f0.Value == "Period (s)"
                app.signal_frequency = 1/app.f0value.Value;                         %Signal frequency
            end
            
            UpdateProperties(app);
        end

        % Value changed function: phasevalue
        function phasevalueValueChanged(app, event)
            
            if app.phase.Value == "Phase shift (rad)"
                app.phase_shift = app.phasevalue.Value;                           %Phase shift
            end
            if app.phase.Value == "Phase shift (degree)"
                app.phase_shift = app.phasevalue.Value*pi/180;                           %Phase shift
            end
            
            UpdateProperties(app);
        end

        % Value changed function: ampvalue
        function ampvalueValueChanged(app, event)
            
            if app.amp.Value == "Amplitude Max (Volts)"
               app.signal_amplitude = app.ampvalue.Value;                        %Signal Amplitude
            end
            if app.amp.Value == "Peak to Peak (Volts)"
               app.signal_amplitude = app.ampvalue.Value/2;                        %Signal Amplitude
            end
            if app.amp.Value == "RMS(Volts)"
               app.signal_amplitude = app.ampvalue.Value*sqrt(2);                        %Signal Amplitude
            end
            
            UpdateProperties(app);
        end

        % Value changed function: harmorder
        function harmorderValueChanged(app, event)
            UpdateProperties(app);
            app.orderslider.Value = app.harmorder.Value;
        end

        % Value changed function: harmag
        function harmagValueChanged(app, event)
            UpdateProperties(app);
        end

        % Value changed function: harmode
        function harmodeValueChanged(app, event)
            UpdateProperties(app);
        end

        % Value changing function: noiseslider
        function noisesliderValueChanging(app, event)
            app.noisemag.Value = event.Value;
            UpdateProperties(app);
        end

        % Value changing function: orderslider
        function ordersliderValueChanging(app, event)
            app.harmorder.Value = event.Value;
            UpdateProperties(app);
        end

        % Value changed function: Minfreq
        function MinfreqValueChanged(app, event)
            UpdateProperties(app);
        end

        % Value changed function: f0
        function f0ValueChanged(app, event)
 
            if app.f0.Value == "Frequency (Hz)"
               app.signal_frequency = app.f0value.Value;                         %Signal frequency
            end
            if app.f0.Value == "Period (s)"
               app.signal_frequency = 1/app.f0value.Value;                         %Signal frequency
            end
           
            UpdateProperties(app);
        end

        % Value changed function: phase
        function phaseValueChanged(app, event)
            if app.phase.Value == "Phase shift (rad)"
                app.phase_shift = app.phasevalue.Value;                           %Phase shift
            end
            if app.phase.Value == "Phase shift (degree)"
                app.phase_shift = app.phasevalue.Value*pi/180;                     %Phase shift
            end
            
            UpdateProperties(app);
        end

        % Value changed function: amp
        function ampValueChanged(app, event)
            if app.amp.Value == "Amplitude Max (Volts)"
               app.signal_amplitude = app.ampvalue.Value;                        %Signal Amplitude
            end
            
            if app.amp.Value == "Peak to Peak (Volts)"
               app.signal_amplitude = app.ampvalue.Value/2;                        %Signal Amplitude
            end
            
            if app.amp.Value == "RMS(Volts)"
               app.signal_amplitude = (app.ampvalue.Value)*sqrt(2);                        %Signal Amplitude
            end
            
            UpdateProperties(app);
        end

        % Value changed function: NumberofCycles
        function NumberofCyclesValueChanged(app, event)
            UpdateProperties(app);
        end

        % Value changed function: EnableMod
        function EnableModValueChanged(app, event)
            
            if app.EnableMod.Value
               app.modfreqslider.Enable=true;
               app.modfreq.Enable=true;
               app.kxfield.Enable=true;
               app.kafield.Enable=true;
               app.kx=app.kxfield.Value/100;
               app.ka=app.kafield.Value/100;
            elseif not(app.EnableMod.Value)
               app.modfreqslider.Enable=false;
               app.modfreq.Enable=false;
               app.kxfield.Enable=false;
               app.kafield.Enable=false;
               app.kx=0;
               app.ka=0;
               app.modfreqslider.Limits=[0 6];
            end
            UpdateProperties(app);
        end

        % Value changed function: modfreq
        function modfreqValueChanged(app, event)
            app.f_mod = app.modfreq.Value;
            
            if app.modfreq.Value > 6
                app.modfreqslider.Limits=[0 app.modfreq.Value+2];
            end
            app.modfreqslider.Value = app.modfreq.Value;
            
            UpdateProperties(app);
        end

        % Value changing function: modfreqslider
        function modfreqsliderValueChanging(app, event)
            app.modfreq.Value = event.Value;
            app.f_mod = event.Value;
            UpdateProperties(app);
        end

        % Value changed function: kafield
        function kafieldValueChanged(app, event)
            app.ka = app.kafield.Value/100;
            UpdateProperties(app);
        end

        % Value changed function: kxfield
        function kxfieldValueChanged(app, event)
            app.kx = app.kxfield.Value/100;
            UpdateProperties(app);
        end

        % Value changed function: Enableramp
        function EnablerampValueChanged(app, event)
            
            if app.Enableramp.Value
                app.Initfreq.Enable=true;
                app.rampfreq.Enable=true;
                app.rampfreqslider.Enable=true;
                app.Ramp_rate= app.rampfreq.Value;
                app.signal_frequency= app.Initfreq.Value;
            elseif not(app.Enableramp.Value)
                app.Initfreq.Enable=false;
                app.rampfreq.Enable=false;
                app.rampfreqslider.Enable=false;
                app.Ramp_rate = 0;
                
                if app.f0.Value == "Frequency (Hz)"
                    app.signal_frequency = app.f0value.Value;                         %Signal frequency
                end
                if app.f0.Value == "Period (s)"
                    app.signal_frequency = 1/app.f0value.Value;                         %Signal frequency
                end
                app.rampfreqslider.Limits=[-2 2];
            end
            
            UpdateProperties(app);
        end

        % Value changed function: rampfreq
        function rampfreqValueChanged(app, event)
            app.Ramp_rate = app.rampfreq.Value;
            
            if app.rampfreq.Value > 2
                app.rampfreqslider.Limits=[-2 app.rampfreq.Value];
            end
            
            if app.rampfreq.Value < -2
                app.rampfreqslider.Limits=[app.rampfreq.Value 2];
            end
            
            app.rampfreqslider.Value = app.rampfreq.Value;
            
            UpdateProperties(app);
        end

        % Value changing function: rampfreqslider
        function rampfreqsliderValueChanging(app, event)
            app.rampfreq.Value = event.Value;
            app.Ramp_rate = event.Value;
            UpdateProperties(app);
        end

        % Value changed function: Initfreq
        function InitfreqValueChanged(app, event)
            app.signal_frequency = app.Initfreq.Value;
            UpdateProperties(app);
        end

        % Value changed function: EnableStep
        function EnableStepValueChanged(app, event)

            if app.EnableStep.Value
               app.stepinstantslider.Enable=true;
               app.stepinstant.Enable=true;
               app.kxstep.Enable=true;
               app.kastep.Enable=true;
               app.kxs=app.kxstep.Value/100;
               app.kas=app.kastep.Value;
            elseif not(app.EnableStep.Value)
               app.stepinstantslider.Enable=false;
               app.stepinstant.Enable=false;
               app.kxstep.Enable=false;
               app.kastep.Enable=false;
               app.kxs=0;
               app.kas=0;
               app.stepinstantslider.Limits=[0 0.5];
            end
            UpdateProperties(app);
        end

        % Value changed function: kastep
        function kastepValueChanged(app, event)
            app.kas=app.kastep.Value;
            UpdateProperties(app);
        end

        % Value changed function: kxstep
        function kxstepValueChanged(app, event)
            app.kxs=app.kxstep.Value/100;
            UpdateProperties(app);
        end

        % Value changing function: stepinstantslider
        function stepinstantsliderValueChanging(app, event)
            app.stepinstant.Value = event.Value;
            app.step_instant = event.Value;
            UpdateProperties(app);
            
            if app.step_instant <= 0.5
                app.stepinstantslider.Limits=[0 0.5];
            end
        end

        % Value changed function: stepinstant
        function stepinstantValueChanged(app, event)
            app.step_instant = app.stepinstant.Value;
            
            
            if app.step_instant > 0.5
                app.stepinstantslider.Limits=[0 app.NumberofCycles.Value/app.signal_frequency];
                %app.UIAxes.XLim=[0 app.NumberofCycles.Value/app.signal_frequency];
            end
            
            app.stepinstantslider.Value = app.stepinstant.Value;
            UpdateProperties(app);
        end

        % Button pushed function: GenerateButton
        function GenerateButtonPushed(app, event)
            T = table(app.t',app.finalsignal','VariableNames',{'Time','Measurement'});
            writetable(T,'Raw_data.csv')
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create PMUDev and hide until all components are created
            app.PMUDev = uifigure('Visible', 'off');
            app.PMUDev.Color = [0.8 0.8 0.8];
            app.PMUDev.Position = [100 100 1054 577];
            app.PMUDev.Name = 'UI Figure';
            app.PMUDev.Resize = 'off';

            % Create Tabs
            app.Tabs = uitabgroup(app.PMUDev);
            app.Tabs.Position = [1 1 1054 528];

            % Create SteadyState
            app.SteadyState = uitab(app.Tabs);
            app.SteadyState.Title = 'Signal Generation';
            app.SteadyState.BackgroundColor = [0.902 0.902 0.902];

            % Create UIAxes
            app.UIAxes = uiaxes(app.SteadyState);
            title(app.UIAxes, 'Output Signal')
            xlabel(app.UIAxes, 't (sec)')
            ylabel(app.UIAxes, ' x(t) (Volts)')
            app.UIAxes.AmbientLightColor = [0.502 0.502 0.502];
            app.UIAxes.XLim = [0 1];
            app.UIAxes.XGrid = 'on';
            app.UIAxes.YGrid = 'on';
            app.UIAxes.ColorOrder = [0.2314 0.2314 1;0.851 0.3294 0.102;0.9294 0.6941 0.1255;0.4941 0.1843 0.5569;0.4667 0.6745 0.1882;0.302 0.749 0.9294;0.6353 0.0784 0.1843];
            app.UIAxes.GridColor = [0.8 0.8 0.8];
            app.UIAxes.MinorGridColor = [0.149 0.149 0.149];
            app.UIAxes.Box = 'on';
            app.UIAxes.Position = [272 149 759 330];

            % Create SignalPanel
            app.SignalPanel = uipanel(app.SteadyState);
            app.SignalPanel.Title = 'Signal ';
            app.SignalPanel.Position = [27 340 233 142];

            % Create f0
            app.f0 = uidropdown(app.SignalPanel);
            app.f0.Items = {'Frequency (Hz)', 'Period (s)', '', ''};
            app.f0.ValueChangedFcn = createCallbackFcn(app, @f0ValueChanged, true);
            app.f0.Position = [9 62 99 22];
            app.f0.Value = 'Frequency (Hz)';

            % Create phase
            app.phase = uidropdown(app.SignalPanel);
            app.phase.Items = {'Phase shift (rad)', 'Phase shift (degree)', ''};
            app.phase.ValueChangedFcn = createCallbackFcn(app, @phaseValueChanged, true);
            app.phase.Position = [9 35 99 22];
            app.phase.Value = 'Phase shift (rad)';

            % Create amp
            app.amp = uidropdown(app.SignalPanel);
            app.amp.Items = {'Amplitude Max (Volts)', 'RMS(Volts)', 'Peak to Peak (Volts)'};
            app.amp.ValueChangedFcn = createCallbackFcn(app, @ampValueChanged, true);
            app.amp.Position = [9 8 99 22];
            app.amp.Value = 'RMS(Volts)';

            % Create f0value
            app.f0value = uieditfield(app.SignalPanel, 'numeric');
            app.f0value.Limits = [0 Inf];
            app.f0value.ValueChangedFcn = createCallbackFcn(app, @f0valueValueChanged, true);
            app.f0value.Position = [122 62 100 22];
            app.f0value.Value = 50;

            % Create phasevalue
            app.phasevalue = uieditfield(app.SignalPanel, 'numeric');
            app.phasevalue.ValueChangedFcn = createCallbackFcn(app, @phasevalueValueChanged, true);
            app.phasevalue.Position = [122 35 100 22];

            % Create ampvalue
            app.ampvalue = uieditfield(app.SignalPanel, 'numeric');
            app.ampvalue.Limits = [0 Inf];
            app.ampvalue.ValueChangedFcn = createCallbackFcn(app, @ampvalueValueChanged, true);
            app.ampvalue.Position = [122 8 100 22];
            app.ampvalue.Value = 10;

            % Create SamplesEditFieldLabel
            app.SamplesEditFieldLabel = uilabel(app.SignalPanel);
            app.SamplesEditFieldLabel.HorizontalAlignment = 'right';
            app.SamplesEditFieldLabel.Position = [54 91 54 22];
            app.SamplesEditFieldLabel.Text = 'Sample/s';

            % Create fsvalue
            app.fsvalue = uieditfield(app.SignalPanel, 'numeric');
            app.fsvalue.Limits = [1 Inf];
            app.fsvalue.RoundFractionalValues = 'on';
            app.fsvalue.ValueDisplayFormat = '%.0f';
            app.fsvalue.ValueChangedFcn = createCallbackFcn(app, @fsvalueValueChanged, true);
            app.fsvalue.Position = [121 91 100 22];
            app.fsvalue.Value = 6400;

            % Create HarmonicsPanel
            app.HarmonicsPanel = uipanel(app.SteadyState);
            app.HarmonicsPanel.Title = 'Harmonics';
            app.HarmonicsPanel.Position = [27 147 233 183];

            % Create harmode
            app.harmode = uidropdown(app.HarmonicsPanel);
            app.harmode.Items = {'None', 'Up to', 'Random', 'One'};
            app.harmode.ValueChangedFcn = createCallbackFcn(app, @harmodeValueChanged, true);
            app.harmode.Position = [9 126 100 22];
            app.harmode.Value = 'None';

            % Create harmorder
            app.harmorder = uieditfield(app.HarmonicsPanel, 'numeric');
            app.harmorder.Limits = [2 100];
            app.harmorder.RoundFractionalValues = 'on';
            app.harmorder.ValueDisplayFormat = '%.0f';
            app.harmorder.ValueChangedFcn = createCallbackFcn(app, @harmorderValueChanged, true);
            app.harmorder.Position = [119 126 100 22];
            app.harmorder.Value = 50;

            % Create OrderSliderLabel
            app.OrderSliderLabel = uilabel(app.HarmonicsPanel);
            app.OrderSliderLabel.HorizontalAlignment = 'right';
            app.OrderSliderLabel.Position = [12 29 34 22];
            app.OrderSliderLabel.Text = 'Order';

            % Create orderslider
            app.orderslider = uislider(app.HarmonicsPanel);
            app.orderslider.Limits = [2 100];
            app.orderslider.ValueChangingFcn = createCallbackFcn(app, @ordersliderValueChanging, true);
            app.orderslider.Position = [57 38 157 3];
            app.orderslider.Value = 2;

            % Create Max10nEditFieldLabel
            app.Max10nEditFieldLabel = uilabel(app.HarmonicsPanel);
            app.Max10nEditFieldLabel.HorizontalAlignment = 'right';
            app.Max10nEditFieldLabel.Position = [120 57 58 22];
            app.Max10nEditFieldLabel.Text = 'Max 10^n';

            % Create Maxfreq
            app.Maxfreq = uieditfield(app.HarmonicsPanel, 'numeric');
            app.Maxfreq.Position = [193 57 27 22];
            app.Maxfreq.Value = 3;

            % Create Frequencyrange_______________________Label
            app.Frequencyrange_______________________Label = uilabel(app.HarmonicsPanel);
            app.Frequencyrange_______________________Label.FontSize = 11;
            app.Frequencyrange_______________________Label.FontColor = [0.502 0.502 0.502];
            app.Frequencyrange_______________________Label.Position = [14 78 212 22];
            app.Frequencyrange_______________________Label.Text = 'Frequency range_______________________';

            % Create Min10nEditFieldLabel
            app.Min10nEditFieldLabel = uilabel(app.HarmonicsPanel);
            app.Min10nEditFieldLabel.HorizontalAlignment = 'right';
            app.Min10nEditFieldLabel.Position = [15 57 54 22];
            app.Min10nEditFieldLabel.Text = 'Min 10^n';

            % Create Minfreq
            app.Minfreq = uieditfield(app.HarmonicsPanel, 'numeric');
            app.Minfreq.ValueChangedFcn = createCallbackFcn(app, @MinfreqValueChanged, true);
            app.Minfreq.Position = [84 57 26 22];
            app.Minfreq.Value = 2;

            % Create MagtitudeEditFieldLabel
            app.MagtitudeEditFieldLabel = uilabel(app.HarmonicsPanel);
            app.MagtitudeEditFieldLabel.HorizontalAlignment = 'right';
            app.MagtitudeEditFieldLabel.Position = [37 96 72 22];
            app.MagtitudeEditFieldLabel.Text = 'Magtitude %';

            % Create harmag
            app.harmag = uieditfield(app.HarmonicsPanel, 'numeric');
            app.harmag.Limits = [0 100];
            app.harmag.ValueChangedFcn = createCallbackFcn(app, @harmagValueChanged, true);
            app.harmag.Position = [119 96 100 22];
            app.harmag.Value = 10;

            % Create NoisePanel
            app.NoisePanel = uipanel(app.SteadyState);
            app.NoisePanel.Title = 'Noise';
            app.NoisePanel.Position = [27 25 233 113];

            % Create noisemode
            app.noisemode = uidropdown(app.NoisePanel);
            app.noisemode.Items = {'Gaussian (%)'};
            app.noisemode.Position = [11 61 100 22];
            app.noisemode.Value = 'Gaussian (%)';

            % Create MaxSliderLabel
            app.MaxSliderLabel = uilabel(app.NoisePanel);
            app.MaxSliderLabel.HorizontalAlignment = 'right';
            app.MaxSliderLabel.Position = [11 35 47 22];
            app.MaxSliderLabel.Text = 'Max (%)';

            % Create noiseslider
            app.noiseslider = uislider(app.NoisePanel);
            app.noiseslider.ValueChangingFcn = createCallbackFcn(app, @noisesliderValueChanging, true);
            app.noiseslider.Position = [72 45 142 3];

            % Create noisemag
            app.noisemag = uieditfield(app.NoisePanel, 'numeric');
            app.noisemag.ValueDisplayFormat = '%.4f';
            app.noisemag.Position = [119 61 100 22];

            % Create GenerateDataPanel
            app.GenerateDataPanel = uipanel(app.SteadyState);
            app.GenerateDataPanel.Title = 'Generate Data';
            app.GenerateDataPanel.Position = [931 22 100 113];

            % Create NCyclesLabel
            app.NCyclesLabel = uilabel(app.GenerateDataPanel);
            app.NCyclesLabel.HorizontalAlignment = 'right';
            app.NCyclesLabel.Position = [28 65 52 22];
            app.NCyclesLabel.Text = 'N Cycles';

            % Create NumberofCycles
            app.NumberofCycles = uieditfield(app.GenerateDataPanel, 'numeric');
            app.NumberofCycles.Limits = [0 Inf];
            app.NumberofCycles.ValueDisplayFormat = '%.0f';
            app.NumberofCycles.ValueChangedFcn = createCallbackFcn(app, @NumberofCyclesValueChanged, true);
            app.NumberofCycles.Position = [22 36 63 22];
            app.NumberofCycles.Value = 75;

            % Create GenerateButton
            app.GenerateButton = uibutton(app.GenerateDataPanel, 'push');
            app.GenerateButton.ButtonPushedFcn = createCallbackFcn(app, @GenerateButtonPushed, true);
            app.GenerateButton.Position = [22 7 63 23];
            app.GenerateButton.Text = 'Generate';

            % Create ModulationPanel
            app.ModulationPanel = uipanel(app.SteadyState);
            app.ModulationPanel.Title = 'Modulation';
            app.ModulationPanel.Position = [272 25 206 113];

            % Create kaEditFieldLabel
            app.kaEditFieldLabel = uilabel(app.ModulationPanel);
            app.kaEditFieldLabel.HorizontalAlignment = 'right';
            app.kaEditFieldLabel.Position = [15 11 37 22];
            app.kaEditFieldLabel.Text = 'ka (%)';

            % Create kafield
            app.kafield = uieditfield(app.ModulationPanel, 'numeric');
            app.kafield.ValueChangedFcn = createCallbackFcn(app, @kafieldValueChanged, true);
            app.kafield.Position = [61 11 39 22];
            app.kafield.Value = 10;

            % Create kxEditFieldLabel
            app.kxEditFieldLabel = uilabel(app.ModulationPanel);
            app.kxEditFieldLabel.HorizontalAlignment = 'right';
            app.kxEditFieldLabel.Position = [109 11 37 22];
            app.kxEditFieldLabel.Text = 'kx (%)';

            % Create kxfield
            app.kxfield = uieditfield(app.ModulationPanel, 'numeric');
            app.kxfield.ValueChangedFcn = createCallbackFcn(app, @kxfieldValueChanged, true);
            app.kxfield.Position = [157 11 37 22];
            app.kxfield.Value = 10;

            % Create FreqHzEditFieldLabel
            app.FreqHzEditFieldLabel = uilabel(app.ModulationPanel);
            app.FreqHzEditFieldLabel.HorizontalAlignment = 'right';
            app.FreqHzEditFieldLabel.Position = [2 51 51 22];
            app.FreqHzEditFieldLabel.Text = 'Freq (Hz)';

            % Create modfreq
            app.modfreq = uieditfield(app.ModulationPanel, 'numeric');
            app.modfreq.Limits = [0 Inf];
            app.modfreq.ValueDisplayFormat = '%.2f';
            app.modfreq.ValueChangedFcn = createCallbackFcn(app, @modfreqValueChanged, true);
            app.modfreq.Position = [61 51 39 22];
            app.modfreq.Value = 3;

            % Create modfreqslider
            app.modfreqslider = uislider(app.ModulationPanel);
            app.modfreqslider.Limits = [0 6];
            app.modfreqslider.ValueChangingFcn = createCallbackFcn(app, @modfreqsliderValueChanging, true);
            app.modfreqslider.Position = [117 67 75 3];

            % Create EnableMod
            app.EnableMod = uicheckbox(app.ModulationPanel);
            app.EnableMod.ValueChangedFcn = createCallbackFcn(app, @EnableModValueChanged, true);
            app.EnableMod.Text = 'Enable';
            app.EnableMod.Position = [6 71 57 22];

            % Create THDTotalHarmonicDistortionEditFieldLabel
            app.THDTotalHarmonicDistortionEditFieldLabel = uilabel(app.SteadyState);
            app.THDTotalHarmonicDistortionEditFieldLabel.HorizontalAlignment = 'right';
            app.THDTotalHarmonicDistortionEditFieldLabel.Position = [318 427 174 22];
            app.THDTotalHarmonicDistortionEditFieldLabel.Text = 'THD (Total Harmonic Distortion): ';

            % Create THD
            app.THD = uieditfield(app.SteadyState, 'numeric');
            app.THD.ValueDisplayFormat = '%.2f';
            app.THD.Editable = 'off';
            app.THD.Position = [496 427 49 22];

            % Create LinearFrequencyRampPanel
            app.LinearFrequencyRampPanel = uipanel(app.SteadyState);
            app.LinearFrequencyRampPanel.Title = 'Linear Frequency Ramp';
            app.LinearFrequencyRampPanel.Position = [491 23 206 113];

            % Create InitialFrequencyHzLabel
            app.InitialFrequencyHzLabel = uilabel(app.LinearFrequencyRampPanel);
            app.InitialFrequencyHzLabel.HorizontalAlignment = 'right';
            app.InitialFrequencyHzLabel.Position = [11 14 111 22];
            app.InitialFrequencyHzLabel.Text = 'Initial Frequency (Hz)';

            % Create Initfreq
            app.Initfreq = uieditfield(app.LinearFrequencyRampPanel, 'numeric');
            app.Initfreq.ValueChangedFcn = createCallbackFcn(app, @InitfreqValueChanged, true);
            app.Initfreq.Position = [133 13 45 22];
            app.Initfreq.Value = 50;

            % Create RfHzsLabel
            app.RfHzsLabel = uilabel(app.LinearFrequencyRampPanel);
            app.RfHzsLabel.HorizontalAlignment = 'right';
            app.RfHzsLabel.Position = [3 51 50 22];
            app.RfHzsLabel.Text = 'Rf (Hz/s)';

            % Create rampfreq
            app.rampfreq = uieditfield(app.LinearFrequencyRampPanel, 'numeric');
            app.rampfreq.ValueDisplayFormat = '%.2f';
            app.rampfreq.ValueChangedFcn = createCallbackFcn(app, @rampfreqValueChanged, true);
            app.rampfreq.Position = [61 51 39 22];
            app.rampfreq.Value = 1;

            % Create rampfreqslider
            app.rampfreqslider = uislider(app.LinearFrequencyRampPanel);
            app.rampfreqslider.Limits = [-2 2];
            app.rampfreqslider.ValueChangingFcn = createCallbackFcn(app, @rampfreqsliderValueChanging, true);
            app.rampfreqslider.Position = [117 67 75 3];

            % Create Enableramp
            app.Enableramp = uicheckbox(app.LinearFrequencyRampPanel);
            app.Enableramp.ValueChangedFcn = createCallbackFcn(app, @EnablerampValueChanged, true);
            app.Enableramp.Text = 'Enable';
            app.Enableramp.Position = [6 71 57 22];

            % Create StepChangePanel
            app.StepChangePanel = uipanel(app.SteadyState);
            app.StepChangePanel.Title = 'Step Change';
            app.StepChangePanel.Position = [710 23 206 113];

            % Create karadLabel
            app.karadLabel = uilabel(app.StepChangePanel);
            app.karadLabel.HorizontalAlignment = 'right';
            app.karadLabel.Position = [7 11 45 22];
            app.karadLabel.Text = 'ka (rad)';

            % Create kastep
            app.kastep = uieditfield(app.StepChangePanel, 'numeric');
            app.kastep.ValueChangedFcn = createCallbackFcn(app, @kastepValueChanged, true);
            app.kastep.Position = [61 11 39 22];

            % Create kxEditFieldLabel_2
            app.kxEditFieldLabel_2 = uilabel(app.StepChangePanel);
            app.kxEditFieldLabel_2.HorizontalAlignment = 'right';
            app.kxEditFieldLabel_2.Position = [109 11 37 22];
            app.kxEditFieldLabel_2.Text = 'kx (%)';

            % Create kxstep
            app.kxstep = uieditfield(app.StepChangePanel, 'numeric');
            app.kxstep.ValueChangedFcn = createCallbackFcn(app, @kxstepValueChanged, true);
            app.kxstep.Position = [157 11 37 22];
            app.kxstep.Value = 10;

            % Create InstantsLabel
            app.InstantsLabel = uilabel(app.StepChangePanel);
            app.InstantsLabel.HorizontalAlignment = 'right';
            app.InstantsLabel.Position = [0 51 58 22];
            app.InstantsLabel.Text = ' Instant(s) ';

            % Create stepinstant
            app.stepinstant = uieditfield(app.StepChangePanel, 'numeric');
            app.stepinstant.Limits = [0 Inf];
            app.stepinstant.ValueDisplayFormat = '%.2f';
            app.stepinstant.ValueChangedFcn = createCallbackFcn(app, @stepinstantValueChanged, true);
            app.stepinstant.Position = [61 51 39 22];
            app.stepinstant.Value = 0.25;

            % Create stepinstantslider
            app.stepinstantslider = uislider(app.StepChangePanel);
            app.stepinstantslider.Limits = [0 0.5];
            app.stepinstantslider.ValueChangingFcn = createCallbackFcn(app, @stepinstantsliderValueChanging, true);
            app.stepinstantslider.Position = [117 67 75 3];

            % Create EnableStep
            app.EnableStep = uicheckbox(app.StepChangePanel);
            app.EnableStep.ValueChangedFcn = createCallbackFcn(app, @EnableStepValueChanged, true);
            app.EnableStep.Text = 'Enable';
            app.EnableStep.Position = [6 71 57 22];

            % Create IEEEIEC6025511812018SteadyStateTab
            app.IEEEIEC6025511812018SteadyStateTab = uitab(app.Tabs);
            app.IEEEIEC6025511812018SteadyStateTab.Title = 'IEEE/IEC 60255-118-1-2018 Steady-State';

            % Create HTML
            app.HTML = uihtml(app.IEEEIEC6025511812018SteadyStateTab);
            app.HTML.HTMLSource = '<table style="height: 1688px; border-color: black; width: 565px;" border="black" width="565"><tbody><tr><td style="width: 556px;" colspan="6"><h3><strong>Steady-state synchrophasor measurement requirements</strong></h3></td></tr><tr><td style="width: 149.6px;" rowspan="3">Influence quantity</td><td style="width: 83.2px;" rowspan="3">Reference condition</td><td style="width: 312px;" colspan="4">Minimum range of influence quantity over which PMU shall be within given TVE limit</td></tr><tr><td style="width: 147.2px;" colspan="2">P class</td><td style="width: 159.2px;" colspan="2">M class</td></tr><tr><td style="width: 96.8px;">Range</td><td style="width: 44.8px;">Max TVE (%)</td><td style="width: 107.2px;">Range</td><td style="width: 46.4px;">Max TVE (%)</td></tr><tr><td style="width: 149.6px;">Signal frequency range―f<sub>dev<br /></sub>(test applied nominal<br />+ deviation: f<sub>0</sub> &plusmn; f<sub>dev</sub>)</td><td style="width: 83.2px;"><sup>F</sup>nominal<br />(f<sub>0</sub>)</td><td style="width: 96.8px;">&plusmn; 2.0 Hz</td><td style="width: 44.8px;">1</td><td style="width: 107.2px;">&plusmn; 2.0 Hz for F<sub>s</sub>&lt;10<br />&plusmn; F<sub>s</sub>/5 for 10 &le; F<sub>s</sub> &lt; 25<br />&plusmn; 5.0 Hz for F<sub>s</sub> &ge;25</td><td style="width: 46.4px;">1</td></tr><tr><td style="width: 556px;" colspan="6">The signal frequency range tests above are to be performed over the given ranges and meet the given requirements at three temperatures: T = nominal (~23 &ordm;C), T = 0 &ordm;C, and T = 50 &ordm;C</td></tr><tr><td style="width: 149.6px;">Signal magnitude―<br />Voltage</td><td style="width: 83.2px;">100%<br />rated</td><td style="width: 96.8px;">80% to 120%<br />rated</td><td style="width: 44.8px;">1</td><td style="width: 107.2px;">10% to 120% rated</td><td style="width: 46.4px;">1</td></tr><tr><td style="width: 149.6px;">Signal magnitude― Current</td><td style="width: 83.2px;">100%<br />rated</td><td style="width: 96.8px;">10% to 200%<br />rated</td><td style="width: 44.8px;">1</td><td style="width: 107.2px;">10% to 200% rated</td><td style="width: 46.4px;">1</td></tr><tr><td style="width: 149.6px;">Phase angle with<br />| f<sub>in</sub> &ndash; f<sub>0</sub> | &lt;0.25 Hz (See NOTE 1)</td><td style="width: 83.2px;">Constant<br />or slowly varying<br />angle</td><td style="width: 96.8px;">&plusmn;p radians</td><td style="width: 44.8px;">1</td><td style="width: 107.2px;">&plusmn;p radians</td><td style="width: 46.4px;">1</td></tr><tr><td style="width: 149.6px;">Harmonic distortion (single harmonic)</td><td style="width: 83.2px;">&lt;0.2% (THD)</td><td style="width: 96.8px;">1%, each<br />harmonic up to 50th</td><td style="width: 44.8px;">1</td><td style="width: 107.2px;">10%, each harmonic up to 50th</td><td style="width: 46.4px;">1</td></tr><tr><td style="width: 149.6px;">Out-of-band<br />interference as described below<br />(See NOTES 2 and 3)</td><td style="width: 83.2px;">&lt;0.2% of<br />input<br />signal magnitude</td><td style="width: 96.8px;">&nbsp;</td><td style="width: 44.8px;">None</td><td style="width: 107.2px;">10% of input signal<br />magnitude for F<sub>s</sub> &ge; 10. No requirement for<br />F<sub>s</sub> &lt; 10.</td><td style="width: 46.4px;">1.3</td></tr><tr><td style="width: 556px;" colspan="6">Out-of-band interference testing: The passband at each reporting rate is defined as |f &ndash; f<sub>0</sub> | &lt; F<sub>s</sub> /2. An interfering signal outside the filter passband is a signal at frequency f where: |f &ndash; f<sub>0</sub> | &ge; F<sub>s</sub> /2<br />For test the input test signal frequency f<sub>in</sub> is varied between f<sub>0</sub> and &plusmn; (10%) of the Nyquist frequency of the reporting rate.<br />That is: f<sub>0</sub> &ndash; 0.1 (F<sub>s</sub> /2) &le; f<sub>in</sub> &le; f<sub>0</sub> + 0.1 (F<sub>s</sub>/2) where<br />F<sub>s</sub> = phasor reporting rate<br />f<sub>0</sub> = nominal system frequency<br />f<sub>in</sub> = fundamental frequency of the input test signal</td></tr><tr><td style="width: 556px;" colspan="6">NOTE 1&mdash;The&nbsp;&nbsp; phase&nbsp;&nbsp; angle&nbsp;&nbsp; test&nbsp;&nbsp; can&nbsp;&nbsp; be&nbsp;&nbsp; performed&nbsp;&nbsp; with&nbsp;&nbsp; the&nbsp;&nbsp; input&nbsp;&nbsp; frequency&nbsp;&nbsp; f<sub>in</sub>&nbsp;&nbsp; offset&nbsp;&nbsp; from&nbsp;&nbsp; f<sub>0</sub>&nbsp;&nbsp; where<br />|&nbsp; f<sub>in</sub>&nbsp; &ndash;&nbsp; f<sub>0</sub>&nbsp; |&lt;0.25&nbsp; Hz.&nbsp; This&nbsp; provides&nbsp; a&nbsp; slowly&nbsp; varying&nbsp; phase&nbsp; angle&nbsp; that&nbsp; simplifies&nbsp; compliance&nbsp; verification&nbsp; without causing significant other effects.<br />NOTE 2&mdash;A signal whose frequency exceeds the Nyquist rate for the reporting rate F<sub>s</sub> can alias into the passband. The&nbsp; test&nbsp; signal&nbsp; described&nbsp; for&nbsp; the&nbsp; out-of-band&nbsp; interference&nbsp; test&nbsp; verifies&nbsp; the&nbsp; effectiveness&nbsp; of&nbsp; the&nbsp; PMU&nbsp; anti-alias filtering.&nbsp; The&nbsp; test&nbsp; signal&nbsp; shall&nbsp; include&nbsp; those&nbsp; frequencies&nbsp; outside&nbsp; of&nbsp; the&nbsp; bandwidth&nbsp; specified&nbsp; above&nbsp; that&nbsp; cause&nbsp; the greatest TVE.<br />NOTE 3&mdash;Compliance with out-of-band rejection can be confirmed by using a single frequency sinusoid added to the&nbsp; fundamental&nbsp; power&nbsp; signal&nbsp; at&nbsp; the&nbsp; required&nbsp; magnitude&nbsp; level. The&nbsp; signal&nbsp; frequency&nbsp; is&nbsp; varied&nbsp; over&nbsp; a&nbsp; range&nbsp; from below the passband (at least down to 10 Hz) and from above the passband up to the second harmonic (2 &times; f<sub>0</sub>). If the positive sequence measurement is being tested, the interfering signal is a positive sequence.</td></tr><tr><td style="width: 556px;" colspan="6"><h3><strong>Steady-state frequency and ROCOF measurement requirements</strong></h3></td></tr><tr><td style="width: 149.6px;" rowspan="2">Influence quantity</td><td style="width: 83.2px;" rowspan="2">Reference condition</td><td style="width: 312px;" colspan="4">Error requirements for compliance</td></tr><tr><td style="width: 147.2px;" colspan="2">P class</td><td style="width: 159.2px;" colspan="2">M class</td></tr><tr><td style="width: 149.6px;" rowspan="3">Signal frequency</td><td style="width: 83.2px;" rowspan="3">Frequency = f<sub>0<br /></sub><sup>(</sup><sup>f</sup>nominal<sup>) </sup>Phase angle constant</td><td style="width: 147.2px;" colspan="2">Range: f<sub>0</sub> &plusmn; 2.0</td><td style="width: 159.2px;" colspan="2">Range:<br />f<sub>0</sub> &plusmn; 2.0 Hz for F<sub>s</sub> &le; 10<br />&plusmn; F<sub>s</sub>/5 for 10 &le; F<sub>s</sub> &lt; 25<br />&plusmn; 5.0 Hz for F<sub>s</sub> &ge;25</td></tr><tr><td style="width: 96.8px;">Max FE</td><td style="width: 44.8px;">Max<br />RFE</td><td style="width: 107.2px;">Max FE</td><td style="width: 46.4px;">Max<br />RFE</td></tr><tr><td style="width: 96.8px;">0.005 Hz</td><td style="width: 44.8px;">0.01<br />Hz/s</td><td style="width: 107.2px;">0.005 Hz</td><td style="width: 46.4px;">0.01<br />Hz/s</td></tr><tr><td style="width: 149.6px;" rowspan="4">Harmonic distortion (same as Table 3) (single harmonic)</td><td style="width: 83.2px;" rowspan="2">&lt;0.2% THD</td><td style="width: 147.2px;" colspan="2">1% each harmonic up to 50th</td><td style="width: 159.2px;" colspan="2">10% each harmonic up to 50th</td></tr><tr><td style="width: 96.8px;">Max FE</td><td style="width: 44.8px;">Max<br />RFE</td><td style="width: 107.2px;">Max FE</td><td style="width: 46.4px;">Max<br />RFE</td></tr><tr><td style="width: 83.2px;">F<sub>s</sub> &gt; 20</td><td style="width: 96.8px;">0.005 Hz</td><td style="width: 44.8px;">0.01<br />Hz/s</td><td style="width: 107.2px;">0.025 Hz</td><td style="width: 46.4px;">6 Hz/s</td></tr><tr><td style="width: 83.2px;">F<sub>s</sub> &le; 20</td><td style="width: 96.8px;">0.005 Hz</td><td style="width: 44.8px;">0.01<br />Hz/s</td><td style="width: 107.2px;">0.005 Hz</td><td style="width: 46.4px;">2 Hz/s</td></tr><tr><td style="width: 149.6px;" rowspan="3">Out-of-band<br />interference (same as Table 3)</td><td style="width: 83.2px;" rowspan="3">&lt;0.2% of input<br />signal magnitude</td><td style="width: 147.2px;" colspan="2">No requirements</td><td style="width: 159.2px;" colspan="2">Interfering signal 10% of signal<br />magnitude</td></tr><tr><td style="width: 96.8px;">&nbsp;</td><td style="width: 44.8px;">&nbsp;</td><td style="width: 107.2px;">Max FE</td><td style="width: 46.4px;">Max<br />RFE</td></tr><tr><td style="width: 96.8px;">None</td><td style="width: 44.8px;">None</td><td style="width: 107.2px;">0.01 Hz</td><td style="width: 46.4px;">0.1 Hz/s</td></tr></tbody></table>';
            app.HTML.Position = [15 12 591 483];

            % Create IEEEIEC6025511812018DynamicTab
            app.IEEEIEC6025511812018DynamicTab = uitab(app.Tabs);
            app.IEEEIEC6025511812018DynamicTab.Title = 'IEEE/IEC 60255-118-1-2018 Dynamic';

            % Create HTML2
            app.HTML2 = uihtml(app.IEEEIEC6025511812018DynamicTab);
            app.HTML2.HTMLSource = '<table style="border-color: black; width: 761px;" border="black" width="761"><tbody><tr><td colspan="6" width="441">Synchrophasor measurement bandwidth requirements<br />using modulated test signals</td><td width="64">&nbsp;</td><td width="64">&nbsp;</td><td width="64">&nbsp;</td><td width="64">&nbsp;</td><td width="64">&nbsp;</td></tr><tr><td rowspan="3" width="64">Modulation level</td><td rowspan="3" width="64">Reference condition</td><td colspan="4" width="313">Minimum range of influence quantity over which PMU<br />shall be within given TVE limit</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td colspan="2" width="150">P class</td><td colspan="2" width="163">M class</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td width="86">Range</td><td width="64">Max TVE</td><td width="64">Range</td><td width="99">Max TVE</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td width="64">k<sub>x</sub> = 0.1,<br />ka = 0.1<br />radian</td><td width="64">100% rated signal signal magnitude, fnominal</td><td rowspan="2" width="86">Modulation frequency 0.1 to lesser of Fs/10 or 2 Hz</td><td>3%</td><td rowspan="2" width="64">Modulation frequency 0.1 to lesser of Fs/5 or 5 Hz</td><td>3%</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td width="64">k<sub>x</sub> = 0,<br />ka = 0.1<br />radian</td><td width="64">100% rated</td><td>3%</td><td>3%</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td colspan="6" width="441">Frequency and ROCOF performance requirements under modulation tests</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td colspan="2" rowspan="3" width="128">Modulation level, reference condition, range(use the same modulation levels and ranges under the referenceconditions specified in Table 5)</td><td colspan="4" width="313">Error requirements for compliance</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td colspan="2" width="150">P class</td><td colspan="2" width="163">M class</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td width="86">Max FE</td><td width="64">Max RFE<sup>a</sup></td><td width="64">Max FE</td><td width="99">Max RFE<sup>a</sup></td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td colspan="2" width="128">F<sub>s</sub> &gt; 20</td><td width="86">0.06 Hz</td><td width="64">3 Hz/s</td><td width="64">0.3 Hz</td><td width="99">30 Hz/s</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td colspan="2" width="128">F<sub>s</sub> &le; 20</td><td width="86">0.01 Hz</td><td width="64">0.2 Hz/s</td><td width="64">0.06 Hz</td><td width="99">2 Hz/s</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td colspan="6">Synchrophasor performance requirements under frequency ramp tests</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td rowspan="2" width="64">Test signal</td><td rowspan="2" width="64">Reference condition</td><td colspan="4" width="313">Minimum range of influence quantity over which PMU shall be within given TVE limit</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td width="86">Ramp rate (R<sub>f</sub>) (positive and<br />negative ramp)</td><td width="64">Performance class</td><td width="64">Ramp range</td><td width="99">Max TVE</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td rowspan="2" width="64">Linear frequency ramp</td><td rowspan="2" width="64">100% rated signal magnitude, <sup>&amp; f</sup>nominal <sup>at </sup>start or some point during the test</td><td rowspan="2" width="86">&plusmn; 1.0 Hz/s</td><td width="64">P class</td><td width="64">&plusmn; 2 Hz</td><td>1%</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td width="64">M class</td><td width="64">Lesser of &plusmn; (F<sub>s</sub> /5) or<br />&plusmn; 5 Hz <sup>a</sup></td><td>1%</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td colspan="7" width="505">Frequency and ROCOF performance requirements under frequency ramp tests</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td width="64">Signal specification</td><td width="64">Reference condition</td><td width="86">Transition time</td><td colspan="4" width="291">Error requirements for compliance</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td rowspan="3" width="64">Ramp tests― same as specified in Table 7</td><td rowspan="3" width="64">100% rated signal magnitude and<br />0 radian base angle</td><td rowspan="3" width="86">&plusmn; 2/F<sub>s</sub> for the start and end of ramp</td><td colspan="2" width="128">P class</td><td colspan="2" width="163">M class</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td width="64">Max FE</td><td width="64">Max RFE</td><td width="99">Max FE</td><td width="64">Max RFE</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td width="64">0.01 Hz</td><td width="64">0.1 Hz/s</td><td width="99">0.005 Hz</td><td width="64">0.1 Hz/s</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td colspan="8" width="569">Phasor performance requirements for input step change</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td rowspan="3" width="64">Step change specifica- tion</td><td rowspan="3" width="64">Reference condition</td><td colspan="6" width="441">Maximum response time, delay time, and overshoot</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td colspan="3" width="214">P class</td><td colspan="3" width="227">M class</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td width="86">Response time<br />(s)</td><td width="64">|Delay time|<br />(s)</td><td width="64">Max overshoot/<br />undershoot</td><td width="99">Response time<br />(s)</td><td width="64">|Delay time| (s)</td><td width="64">Max Overshoot/<br />undershoot</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td width="64">Magnitude<br />= &plusmn; 10%, <br />kx = &plusmn; 0.1,<br />ka = 0</td><td width="64">All test conditions nominal at<br />start or end of step</td><td width="86">1.7/f<sub>0</sub></td><td width="64">1/(4 &times; F<sub>s</sub>)</td><td width="64">5% of step magnitude</td><td width="99">See Table 11</td><td width="64">1/(4 &times; Fs)</td><td width="64">10% of step magnitude</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td width="64">Angle &plusmn; 10&deg;, <br />kx = 0, <br />ka = &plusmn; &pi;/18</td><td width="64">All test conditions nominal at<br />start or end of step</td><td width="86">1.7/f<sub>0</sub></td><td width="64">1/(4 &times; F<sub>s</sub>)</td><td width="64">5% of step magnitude</td><td width="99">See Table 11</td><td width="64">1/(4 &times; Fs)</td><td width="64">10% of step magnitude</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td colspan="6" width="441">Frequency and ROCOF performance requirements for input step change</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td rowspan="3" width="64">Signal specification</td><td rowspan="3" width="64">Reference condition</td><td colspan="4" width="313">Maximum response time</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td colspan="2" width="150">P class</td><td colspan="2" width="163">M class</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td width="86">Frequency<br />response time (s)</td><td width="64">ROCOF<br />response time (s)</td><td width="64">Frequency<br />response time (s)</td><td width="99">ROCOF<br />response time (s)</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td width="64">Magnitude<br />test as in Table 9</td><td width="64">Same as in<br />Table 9</td><td width="86">3.5/f<sub>0</sub></td><td width="64">4/f<sub>0</sub></td><td width="64">See Table 11</td><td width="99">See Table 11</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td width="64">Phase test as in Table 9</td><td width="64">Same as in Table 9</td><td width="86">3.5/f<sub>0</sub></td><td width="64">4/f<sub>0</sub></td><td width="64">See Table 11</td><td width="99">See Table 11</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td colspan="11" width="761">Maximum response time in step change test for M class, in seconds</td></tr><tr><td width="64">Reporting rate (F<sub>s</sub>)</td><td>10</td><td>12</td><td>15</td><td>20</td><td>25</td><td>30</td><td>50</td><td>60</td><td width="64">100*</td><td width="64">120*</td></tr><tr><td width="64">Phasor<br />(TVE)</td><td>0.595</td><td>0.493</td><td>0.394</td><td>0.282</td><td>0.231</td><td>0.182</td><td>0.199</td><td>0.079</td><td>0.050</td><td>0.035</td></tr><tr><td width="64">Frequency<br />(FE)</td><td>0.869</td><td>0.737</td><td>0.629</td><td>0.478</td><td>0.328</td><td>0.305</td><td>0.130</td><td>0.120</td><td>0.059</td><td>0.053</td></tr><tr><td width="64">ROCOF<br />(RFE)</td><td>1.038</td><td>0.863</td><td>0.691</td><td>0.520</td><td>0.369</td><td>0.314</td><td>0.134</td><td>0.129</td><td>0.061</td><td>0.056</td></tr><tr><td colspan="11" width="761">* Rates higher than 60 are not required, so this listing is advisory only. Rates even higher will be limited by the measurement window. Rates lower than 10/s are not expected to be used for dynamic measurement and are not included in this table.</td></tr><tr><td colspan="7">Measurement reporting latency</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td colspan="2">Performance class</td><td colspan="5" width="377">Maximum measurement reporting latency<br />(s)</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td colspan="2">P Class</td><td colspan="5">2/ Fs</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td colspan="2">M Class</td><td colspan="5">5/ Fs</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr></tbody></table>';
            app.HTML2.Position = [18 17 790 469];

            % Create Image2
            app.Image2 = uiimage(app.PMUDev);
            app.Image2.ScaleMethod = 'stretch';
            app.Image2.HandleVisibility = 'off';
            app.Image2.BackgroundColor = [1 1 1];
            app.Image2.Position = [2 526 1053 51];
            app.Image2.ImageSource = 'Rectangle smooth.png';

            % Create Image4
            app.Image4 = uiimage(app.PMUDev);
            app.Image4.Position = [0 541 253 23];
            app.Image4.ImageSource = 'PMU Test Signal Generator LOGO.svg';

            % Create Image3
            app.Image3 = uiimage(app.PMUDev);
            app.Image3.Position = [984 521 42 64];
            app.Image3.ImageSource = 'DevPMU logo.svg';

            % Show the figure after all components are created
            app.PMUDev.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = PMU_Signal_Generator_exported

            runningApp = getRunningApp(app);

            % Check for running singleton app
            if isempty(runningApp)

                % Create UIFigure and components
                createComponents(app)

                % Register the app with App Designer
                registerApp(app, app.PMUDev)

                % Execute the startup function
                runStartupFcn(app, @startupFcn)
            else

                % Focus the running singleton app
                figure(runningApp.PMUDev)

                app = runningApp;
            end

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.PMUDev)
        end
    end
end