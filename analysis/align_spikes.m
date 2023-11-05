function align_spikes(paths, varargin)
% ALIGN_SPIKES Align detected Interictal Spikes.
%
% Syntax:
%   align_spikes(paths, 'Name', 'Value')
%
% Description:
%   The align_spikes function aligns HFO spikes detected using a CNN model
%   for a patient. It preprocesses the data, aligns the spikes, and saves
%   the aligned spikes in a new file.
%
% Input:
%   - paths: A structure containing various file paths for the patient.
%   - 'Name', 'Value' (optional): Additional options for spike alignment.
%
% Optional values:
%   - 'overwrite' (logical): Flag to overwrite existing aligned spikes (default: false).
%   - 'delta' (double): Spike alignment delta in seconds (default: 0.2).
%   - 'align_interval' (double): Time window (ms) for spike alignment (default: 80).
%   - 'path_to_align' (char): Path to the directory containing detection results (default: paths.cnn_delphos_results_path).

    p = inputParser();
    
    addOptional(p, 'overwrite', false);
    addOptional(p, 'delta', 0.2);
    addOptional(p, 'align_interval', 80);
    addOptional(p, 'path_to_align', paths.cnn_delphos_results_path); 
    
    parse(p, varargin{:});

    overwrite = p.Results.overwrite; 
    delta = p.Results.delta; 
    align_interval = p.Results.align_interval; 
    path_to_align = p.Results.path_to_align; 

    
    filenames = natsortfiles(cellstr(ls(fullfile(path_to_align, 'HFO*.mat'))))'; 
    
    if ~isempty(filenames)

        for filename = filenames

            filename = char(filename); 
            result_file = fullfile(paths.cnn_delphos_aligned_path, filename); 
            
            if isfile(fullfile(path_to_align, filename))
                
                if ~isfile(result_file) || overwrite 
                    
                    [patientStruct, skip_file]  = load_HFOobj_data(paths.data_path, filename); 

                    if ~skip_file 
                        
                        patientStruct = detrend_signal(patientStruct); 
                        patientStruct = notch_filter(patientStruct, 50); 

                        spikes = load_detected_spikes(path_to_align, filename, patientStruct.epochsList.Fs); 
                        aligned_spikes = get_aligned_spikes(patientStruct, spikes, delta, align_interval); 

                        Fs = patientStruct.epochsList.Fs; 
                        aligned_spikes(:, 2) = aligned_spikes(:, 2) / Fs; 

                        save(result_file, "aligned_spikes"); 
                        
                    else 
                        fprintf('Skipped wrong data type: %s', filename); 
                    end 
                    
                else
                    warning(['Already exist detection: ' result_file]) 
                end 
                
            else
                error('Not found detection results in %s', path_to_align)
            end
        end   
        
    else 
        error('Not found data files in %s', paths.data_path); 
    end
    
end

