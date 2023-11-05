function plot_tfr(patientStruct, ind_ch, event_time, varargin)
% plot_tfr - Plot Time-Frequency Representation of EEG Signals
%
% Description:
%   The `plot_tfr` function is used to generate a time-frequency representation
%   plot of EEG signals centered around a specific event time.
%
% Inputs:
%   - patientStruct: A struct containing the patient's electrophysiological data.
%   - ind_ch: The index of the channel for which the TFR is to be plotted.
%   - event_time: The time of the event (in samples) around which the TFR is centered.
%   - varargin: Optional name-value pairs for customization (see below).
%
% Optional Inputs (Name-Value Pairs):
%   - 'fig_fontsize': Font size for the figure (default: 10).
%   - 'linewidth': Line width for the EEG signal (default: 1).
%   - 'freq_band': Frequency band of interest (default: []).
%   - 'nsecs': Duration of the TFR in seconds (default: 1).
%   - 'cmap': Colormap for the TFR plot (default: 'parula').
%   - 'colorbar_flag': Flag for displaying a colorbar (default: 0).
%   - 'colorbar_str': Label for the colorbar (default: '').

    p = inputParser;
    addParameter(p, 'fig_fontsize', 10);
    addParameter(p, 'linewidth', 1);
    addParameter(p, 'freq_band', []);
    addParameter(p, 'nsecs', 1);
    addParameter(p, 'cmap', 'parula');
    addParameter(p, 'colorbar_flag', 0);
    addParameter(p, 'colorbar_str', '');
    
    parse(p, varargin{:});
    
    fig_fontsize = p.Results.fig_fontsize; 
    linewidth = p.Results.linewidth; 
    freq_band = p.Results.freq_band; 
    nsecs = p.Results.nsecs;
    cmap = p.Results.cmap;
    colorbar_flag = p.Results.colorbar_flag; 
    colorbar_str = p.Results.colorbar_str; 
    
    
    Fs = patientStruct.epochsList.Fs; 
    min_nsecs = 1; 
    
    if min_nsecs <= nsecs
        min_nsecs = nsecs;
    end
    
    if isempty(freq_band)
        Oct(1) = floor(log(Fs./(4*80))/log(2));
        Oct(2) = ceil(log(Fs./(4*8))/log(2));
    else 
        Oct(1) = floor(log(Fs./(4*max(freq_band)))/log(2));
        Oct(2) = ceil(log(Fs./(4*min(freq_band)))/log(2));
    end 
    
%     NbOct = length(Oct(1):Oct(2))-1;
    NbVoi = 12;
    VanMom = 20;

    signal = patientStruct.epochsList.X_raw(ind_ch, [event_time-min_nsecs*Fs : event_time+min_nsecs*Fs]); 
    [tfr, freqs] = DoG(signal, Oct, NbVoi, VanMom, 2, Fs, 0);
 
    [tfz, ~, ~, ~] = z_H0(tfr, Fs, []);
    
    if nsecs ~= min_nsecs
        tfz = tfz((min_nsecs - nsecs) * Fs : length(tfz) - ((min_nsecs - nsecs) * Fs), :); 
        signal = signal((min_nsecs - nsecs) * Fs :  length(signal) - ((min_nsecs - nsecs) * Fs)); 
    end 
    
    tt = linspace(-nsecs, nsecs, size(tfz, 1)); 
    
    imagesc(flipud(real(tfz)'), ...
            'XData', tt, 'YData', flipud(freqs));  
    colormap(cmap);
    
    set(gca, 'YDir', 'normal', ...
             'FontSize', fig_fontsize);  
    
    xticks([-nsecs 0 nsecs]); 
    xticklabels([-nsecs 0 nsecs]); 
    
    xlabel('Time (s)', ...
           'FontSize', fig_fontsize, ...
           'Color', 'k'); 

    ylabel('Frequency', ...
           'FontSize', fig_fontsize); 
    
    yticks(floor(linspace(1, max(freqs), 5))); 
    yticklabels(floor(linspace(1, max(freqs), 5)));
       
    hold on 

    yyaxis right
    plot(tt, signal, ...
         'Color', 'w', ...
         'linewidth', linewidth); 

    ylabel('Amplitude', ...
           'FontSize', fig_fontsize, ...
           'Color', 'k', ...
           'Rotation', -90); 
    
    yticks(round([min(signal)-20 0 max(signal)+30], -1)); 
    yticklabels(round([min(signal)-20 0 max(signal)+30], -1)); 
    ylim([round([min(signal)-20 max(signal)+30], -1)]); 
    
    set(gca, 'YColor', 'k');
    
    
    if colorbar_flag

         c = colorbar('southoutside', ...
                     'Ticks', [min(tfz, [], 'all'), max(tfz, [], 'all')/2, max(tfz, [], 'all')], ...
                     'TickLabels', append(repmat("\color{black}", 1, 3), ...
                                          string(round( ...
                                                [min(tfz, [], 'all'), ...
                                                max(tfz, [], 'all')/2, ...
                                                max(tfz, [], 'all')]))));
                                            
        c.Label.String = colorbar_str;
        c.Label.VerticalAlignment = 'bottom';
        
        tmp_pos = get(gca, 'Position');
        
        c.Position(2) = c.Position(2) - 2 * c.Position(4); 
        tmp_pos(2) = tmp_pos(2) - 2 * c.Position(4); 
        tmp_pos(4) = tmp_pos(4) + 2 * c.Position(4);
        c.Position(4) = c.Position(4) / 2;  
        
        c.TickLength = 0; 
        c.Box = 'off'; 
        c.EdgeColor = 'w'; 
        c.Label.Color = 'k'; 
        c.Label.Position(2) = c.Position(2) + 1; 
        c.Label.FontSize = fig_fontsize; 
        
        set(gca, 'Position', tmp_pos);
    end 

end 