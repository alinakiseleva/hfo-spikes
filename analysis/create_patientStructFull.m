function patientStructFull = create_patientStructFull(paths, patient, varargin)
% Create a patientStructFull structure by processing EEG data for multiple files.
%
% Input:
%   - paths (struct): A structure containing file paths and configuration.
%   - patient (string): The patient identifier.
%
% Optional:
%    - 'flag_results' (string): Specifies which spike detection results to use ('delphos', 'cnn', 'aligned'). Default is 'aligned'.
%    - 'flag_use_every_second_channel' (logical): Use every second channel for processing. Default is false.
%    - 'overwrite' (logical): Set to true to overwrite existing patientStructFull, if any. Default is false.
%    - 'seq_win_s' (double): The time window for spike sequence extraction in seconds. Default is 0.1.
%    - 'onsetElectrodes' (string): Array, containing onset electode names
%    - 'State' (string): 'asleep' (default) or 'awake' 
%
% Output:
%   patientStructFull (struct): The patientStructFull structure containing
%   processed EEG data and spike information, with subfields:
%   - epochsList: 
%       - Fs: Sampling frequency in Hertz (Hz).
%       - X_raw: Matrix of EEG data, with channels as rows and 
%       time samples as columns.
%       - chan_names: Cell array containing channel names.
% - State: Patient's state during EEG recording (e.g., 'awake' or 'asleep').
% - spikes: 
%       - spk_order: Matrix indicating the order of spike occurrences 
%       in EEG data.
%       - rast_order: Cell array specifying the order of channels 
%       associated with spike events.
%       - my_rast: Matrix marking spike events in EEG data.
% - localization: Localization of iEEG electrodes
% - patient: Patient Identifier
% - leadlocations: Electrodes 3D coordinates (x, y, z).
% - listFull: Array containing the names of all EEG channels in the dataset.
% - onsetElectrodes (Optional)

    p = inputParser();
    
    addOptional(p, 'flag_results', 'aligned');
    addOptional(p, 'flag_use_every_second_channel', false);
    addOptional(p, 'overwrite', false);
    addOptional(p, 'seq_win_s', 0.1);
    addOptional(p, 'onsetElectrodes', '');
    addOptional(p, 'State', 'asleep');

    parse(p, varargin{:});
       
    switch p.Results.flag_results 
        case 'delphos'
            results_to_use = paths.delphos_results_path; 
        case 'cnn'
            results_to_use = paths.cnn_delphos_results_path; 
        case 'aligned'
            results_to_use = paths.cnn_delphos_aligned_path; 
    end 

    patientStructFull = []; 
    patientStructFull.epochsList = []; 
    
    if p.Results.flag_use_every_second_channel
        patientStructFull_save_filename = ['_half_chs_' paths.patientStructFull_fname]; 
    end
    
    results_file = fullfile(paths.patientStructFull_path, [p.Results.flag_results patientStructFull_save_filename]); 
    
    if isfile(results_file) && p.Results.overwrite == false 
        load(results_file); 

    else 
        filenames = natsort(cellstr(ls(fullfile(paths.data_path, 'HFO*.mat'))))'; 
        
        for filename = filenames
            filename = char(filename); 

            if isfile(fullfile(paths.data_path, filename)) 
                data = load(fullfile(paths.data_path, filename)); 
                
                if isfield(data, 'HFOobj')
                    
                    HFOobj = data.HFOobj; 
                    disp(filename)

                    patientStruct = build_patientStruct_from_HFOobj(HFOobj, 'raw');
                    X_raw = patientStruct.epochsList.X_raw; 
                    chan_names = patientStruct.epochsList.chan_names; 
                    seq_win = round(p.Results.seq_win_s * patientStruct.epochsList.Fs); 

                    if size(X_raw, 1) < size(X_raw, 2) 
                        X_raw = X_raw'; 
                    end 

                    if size(chan_names, 1) < size(chan_names, 2) 
                        chan_names = chan_names'; 
                    end 
                        
                    if ~exist('listFull', 'var')
                        listFull = chan_names; 
                    end 
                    
                    use_channels = ones(length(listFull), 1);
                    if p.Results.flag_use_every_second_channel
                        [~, use_channels] = bipolar_to_monopolar_ch_names(listFull); 
                    end
                   
                    [add_chs, exclude_chs] = compare_channels(listFull, chan_names); 
                    bad_channels = get_bad_channels(paths.bad_channels_path, paths.list_name, chan_names);
                    spikes = load_detected_spikes(results_to_use, filename, patientStruct.epochsList.Fs); 
                    
                    if ~isempty(bad_channels)
                        spikes = spikes(~sum(spikes(:, 1) == bad_channels, 2), :); 
                    end 
                    
                    my_rast = zeros(size(X_raw));
                    my_rast(sub2ind(size(my_rast), spikes(:,2), spikes(:,1))) = 1;

                    chan_names(exclude_chs) = ''; 
                    X_raw(:, exclude_chs) = []; 
                    my_rast(:, exclude_chs) = []; 

                    for add_ch = add_chs' 
                        X_raw =  [X_raw(:, 1:add_ch-1), zeros(length(X_raw(:,1)), 1), X_raw(:, add_ch:end)]; 
                        my_rast =  [my_rast(:, 1:add_ch-1), zeros(length(my_rast(:,1)), 1), my_rast(:, add_ch:end)]; 
                        chan_names = [chan_names(1:add_ch-1); listFull(add_ch); chan_names(add_ch:end)]; 
                    end 

                    assert(length(listFull) == length(chan_names), 'Different channels used in %s', patient); 
                    assert(size(X_raw,2) == length(listFull), 'Channels error in %s', patient); 

                    my_rast(:, ~use_channels) = 0; 
                    
                    num = length(patientStructFull.epochsList) + 1; 
                    patientStructFull.epochsList(num).X_raw = X_raw; 
                    patientStructFull.epochsList(num).chan_names = chan_names;
                    patientStructFull.epochsList(num).Fs = patientStruct.epochsList.Fs; 
                    patientStructFull.epochsList(num).State = p.Results.State; 
                    patientStructFull.epochsList(num).spikes.spk_order = get_spike_order(my_rast, chan_names, seq_win); 
                    patientStructFull.epochsList(num).spikes.rast_order = chan_names; 
                    patientStructFull.epochsList(num).spikes.my_rast = my_rast;  
                    
                end 
            end 
        end 

        leadLocations = {}; 
        localization = get_localization(paths.localization_path, paths.list_name, 'acpc'); 
        for i = 1:numel(listFull)
            split = strsplit(listFull{i}, '-');
            ind = strcmp(split(1), localization(:,1))==1;
            leadLocations(i, 1:4) = [listFull(i), localization(ind, 2:4)]; 
        end

        patientStructFull.localization = localization; 
        patientStructFull.Patient = patient;  
        patientStructFull.leadLocations = leadLocations; 
        patientStructFull.listFull = listFull; 
        patientStructFull.onsetElectrodes = p.Results.onsetElectrodes; 

        save(results_file, "patientStructFull", '-v7.3'); 
    end
end
