
patients_electrode_counts = []; 
num_intervals = []; 

for patient = manuscript_patients 

    paths = build_patient_paths(config, patient); 
    
    [num_electrodes, num_contacts] = count_electrodes(paths); 
 
    [~, bad_chs_spikes] = get_bad_channels(paths.bad_channels_path, paths.list_name); 
    [~, bad_chs_hfo] = get_bad_channels(paths.bad_channels_hfo_path, paths.list_name); 
    
    num_bad_chs_spikes = length(unique(split_hyphen_strings(bad_chs_spikes), 'stable')); 
    num_bad_chs_hfo = length(unique(split_hyphen_strings(bad_chs_hfo), 'stable')); 
    
    patients_electrode_counts = [patients_electrode_counts; patient, num_electrodes, num_contacts, num_bad_chs_spikes, num_bad_chs_hfo]; 

    num_intervals = [num_intervals; size(ls(fullfile(paths.delphos_results_path, '*.mat')), 1)]; 
    
end 

total_num_electrodes = patients_electrode_counts(:, 2); 
total_num_contacts = patients_electrode_counts(:, 3); 

fprintf('\n(electrodes: mean = %.2f, SD = %.2f, range = %d-%d; contacts: mean = %.2f, SD = %.2f, range = %d-%d)\n', ...
        mean(total_num_electrodes), std(total_num_electrodes), min(total_num_electrodes), max(total_num_electrodes), ...
        mean(total_num_contacts), std(total_num_contacts), min(total_num_contacts), max(total_num_contacts)); 

total_bad_chs_spikes = patients_electrode_counts(:, 4); 
total_bad_chs_hfo = patients_electrode_counts(:, 5); 

fprintf('\nNoisy contacts (Spikes: mean = %.2f, SD = %.2f, range = %d-%d; HFO: mean = %.2f, SD = %.2f, range = %d-%d)\n', ...
        mean(total_bad_chs_spikes), std(total_bad_chs_spikes), min(total_bad_chs_spikes), max(total_bad_chs_spikes), ...
        mean(total_bad_chs_hfo), std(total_bad_chs_hfo), min(total_bad_chs_hfo), max(total_bad_chs_hfo)); 

fprintf('\nAfter rejection of noisy contacts, for spikes mean = %.2f, SD = %.2f; for HFO mean = %.2f, SD = %.2f\n', ...
        mean(total_num_contacts - total_bad_chs_spikes), std(total_num_contacts - total_bad_chs_spikes), ...
        mean(total_num_contacts - total_bad_chs_hfo), std(total_num_contacts - total_bad_chs_hfo)); 

fprintf('\nWe identified %d to %d interictal intervals of 5 minutes\n', ...
        min(num_intervals), max(num_intervals)); 
