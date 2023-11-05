clear all; clc; format compact;

%% Set-up
code_folder = pwd; 

addpath(genpath(fullfile(code_folder, 'analysis')));
addpath(genpath(fullfile(code_folder, 'data_processing')));
addpath(genpath(fullfile(code_folder, 'utils')));
addpath(genpath(fullfile(code_folder, 'visualization')));
addpath(genpath(fullfile(code_folder, 'stats')));

config = ReadYaml(fullfile(code_folder, 'config.yml')); 

patients = config.analyse_patients; 

seq_win_s = config.params.seq_win_s; 
flag_results = config.params.flag_results; 
flag_use_every_second_channel = config.params.flag_use_every_second_channel; 
overwrite = config.params.overwrite_analysis; 
prctile_thr = config.params.prctile_threshold; 
graph_thr = config.params.graph_thr; 

[cmap, custom_colormap] = process_config_colors(config); 

%% Analysis

for patient = patients
    
    paths = build_patient_paths(config, patient); 
    
    % run delphos detector 
    run_delphos_detector(paths, overwrite)

    % run CNN detector 
    system(sprintf('"%s" "%s" -patient %s -overwrite %d -data_root "%s" -save_root "%s"', ...
                   config.python.venv_path, config.python.cnn_code_path, paths.patient, double(overwrite), paths.data_root, paths.save_root))

    % Align spikes 
    align_spikes(paths, overwrite)

    patientStructFull = create_patientStructFull(paths, ...
                                                 patient, ...
                                                 'flag_results', flag_results, ...
                                                 'flag_use_every_second_channel', flag_use_every_second_channel, ...
                                                 'overwrite', overwrite, ...
                                                 'seq_win_s', seq_win_s); 
end

%% All intervals visualization 

for patient = patients 

    paths = build_patient_paths(config, patient); 
    
    patientStructFull = create_patientStructFull(paths, ...
                                                 patient, ...
                                                 'flag_results', flag_results, ...
                                                 'flag_use_every_second_channel', flag_use_every_second_channel, ...
                                                 'overwrite', overwrite, ...
                                                 'seq_win_s', seq_win_s); 
                                             
    chan_names = patientStructFull.listFull; 
    bad_channels = get_bad_channels(paths.bad_channels_path, paths.list_name, chan_names);
    bad_channels_hfo = get_bad_channels(paths.bad_channels_hfo_path, paths.list_name, chan_names);
    
    % propagation graph and adjMatrix   
    graph_thr = config.params.graph_thr; 
    seq_win_s = config.params.seq_win_s; 
    flag_results = config.params.flag_results; 
    flag_use_every_second_channel = config.params.flag_use_every_second_channel;
    
    [adjMatrixfig, graph, cleaned_graph] = plot_propagation_patterns(patientStructFull, ...
                                                                     graph_thr, ...
                                                                     seq_win_s); 
                                                                 
    seq_win = seq_win_s * patientStructFull.epochsList(1).Fs; 
    saveas(adjMatrixfig,  fullfile(paths.prop_plots_path, ...
                                   [flag_results '_adj_matrix_' ...
                                   'seqwin_' num2str(seq_win) '.png']));
                               
    graph_fname = [flag_results '_graph_seqwin_' num2str(seq_win)]; 
    if flag_use_every_second_channel
        graph_fname = [graph_fname '_half_chs']; 
    end

    saveas(graph,  fullfile(paths.prop_plots_path, [graph_fname '_noisy.png']));
    saveas(cleaned_graph,  fullfile(paths.prop_plots_path, [graph_fname '_cleaned.png']));

    close all

    % travelling waves  
    flag_results = config.params.flag_results; 
    flag_use_every_second_channel = config.params.flag_use_every_second_channel;

    [bar_travelling_waves] = plot_bar_travel_waves(paths.patient, patientStructFull, ...
                                                   bad_channels); 
                                               
    bar_traveling_fname = [flag_results '_bar_travelling_waves_all_int_patient_' num2str(paths.patient)]; 
    if flag_use_every_second_channel
        bar_traveling_fname = [bar_traveling_fname '_half_chs']; 
    end
    saveas(bar_travelling_waves, fullfile(paths.prop_plots_path, [bar_traveling_fname '.png']));
    close all 

    % spike and HFO rates viz 
    prctile_thr = config.params.prctile_threshold; 
    [hfo_rates, spike_rates] = load_full_rates(paths, patientStructFull);  
    [rates_plot] = plot_bar_rates(paths.patient, patientStructFull, ...
                                  hfo_rates, spike_rates, ...
                                  bad_channels, bad_channels_hfo, ...
                                  prctile_thr, ...
                                  [cmap('blue'); cmap('red')]); 
                              
    saveas(rates_plot, fullfile(paths.bar_plot_folder, ... 
                                paths.patient + "_hfo_spike_rates_" + ... 
                                "thr_" + prctile_thr + ".png")); 
    close all
    
    % propagation pattern on the electrode layout 
    [~, spike_rates] = load_full_rates(paths, patientStructFull); 
    [~, outstr] = get_in_out_str(patientStructFull); 
    position = 'top'; 
    
    [brain] = plot_el_layout(patientStructFull, ...
                             'position', position, ...
                             'colormap_flag', true, ...
                             'colormap', spike_rates .* outstr', ...
                             'colormap_str', 'Weighted outstrength', ...
                             'propagation_flag', true, ...
                             'graph_thr', graph_thr, ...
                             'color_prop', cmap('light_gray'), ...
                             'spike_rate', spike_rates, ...
                             'prop_edge_scale', 7, ...
                             'plot_cmap', cmap('custom_cmap'), ...
                             'spacing', 10); 
                         
    saveas(brain, fullfile(paths.prop_plots_path, ...
                           ['propagation_layout_pat_' num2str(paths.patient) ...
                           '_position_' position ...
                           '_thr_' num2str(graph_thr) ...
                           '.png']))
    close all
    
    % in- and out- strength rates 
    [in_out_bar] = plot_bar_in_out_strength(patientStructFull, ...
                                            bad_channels, ...
                                            prctile_thr, ...
                                            [cmap('blue'); cmap('red')]); 
                                        
    saveas(in_out_bar, fullfile(paths.prop_plots_path, ...
                                ['In_out_strength' ...
                                '_pat_' num2str(paths.patient) ...
                                '.png'])) 
                            
    close all
end 

full_analysis_presentation(config, patients, ...
                           fullfile(config.paths.save_root, 'full_analysis_presentation.pptx'), ...
                           config.paths.template_presentation_path); 

%% statistics 

patients = config.manuscript_figs_settings.manuscript_patients; 


travelling_waves_stats(patients, config); 

areas_and_rates_stats(patients, config); 

spike_hfo_cooccurrence_stats(patients, config, config.params.spike_hfo_cooccur_tolerance)

in_out_str_stats(patients, config); 

spike_velocity_stats(patients, config, config.params.lower_spike_velocity_thr); 

final_stats(config, patients)

num_contacts_stats(config)