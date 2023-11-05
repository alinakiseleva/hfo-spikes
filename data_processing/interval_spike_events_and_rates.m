function [events, bars] = interval_spike_events_and_rates(paths, filename, labels, resample_frequency)
% interval_spike_events_and_rates - Calculate Spike Events and Rates in Intervals
%
% Description:
%   The `interval_spike_events_and_rates` function loads spike data from multiple
%   sources (e.g., Delphos, CNN, aligned) and calculates spike events and rates for
%   specified channel labels in a given recording interval.
%
% Inputs:
%   - paths: A structure containing file paths and configurations.
%   - filename: The name of the recording file.
%   - labels: A vector containing channel labels for which spike events and rates
%     will be calculated.
%   - resample_frequency: The resampling frequency for the spike data.
%
% Outputs:
%   - events: A structure containing spike events for each specified channel. The
%     structure fields include 'delphos', 'CNN', and 'aligned', each holding unique
%     spike event times.
%   - bars: A structure containing spike rates for each specified channel. It
%     includes the spike counts from 'delphos' and 'CNN' for each channel.

    delphos_spikes = load_detected_spikes(paths.delphos_results_path, filename, resample_frequency); 
    cnn_spikes = load_detected_spikes(paths.cnn_delphos_results_path, filename, resample_frequency); 
    aligned_spikes = load_detected_spikes(paths.cnn_delphos_aligned_path, filename, resample_frequency); 

    events = [];
    bars = []; 

    for ch = labels
        events(ch).delphos = unique(delphos_spikes(delphos_spikes(:,1) == ch,2)); 
        events(ch).CNN = unique(cnn_spikes(cnn_spikes(:,1) == ch,2)); 
        events(ch).aligned = unique(aligned_spikes(aligned_spikes(:,1) == ch,2)); 

        bars.CNN(ch) = length(events(ch).CNN);
        bars.delphos(ch) = length(events(ch).delphos); 
    end
    
end 