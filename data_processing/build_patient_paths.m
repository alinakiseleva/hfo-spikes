function paths = build_patient_paths(config, patient, verbose)
% build_patient_paths -  Build a structure of file paths related to a specific patient.
%
% Syntax:
%   paths = build_patient_paths(config, patient)
%
% Description:
%   The build_patient_paths function generates a structure of file paths
%   associated with a particular patient. It constructs paths for data
%   storage, results, plots, and other relevant folders.
%
% Input:
%   - config: Configuration structure containing path information.
%   - patient: Patient identifier or name.
%   - verbose: To write patient's number (Optional, default: true). 
%
% Output:
%   - paths: A structure containing paths for the patient, including
%     data, results, plots, and other relevant directories.
    
    if nargin < 3
        verbose = true; 
    end 

    config = config.paths; 

    %% find patient number by name 
    if isfield(config, 'patient_numbers') && isfield(config.patient_numbers, char(patient)) 
        patient = config.patient_numbers.(char(patient)); 
    end 

    patient = char(string(patient)); 
    
    if verbose
        fprintf('Started patient %s \n', patient); 
    end 
    
    %% main roots
    
    if all(isfield(config, {'data_root', 'save_root'}))
        data_root = config.data_root;  
        save_root = config.save_root;  
    else
        error('Missing data_root and save_root specifications in configuration structure')
    end
    
    %% define data path
    if exist(fullfile(save_root, ['p' patient], 'Block_samples'), 'dir')
        data_root = save_root; 
        if verbose
            warning('Data folder is %s', save_root); 
        end
    end 

    patient_folder = ls(fullfile(data_root, ['p' patient '*'])); 
    data_path = fullfile(data_root, patient_folder, 'Block_samples'); 

    %% path with bad channels and localization 
    list_name = ['p' patient]; % xlsx list name 

    bad_channels_path = fullfile(save_root, get_field_or_empty(config, 'bad_channels_fname')); 
    bad_channels_hfo_path = fullfile(save_root, get_field_or_empty(config, 'bad_channels_hfo_fname')); 

    localization_path = fullfile(save_root, get_field_or_empty(config, 'localization_fname')); 

    %% save paths 
    save_path = fullfile(save_root, patient_folder); 

    %% paths for spike detection results  
    delphos_results_path = fullfile(save_path, 'delphos_results'); %% path with delphos results    
    cnn_delphos_results_path = fullfile(save_path, 'cnn_delphos_results'); %% path with cnn results
    cnn_delphos_aligned_path = fullfile(save_path, 'cnn_delphos_aligned_results'); %% path with aligned spikes

    check_dir(delphos_results_path); 
    check_dir(cnn_delphos_results_path);  
    check_dir(cnn_delphos_aligned_path); 

    %% paths to pictures and plots 
    plot_path =  fullfile(save_path, 'plots'); 
    check_dir(plot_path); 

    % signal plots with detection and bar plots 
    signal_plot_folder = fullfile(plot_path, 'signal_plots'); 
    bar_plot_folder = fullfile(plot_path, 'bar_plots'); 

    check_dir(signal_plot_folder);
    check_dir(bar_plot_folder);

    %  spike and hfo rates
    hfo_spike_rates_plot_folder = fullfile(plot_path, 'hfo_spike_rates'); 
    check_dir(hfo_spike_rates_plot_folder); 
    
    %% propagation paths 
    % folder for saving propagation pictures 
    propagation_plots_path = fullfile(plot_path, 'propagation_pics');
    check_dir(propagation_plots_path); 
    
    % signal plots with propagation
    prop_signal_plot_path = fullfile(propagation_plots_path, 'propagation_signal_pics'); 
    check_dir(prop_signal_plot_path)

    % paths for saving the full dataset: 
    patientStructFull_path = fullfile(save_path, 'all_epochs'); 
    check_dir(patientStructFull_path);

    patientStructFull_save_filename = [patient '.mat']; 
    
    %% assign paths to struct
    paths = struct('patient', patient, ...
                   'save_root', save_root, ...
                   'data_root', data_root, ...
                   'data_path', data_path, ...
                   'save_path', save_path, ...
                   'list_name', list_name, ...
                   'bad_channels_path', bad_channels_path, ...
                   'bad_channels_hfo_path', bad_channels_hfo_path, ...
                   'localization_path', localization_path, ...
                   'delphos_results_path', delphos_results_path, ...
                   'cnn_delphos_results_path', cnn_delphos_results_path, ...
                   'cnn_delphos_aligned_path', cnn_delphos_aligned_path, ...
                   'plot_path', plot_path, ...
                   'signal_plot_folder', signal_plot_folder, ...
                   'bar_plot_folder', bar_plot_folder, ...
                   'hfo_spike_rates_plot_folder', hfo_spike_rates_plot_folder, ...
                   'prop_plots_path', propagation_plots_path, ...
                   'prop_signal_plot_path', prop_signal_plot_path, ...
                   'patientStructFull_path', patientStructFull_path, ...
                   'patientStructFull_fname', patientStructFull_save_filename, ...
                   'biomarker_areas_fname', get_field_or_empty(config.stat_results_fnames, 'biomarker_areas_fname'), ...
                   'outcomes_fname', get_field_or_empty(config.stat_results_fnames, 'outcomes_fname'), ...
                   'final_statistics_fname', get_field_or_empty(config.stat_results_fnames, 'final_statistics_fname'), ...
                   'soz_electrodes_fname', get_field_or_empty(config.stat_results_fnames, 'soz_electrodes_fname'), ...
                   'resected_electrodes_fname', get_field_or_empty(config.stat_results_fnames, 'resected_electrodes_fname'), ...
                   'rates_stat_fname', get_field_or_empty(config.stat_results_fnames, 'rates_stat_fname'), ...
                   'spike_hfo_coocurrence_fname', get_field_or_empty(config.stat_results_fnames, 'spike_hfo_coocurrence_fname'), ...
                   'spike_velocity_fname', get_field_or_empty(config.stat_results_fnames, 'spike_velocity_fname'), ...
                   'travelling_waves_percents_fname', get_field_or_empty(config.stat_results_fnames, 'travelling_waves_percents_fname'), ...
                   'in_out_strengths_fname', get_field_or_empty(config.stat_results_fnames, 'in_out_strengths_fname'), ...
                   'onset_numbers_fname', get_field_or_empty(config.stat_results_fnames, 'onset_numbers_fname'), ...
                   'num_contacts_fname', get_field_or_empty(config.stat_results_fnames, 'num_contacts_fname'));
    
end
