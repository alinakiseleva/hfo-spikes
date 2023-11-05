function spike_rate = get_patientStructFull_spike_rates(patientStructFull)
% get_patientStructFull_spike_rates - Calculate Spike Rates for Channels in patientStructFull
%
% Description:
%   The `get_patientStructFull_spike_rates` function calculates spike rates for
%   each channel in the patientStructFull structure. It counts the total number
%   of spikes for each channel and normalizes it by the duration of the recorded
%   data to obtain spike rates in spikes per minute.
%
% Inputs:
%   - patientStructFull: A structure containing processed EEG data and spike
%     information.
%
% Output:
%   - spike_rate: A vector of spike rates for each channel, expressed in spikes
%     per minute.

    minutes = get_duration(patientStructFull); 
    
    chan_names = patientStructFull.epochsList.chan_names; 
   
    spike_rate = zeros(size(chan_names));
    
    for num = 1:length(patientStructFull.epochsList)
        
        if ~isempty(patientStructFull.epochsList(num).spikes)
            
            for ll = 1:length(chan_names)
                myElec = chan_names(ll);
                [~,totalSpikes,~] =  retrieveSpikeRate(patientStructFull.epochsList(num).spikes, myElec); 
                spike_rate(ll) = spike_rate(ll) + totalSpikes;
            end
            
        end 
        
    end 
    
    spike_rate = spike_rate / minutes; 

end 




