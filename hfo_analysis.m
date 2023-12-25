format compact; 

code_folder = pwd; 
config = ReadYaml(fullfile(code_folder, 'config.yml')); 

%% libraries  
addpath(fullfile(pwd, 'utils', 'filedtrip'));  
addpath(fullfile(pwd, 'hfo_analysis')); 

%% data paths 
datadir = config.paths.edf_root; 
resultsdir = config.paths.save_root; 
bad_channels_path = fullfile(config.paths.save_root, config.paths.bad_channels_hfo_fname); 

%% analysis 

patient = 1; 
detector = 1; 
rereference_flag = 1; 
names = cell2mat(config.analyse_patients); 

for name = names 
    
    close all
    
    paths = build_patient_paths(config, name);
    folder(patient).name = num2str(paths.patient); 

    % HFO detection 
    HFO_processing(datadir, ...
                   resultsdir, ...
                   folder, ...
                   patient, ...
                   detector, ...
                   bad_channels_path, ...
                   rereference_flag); 

    % Build HFO final results            
    HFO_results(resultsdir, ...
                folder, ...
                patient); 

    % Build final bar plot for HFO analysis 
    filenames = cellstr(natsort(ls([paths.data_path '\HFO_pat*.mat'])))'; 
    n_recs = length(filenames) - 1; 

    filename = filenames{1};   
    load(fullfile(paths.data_path, filename)); 

    chan_names = [HFOobj(:).label]; 

    bad_channels_hfo = get_bad_channels(paths.bad_channels_hfo_path, paths.list_name, chan_names);
    filename = [ls([paths.data_path '\HFO_*rate*_*.mat']) ls([paths.data_path '\HFO_*result*.mat'])]; 
    load(fullfile(paths.data_path, filename));        

    bar_hfo_plot = build_hfo_bar(N_m_ripple, N_m_FR, N_m_RFR, N_m_THRFR, n_recs, chan_names, bad_channels_hfo); 

    saveas(bar_hfo_plot, fullfile(paths.plot_path, ...
                                  ['HFO_pat_', num2str(patient), '_bar_plot.png'])); 

    close(bar_hfo_plot); 

end

%% Plot chosen channels
[~, chosen_channels] = maxk(sum(N_m_RFR, 1), 7); 

labels = [HFOobj.label]; 
labels(chosen_channels)

plot_chosen_hfo_channels(HFOobj, chosen_channels); 


%% date and time of SWS intervals

for name = names 

    xlsx_filename = fullfile(config.paths.save_root, 'time_date_sws_intervals.xlsx');
    sws_intervals_time = date_time_sws(name, patient, config.paths.edf_root, xlsx_filename); 

end 

