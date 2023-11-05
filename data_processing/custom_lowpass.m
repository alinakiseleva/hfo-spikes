function filtered_signal = custom_lowpass(original_signal, CutoffFrequency, Fs)
% custom_lowpass - Apply a custom low-pass filter to a signal
%
% Syntax:
%   filtered_signal = custom_lowpass(original_signal, CutoffFrequency, Fs)
%
% Description:
%   The `custom_lowpass` function filters an input signal using a custom
%   low-pass filter with the specified cutoff frequency.
%
% Inputs:
%   - original_signal: The input signal to be filtered.
%   - CutoffFrequency: The cutoff frequency (in Hertz) of the low-pass filter.
%   - Fs: The sampling frequency (in Hertz) of the input signal.
%
% Outputs:
%   - filtered_signal: The filtered output signal after applying the low-pass
%     filter with the specified cutoff frequency.    

    lpFilt = designfilt('lowpassfir', ...
                         'FilterOrder', 6, ...
                         'CutoffFrequency', CutoffFrequency, ...
                         'DesignMethod', 'window', ...
                         'Window', {@kaiser,3}, ...
                         'SampleRate', Fs);

    filtered_signal = filtfilt(lpFilt, original_signal);  
    
end