function spikes = load_detected_spikes(results_path, filename, Fs)
% load_detected_spikes - Load and Convert Detected Spike Events
%
% Description:
%   The `load_detected_spikes` function loads detected spike events from a results
%   file, converts the time points to a specified sampling frequency, and returns
%   the spike events as a matrix.
%
% Inputs:
%   - results_path: The path to the directory containing the results file.
%   - filename: The name of the results file.
%   - Fs: The sampling frequency for time conversion (1 if no conversion needed).
%
% Outputs:
%   - spikes: A matrix with two columns representing spike events. The first column
%     contains channel identifiers, and the second column contains spike event times
%     in the specified time units.
    
    detected_events = load(fullfile(results_path, filename)); 
    detected_events = detected_events.(char(fieldnames(detected_events))); 
    
    spikes = [];
    spikes(:,1) = [detected_events(:,1)]; 
    if Fs == 1
        spikes(:,2) = [detected_events(:,2)]; 
    else
        spikes(:,2) = round([detected_events(:,2)].*Fs);
    end 
    
    spikes = spikes(spikes(:,2) > 0, :); 
    
end 