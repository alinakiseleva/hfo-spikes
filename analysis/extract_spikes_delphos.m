function [spikes, features, tfz, tf, f] = extract_spikes_delphos(patientStruct) 
% extract_spikes_delphos - Extracts Interictal Spikes detection using the Delphos algorithm.
%
% Syntax:
%   [spikes, features, tfz, tf, f] = extract_spikes_delphos(patientStruct)
%
% Description:
%   The extract_spikes_delphos function detects and extracts Interictal Spikes 
%   in iEEG data using the Delphos algorithm. It returns information about
%   detected spikes, spike features, time-frequency information, and frequency
%   information.
%
% Input:
%   - patientStruct: A structure containing iEEG data and information.
%
% Output:
%   - spikes: A matrix containing information about detected HFOs.
%     - Column 1: Channels where Spikes were detected.
%     - Column 2: Time of Spikes occurrence in milliseconds.
%   - features: Extracted features of detected Spikes.
%   - tfz: Z-scored time-frequency representation of the signal.
%   - tf: Time-frequency representation of the signal.
%   - f: List of frequencies.

    X_raw = patientStruct.epochsList.X_raw;
    if size(X_raw, 1) > size(X_raw, 2)
        X_raw = X_raw'; 
    end

    Nch = length(patientStruct.epochsList.chan_names);
    labels = [1:Nch];

    Fs = patientStruct.epochsList.Fs;

    [results, features, tfz, tf, f] = Delphos_detector(X_raw(labels,:), labels, 'SEEG', Fs, {'Spk'}, [], [], 40, []);
    
    spikes = [];
    spikes(:,1) = [results.markers(:).channels]; 
    spikes(:,2) = [results.markers(:).position]; 

end 