function [stat, area_channels] = areas_and_rates_stats(patients, config)
% Calculate Spike and HFO rates and Outstrength values, and define Spike,
% HFO and Weighted Outstrength areas. 
%
% Input:
%   - patients: a list of patient identifiers.
%   - config: a configuration structure.
%
% Output:
%   - stat: a matrix of calculated rates (values).
%   - area_channels: a matrix containing electrodes in biomarker areas.
    
    params = config.params; 

    spikes_all_chs = containers.Map; 
    spikes_max_chs = containers.Map; 
    hfo_all_chs = containers.Map; 
    hfo_max_chs = containers.Map; 

    outstr_all_chs = containers.Map; 
    outstr_w_all_chs = containers.Map; 
    outstr_max_chs = containers.Map; 
    outstr_w_max_chs = containers.Map; 

    spike_area_chs = containers.Map;
    hfo_area_chs = containers.Map;
    outstr_w_area_chs = containers.Map;

    stat = []; 
    
    area_channels = ["Patient", "Spike area", "HFO area", "Weighted oustrength area"];

    for patient = patients

        paths = build_patient_paths(config, patient); 

        patientStructFull = create_patientStructFull(paths, ...
                                                     patient, ...
                                                     'flag_results', params.flag_results, ...
                                                     'flag_use_every_second_channel', params.flag_use_every_second_channel, ...
                                                     'overwrite', params.overwrite_analysis, ...
                                                     'seq_win_s', params.seq_win_s); 

        [hfo_rates, spike_rates] = load_full_rates(paths, patientStructFull);   
        [instr, outstr] = get_in_out_str(patientStructFull);  

        if size(outstr) ~= size(spike_rates)   
            outstr = outstr'; 
            instr = instr'; 
        end 

        if size(hfo_rates) ~= size(spike_rates)   
            hfo_rates = hfo_rates'; 
        end 

        spikes_all_chs(num2str(patient)) = mean(spike_rates); 
        hfo_all_chs(num2str(patient)) = mean(hfo_rates); 

        ind_max = find(spike_rates > prctile(spike_rates, prctile_thr)); 
        spikes_max_chs(num2str(patient)) = mean(spike_rates(ind_max));
        spike_area_chs(num2str(patient)) = strjoin(patientStructFull.listFull(ind_max));

        ind_max = find(hfo_rates > prctile(hfo_rates, prctile_thr)); 
        hfo_max_chs(num2str(patient)) = mean(hfo_rates(ind_max));
        hfo_area_chs(num2str(patient)) = strjoin(patientStructFull.listFull(ind_max));

        outstr_all_chs(num2str(patient)) =  mean(outstr);
        outstr_w_all_chs(num2str(patient)) = mean(outstr .* spike_rates); 

        ind_max = find(outstr > prctile(outstr, prctile_thr)); 
        outstr_max_chs(num2str(patient)) = mean(outstr(ind_max)); 

        w_outstr = outstr .* spike_rates;
        ind_max = find(w_outstr > prctile(w_outstr, prctile_thr)); 
        outstr_w_max_chs(num2str(patient)) =  mean(w_outstr(ind_max)); 
        outstr_w_area_chs(num2str(patient)) = strjoin(patientStructFull.listFull(ind_max));
        
    end 

    for key = keys(hfo_max_chs)
        stat = [stat; str2num(string(key{1})), ... 
                (spikes_all_chs(key{1})), (spikes_max_chs(key{1})), ...
                (hfo_all_chs(key{1})), (hfo_max_chs(key{1})), ...
                outstr_all_chs(key{1}), outstr_max_chs(key{1}), ...
                outstr_w_all_chs(key{1}), outstr_w_max_chs(key{1})]; 
    end 
    writematrix(stat, fullfile(paths.save_root, paths.rates_stat_fname)); 

    for key = keys(hfo_area_chs)
        area_channels = [area_channels; ...
                         string(key{1}), ...
                         spike_area_chs(key{1}), ...
                         hfo_area_chs(key{1}), ...
                         outstr_w_area_chs(key{1})]; 
    end 
    writematrix(area_channels, fullfile(paths.save_root, paths.biomarker_areas_fname)); 
end 

