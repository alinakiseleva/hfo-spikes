function hfo_timestamps = extract_hfo(HFOobj, event_type, Fs)
% EXTRACT_HFO - Extract High-Frequency Oscillation (HFO) timestamps
%
% Syntax:
%   hfo_timestamps = extract_hfo(HFOobj, event_type, Fs)
%
% Description:
%   The `extract_hfo` function extracts the timestamps of High-Frequency
%   Oscillations (HFOs) from an array of HFO objects (`HFOobj`). It retrieves
%   the start and end times of events with the specified `event_type` for
%   each channel within `HFOobj`. The timestamps are then adjusted according to
%   the sampling frequency (`Fs`).
%
% Inputs:
%   - HFOobj: An array of HFO objects containing HFO event information.
%   - event_type: The type of HFO event to extract timestamps for: 
%       1 - Ripples, 
%       2 - Fast Ripples, 
%       3 - Co-occurring Ripples and Fast Ripples.
%   - Fs: The sampling frequency of the EEG data.
%
% Outputs:
%   - hfo_timestamps: A matrix where each row contains information about an
%     extracted HFO event. The columns represent:
%     1. Channel index.
%     2. Start time of the HFO event (in samples).
%     3. End time of the HFO event (in samples).

    hfo_timestamps = []; 

    for ch = 1:length(HFOobj)
        event_ids = HFOobj(ch).result.mark == event_type;  
        t_start = HFOobj(ch).result.autoSta(event_ids); 
        t_end = HFOobj(ch).result.autoEnd(event_ids); 
        
        if length(t_start) ~= length(t_end)
            error('Wrong timepoints with %d start and %d end values', length(t_start), length(t_end))
        end 
        
        hfo_timestamps = [hfo_timestamps; repmat(ch, length(t_start), 1), t_start' .* Fs, t_end' .* Fs]; 
    end 
    
end 