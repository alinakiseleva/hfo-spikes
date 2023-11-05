function [trav_waves_rates] = get_travelling_waves_rates(patientStructFull)
% get_travelling_waves_rates - Calculate Traveling Waves Rates
%
% Description:
%   The `get_travelling_waves_rates` function calculates the rate of traveling
%   waves for each channel in a `patientStructFull` structure. Traveling waves
%   are detected by analyzing spike orders across epochs.
%
% Inputs:
%   - patientStructFull: A structure containing patient data, including spike
%     order information for each epoch.
%
% Output:
%   - trav_waves_rates: A column vector containing the rates of traveling waves
%     for each channel, calculated in spikes per minute.

    ch_names = patientStructFull.listFull; 
    trav_waves_rates = zeros(size(ch_names)); 

	minutes = get_duration(patientStructFull); 

    for epoch = 1:length(patientStructFull.epochsList)
          
        spk_order = patientStructFull.epochsList(epoch).spikes.spk_order{1, 5}; 
        spk_order = reshape(spk_order, [1, size(spk_order, 2) * size(spk_order, 1)]); 
        spk_order = spk_order(cellfun('isclass', spk_order, 'char') & ~cellfun(@isempty, spk_order)); 

        for ch = 1:length(ch_names)
            trav_waves_rates(ch) = trav_waves_rates(ch) + sum(strcmp(spk_order, ch_names{ch})); 
        end
    end
    
    trav_waves_rates = trav_waves_rates' / minutes; 
    
end 