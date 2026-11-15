function interactive_smart_street_sim()
    % INTERACTIVE SMART STREET RUNOFF COEFFICIENT SIMULATOR
    
    % Create UI Window
    fig = uifigure('Name', 'Smart Street C_composite Optimization', ...
                   'Position', [100 100 950 600], ...
                   'Color', [0.93 0.95 0.98]);

    % Define reference surface data from design tables
    pavement_data = struct(...
        'name', {'Asphaltic Street (0.70 - 0.95)', 'Concrete Street (0.80 - 0.95)', 'Brick Street (0.70 - 0.85)', 'Drives and Walks (0.75 - 0.85)'}, ...
        'min',  {0.70, 0.80, 0.70, 0.75}, ...
        'max',  {0.95, 0.95, 0.85, 0.85}, ...
        'default', {0.70, 0.85, 0.75, 0.80});

    bioretention_data = struct(...
        'name', {'BSM - Sandy Soil Flat 2% (0.05 - 0.10)', 'BSM - Sandy Soil Avg 2-7% (0.10 - 0.15)', 'BSM - Sandy Soil Steep 7% (0.15 - 0.20)', 'Heavy Soil Flat 2% (0.13 - 0.17)'}, ...
        'min',  {0.05, 0.10, 0.15, 0.13}, ...
        'max',  {0.10, 0.15, 0.20, 0.17}, ...
        'default', {0.05, 0.10, 0.15, 0.13});

    % Left Control Panel
    panel = uipanel(fig, 'Title', 'SIMULATION PARAMETERS', 'Position', [20 20 330 560], 'BackgroundColor',[0.97 0.98 0.95]);

    % 1. Pavement Controls
    uilabel(panel, 'Text', 'Pavement Surface Type:', 'Position', [15 510 280 22], 'FontWeight', 'bold');
    drop_pave = uidropdown(panel, 'Items', {pavement_data.name}, 'Position', [15 485 290 25], 'BackgroundColor',[0.77 0.98 0.75]);
    
    uilabel(panel, 'Text', 'Pavement Runoff Coeff (C_pavement):', 'Position', [15 455 280 22]);
    slider_C_pave = uislider(panel, 'Position', [20 440 270 3], 'Limits', [0.70 0.95], 'Value', 0.70);

    % 2. Bioretention Controls
    uilabel(panel, 'Text', 'Bioretention Media & Slope:', 'Position', [15 380 280 22], 'FontWeight', 'bold');
    drop_bio = uidropdown(panel, 'Items', {bioretention_data.name}, 'Position', [15 355 290 25], 'BackgroundColor',[0.77 0.98 0.75]);

    uilabel(panel, 'Text', 'Bioretention Coeff (C_bioretention):', 'Position', [15 325 280 22]);
    slider_C_bio = uislider(panel, 'Position', [20 310 270 3], 'Limits', [0.05 0.10], 'Value', 0.05);

    % 3. Geometry & Area Controls
    uilabel(panel, 'Text', 'Total Street Section Area (A_total in m²):', 'Position', [15 250 290 22], 'FontWeight', 'bold');
    slider_Atotal = uislider(panel, 'Position', [20 235 270 3], 'Limits', [100 1000], 'Value', 500);

    uilabel(panel, 'Text', 'Bioretention Area Share (%):', 'Position', [15 175 280 22], 'FontWeight', 'bold');
    slider_pct = uislider(panel, 'Position', [20 160 270 3], 'Limits', [0 50], 'Value', 25);

    % Output Summary Panel
    lbl_summary = uilabel(panel, 'Position', [15 10 300 120], 'Text', '', 'WordWrap', 'on', 'FontSize', 11, 'FontWeight', 'bold');

    % Axes Display
    ax = uiaxes(fig, 'Position', [380 60 540 500]);

    % Callbacks
    drop_pave.ValueChangedFcn = @(~,~) updatePaveLimits();
    drop_bio.ValueChangedFcn  = @(~,~) updateBioLimits();
    slider_C_pave.ValueChangedFcn = @(~,~) updatePlot();
    slider_C_bio.ValueChangedFcn  = @(~,~) updatePlot();
    slider_Atotal.ValueChangedFcn = @(~,~) updatePlot();
    slider_pct.ValueChangedFcn    = @(~,~) updatePlot();

    % Initialize Settings
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
        Cp = slider_C_pave.Value;
        Cb = slider_C_bio.Value;
        Atotal = slider_Atotal.Value;
        bio_pct = slider_pct.Value;

        % Sweep bioretention share from 0% to 50%
        pct_range = 0:0.5:50;
        A_bio_range = (pct_range / 100) * Atotal;
        A_pave_range = Atotal - A_bio_range;

        % Calculate composite curve
        C_comp_curve = (Cp .* A_pave_range + Cb .* A_bio_range) ./ Atotal;

        % Current single operating point
        A_bio_curr = (bio_pct / 100) * Atotal;
        A_pave_curr = Atotal - A_bio_curr;
        C_comp_curr = (Cp * A_pave_curr + Cb * A_bio_curr) / Atotal;

        % Percentage reduction vs fully paved surface
        reduction = (1 - C_comp_curr / Cp) * 100;

        % Render Plot
        cla(ax);
        plot(ax, pct_range, C_comp_curve, 'b-', 'LineWidth', 2);
        hold(ax, 'on');

        % Highlight feasible civil engineering zone (15% - 30% area allocation)
        patch(ax, [15 30 30 15], [0 0 1 1], [0.38 0.95 1.00], 'FaceAlpha', 0.4, 'EdgeColor', 'none');

        % Operating Point Marker
        plot(ax, bio_pct, C_comp_curr, 'ro', 'MarkerSize', 9, 'MarkerFaceColor', 'r');

        hold(ax, 'off');
        xlim(ax, [0 50]);
        ylim(ax, [0 1.0]);
        grid(ax, 'on');
        title(ax, sprintf('Composite Runoff Coeff: C_{composite} = %.3f', C_comp_curr));
        xlabel(ax, 'Bioretention Area Share (%)');
        ylabel(ax, 'C_{composite}');
        legend(ax, {'C_{composite} Curve', 'Realistic Urban Zone (15–30%)', 'Current Operating Point'}, 'Location', 'northeast', 'Color', [0.90 0.90 0.90]);

        % Update readout text
        lbl_summary.Text = sprintf(['Current Simulation State:\n' ...
                                    '• C_pavement: %.2f | C_bioretention: %.2f\n' ...
                                    '• Pavement Area: %.1f m² (%.1f%%)\n' ...
                                    '• Bioretention Area: %.1f m² (%.1f%%)\n' ...
                                    '• Composite C: %.3f\n' ...
                                    '• Runoff Reduction vs Paved Road: %.1f%%'], ...
                                    Cp, Cb, A_pave_curr, (100 - bio_pct), A_bio_curr, bio_pct, C_comp_curr, reduction);
    end
end