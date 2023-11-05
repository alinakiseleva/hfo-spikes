function patientStruct = build_patientStruct_from_HFOobj(HFOobj, freq_range)
% build_patientStruct_from_HFOobj - Create a patientStruct from HFOobj data
%
% Syntax:
%   patientStruct = build_patientStruct_from_HFOobj(HFOobj, freq_range)
%
% Description:
%   The `build_patientStruct_from_HFOobj` function constructs a `patientStruct`
%   from High-Frequency Oscillation (HFO) data.
%
% Inputs:
%   - HFOobj: An array of HFO objects, each containing HFO data.
%   - freq_range: A string specifying the frequency range ('raw', 'filt', or
%     'filtFR') to use when extracting the signal data.
%
% Outputs:
%   - patientStruct: A structure with the following fields:
%       - patientStruct.epochsList.X_raw: A matrix of raw signal data.
%       - patientStruct.epochsList.chan_names: A vector of channel names.
%       - patientStruct.epochsList.Fs: The sampling frequency of the recording.
%
    X_raw = []; 
    for i = 1:length(HFOobj)
        
        switch freq_range
            case 'raw'
                signal = HFOobj(i).result.signal; 
            case 'filt'
                signal = HFOobj(i).result.signalFilt; 
            case 'filtFR'
                signal = HFOobj(i).result.signalFiltFR; 
            otherwise
                error('Unexpected frequency range value: %s', freq_range)
        end
        
        if signal == 0
            signal = repmat([0], size(HFOobj(i).result.time)); 
        end 
        
        if size(signal, 1) > size(signal, 2)
            signal = signal';
        end 
        
        X_raw = [X_raw; signal]; 
    end 
    
    chan_names = [HFOobj(:).label]; 
    del_strings = {'EEG', ' ', '_'}; 
 
    patientStruct = []; 
    patientStruct.epochsList.X_raw = X_raw; 
    patientStruct.epochsList.chan_names = del_repeating_ch_names(trim_ch_names(chan_names, del_strings)); 
    patientStruct.epochsList.Fs = size(HFOobj(1).result.signal, 2) / HFOobj(1).result.time(end);
end 
