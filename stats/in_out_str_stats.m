function stat = in_out_str_stats(patients, config)
% Calculate statistics related to instrength and outstrength for a list of patients.
% Input:
%   - patients: a list of patient identifiers.
%   - config: a configuration structure.
% Output:
%   - stat: a matrix containing calculated statistics for each patient.

    params = config.params; 

    in_chs = containers.Map; 
    out_chs = containers.Map; 
    out_weighted_chs = containers.Map;

    for patient = patients

        paths = build_patient_paths(config, patient); 

        patientStructFull = create_patientStructFull(paths, ...
                                                     patient, ...
                                                     'flag_results', params.flag_results, ...
                                                     'flag_use_every_second_channel', params.flag_use_every_second_channel, ...
                                                     'overwrite', params.overwrite_analysis, ...
                                                     'seq_win_s', params.seq_win_s); 

        [in, out] = get_in_out_str(patientStructFull); 
        spike_rate = get_patientStructFull_spike_rates(patientStructFull); 

        if size(out) ~= size(spike_rate)
           out = out'; 
           in = in'; 
        end

        chan_names = patientStructFull.listFull; 

        in_chs(num2str(patient)) = strjoin(chan_names(in > prctile(in, prctile_thr)));
        out_chs(num2str(patient)) = strjoin(chan_names(out > prctile(out, prctile_thr))); 
        out_weighted_chs(num2str(patient)) = strjoin(chan_names(out.*spike_rate > prctile(out.*spike_rate, prctile_thr))); 

    end

    stat = ["patient", ...
                "Outstrength channels", ...
                "Weighted outstrength channels", ...
                "Instrength channels"]; 

    for key = keys(in_chs)
        stat = [stat; ...
                string(key{1}), ...
                out_chs(key{1}), ...
                out_weighted_chs(key{1}), ...
                in_chs(key{1})]; 
    end 

    writematrix(stat, fullfile(paths.save_root, paths.in_out_strengths_fname));
end 