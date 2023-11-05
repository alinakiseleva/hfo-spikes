function [stat] = travelling_waves_stats(patients, config)
 % Calculate statistics related to propagating spikes for a list of patients.
% Input:
%   - patients: a list of patient identifiers.
%   - config: a configuration structure.
% Output:
%   - stat: a matrix containing calculated statistics for each patient.

    params = config.params; 

    perc_travel_all_chs = containers.Map; 
    perc_travel_area_chs = containers.Map; 

    num_travelling_all_chs = containers.Map; 
    num_travelling_area_chs = containers.Map; 

    num_isolated_all_chs = containers.Map; 
    num_isolated_area_chs = containers.Map; 

    for patient = patients

        paths = build_patient_paths(config, patient); 

        patientStructFull = create_patientStructFull(paths, ...
                                                     patient, ...
                                                     'flag_results', params.flag_results, ...
                                                     'flag_use_every_second_channel', params.flag_use_every_second_channel, ...
                                                     'overwrite', params.overwrite_analysis, ...
                                                     'seq_win_s', params.seq_win_s); 

        [~, out] = get_in_out_str(patientStructFull);                                          
        spike_rates = get_patientStructFull_spike_rates(patientStructFull);

        if size(out) ~= size(spike_rates)   
            out = out'; 
        end 

        trav_waves_rates = get_travelling_waves_rates(patientStructFull); 

        if size(trav_waves_rates) ~= size(spike_rates)
            trav_waves_rates = trav_waves_rates'; 
        end 

        percent_travel = trav_waves_rates ./ spike_rates;
        percent_travel(isnan(percent_travel)) = 0; 

        area_chs_inds = find(out .* spike_rates > prctile(out .* spike_rates, prctile_thr)); 

        perc_travel_all_chs(num2str(patient)) = mean(percent_travel);
        perc_travel_area_chs(num2str(patient)) = mean(percent_travel(area_chs_inds)); 

        num_travelling_all_chs(num2str(patient)) = mean(trav_waves_rates); 
        num_travelling_area_chs(num2str(patient)) = mean(trav_waves_rates(area_chs_inds)); 

        num_isolated_all_chs(num2str(patient)) = mean(spike_rates - trav_waves_rates); 
        num_isolated_area_chs(num2str(patient)) = mean(spike_rates(area_chs_inds) - trav_waves_rates(area_chs_inds)); 
    end

    mean_perc_travel = []; 
    mean_perc_travel_all = [];

    stat = []; 
    for key = keys(perc_travel_all_chs)

        stat = [stat; str2num(key{1}), ...
                      perc_travel_all_chs(key{1}), perc_travel_area_chs(key{1}), ...
                      num_travelling_all_chs(key{1}), num_travelling_area_chs(key{1}), ...
                      num_isolated_all_chs(key{1}), num_isolated_area_chs(key{1})]; 

        mean_perc_travel_all = [mean_perc_travel_all; perc_travel_all_chs(key{1})]; 
        mean_perc_travel = [mean_perc_travel; perc_travel_area_chs(key{1})]; 

    end 

    writematrix(stat, fullfile(paths.save_root, paths.travelling_waves_percents_fname)); 
    
end 
