function run_delphos_detector(paths, overwrite)
% RUN_DELPHOS_DETECTOR Detects Interictal Spikes using the Delphos algorithm.
%
% Syntax:
%   run_delphos_detector(paths, overwrite)
%
% Description:
%   The run_delphos_detector function processes a collection of EEG data files to
%   detect Interictal Spikes using the Delphos algorithm. It
%   operates on one data file at a time, and
%   saves the results in separate files.
%
% Input:
%   - paths: A structure specifying the data and result directory paths.
%     - paths.data_path: The directory containing EEG data files.
%     - paths.delphos_results_path: The directory to store Delphos results.
%   - overwrite (optional): A logical flag indicating whether to overwrite
%     existing result files. Default is false.
%
% Output:
%   - Detected Interictal Spikes are saved in result files in the specified directory.

    if nargin < 2
        overwrite = false;
    end

    filenames = natsortfiles(cellstr(ls(fullfile(paths.data_path, 'HFO*.mat'))))'; 
    
    if ~isempty(filenames)

        for filename = filenames

            filename = char(filename); 
            result_file = fullfile(paths.delphos_results_path, filename); 

            if ~isfile(result_file) || overwrite 

                disp(filename) 

                [patientStruct, skip_file]  = load_HFOobj_data(paths.data_path, filename); 

                if ~skip_file 

                    patientStruct = detrend_signal(patientStruct); 
                    patientStruct = notch_filter(patientStruct, 50); 

                    [spikes, ~, ~, ~, ~] = extract_spikes_delphos(patientStruct); 

                    save(result_file, "spikes"); 

                else 
                    disp(['Skipped wrong data type: ' filename]); 
                end

            else
                warning(['Already exist detection: ' result_file]) 
            end
        end
        
    else
        error('Not found data files in %s', paths.data_path);     
    end    
end