function patientStruct = detrend_signal(patientStruct)
% detrend_signal - Remove linear trends from EEG data
%
% Syntax:
%   patientStruct = detrend_signal(patientStruct)
%
% Description:
%   The `detrend_signal` function removes linear trends from EEG data within
%   a `patientStruct`. This is particularly useful for removing slow drifts or
%   artifacts from the EEG signal.
%
% Inputs:
%   - patientStruct: A structure containing EEG data.
%
% Outputs:
%   - patientStruct: The input `patientStruct` with linear trends removed from
%     the EEG data.

    X_raw = patientStruct.epochsList.X_raw; 
    if size(X_raw, 1) > size(X_raw, 2)
        X_raw = X_raw'; 
    end 

    for ch = 1:size(X_raw, 1)
        X_raw(ch, :) = detrend(X_raw(ch, :)); 
    end 
    
    patientStruct.epochsList.X_raw = X_raw; 

end 