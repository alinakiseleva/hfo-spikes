function [hfo_rates, spike_rates] = load_full_rates(paths, patientStructFull, spike_path)
% load_full_rates - Load and Compute HFO and Spike Rates
%
% Description:
%   The `load_full_rates` function loads high-frequency oscillation (HFO) rates and
%   spike rates from specified data and spike files. It calculates the rates and
%   accounts for any bad channels.
%
% Inputs:
%   - paths: A structure containing file paths and configuration.
%   - patientStructFull: The patientStructFull structure containing processed EEG
%     data and spike information.
%   - spike_path: (Optional) The path to the directory containing spike data.
%     Defaults to `paths.cnn_delphos_aligned_path`.
%
% Outputs:
%   - hfo_rates: A vector containing HFO rates for each channel.
%   - spike_rates: A vector containing spike rates for each channel.

    if nargin < 3
        spike_path = paths.cnn_delphos_aligned_path; 
    end 
    
    minutes = get_duration(patientStructFull); 
    chan_names = patientStructFull.listFull; 
    
    bad_channels = get_bad_channels(paths.bad_channels_path, paths.list_name, chan_names);
    bad_channels_hfo = get_bad_channels(paths.bad_channels_hfo_path, paths.list_name, chan_names);
    
    % hfo
    filename = [ls(fullfile(paths.data_path, 'HFO_*rate*_*.mat')) ls(fullfile(paths.data_path, 'HFO_*result*.mat'))]; 
    load(fullfile(paths.data_path, filename)); 
    
    hfo_rates = sum(N_m_RFR, 1); 
    hfo_rates = hfo_rates / minutes; 
    hfo_rates(bad_channels_hfo) = 0; 
    
    % spikes 
    filenames = cellstr(ls(fullfile(spike_path, '*.mat')));
    spike_rates = zeros(size(chan_names));
    for num = 1:length(filenames)
        filename = filenames{num};
        spikes = load_detected_spikes(spike_path, filename, 1); 
        for i = 1:length(chan_names)
            spike_rates(i) = spike_rates(i) + length(unique(spikes(spikes(:,1) == i, 2))); 
        end 
    end
    
    spike_rates = spike_rates / minutes; 
    spike_rates(bad_channels) = 0; 
    
end 