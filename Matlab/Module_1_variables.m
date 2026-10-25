function interactive_smart_street_sim()
    % MODULE 1 TECHNICAL BASELINE SIMULATION
    
    % --- Dynamic Screen-Aware Main Window ---
    screen_size = get(0, 'ScreenSize'); % [left, bottom, width, height]
    sw = screen_size(3);
    sh = screen_size(4);
    
    % Scale appropriately for 13" laptops and high-DPI scaling
    fig_w = min(1200, round(sw * 0.90));
    fig_h = min(680, round(sh * 0.85));
    fig_x = max(10, round((sw - fig_w) / 2));
    fig_y = max(30, round((sh - fig_h) / 2));

    fig = uifigure('Name', 'Smart Street Module 1: Bio-Retention & Hydraulic Control', ...
                   'Position', [fig_x fig_y fig_w fig_h], ...
                   'Color', [0.93 0.95 0.98]);
                   
    % Top-level responsive grid layout ('1x' used for flexible proportion)
    grid_main = uigridlayout(fig, [1 2]);
    grid_main.ColumnWidth = {360, '1x'};
    grid_main.RowHeight = {'1x'};
    grid_main.Padding = [10 10 10 10];
    grid_main.ColumnSpacing = 10;

    % Reference surface parameters
    pavement_data = struct(...
        'name', {'Asphaltic Street (0.70 - 0.95)', 'Concrete Street (0.80 - 0.95)', 'Brick Street (0.70 - 0.85)', 'Drives and Walks (0.75 - 0.85)'}, ...
        'min',  {0.70, 0.80, 0.70, 0.75}, ...
        'max',  {0.95, 0.95, 0.85, 0.85}, ...
        'default', {0.70, 0.85, 0.75, 0.80});
        
    bioretention_data = struct(...
        'name', {'BSM - Heavy Soil Flat 2% (0.10 - 0.17)', 'BSM - Sandy Soil Flat 2% (0.05 - 0.10)', 'BSM - Sandy Soil Avg 2-7% (0.10 - 0.15)', 'BSM - Heavy Soil Steep 7% (0.15 - 0.20)'}, ...
        'min',  {0.10, 0.05, 0.10, 0.15}, ...
        'max',  {0.17, 0.10, 0.15, 0.20}, ...
        'default', {0.10, 0.05, 0.10, 0.15});
        
    % --- Left Control Panel ---
    panel = uipanel(grid_main, 'Title', 'SIMULATION PARAMETERS', ...
                    'BackgroundColor', [0.97 0.98 0.95], 'Scrollable', 'on');
    panel.Layout.Row = 1;
    panel.Layout.Column = 1;
                    
    % 1. Pavement Controls
    uilabel(panel, 'Text', '1. PAVEMENT SURFACE CHARACTERISTICS', 'Position', [15 1200 320 20], 'FontWeight', 'bold', 'FontColor', [0.10 0.30 0.60]);
    uilabel(panel, 'Text', 'Pavement Surface Type:', 'Position', [15 1172 320 18]);
    drop_pave = uidropdown(panel, 'Items', {pavement_data.name}, 'Position', [15 1145 320 25], 'BackgroundColor', [0.88 0.94 1.00]);
    
    uilabel(panel, 'Text', 'Pavement Runoff Coeff (C_pavement):', 'Position', [15 1115 210 18]);
    lbl_val_Cp = uilabel(panel, 'Text', '0.70', 'Position', [230 1115 105 18], 'FontWeight', 'bold', 'HorizontalAlignment', 'right');
    slider_C_pave = uislider(panel, 'Position', [20 1090 310 3], 'Limits', [0.70 0.95], 'Value', 0.70, 'MajorTicks', 0.70:0.05:0.95);
    
    % 2. Bioretention Controls
    uilabel(panel, 'Text', '2. BIORETENTION MEDIA & SLOPE', 'Position', [15 1030 320 20], 'FontWeight', 'bold', 'FontColor', [0.10 0.50 0.20]);
    uilabel(panel, 'Text', 'Bioretention Surface Type:', 'Position', [15 1002 320 18]);
    drop_bio = uidropdown(panel, 'Items', {bioretention_data.name}, 'Position', [15 975 320 25], 'BackgroundColor', [0.88 0.96 0.88]);
    
    uilabel(panel, 'Text', 'Bioretention Coeff (C_bioretention):', 'Position', [15 945 210 18]);
    lbl_val_Cb = uilabel(panel, 'Text', '0.10', 'Position', [230 945 105 18], 'FontWeight', 'bold', 'HorizontalAlignment', 'right');
    slider_C_bio = uislider(panel, 'Position', [20 920 310 3], 'Limits', [0.05 0.20], 'Value', 0.10, 'MajorTicks', 0.05:0.05:0.20);
    
    % 3. Geometry & Area Controls
    uilabel(panel, 'Text', '3. CATCHMENT GEOMETRY', 'Position', [15 860 320 20], 'FontWeight', 'bold');
    uilabel(panel, 'Text', 'Total Street Area (A_total in m²):', 'Position', [15 832 210 18]);
    lbl_val_Atotal = uilabel(panel, 'Text', '50 m²', 'Position', [230 832 105 18], 'FontWeight', 'bold', 'HorizontalAlignment', 'right');
    slider_Atotal = uislider(panel, 'Position', [20 807 310 3], 'Limits', [10 200], 'Value', 50, 'MajorTicks', [10 50 100 150 200]);
    
    uilabel(panel, 'Text', 'Bioretention Area Share (%):', 'Position', [15 750 210 18]);
    lbl_val_pct = uilabel(panel, 'Text', '20.0 %', 'Position', [230 750 105 18], 'FontWeight', 'bold', 'HorizontalAlignment', 'right');
    slider_pct = uislider(panel, 'Position', [20 725 310 3], 'Limits', [1 50], 'Value', 20, 'MajorTicks', 0:10:50);
    
    % 4. Mean Rainfall Intensity & Time Step Settings
    uilabel(panel, 'Text', '4. STAGE 1: PRECIPITATION & TIME STEP', 'Position', [15 665 320 20], 'FontWeight', 'bold', 'FontColor', [0.80 0.20 0.10]);
    uilabel(panel, 'Text', 'Precipitation Intensity I (mm/hr):', 'Position', [15 637 210 18]);
    lbl_val_I = uilabel(panel, 'Text', '50.0 mm/hr', 'Position', [230 637 105 18], 'FontWeight', 'bold', 'HorizontalAlignment', 'right');
    slider_I = uislider(panel, 'Position', [20 612 310 3], 'Limits', [0 120], 'Value', 50, 'MajorTicks', 0:20:120);
    
    uilabel(panel, 'Text', 'Rain Duration (minutes):', 'Position', [15 555 210 18]);
    lbl_val_dur = uilabel(panel, 'Text', '30 min', 'Position', [230 555 105 18], 'FontWeight', 'bold', 'HorizontalAlignment', 'right');
    slider_dur = uislider(panel, 'Position', [20 530 310 3], 'Limits', [5 90], 'Value', 30, 'MajorTicks', [5 20 40 60 80 90]);
    
    uilabel(panel, 'Text', 'Simulation Time Step dt (seconds):', 'Position', [15 473 210 18]);
    lbl_val_dt = uilabel(panel, 'Text', '1.0 s', 'Position', [230 473 105 18], 'FontWeight', 'bold', 'HorizontalAlignment', 'right');
    slider_dt = uislider(panel, 'Position', [20 448 310 3], 'Limits', [0.1 5.0], 'Value', 1.0, 'MajorTicks', 0.5:1.0:4.5);
    
    % 5. Stage 2 BSM Soil Properties
    uilabel(panel, 'Text', '5. STAGE 2: BSM SOIL PROPERTIES', 'Position', [15 388 320 20], 'FontWeight', 'bold', 'FontColor', [0.40 0.30 0.10]);
    uilabel(panel, 'Text', 'BSM Soil Porosity phi (0.35-0.45):', 'Position', [15 360 210 18]);
    lbl_val_phi = uilabel(panel, 'Text', '0.40', 'Position', [230 360 105 18], 'FontWeight', 'bold', 'HorizontalAlignment', 'right');
    slider_phi = uislider(panel, 'Position', [20 335 310 3], 'Limits', [0.35 0.45], 'Value', 0.40, 'MajorTicks', 0.35:0.025:0.45);
    
    uilabel(panel, 'Text', 'BSM Cond K_sat (mm/hr):', 'Position', [15 278 210 18]);
    lbl_val_ksat = uilabel(panel, 'Text', '150 mm/hr', 'Position', [230 278 105 18], 'FontWeight', 'bold', 'HorizontalAlignment', 'right');
    slider_ksat = uislider(panel, 'Position', [20 253 310 3], 'Limits', [100 300], 'Value', 150, 'MajorTicks', 100:50:300);
    
    % 6. Stage 3 Actuator Control Settings
    uilabel(panel, 'Text', '6. STAGE 3: ACTUATOR GATE CONFIG', 'Position', [15 193 320 20], 'FontWeight', 'bold', 'FontColor', [0.50 0.10 0.50]);
    uilabel(panel, 'Text', 'Trigger Puddle Depth H (mm):', 'Position', [15 165 210 18]);
    lbl_val_Htrig = uilabel(panel, 'Text', '50 mm', 'Position', [230 165 105 18], 'FontWeight', 'bold', 'HorizontalAlignment', 'right');
    slider_Htrig = uislider(panel, 'Position', [20 140 310 3], 'Limits', [10 100], 'Value', 50, 'MajorTicks', 10:20:90);
    
    % Summary Label at bottom with sufficient clearance
    lbl_summary = uilabel(panel, 'Position', [15 15 330 80], 'Text', '', 'WordWrap', 'on', 'FontSize', 9.5, 'FontWeight', 'bold');
    
    % --- Tab Container & Dynamic Grids ---
    tabgroup = uitabgroup(grid_main);
    tabgroup.Layout.Row = 1;
    tabgroup.Layout.Column = 2;
    
    % TAB 1: C_composite Optimization
    tab1 = uitab(tabgroup, 'Title', 'C_composite Optimization');
    grid_tab1 = uigridlayout(tab1, [1 1]);
    grid_tab1.Padding = [10 10 10 10];
    ax_comp = uiaxes(grid_tab1);
    ax_comp.Layout.Row = 1;
    ax_comp.Layout.Column = 1;
    
    % TAB 2: Stage 1 Runoff & Stage 2 Soil Saturation
    tab2 = uitab(tabgroup, 'Title', 'Stage 1 Runoff & Stage 2 Soil Saturation (VWC)');
    grid_tab2 = uigridlayout(tab2, [2 1]);
    grid_tab2.RowHeight = {'1x', '1x'};
    grid_tab2.Padding = [10 10 10 10];
    grid_tab2.RowSpacing = 10;
    ax_vol  = uiaxes(grid_tab2);
    ax_vol.Layout.Row = 1;
    ax_vol.Layout.Column = 1;
    ax_soil = uiaxes(grid_tab2);
    ax_soil.Layout.Row = 2;
    ax_soil.Layout.Column = 1;
    
    % TAB 3: Stage 2 Puddle Depth & Stage 3 Gate Actuation
    tab3 = uitab(tabgroup, 'Title', 'Stage 2 Puddle Depth & Stage 3 Gate Actuation');
    grid_tab3 = uigridlayout(tab3, [2 1]);
    grid_tab3.RowHeight = {'1x', '1x'};
    grid_tab3.Padding = [10 10 10 10];
    grid_tab3.RowSpacing = 10;
    ax_h    = uiaxes(grid_tab3);
    ax_h.Layout.Row = 1;
    ax_h.Layout.Column = 1;
    ax_gate = uiaxes(grid_tab3);
    ax_gate.Layout.Row = 2;
    ax_gate.Layout.Column = 1;
    
    % Bind Callbacks
    drop_pave.ValueChangedFcn     = @(~,~) updatePaveLimits();
    drop_bio.ValueChangedFcn      = @(~,~) updateBioLimits();
    slider_C_pave.ValueChangedFcn = @(~,~) updatePlot();
    slider_C_bio.ValueChangedFcn  = @(~,~) updatePlot();
    slider_Atotal.ValueChangedFcn = @(~,~) updatePlot();
    slider_pct.ValueChangedFcn    = @(~,~) updatePlot();
    slider_I.ValueChangedFcn      = @(~,~) updatePlot();
    slider_dur.ValueChangedFcn    = @(~,~) updatePlot();
    slider_dt.ValueChangedFcn     = @(~,~) updatePlot();
    slider_phi.ValueChangedFcn    = @(~,~) updatePlot();
    slider_ksat.ValueChangedFcn   = @(~,~) updatePlot();
    slider_Htrig.ValueChangedFcn  = @(~,~) updatePlot();
    
    % Initialize
    updatePaveLimits();
    updateBioLimits();
    
    function updatePaveLimits()
        val = drop_pave.Value;
        p_idx = find(strcmp({pavement_data.name}, val));
        slider_C_pave.Limits = [pavement_data(p_idx).min, pavement_data(p_idx).max];
        slider_C_pave.Value  = pavement_data(p_idx).default;
        updatePlot();
    end
    
    function updateBioLimits()
        val = drop_bio.Value;
        b_idx = find(strcmp({bioretention_data.name}, val));
        slider_C_bio.Limits = [bioretention_data(b_idx).min, bioretention_data(b_idx).max];
        slider_C_bio.Value  = bioretention_data(b_idx).default;
        updatePlot();
    end
    
    function updatePlot()
        % --- 1. FETCH PARAMETERS FROM GUI & UPDATE READOUT LABELS ---
        Cp = slider_C_pave.Value;
        Cb = slider_C_bio.Value;
        Atotal = slider_Atotal.Value;
        bio_pct = slider_pct.Value;
        I_mean = slider_I.Value;             % mm/hr (constant intensity)
        storm_dur_min = slider_dur.Value;    % minutes
        dt = slider_dt.Value;                % seconds per tick
        phi = slider_phi.Value;              % soil porosity (0.35 - 0.45)
        ksat_mmhr = slider_ksat.Value;       % max hydraulic conductivity (mm/hr)
        H_TRIGGER_OPEN = slider_Htrig.Value; % gate actuation puddle depth (mm)
        cooldown_dur_sec = 60;               % fixed safety cooldown timer (seconds)
        
        % Update dynamic value labels next to controls
        lbl_val_Cp.Text     = sprintf('%.2f', Cp);
        lbl_val_Cb.Text     = sprintf('%.2f', Cb);
        lbl_val_Atotal.Text = sprintf('%.0f m²', Atotal);
        lbl_val_pct.Text    = sprintf('%.1f %%', bio_pct);
        lbl_val_I.Text      = sprintf('%.1f mm/hr', I_mean);
        lbl_val_dur.Text    = sprintf('%.0f min', storm_dur_min);
        lbl_val_dt.Text     = sprintf('%.1f s', dt);
        lbl_val_phi.Text    = sprintf('%.2f', phi);
        lbl_val_ksat.Text   = sprintf('%.0f mm/hr', ksat_mmhr);
        lbl_val_Htrig.Text  = sprintf('%.0f mm', H_TRIGGER_OPEN);
        
        % Area and composite runoff coefficient math
        A_bio_curr = (bio_pct / 100) * Atotal; % calculating area occupied by bioretention
        A_pave_curr = Atotal - A_bio_curr;      % calculating area occupied by pavement/road
        C_comp_curr = (Cp * A_pave_curr + Cb * A_bio_curr) / Atotal; % calculating C composite
        
        % --- 2. TAB 1: C_COMPOSITE CURVE ---
        pct_range = 0:0.5:50;
        A_bio_range = (pct_range / 100) * Atotal;
        A_pave_range = Atotal - A_bio_range;
        C_comp_curve = (Cp .* A_pave_range + Cb .* A_bio_range) ./ Atotal;
        reduction = (1 - C_comp_curr / Cp) * 100;
        
        cla(ax_comp);
        plot(ax_comp, pct_range, C_comp_curve, 'b-', 'LineWidth', 2);
        hold(ax_comp, 'on');
        patch(ax_comp, [15 30 30 15], [0 0 1 1], [0.38 0.95 1.00], 'FaceAlpha', 0.4, 'EdgeColor', 'none');
        plot(ax_comp, bio_pct, C_comp_curr, 'ro', 'MarkerSize', 9, 'MarkerFaceColor', 'r');
        hold(ax_comp, 'off');
        xlim(ax_comp, [0 50]);
        ylim(ax_comp, [0 1.0]);
        grid(ax_comp, 'on');
        title(ax_comp, sprintf('Composite Runoff Coeff: C_{composite} = %.3f', C_comp_curr));
        xlabel(ax_comp, 'Bioretention Area Share (%)');
        ylabel(ax_comp, 'C_{composite}');
        legend(ax_comp, {'C_{composite} Curve', 'Realistic Urban Zone (15–30%)', 'Operating Point'}, 'Location', 'northeast', 'Color', [0.90 0.90 0.90]);
        
        ax_comp.Interactions = dataTipInteraction;
        enableDefaultInteractivity(ax_comp);
        
        % --- 3. STAGE-BY-STAGE DISCRETE SIMULATION LOOP ---
        storm_dur_sec = storm_dur_min * 60;
        total_sim_sec = storm_dur_sec * 1.8;
        time_sec = 0:dt:total_sim_sec;
        num_ticks = length(time_sec);
        
        soil_depth_m = 0.5; 
        soil_max_capacity_L = A_bio_curr * soil_depth_m * phi * 1000;
        soil_k_sat_Lps = (A_bio_curr * ksat_mmhr) / 3600;
        
        volume_in_step_liters = zeros(1, num_ticks);
        cum_rain_volume_L     = zeros(1, num_ticks);
        soil_vol_liters       = zeros(1, num_ticks);
        soil_saturation_pct   = zeros(1, num_ticks);
        surface_vol_liters    = zeros(1, num_ticks);
        h_puddle_mm           = zeros(1, num_ticks);
        actuator_state        = zeros(1, num_ticks);
        
        cooldown_timer = 0;
        
        for t = 1:num_ticks
            curr_t = time_sec(t);
            
            % --- STAGE 1: Overland Runoff Generation ---
            if curr_t <= storm_dur_sec
                vol_step = ((1 - C_comp_curr) * I_mean * Atotal / 3600) * dt;
            else
                vol_step = 0;
            end
            volume_in_step_liters(t) = vol_step;
            
            if t == 1
                cum_rain_volume_L(t) = vol_step;
            else
                cum_rain_volume_L(t) = cum_rain_volume_L(t-1) + vol_step;
            end
            
            % --- STAGE 2: Bio-Retention Soil Mass Balance & Infiltration ---
            if t == 1
                prev_soil_vol = 0;
                prev_surface_vol = 0;
            else
                prev_soil_vol = soil_vol_liters(t-1);
                prev_surface_vol = surface_vol_liters(t-1);
            end
            
            avail_soil_cap = max(0, soil_max_capacity_L - prev_soil_vol);
            max_infilt_rate = soil_k_sat_Lps * dt;
            water_on_surface = vol_step + prev_surface_vol;
            
            vol_infilt = min([max_infilt_rate, avail_soil_cap, water_on_surface]);
            vol_infilt = max(0, vol_infilt);
            
            curr_soil_vol = prev_soil_vol + vol_infilt;
            soil_vol_liters(t) = curr_soil_vol;
            soil_saturation_pct(t) = (curr_soil_vol / soil_max_capacity_L) * 100;
            
            rem_surface_vol = water_on_surface - vol_infilt;
            raw_h_mm = rem_surface_vol / A_bio_curr;
            
            % --- STAGE 3: Actuator Decision Logic ---
            if raw_h_mm >= H_TRIGGER_OPEN
                act_state = 1;
                cooldown_timer = cooldown_dur_sec;
            else
                if cooldown_timer > 0
                    act_state = 1;
                    cooldown_timer = cooldown_timer - dt;
                else
                    act_state = 0;
                end
            end
            actuator_state(t) = act_state;
            
            if act_state == 1
                surface_vol_liters(t) = 0;
                h_puddle_mm(t) = 0;
            else
                surface_vol_liters(t) = rem_surface_vol;
                h_puddle_mm(t) = raw_h_mm;
            end
        end
        
        time_min = time_sec / 60;
        
        % --- 4. RENDER TELEMETRY GRAPHS ---
        % TAB 2 Graph 1: Stage 1 Inflow Volume
        cla(ax_vol);
        yyaxis(ax_vol, 'left');
        plot(ax_vol, time_min, cum_rain_volume_L, 'b-', 'LineWidth', 1.6);
        ylabel(ax_vol, 'Cum. Captured Rain (L)');
        
        yyaxis(ax_vol, 'right');
        plot(ax_vol, time_min, volume_in_step_liters, 'r--', 'LineWidth', 1.2);
        ylabel(ax_vol, sprintf('Vol / Tick (L per %.1fs)', dt));
        grid(ax_vol, 'on');
        title(ax_vol, sprintf('Stage 1: Overland Inflow Volume per Step (dt = %.1f s)', dt));
        xlabel(ax_vol, 'Time (Minutes)');
        
        % TAB 2 Graph 2: Stage 2 Sub-Surface Soil Saturation
        cla(ax_soil);
        plot(ax_soil, time_min, soil_saturation_pct, 'm-', 'LineWidth', 1.6); hold(ax_soil, 'on');
        yline(ax_soil, 100, 'k--', '100% Saturation Capacity', 'LineWidth', 1.2); hold(ax_soil, 'off');
        grid(ax_soil, 'on');
        title(ax_soil, 'Stage 2: Sub-Surface Soil Saturation (\theta) - Virtual VWC Sensor Telemetry');
        xlabel(ax_soil, 'Time (Minutes)');
        ylabel(ax_soil, 'Soil Saturation (%)');
        ylim(ax_soil, [0 115]);
        
        % TAB 3 Graph 1: Stage 2 Surface Puddle Depth h(t)
        cla(ax_h);
        plot(ax_h, time_min, h_puddle_mm, 'g-', 'LineWidth', 1.5); hold(ax_h, 'on');
        yline(ax_h, H_TRIGGER_OPEN, 'r--', sprintf('Trigger Threshold (%.0f mm)', H_TRIGGER_OPEN), 'LineWidth', 1.2); hold(ax_h, 'off');
        grid(ax_h, 'on');
        title(ax_h, 'Stage 2: Surface Water Depth h(t) - Ultrasonic Level Sensor Telemetry');
        xlabel(ax_h, 'Time (Minutes)');
        ylabel(ax_h, 'Puddle Depth (mm)');
        
        % TAB 3 Graph 2: Stage 3 Actuator Gate State
        cla(ax_gate);
        stairs(ax_gate, time_min, actuator_state, 'Color', [0.5 0 0.5], 'LineWidth', 1.8);
        grid(ax_gate, 'on');
        title(ax_gate, 'Stage 3: Subterranean Channel Actuator Gate State - Limit Switch Telemetry');
        xlabel(ax_gate, 'Time (Minutes)');
        ylabel(ax_gate, 'Gate State');
        yticks(ax_gate, [0 1]);
        yticklabels(ax_gate, {'CLOSED (0)', 'OPEN (1)'});
        ylim(ax_gate, [-0.2 1.2]);
        
        % --- 5. EXPORT CSV WITH ALL STAGE OUTPUTS ---
        time_seconds = time_sec(:);
        vol_step_liters = volume_in_step_liters(:);
        soil_sat_pct = soil_saturation_pct(:);
        puddle_mm = h_puddle_mm(:);
        gate_state = actuator_state(:);
        
        module_1_inputs = table(time_seconds, vol_step_liters, soil_sat_pct, puddle_mm, gate_state, ...
            'VariableNames', {'time_seconds', 'volume_in_step_liters', 'soil_saturation_pct', 'surface_water_depth_mm', 'actuator_state'});
        writetable(module_1_inputs, 'module_1_inputs.csv');
        
        % --- 6. UPDATE SUMMARY TEXT ---
        lbl_summary.Text = sprintf(['• C_pave: %.2f | C_bio: %.2f | C_comp: %.3f (-%.1f%%)\n' ...
                                    '• Max Soil Saturation: %.1f%% | Max Puddle: %.1f mm\n' ...
                                    '• Actuator Triggered: %d time(s) -> Exported module_1_inputs.csv'], ...
                                    Cp, Cb, C_comp_curr, reduction, ...
                                    max(soil_saturation_pct), max(h_puddle_mm), ...
                                    sum(diff([0, actuator_state]) > 0));
    end
end