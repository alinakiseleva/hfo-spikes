function [rates_plot] = plot_bar_rates(patient, patientStructFull, hfo_rates, spike_rates, bad_channels, bad_channels_hfo, prctile_thr, cmap)
% PLOT_BAR_RATES plots bar graphs of spike rates and HFO rates.
%
% Syntax:
%   rates_plot = plot_bar_rates(patient, patientStructFull, hfo_rates, spike_rates, bad_channels, bad_channels_hfo, paths, prctile_thr, cmap)
%
% Input:
%   - patient: Patient identifier.
%   - patientStructFull: Data structure for the patient.
%   - hfo_rates: High-Frequency Oscillation rates.
%   - spike_rates: Spike rates.
%   - bad_channels: Channels to mark as bad for spike rates.
%   - bad_channels_hfo: Channels to mark as bad for HFO rates.
%   - prctile_thr: Percentile threshold for highlighting good channels.
%   - cmap: Colormap for the plot (optional).
%
% Output:
%   - rates_plot: The generated figure.

    if nargin < 8
        bar_color = 'b'; 
        thr_color = 'r'; 
    else
        bar_color = cmap(1, :); 
        thr_color = cmap(2, :); 
    end
    
    if size(spike_rates, 1) > size(spike_rates, 2)
        spike_rates = spike_rates'; 
    end 
    
    if size(hfo_rates, 1) > size(hfo_rates, 2)
        hfo_rates = hfo_rates'; 
    end 
    
    rates_plot = figure('Position', get(0, 'Screensize')); 

    subplot(2, 1, 1)
    build_rate_bar(spike_rates, ...
                   'color', bar_color, ...
                   'xticklabels', patientStructFull.listFull, ...
                   'titlestr', 'Spike rates', ...
                   'bad_channels', bad_channels, ...
                   'good_channels', find(spike_rates > prctile(spike_rates, prctile_thr)), ...
                   'fontsize', 12);   
    hold on;  
    line(xlim, [prctile(spike_rates, prctile_thr), prctile(spike_rates, prctile_thr)], ...
         'color', thr_color, 'LineWidth', 1);
     
    legend("Spike rates", "Threshold")
    suptitle("Patient " + patient)
    
    subplot(2, 1, 2)
    build_rate_bar(hfo_rates, ...
                   'color', bar_color, ...
                   'xticklabels', patientStructFull.listFull, ...
                   'titlestr', 'HFO rates', ...
                   'bad_channels', bad_channels_hfo, ...
                   'good_channels', find(hfo_rates > prctile(hfo_rates, prctile_thr)), ...
                   'fontsize', 12); 
    hold on;
    line(xlim, [prctile(hfo_rates, prctile_thr), prctile(hfo_rates, prctile_thr)], ...
         'color', thr_color, 'LineWidth', 1);
     
    legend("HFO rates", "Threshold")
    
    hold off;
    
end
