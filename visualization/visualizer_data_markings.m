function visualizer_data_markings(cfg, patientStruct, events)
% VISUALIZER_DATA_MARKINGS - Plot Signal with Marked Detected Events
%
% Visualize a signal with marked detected events. This function plots
% multiple channels of signal data with optional event markers and provides
% various customization options.
%
% Syntax:
%   visualizer_data_markings(cfg, patientStruct, events)
%
% Input:
%   - cfg: Configuration structure with optional fields for customizing the
%     plot. It can include the following parameters:
%       - cfg.ch_color (char, default: 'k'): Color for the plotted channels.
%       - cfg.chs_2_plot (vector, default: All channels): Indices of channels
%         to plot.
%       - cfg.shift (double, default: 500): Margin between plotted signal of
%         channels.
%       - cfg.save_flag (logical, default: false): Flag to save the figure.
%       - cfg.filename_save (char): Filename of the figure if save_flag is true.
%       - cfg.time_window (double, default: 100): Time window of the plot in
%         seconds.
%       - cfg.legend (cell array of strings): Description of markers in the plot.
%       - cfg.marker_color (char array): Colors for event markers if events exist.
%       - cfg.marker_style (char, default: 'start'): Mark the start or duration
%         of the events.
%       - cfg.resample_fs (double, default: []): Frequency to resample data for
%         plotting.
%       - cfg.linewidth (double or array, default: 1): Line width of the plotted
%         signal.
%       - cfg.chleader (double): Index of the leader channel for trigger markers
%         (required for 'trigger' style).
%       - cfg.fontsize (double, default: 10): Font size for plot elements.
%       - cfg.box (char, default: 'on'): Axis box display ('on' or 'off').
%       - cfg.YAxis (char, default: 'on'): Y-axis display ('on' or 'off').
%       - cfg.XAxis (char, default: 'on'): X-axis display ('on' or 'off').
%       - cfg.highlight_ch (double): Index of the channel to highlight with bold text.
%
%   - patientStruct: A structure with subfields:
%       - patientStruct.epochsList: Subfield containing the following fields:
%           - Fs (double): Sampling frequency.
%           - X_raw (matrix): Matrix of the signal.
%           - chan_names (cell array): Names of the channels.
%
%   - events (optional): A struct with subfields, each containing samples of
%     events for channels.
%
% Output:
%   - An interactive figure displaying the plotted signal with marked detected
%     events.
%   - A saved figure if save_flag is set to true.

    defaults = struct('ch_color', 'k', ...
                      'chs_2_plot', 1:length(patientStruct.epochsList.chan_names), ...
                      'shift', 500, ...
                      'save_flag', false, ...
                      'time_window', 100, ...
                      'legend', '', ...
                      'marker_color', [], ...
                      'marker_style', 'start', ...
                      'resample_fs', [], ...
                      'linewidth', 1, ...
                      'chleader', [], ...
                      'fontsize', 10, ...
                      'box', 'on', ...
                      'YAxis', 'on', ...
                      'XAxis', 'on', ...
                      'highlight_ch', []);
    cfg = merge_params(defaults, cfg);

    bad_channels = [];
    if any(contains(fieldnames(cfg), 'bad_channels'))
        bad_channels = cfg.bad_channels; 
    end 

    if ~any(contains(fieldnames(cfg), 'marker_color')) && exist('events', 'var')
        cfg.marker_color = repmat(["k", "g", "m", "r"], 1, round(length(fieldnames(events))/4)); 
    end 

    if any(contains(fieldnames(cfg), 'resample_fs')) && cfg.resample_fs ~= false && cfg.resample_fs ~= 0 && cfg.resample_fs ~= patientStruct.epochsList.Fs
        patientStruct = resample_patientStruct(patientStruct, cfg.resample_fs); 
    end 
    
    if strcmp(cfg.marker_style, 'trigger') && isempty(cfg.chleader) 
       error('Trigger channel is not defined') 
    end
    
    data = patientStruct.epochsList; 
    dt   = 1/data.Fs;

    if size(data.X_raw, 1) < size(data.X_raw, 2)
        data.X_raw = data.X_raw';
    end 

    time = dt:dt:length(data.X_raw)*dt;
    ch_o_i = cfg.chs_2_plot;
    
    if size(ch_o_i, 1) > size(ch_o_i, 2)
       ch_o_i = ch_o_i';  
    end
    
    shift = cfg.shift;          
    
    if ~ismember(cfg.chleader, ch_o_i)
        ch_o_i = [cfg.chleader, ch_o_i]; 
    end
    
    if size(cfg.linewidth, 2) ~= size(ch_o_i, 2)
        cfg.linewidth = repmat(cfg.linewidth, size(ch_o_i)); 
    end 

    plot_idx = 1;

    leg = []; 

    for ch = ch_o_i

        ch_color = cfg.ch_color; 
        if any(bad_channels(:) == ch) 
            ch_color = 'r'; 
        end

        sig = detrend(data.X_raw(:,ch)');

        plot(time, ...
             sig - shift*plot_idx, ...
             'Color', ch_color, ...
             'linewidth', cfg.linewidth(plot_idx))

        hold on; 

        markers = fieldnames(events); 

        for i = 1:length(markers)
            for ev_idx = getfield(events(ch), markers{i})'

                if strcmp(cfg.marker_style, 'start') && ev_idx > 0
                    marking = line([time(ev_idx) time(ev_idx)], ...
                                   [-shift/3 shift/4] + sig(ev_idx) - shift * plot_idx, ...
                                   'color', cfg.marker_color(i, :));
                    leg(i) = marking;    

                elseif strcmp(cfg.marker_style, 'duration')
                    marking = plot(time(ev_idx(1):ev_idx(2)), ...
                                   sig(ev_idx(1):ev_idx(2)) - shift*plot_idx, ...
                                   'color', cfg.marker_color(i, :)); 
                    leg(i) = marking;
                    
                elseif strcmp(cfg.marker_style, 'trigger') && ch == cfg.chleader
                     marking = line([time(ev_idx) time(ev_idx)], ...
                                    [ -shift*(length(ch_o_i)+1) 0 ], ...
                                    'color', cfg.marker_color(i, :), ...
                                    'LineStyle', '--'); 
                     leg(i) = marking;
   
                end 
            end 
        end 
        
        plot_idx = plot_idx+1;

    end
    

    if ~isempty(cfg.legend)
        legend(leg, cfg.legend, 'Location', 'northwest'); 
    end 


    if size(data.chan_names, 2) > size(data.chan_names, 1)
        data.chan_names = data.chan_names'; 
    end 
    
    if ~isempty(cfg.highlight_ch)
        data.chan_names{ch_o_i(cfg.highlight_ch)} = ['\bf ' data.chan_names{ch_o_i(cfg.highlight_ch)}]; 
    end 
    
    set(gca, ...
        'YTick', -shift*(plot_idx-1):shift:-shift, ...
        'YTicklabel', flipud(data.chan_names(ch_o_i)), ...
        'fontsize', cfg.fontsize, ...
        'box', cfg.box);
    
    ax = gca;    
    ax
    ax.XRuler.Axle.Visible = cfg.XAxis; 
    ax.YRuler.Axle.Visible = cfg.YAxis; 

    ylim([-shift*(plot_idx+1) shift]); 

    %% save
    if cfg.save_flag
        filename = cfg.filename_save; 
        saveas(gcf, filename)
    end

end