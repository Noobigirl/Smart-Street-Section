function M1_calculations()

    folder     = fileparts(mfilename('fullpath'));
    if isempty(folder), folder = pwd; end
    csv_out    = fullfile(folder, 'module_1_final_inputs.csv'); 
    csv_in     = fullfile(folder, 'actuator_states.csv');      
    A_total    = 1000;    % m^2
    dt         = 1;       % s per time step
    phi        = 0.40;    % soil porosity
    soil_depth = 0.5;     % m
    H_OPEN     = 50;      % mm (just like in the C++ code)
    H_CLOSE    = 40;      % mm (just like in the C++ code)

    R = [];  last_key = 0;  cpp_msg = '';

   
    fig = uifigure('Name', 'Smart Street Module 1', ...
                   'Position', [40 40 1150 680], 'Color', [0.93 0.95 0.98]);
    fig.CloseRequestFcn = @(~,~) close_app();

    panel = uipanel(fig, 'Title', 'PARAMETERS', 'Position', [10 10 340 660]);

    [lCp,  sCp]  = add_slider(555, [0.70 0.95], 0.70);
    [lCb,  sCb]  = add_slider(470, [0.05 0.20], 0.10);
    [lPct, sPct] = add_slider(385, [1 50],      20);
    [lI,   sI]   = add_slider(300, [0 120],     100);
    [lDur, sDur] = add_slider(215, [5 90],      30);
    [lK,   sK]   = add_slider(130, [100 300],   100);

    lblSum = uilabel(panel, 'Position', [15 5 310 95], 'Text', '', ...
                     'WordWrap', 'on', 'VerticalAlignment', 'top', 'FontWeight', 'bold');

    tabs = uitabgroup(fig, 'Position', [360 10 780 660]);
    t1 = uitab(tabs, 'Title', 'C composite');
    t2 = uitab(tabs, 'Title', 'Inflow & Soil');
    t3 = uitab(tabs, 'Title', 'Puddle & C++ Gates');

    axC = uiaxes(t1, 'Position', [50 50 690 540]);
    axF = uiaxes(t2, 'Position', [50 330 690 250]);
    axS = uiaxes(t2, 'Position', [50 40 690 250]);
    axH = uiaxes(t3, 'Position', [50 330 690 250]);
    axG = uiaxes(t3, 'Position', [50 40 690 250]);

    % checks for a new C++ result file every second
    tm = timer('ExecutionMode', 'fixedSpacing', 'Period', 1, 'BusyMode', 'drop', ...
               'TimerFcn', @(~,~) check_cpp());

    update();
    start(tm);


    % SLIDERS, GRAPHS, CSV, C++ RESULT
    function [lbl, sld] = add_slider(y, lim, val)
        lbl = uilabel(panel, 'Text', '', 'Position', [15 y+25 310 22]);
        sld = uislider(panel, 'Position', [20 y 300 3], 'Limits', lim, 'Value', val);
        sld.ValueChangedFcn = @(~,~) update();
    end

    function update()
        Cp = sCp.Value;  Cb = sCb.Value;  pct = sPct.Value;
        I  = sI.Value;   dur = sDur.Value;  ks = sK.Value;

        lCp.Text  = sprintf('Pavement runoff coeff C_pavement: %.2f', Cp);
        lCb.Text  = sprintf('Bioretention coeff C_bioretention: %.2f', Cb);
        lPct.Text = sprintf('Bioretention area share: %.1f %%', pct);
        lI.Text   = sprintf('Rainfall intensity: %.0f mm/hr', I);
        lDur.Text = sprintf('Rain duration: %.0f min', dur);
        lK.Text   = sprintf('Soil conductivity K_sat: %.0f mm/hr', ks);

    
        R = run_model(Cp, Cb, pct, I, dur, ks, A_total, dt, phi, soil_depth);
        draw_model()
  
        writetable(table(R.time_min, R.h_mm, 'VariableNames', {'time_min', 'h_mm'}), csv_out);
        last_key = 0;
        cpp_msg = 'CSV written. Waiting for C++ ...';
        refresh_summary();
        check_cpp();
    end

    function draw_model()
        t = R.time_min;

        % --- Tab 1: composite runoff coefficient ---
        cla(axC);  hold(axC, 'on');
        patch(axC, [15 30 30 15], [0 0 1 1], [0.38 0.95 1.00], 'FaceAlpha', 0.4, 'EdgeColor', 'none');
        plot(axC, R.curve_pct, R.curve_C, 'b-', 'LineWidth', 2);
        plot(axC, sPct.Value, R.C, 'ro', 'MarkerSize', 9, 'MarkerFaceColor', 'r');
        hold(axC, 'off');
        xlim(axC, [0 50]);  ylim(axC, [0 1]);  grid(axC, 'on');
        title(axC, sprintf('C_{composite} = %.3f', R.C));
        xlabel(axC, 'Bioretention area share (%)');  ylabel(axC, 'C_{composite}');
        legend(axC, {'Realistic zone (15-30%)', 'C_{composite} curve', 'Operating point'});

        % --- Tab 2 top: inflow rate vs what the soil can swallow ---
        cla(axF);  hold(axF, 'on');
        plot(axF, t, R.inflow_Lps, 'r-', 'LineWidth', 1.5);
        plot(axF, [t(1) t(end)], [R.k_Lps R.k_Lps], 'b--', 'LineWidth', 1.5);
        hold(axF, 'off');
        grid(axF, 'on');
        ylim(axF, [0, max(1e-3, 1.3 * max(R.k_Lps, max(R.inflow_Lps)))]);
        title(axF, 'Stage 1: inflow rate vs soil infiltration limit (puddle forms when red is above blue)');
        xlabel(axF, 'Time (min)');  ylabel(axF, 'Flow (L/s)');
        legend(axF, {'Inflow', 'Soil infiltration limit'});

        % --- Tab 2 bottom: soil saturation ---
        cla(axS);
        plot(axS, t, R.soil_sat, 'm-', 'LineWidth', 1.6);
        grid(axS, 'on');  ylim(axS, [0 110]);
        title(axS, 'Stage 2: soil saturation');
        xlabel(axS, 'Time (min)');  ylabel(axS, 'Saturation (%)');

        % --- Tab 3 top: puddle depth h with thresholds ---
        cla(axH);  hold(axH, 'on');
        plot(axH, t, R.h_mm, 'g-', 'LineWidth', 1.8);
        plot(axH, [t(1) t(end)], [H_OPEN H_OPEN],   'r--', 'LineWidth', 1.3);
        plot(axH, [t(1) t(end)], [H_CLOSE H_CLOSE], 'm:',  'LineWidth', 1.3);
        hold(axH, 'off');
        grid(axH, 'on');
        xlim(axH, [0 t(end)]);
        ylim(axH, [0, max(H_OPEN * 1.2, 1.1 * max(R.h_mm))]);
        title(axH, 'Stage 2: puddle depth h(t) sent to C++');
        xlabel(axH, 'Time (min)');  ylabel(axH, 'Depth (mm)');
        legend(axH, {'h', sprintf('Open at %d mm', H_OPEN), sprintf('Close below %d mm', H_CLOSE)}, ...
               'AutoUpdate', 'off', 'Location', 'northwest');

        % --- Tab 3 bottom: cleared until C++ answers ---
        cla(axG);
        title(axG, 'Waiting for C++ result ...');
    end

    function check_cpp()
        try
            if ~isfile(csv_in)
                set_msg('actuator_states.csv not found. Is the C++ program running?');
                return
            end
            din  = dir(csv_in);
            dout = dir(csv_out);
            key  = din.datenum + dout.datenum;
            if key == last_key, return, end          % nothing new

            if din.datenum < dout.datenum
                set_msg('Waiting for C++ to process the new CSV ...');
                return
            end
            T = readtable(csv_in);
            if height(T) ~= numel(R.time_min)
                set_msg('C++ result does not match this run yet ...');
                return
            end
            draw_gates(R.time_min, T.actuator_state);
            last_key = key;
            set_msg('C++ gate result loaded.');
        catch err
            set_msg(['C++ read error: ' err.message]);
        end
    end

    function draw_gates(t, state)
        state = state(:) > 0.5;
        n = numel(state);
        d = diff([0; state; 0]);
        i_open  = find(d == 1);
        i_close = min(find(d == -1), n);
        t_open  = t(i_open);
        t_close = t(i_close);

        % bottom graph: gate state with shaded "open" periods
        cla(axG);  hold(axG, 'on');
        for k = 1:numel(t_open)
            patch(axG, [t_open(k) t_close(k) t_close(k) t_open(k)], [0 0 1 1], ...
                  [0.8 0.6 0.9], 'FaceAlpha', 0.5, 'EdgeColor', 'none');
            text(axG, (t_open(k) + t_close(k)) / 2, 0.5, ...
                 sprintf('open %.1f min\n%.1f to %.1f', t_close(k) - t_open(k), t_open(k), t_close(k)), ...
                 'HorizontalAlignment', 'center');
        end
        stairs(axG, t, double(state), 'Color', [0.5 0 0.5], 'LineWidth', 2);
        hold(axG, 'off');
        grid(axG, 'on');
        xlim(axG, [0 t(end)]);  ylim(axG, [-0.2 1.2]);
        yticks(axG, [0 1]);  yticklabels(axG, {'CLOSED', 'OPEN'});
        title(axG, sprintf('C++ gate state: opened %d time(s), open %.1f min in total', ...
                           numel(t_open), sum(t_close - t_open)));
        xlabel(axG, 'Time (min)');  ylabel(axG, 'Gate');

        % same open periods shaded on the puddle graph
        delete(findobj(axH, 'Tag', 'gateband'));
        for k = 1:numel(t_open)
            yl = ylim(axH);
            patch(axH, [t_open(k) t_close(k) t_close(k) t_open(k)], [0 0 yl(2) yl(2)], ...
                  [0.8 0.6 0.9], 'FaceAlpha', 0.25, 'EdgeColor', 'none', 'Tag', 'gateband');
        end
    end

    function set_msg(m)
        if ~strcmp(m, cpp_msg)
            cpp_msg = m;
            refresh_summary();
        end
    end

    function refresh_summary()
        if isempty(R), return, end
        s = sprintf('C_composite = %.3f\nMax puddle h = %.1f mm\nMax soil saturation = %.1f %%\n', ...
                    R.C, max(R.h_mm), max(R.soil_sat));
        if max(R.h_mm) < 0.01
            s = [s 'No ponding: raise rainfall or lower K_sat.' newline];
        end
        lblSum.Text = [s cpp_msg];
    end

    function close_app()
        stop(tm);
        delete(tm);
        delete(fig);
    end
end


% =========================================================================
%  PART 1: CALCULATIONS (no graphics in here)
% =========================================================================
function R = run_model(Cp, Cb, bio_pct, I, dur_min, ksat, A_total, dt, phi, soil_depth)

    % ---- geometry and composite runoff coefficient ----
    A_bio  = bio_pct / 100 * A_total;
    A_pave = A_total - A_bio;
    C      = (Cp * A_pave + Cb * A_bio) / A_total;

    % ---- Stage 1: water reaching the bio-retention ----
    % (1 - C) is what the PDF says. The standard rational method uses C instead;
    % to switch, change the next line to:  runoff_fraction = C;
    runoff_fraction = 1 - C;
    rate_Lps = runoff_fraction * I * A_total / 3600;     % L/s (1 mm on 1 m^2 = 1 L)

    % ---- Stage 2: soil ----
    cap_L = A_bio * soil_depth * phi * 1000;             % max soil storage [L]
    k_Lps = A_bio * ksat / 3600;                         % max infiltration [L/s]

    time_s   = 0:dt:(dur_min * 60 * 1.8);
    n        = numel(time_s);
    vol_step = zeros(n, 1);
    soil_sat = zeros(n, 1);
    h_mm     = zeros(n, 1);
    soil = 0;  surf = 0;

    for k = 1:n
        if time_s(k) < dur_min * 60
            v = rate_Lps * dt;                           % rain only during the storm
        else
            v = 0;
        end
        on_surface = v + surf;
        infilt = max(0, min([k_Lps * dt, cap_L - soil, on_surface]));
        soil = soil + infilt;
        surf = on_surface - infilt;

        vol_step(k) = v;
        soil_sat(k) = soil / cap_L * 100;
        h_mm(k)     = surf / A_bio;                      % L / m^2 = mm
    end

    % ---- results ----
    R.time_min   = time_s(:) / 60;
    R.C          = C;
    R.vol_step   = vol_step;
    R.inflow_Lps = vol_step / dt;
    R.k_Lps      = k_Lps;
    R.soil_sat   = soil_sat;
    R.h_mm       = h_mm;
    R.curve_pct  = (0:0.5:50)';
    R.curve_C    = Cp + (Cb - Cp) * R.curve_pct / 100;
end