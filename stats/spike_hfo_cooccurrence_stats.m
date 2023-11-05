function stat = spike_hfo_cooccurrence_stats(patients, config, tolerance)
 % Calculate statistics related to spike-HFO co-occurrence for a list of patients.
% Input:
%   - patients: a list of patient identifiers.
%   - config: a configuration structure.
%   - tolerance: the temporal tolerance for spike-HFO co-occurrence in seconds (default: 0.05 seconds).
% Output:
%   - stat: a matrix containing calculated statistics for each patient.

    if nargin < 3
        tolerance = 0.05; % s 
    end 

    hfo_spike_coocurrence = containers.Map;
    hfo_spike_coocurrence_max_ch = containers.Map;
    hfo_max_ch = containers.Map; 
    num_hfo = containers.Map; 
    num_hfo_max_ch = containers.Map; 

    for patient = patients

        paths = build_patient_paths(config, patient); 

        filename = [ls(fullfile(paths.data_path, 'HFO_*rate*_*.mat')) ls(fullfile(paths.data_path, 'HFO_*result*.mat'))]; 

        if isfile(fullfile(paths.data_path, filename))
            load(fullfile(paths.data_path, filename));

            hfo_rates = sum(N_m_RFR); 
            [~, ind] = max(hfo_rates); 

            max_ch = ind; 
            num_hfo_max_ch(num2str(patient)) = hfo_rates(ind); 
        else
            error('Not found HFO results'); 
        end 

        filenames = natsort(cellstr(ls(fullfile(paths.data_path, 'HFO*.mat'))))'; 
        k = 0; 
        num_hfo(num2str(patient)) = 0; 
        hfo_spike_coocurrence_max_ch(num2str(patient)) = 0;

        for filename = filenames
            filename = char(filename); 
            if isfile(fullfile(paths.data_path, filename)) && exist(fullfile(paths.cnn_delphos_results_path, filename))

                [patientStruct, skip_file, HFOobj] = load_HFOobj_data(paths.data_path, filename);  

                if ~skip_file

                    disp(filename)

                    Fs = size(HFOobj(1).result.signal, 2) / HFOobj(1).result.time(end); 
                    chan_names = patientStruct.epochsList.chan_names; 

                    bad_channels = get_bad_channels(paths.bad_channels_path, paths.list_name, chan_names);
                    bad_channels_hfo = get_bad_channels(paths.bad_channels_hfo_path, paths.list_name, chan_names);
                    bad_channels  = [bad_channels, bad_channels_hfo]; 


                    spike_timestamps = load_detected_spikes(paths.cnn_delphos_results_path, filename, Fs); 

                    hfo_timestamps = extract_hfo(HFOobj, 3, Fs); 

                    for ch = 1:length(HFOobj)
                        if sum(spike_timestamps(:, 1) == ch) > 0 && sum(hfo_timestamps(:, 1) == ch) > 0 ...
                                && ~ismember(ch, bad_channels)
                            spike_t_ch = spike_timestamps(spike_timestamps(:, 1) == ch, 2);
                            hfo_t_ch = hfo_timestamps(hfo_timestamps(:, 1) == ch, 2:3);

                            num_hfo(num2str(patient)) = num_hfo(num2str(patient)) + length(hfo_t_ch); 

                            for spike_t = spike_t_ch'
                                if any(spike_t > hfo_t_ch(:, 1) - round(tolerance * Fs) & spike_t < hfo_t_ch(:, 2) + round(tolerance * Fs))
                                    k = k + 1; 
                                end 
                            end
                        end 
                    end 

                    spike_t_ch = spike_timestamps(spike_timestamps(:, 1) == max_ch, 2);
                    hfo_t_ch = hfo_timestamps(hfo_timestamps(:, 1) == max_ch, 2:3);

                    hfo_max_ch(num2str(patient)) = chan_names(max_ch); 

                    for spike_t = spike_t_ch'
                        if any(spike_t > hfo_t_ch(:, 1) - tolerance * Fs & spike_t < hfo_t_ch(:, 2) + tolerance * Fs)
                            hfo_spike_coocurrence_max_ch(num2str(patient)) = hfo_spike_coocurrence_max_ch(num2str(patient)) + 1; 
                        end 
                    end 
                end 
            end 
        end 
        hfo_spike_coocurrence(num2str(patient)) = k; 
    end 

    stat = ["patient", ...
            "hfo all ch", "hfo + spikes all ch", ...
            "hfo max ch name", "hfo max ch", ...
            "hfo + spikes max ch"]; 

    for key = keys(hfo_spike_coocurrence)
        stat = [stat; ...
                key{1}, ...
                num_hfo(key{1}), hfo_spike_coocurrence(key{1}), ... 
                hfo_max_ch(key{1}), num_hfo_max_ch(key{1}), ...
                hfo_spike_coocurrence_max_ch(key{1})]; 
    end 

    writematrix(stat, fullfile(paths.save_root, paths.spike_hfo_coocurrence_fname)); 
end 
