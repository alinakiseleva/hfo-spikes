function plot_hfo_channels(HFOobj, fs, cfg)
% plot_hfo_channels - Plot High-Frequency Oscillation (HFO) Data for Multiple Channels
%
% Description:
%   The `plot_hfo_channels` function is designed to plot High-Frequency Oscillation
%   (HFO) data from multiple channels. It displays raw, R-peaks, and fast-ripple (FR)
%   signal components. 
%
% Inputs:
%   - HFOobj: A structure array containing HFO data for multiple channels. Each
%     element of the array corresponds to a channel.
%   - fs: Sampling frequency (in Hz) of the HFO data.
%   - cfg: A structure specifying optional configuration parameters (see below).
%
% Optional Parameters (cfg):
%   - 'ch_color' (default: 'k'): Color for plotting the channel signals.
%   - 'chs_2_plot' (default: All channels): Indices of the channels to plot.
%   - 'shift' (default: 1000): Vertical shift between channel signals.
%   - 'time_window' (default: 100): Time window for plotting HFOs around R-peaks.
%   - 'legend' (default: ''): Text for the plot legend.
%   - 'marker_color' (default: 'r'): Color for marking HFO events.
%   - 'linewidth' (default: 1): Line width for channel signals.
%   - 'fontsize' (default: 10): Font size for the plot labels.
%   - 'box' (default: 'on'): Box property of the plot axes.
%   - 'YAxis' (default: 'on'): Y-axis visibility property.
%   - 'XAxis' (default: 'on'): X-axis visibility property.

     defaults = struct('ch_color', 'k', ...
                      'chs_2_plot', 1:length(HFOobj), ...
                      'shift', 1000, ...
                      'time_window', 100, ...
                      'legend', '', ...
                      'marker_color', 'r', ...
                      'linewidth', 1, ...
                      'fontsize', 10, ...
                      'box', 'on', ...
                      'YAxis', 'on', ...
                      'XAxis', 'on', ...
                      'highlight_ch', []);
                  
    cfg = merge_params(defaults, cfg);

    tt = HFOobj(1).result.time;
    
    chosen_channels = cfg.chs_2_plot; 
    labels = [HFOobj(chosen_channels).label]';
    
    shift = cfg.shift;
    Rshift = 40;
    FRshift = 20; 
    
    if size(cfg.linewidth, 2) ~= size(chosen_channels, 2)
        cfg.linewidth = repmat(cfg.linewidth, size(chosen_channels)); 
    end 

    
    for pos = 1:numel(chosen_channels)
        
        % raw 
        ch = chosen_channels(pos);
        plot(tt, ...
            detrend(HFOobj(ch).result.signal) - shift * (3 * (pos-1) + 1), ...
            'Color', cfg.ch_color, ...
            'linewidth', cfg.linewidth(pos))
        hold on
        
        % R
        HFOobj(ch).result.signalFilt = HFOobj(ch).result.signalFilt * (shift / Rshift); 
        N_ev = find(HFOobj(ch).result.mark ~= 2);
        plot(tt, ...
            HFOobj(ch).result.signalFilt  - shift * (3 * (pos-1) + 2), ...
            'Color', cfg.ch_color, ...
            'linewidth', cfg.linewidth(pos))    
        
        for evin = N_ev
            hfo_samplesin = round(HFOobj(ch).result.autoSta(evin)*fs):round(HFOobj(ch).result.autoEnd(evin)*fs);
            plot(tt(hfo_samplesin), ...
                HFOobj(ch).result.signalFilt(hfo_samplesin) - shift* (3 * (pos-1) + 2), ...
                'Color', cfg.marker_color, ...
                'linewidth', cfg.linewidth(pos))
        end    
        
        % FR 
        HFOobj(ch).result.signalFiltFR = HFOobj(ch).result.signalFiltFR * (shift / FRshift); 
        N_ev = find(HFOobj(ch).result.mark ~= 1);
        plot(tt, ...
            HFOobj(ch).result.signalFiltFR - shift * (3 * (pos-1) + 3), ...
            'Color', cfg.ch_color, ...
            'linewidth', cfg.linewidth(pos))

        for evin = N_ev
            hfo_samplesin = round(HFOobj(ch).result.autoSta(evin)*fs):round(HFOobj(ch).result.autoEnd(evin)*fs);
            plot(tt(hfo_samplesin), ...
                HFOobj(ch).result.signalFiltFR(hfo_samplesin) - shift* (3 * (pos-1) + 3), ...
                'Color', cfg.marker_color, ...
                'linewidth', cfg.linewidth(pos))
        end
            
    end
    
    
    if ~isempty(cfg.highlight_ch)
        labels{cfg.highlight_ch} = ['\bf ' labels{cfg.highlight_ch}]; 
    end
    
    set(gca, ...
        'YTick', [-shift*(3*(numel(chosen_channels)-1)+2) : shift *3 : -shift*2], ...
        'YTicklabel', flipud(labels), ...
        'fontsize', cfg.fontsize, ...
        'Box', cfg.box); 
    
    ax = gca;    
    ax
    ax.XRuler.Axle.Visible = cfg.XAxis; 
    ax.YRuler.Axle.Visible = cfg.YAxis; 
    
end

