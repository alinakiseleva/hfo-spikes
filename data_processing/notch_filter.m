function patientStruct = notch_filter(patientStruct, filt_freq, Q)
% notch_filter - Apply Notch Filter to EEG Signal
%
% Description:
%   The `notch_filter` function applies a notch filter to the EEG signal within
%   the `patientStruct` to attenuate specific frequencies, typically used to
%   remove powerline interference (e.g., 50/60 Hz).
%
% Inputs:
%   - patientStruct: The patientStruct containing iEEG data.
%   - filt_freq: The frequency in Hz to be filtered (e.g., 50 or 60 for powerline
%     interference).
%   - Q (optional): The quality factor of the notch filter. Default is 35.
%
% Outputs:
%   - patientStruct: The updated patientStruct with the notch-filtered EEG data.
    
    if ~exist('Q', 'var')
        Q = 35;
    end 
    
    samp_fs = patientStruct.epochsList.Fs; 
    
    Q = 35; 
    wo = filt_freq/(samp_fs/2);  
    bw = wo/Q;
    [b,a] = iirnotch(wo,bw);
     
    X_raw = patientStruct.epochsList.X_raw; 
    if size(X_raw, 1) > size(X_raw, 2)
        X_raw = X_raw'; 
    end 
    
    for ch = 1:size(X_raw, 1)
        X_raw(ch, :) = filtfilt(b, a, X_raw(ch, :)); 
    end 
    
    patientStruct.epochsList.X_raw = X_raw; 
end 