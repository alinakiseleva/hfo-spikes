function patientStruct = resample_patientStruct(patientStruct, new_Fs)
% RESAMPLE_PATIENTSTRUCT - Resample iEEG Data in PatientStruct
%
% Description:
%   The `resample_patientStruct` function resamples the iEEG data within the
%   `patientStruct` to change its sampling frequency to a new frequency (new_Fs).
%
% Inputs:
%   - patientStruct: The patientStruct containing iEEG data.
%   - new_Fs: The new sampling frequency in Hz.
%
% Outputs:
%   - patientStruct: The updated patientStruct with iEEG data resampled to the
%     specified new sampling frequency.

    X_raw = patientStruct.epochsList.X_raw; 
    Fs = round(patientStruct.epochsList.Fs); 

    for ch = 1:length(patientStruct.epochsList.chan_names)
        resampled_X_raw(ch, :) = resample(X_raw(ch, :), new_Fs, Fs);
    end 
    
    patientStruct.epochsList.X_raw = resampled_X_raw; 
    patientStruct.epochsList.Fs = new_Fs; 
    
end 