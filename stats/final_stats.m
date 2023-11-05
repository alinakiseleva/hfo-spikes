function final_stat = final_stats(config, patients)
% Comprise final statistics for a list of patients.
% Input:
%   - config: a configuration structure.
%   - patients: a list of patient identifiers.
% Output:
%   - final_stat: a structure containing the final statistics.

    final_stat = readtable(fullfile(config.paths.save_root, config.paths.stat_results_fnames.biomarker_areas_fname)); 
    outcomes = readtable(fullfile(config.paths.save_root, config.paths.stat_results_fnames.outcomes_fname)); 

    results = []; 
    size_ra = []; 
    InterceptOutstrHFO = {}; 
    RA = {}; 
    SOZ = {}; 
    outstr_hfo_perc = []; 

    for patient = patients

        paths = build_patient_paths(config, patient); 

        ra = readtable(fullfile(paths.save_root, paths.resected_electrodes_fname), ...
                       'Sheet', paths.list_name); 

        soz = readtable(fullfile(paths.save_root, paths.soz_electrodes_fname), ...
                       'Sheet', paths.list_name);            

        hfo_outstr = [intercept_channels(strsplit(char(final_stat.HFOArea(final_stat.Patient == patient))), ...
                                         strsplit(char(final_stat.WeightedOustrengthArea(final_stat.Patient == patient))));  ...
                      intercept_channels(strsplit(char(final_stat.WeightedOustrengthArea(final_stat.Patient == patient))), ...
                                         strsplit(char(final_stat.HFOArea(final_stat.Patient == patient))))]; 
        hfo_outstr = unique(hfo_outstr); 

        outstr_w_hfo = length( ...
                          intercept_channels( ...
                          strsplit(char(final_stat.WeightedOustrengthArea(final_stat.Patient == patient))), ...
                          strsplit(char(final_stat.HFOArea(final_stat.Patient == patient))) )); 
        outstr_hfo_perc = [outstr_hfo_perc; outstr_w_hfo / length(strsplit(final_stat.WeightedOustrengthArea{final_stat.Patient == patient})) * 100]; 

        if ~isempty(hfo_outstr)
            hfo_outstr = strjoin(hfo_outstr); 
        else
            hfo_outstr = {'None'}; 
        end

        InterceptOutstrHFO = [InterceptOutstrHFO; hfo_outstr]; 

        if ~isempty(ra) && ~isempty(soz)

            ra_chs = ra.resected_channels;
            RA = [RA; strjoin(ra_chs)]; 

            size_ra = [size_ra; length(ra_chs)]; 

            soz_chs = soz.soz_channels; 
            SOZ = [SOZ; strjoin(soz_chs)]; 

            biomarkers = [final_stat.SpikeArea(final_stat.Patient == patient), ...
                          final_stat.HFOArea(final_stat.Patient == patient), ...
                          final_stat.WeightedOustrengthArea(final_stat.Patient == patient), ...
                          hfo_outstr, ...
                          strjoin(soz_chs)]; 

            n_in_ra = zeros(1, length(biomarkers));

            for b = 1:length(biomarkers)  
                biomarker = biomarkers(b); 
                biomarker_chs = strsplit(char(biomarker));

                for ch = 1:length(biomarker_chs)
                    split_chs = split_hyphen_strings(biomarker_chs(ch)); 
                    if count_matching_strings(split_chs, ra_chs) > 0
                        n_in_ra(b) = n_in_ra(b) + 1;  
                    end 
                end 
                n_in_ra(b) = n_in_ra(b) / length(biomarker_chs) * 100;  
            end  

        results = [results; patient, n_in_ra];

        else
            results = [results; patient, zeros(1, length(biomarkers))]; 
            RA = [RA; {''}];
            SOZ = [SOZ; {''}]; 
            size_ra = [size_ra; 0]; 
        end

    end 

    out = []; 
    for patient = final_stat.Patient' 
        if any(outcomes.patient == patient)
            out = [out; outcomes.outcome(outcomes.patient == patient)]; 
        else
            out = [out; -1]; 
        end 
    end 

    final_stat.InterceptOutstrHFO = InterceptOutstrHFO; 
    final_stat.RA = RA; 
    final_stat.SOZ = SOZ; 
    final_stat.size_ra = size_ra; 
    final_stat.outstr_hfo_perc = outstr_hfo_perc; 

    final_stat.SOZ_in_RA = results(:, 6);
    final_stat.Spike_in_RA = results(:, 2);
    final_stat.HFO_in_RA = results(:, 3);
    final_stat.W_outstr_in_RA = results(:, 4);
    final_stat.W_outstr_HFO_in_RA = results(:, 5);

    final_stat.All_SOZ_in_RA = int8(results(:, 6) == 100); 
    final_stat.All_spikes_in_RA = int8(results(:, 2) == 100); 
    final_stat.All_HFO_in_RA = int8(results(:, 3) == 100); 
    final_stat.All_w_outstr_in_RA = int8(results(:, 4) == 100); 
    final_stat.All_w_outstr_HFO_in_RA = int8(results(:, 5) == 100); 

    final_stat.outcome = out; 

    total_scores = []; 
    results = [final_stat.All_SOZ_in_RA, ...
               final_stat.All_spikes_in_RA, ...
               final_stat.All_HFO_in_RA, ...
               final_stat.All_w_outstr_in_RA, ...
               final_stat.All_w_outstr_HFO_in_RA]; 
    biomarker_names = ["SOZ", "Spikes", "HFO", "W_outstr", "W_outstr_HFO"];        

    for i = 1:size(results, 2)
        if i == 5
            [~, scores] = get_status(results(~strcmp(final_stat.InterceptOutstrHFO, 'None'), i), final_stat.outcome(~strcmp(final_stat.InterceptOutstrHFO, 'None'))); 
        else
            [~, scores] = get_status(results(:, i), final_stat.outcome); 
        end 
        total_scores.(biomarker_names(i)) = scores; 
        [status, ~] = get_status(results(:, i), final_stat.outcome); 

        if i == 5
            status(strcmp(final_stat.InterceptOutstrHFO, 'None')) = {''}; 
        end 
        final_stat.("Status_" + biomarker_names(i)) = status; 
    end 

    writetable(final_stat, fullfile(paths.save_root, paths.final_statistics_fname)); 
end 
