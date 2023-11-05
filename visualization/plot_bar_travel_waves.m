function [bar_travelling_waves] = plot_bar_travel_waves(patient, patientStructFull, bad_channels)
% PLOT_BAR_TRAVEL_WAVES generates a stacked bar plot of traveling waves and non-traveling waves rates.
%
% Syntax:
%   bar_travelling_waves = plot_bar_travel_waves(patient, patientStructFull, bad_channels, paths, flag_results, flag_use_every_second_channel)
%
% Input:
%   - patient: Patient identifier.
%   - patientStructFull: Data structure for the patient.
%   - bad_channels: Channels to mark as bad.
%
% Output:
%   - bar_travelling_waves: The generated figure.

    [trav_waves_rates] = get_travelling_waves_rates(patientStructFull); 
    spike_rate = get_patientStructFull_spike_rates(patientStructFull);

    bar_travelling_waves = figure('Position', get(0, 'Screensize')); 
    
    if size(spike_rate, 1) > size(spike_rate, 2)
        spike_rate = spike_rate'; 
    end 
    
    if size(trav_waves_rates, 1) > size(trav_waves_rates, 2)
        trav_waves_rates = trav_waves_rates'; 
    end 
    
    build_rate_bar([spike_rate - trav_waves_rates; trav_waves_rates]',... 
                   'xticklabels', patientStructFull.listFull, ...
                   'titlestr', ['Travelling waves, patient ' num2str(patient)],...
                   'bad_channels', bad_channels, ... 
                   'style', 'stacked', ...
                   'legend', ["Non-travelling waves", "Travelling waves"], ...
                   'fontsize', 12);    
    
end