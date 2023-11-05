function minutes = get_duration(patientStructFull)
% get_duration - Calculate the Total Duration of EEG Data in Minutes
%
% Description:
%   The `get_duration` function calculates the total duration of EEG data in
%   minutes contained within the `patientStructFull` structure. 
%
% Inputs:
%   - patientStructFull: A structure containing EEG data with epoch information.
%
% Output:
%   - minutes: The total duration of EEG data in minutes.
    
    minutes = 0; 
    
    for epoch = 1:length(patientStructFull.epochsList)
        minutes = minutes + length(patientStructFull.epochsList(epoch).X_raw) / patientStructFull.epochsList(epoch).Fs / 60;
    end

end