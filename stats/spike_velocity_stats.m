function stat = spike_velocity_stats(patients, config, low_thr_s)
 % Calculate statistics related to spike propagation velocity for a list of patients.
% Input:
%   - patients: a list of patient identifiers.
%   - config: a configuration structure.
%   - low_thr_s: the lower time threshold for considering spike propagation (default: 0.01 seconds).
% Output:
%   - stat: a matrix containing calculated statistics for each patient.

    if nargin < 3
        low_thr_s = 0.01; % s 
    end
    
    params = config.params; 

    spike_velocities = containers.Map; 

    for patient = patients 

        paths = build_patient_paths(config, patient); 

        patientStructFull = create_patientStructFull(paths, ...
                                                     patient, ...
                                                     'flag_results', params.flag_results, ...
                                                     'flag_use_every_second_channel', params.flag_use_every_second_channel, ...
                                                     'overwrite', params.overwrite_analysis, ...
                                                     'seq_win_s', params.seq_win_s); 


        adjMatrix = get_adjMatrix(patientStructFull); 
        spike_rate = get_patientStructFull_spike_rates(patientStructFull);
        outstr = sum(adjMatrix, 2) .* spike_rate; 
        [~, max_ch] = max(outstr); 

        instr_chs = find(adjMatrix(max_ch, :)); 

        Fs = patientStructFull.epochsList(1).Fs; 
        seq_win = round(seq_win_s * Fs); 

        low_thr = round(low_thr_s * Fs); 

        max_ch_coords = cell2mat(patientStructFull.leadLocations(max_ch, 2:4)); 
        instr_chs_coords = cell2mat(patientStructFull.leadLocations(instr_chs, 2:4)); 

        pat_prop_speed = []; 

        for epoch = 1:length(patientStructFull.epochsList)
            for spk_time = find(patientStructFull.epochsList(epoch).spikes.my_rast(:, max_ch))' 
                samples = spk_time:spk_time+seq_win; 
                if any(samples > size(patientStructFull.epochsList(epoch).spikes.my_rast, 1)) 
                    samples = [spk_time:size(patientStructFull.epochsList(epoch).spikes.my_rast, 1)]; 
                end 
                prop_chs = sum(patientStructFull.epochsList(epoch).spikes.my_rast(samples, instr_chs), 1);
                if any(prop_chs)
                    for ch = find(prop_chs)
                        prop_time = find(patientStructFull.epochsList(epoch).spikes.my_rast(samples, instr_chs(ch))', 1, 'first'); 
                        if prop_time > low_thr 
                            prop_distance = norm(max_ch_coords - instr_chs_coords(ch)) / 1000; 
                            pat_prop_speed = [pat_prop_speed; prop_distance / (prop_time / Fs)]; 
                        end 
                    end 
                end
            end 
        end
        spike_velocities(num2str(patient)) = mean(pat_prop_speed); 
    end 


    stat = [];
    for key = keys(spike_velocities)
        stat = [stat; ...
                str2num(key{1}), ...
                spike_velocities(key{1})]; 
    end 

    writematrix(stat, fullfile(paths.save_root, paths.spike_velocity_fname)); 

end 
