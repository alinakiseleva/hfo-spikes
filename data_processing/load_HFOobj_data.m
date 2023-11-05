function [patientStruct, skip_file, HFOobj] = load_HFOobj_data(data_path, filename, freq_range)
% load_HFOobj_data - Load HFOobj Data and Build PatientStruct
%
% Syntax:
%   [patientStruct, skip_file, HFOobj] = load_HFOobj_data(data_path, filename, freq_range)
%
% Description:
%   This function loads HFOobj data from a file and builds a patientStruct
%   structure from the HFOobj. HFOobj is an object used for High-Frequency
%   Oscillation (HFO) detection and analysis in electrophysiological data.
%
% Input:
%   - data_path: A string representing the path to the directory where the
%     HFOobj data file (specified by 'filename') is located.
%
%   - filename: A string representing the filename of the HFOobj data to be
%     loaded.
%
%   - freq_range (optional): A string specifying the frequency range of the
%     EEG data in the HFOobj. If not provided, it defaults to 'raw'.
%
% Output:
%   - patientStruct: A structure containing EEG data and relevant information
%     extracted from the loaded HFOobj data.
%
%   - skip_file: A boolean flag indicating whether the data file was successfully
%     loaded ('false') or not ('true'). If 'skip_file' is 'true', 'patientStruct'
%     will be an empty array.
%
%   - HFOobj: The HFOobj object loaded from the file if it exists; otherwise, it
%     is an empty array.

    if ~exist('freq_range', 'var') 
        freq_range = 'raw'; 
    end

    data = load(fullfile(data_path, filename)); 
    
    if isfield(data, 'HFOobj')
        
         HFOobj = data.HFOobj; 
         patientStruct = build_patientStruct_from_HFOobj(HFOobj, freq_range); 
         skip_file = false; 
         
    else
        
        warning('Wrong data type in %s', filename); 
        patientStruct = []; 
        skip_file = true; 
        
    end 

end 