function num_contacts = num_contacts_stats(config)

    final_stats = readtable(fullfile(config.paths.save_root, config.paths.stat_results_fnames.final_statistics_fname)); 

    good_outcomes = find(final_stats.outcome == 1); 
    poor_outcomes = find(final_stats.outcome == 0); 

    num_contacts = []; 

    for patient = final_stats.Patient'

        paths = build_patient_paths(config, patient); 
        [~, pat_num_contacts] = count_electrodes(paths); 

        biomarkers = [final_stats.SpikeArea, ...
                      final_stats.HFOArea, ...
                      final_stats.WeightedOustrengthArea, ...
                      final_stats.InterceptOutstrHFO]; 

        for bio = biomarkers    
            pat_num_contacts = [pat_num_contacts, length(strsplit(char(bio(final_stats.Patient == patient))))]; 
        end 

        num_contacts = [num_contacts; patient, pat_num_contacts]; 

    end

    writematrix(num_contacts, fullfile(paths.save_root, paths.num_contacts_fname)); 
    
end 
