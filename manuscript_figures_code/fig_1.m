settings = config.manuscript_figs_settings; 

patient = settings.fig_1_settings.patient;
rec_num = settings.fig_1_settings.rec_num;  
graph_thr = settings.fig_1_settings.graph_thr;

t1 = containers.Map; 
t2 = containers.Map; 
t1('spike') = settings.fig_1_settings.spike_t{1}; t2('spike') = settings.fig_1_settings.spike_t{2}; 
t1('RFR') = settings.fig_1_settings.hfo_t{1}; t2('RFR') = settings.fig_1_settings.hfo_t{2};
t1('prop') = settings.fig_1_settings.prop_t{1}; t2('prop') = settings.fig_1_settings.prop_t{2};

spike_num = settings.fig_1_settings.spike_num; 
hfo_num = settings.fig_1_settings.hfo_num; 

%% load data 

% el layout plots 
paths = build_patient_paths(config, patient); 

patientStructFull = create_patientStructFull(paths, ...
                                             patient, ...
                                             'flag_results', flag_results, ...
                                             'flag_use_every_second_channel', flag_use_every_second_channel, ...
                                             'overwrite', false, ...
                                             'seq_win_s', seq_win_s); 

[hfo_rates, spike_rates] = load_full_rates(paths, patientStructFull); 
spike_rates = spike_rates'; 

% for spike and HFO traces 
filenames = cellstr(natsort(ls(fullfile(paths.data_path, 'HFO*.mat'))))'; 
filename = filenames{rec_num};   

load(fullfile(paths.data_path, filename)); 
patientStruct = build_patientStruct_from_HFOobj(HFOobj, 'raw'); 

% preprocess 
patientStruct = detrend_signal(patientStruct); 
patientStruct = notch_filter(patientStruct, 50); 

chan_names = patientStruct.epochsList.chan_names;
bad_channels = get_bad_channels(paths.bad_channels_path, paths.list_name, chan_names);
resample_frequency = patientStruct.epochsList.Fs; 

% spikes
[spike_events, ~] = interval_spike_events_and_rates(paths, filename, [1:length(chan_names)], 200);  
res_patientStruct = resample_patientStruct(patientStruct, 200); 
[~, tfr_spike_ch] = max(spike_rates);
tfr_spike_time = spike_events(tfr_spike_ch).CNN(spike_num);  
spike_events = rmfield(spike_events, {'delphos', 'CNN'});

% hfo
bad_channels_hfo = get_bad_channels(paths.bad_channels_hfo_path, paths.list_name, chan_names);
hfo_events = interval_hfo_events(HFOobj, bad_channels_hfo, 3, resample_frequency); 

[~, tfr_hfo_ch] = max(hfo_rates);
tfr_hfo_time =  round(mean(hfo_events(tfr_hfo_ch).RFR(hfo_num, :)));  

% in out str
[instr, outstr] = get_in_out_str(patientStructFull); 

% RA
ra_channels_path = fullfile(paths.save_root, paths.resected_electrodes_fname); 
ra_channels_indices = get_ra_channels(ra_channels_path, paths.list_name, patientStructFull.listFull); 

%%
num_subplots = 13; 
p1 = 1:3; 
p2 = 5:8; 
p3 = 10:13; 

NV = struct('FontSize', 12, ...
            'FontWeight', 'normal', ...
            'Location', 'NorthWest', ...
            'HShift', -0.04, ...
            'VShift', 0, ...
            'Color', [0 0 0], ...
            'FitLocation', false); 

linewidth = .7;         
        
%% plotting %%% 

%% Spike row 
figure('units', 'normalized', 'outerposition', [0 0 .8 0.55]); 

% electrode layout 
subplot(1, num_subplots, p3); 
plot_el_layout(patientStructFull, ...
               'position', 'top', ...
               'new_fig', false, ... 
               'fontsize', fig_fontsize, ...
               'marker_size', 2, ...
               'arrows_flag', true, ...
               'colormap_flag', true, ...
               'colormap_position', 'southoutside', ...
               'colormap', spike_rates, ...
               'colormap_str', 'Spike rates', ...
               'fontsize', fig_fontsize, ...
               'ra_area_flag', true, ...
               'ra_chs', ra_channels_indices, ...
               'ra_color', cmap('ra'), ...
               'spacing', 20);  

% spike traces 
traces = subplot(1, num_subplots, p1); 
ind_chs = find(spike_rates > prctile(spike_rates, prctile_thr));

cfg = struct('shift', 1200, ...
             'chs_2_plot', sort(ind_chs), ...
             'ch_color', cmap('dark_blue'), ...
             'marker_color', cmap('gray'), ...
             'marker_style', 'start', ...
             'resample_fs', 200, ...
             'save_flag', false, ...
             'linewidth', linewidth, ...
             'fontsize', fig_fontsize, ...
             'box', 'off', ...
             'YAxis', 'off', ...
             'XAxis', 'off', ...
             'highlight_ch', find(ind_chs == tfr_spike_ch)); 
         
visualizer_data_markings(cfg, patientStruct, spike_events); 

tmin = t1('spike'); tmax = t2('spike'); 
xlim([tmin tmax]);
ylim([-cfg.shift*(length(ind_chs)+1.5) cfg.shift/2]);
xticks([]); 

add_mv_ms_line('shift', cfg.shift, ...
               'tmin', tmin, ...
               'tmax', tmax, ...
               'fig_fontsize', fig_fontsize-2, ...
               'color', cmap('dark_gray')); 
 
% tfr 
subplot(1, num_subplots, p2)
plot_tfr(res_patientStruct, tfr_spike_ch, tfr_spike_time, ...
        'freq_band', [2 60], ...
        'fig_fontsize', fig_fontsize, ...
        'cmap', cmap('custom_cmap'), ...
        'nsecs', .5, ...
        'colorbar_flag', 1, ...
        'colorbar_str', 'Power'); 
        
AddLetters2Plots({traces}, {'A'}, NV); 
 
print(fullfile(article_figs_saveroot, 'fig1_1.png'), '-dpng', '-r500');

%% HFO row 
figure('units', 'normalized', 'outerposition', [0 0 .8 0.55]);  
          
% electrode layout                       
subplot(1, num_subplots, p3)
plot_el_layout(patientStructFull, ...
               'position', 'top', ...
               'new_fig', false, ... 
               'fontsize', fig_fontsize, ...
               'marker_size', 2, ...
               'arrows_flag', true, ...
               'colormap_flag', true, ...
               'colormap', hfo_rates, ...
               'colormap_position', 'southoutside', ...
               'colormap_str', 'HFO rates', ...
               'fontsize', fig_fontsize, ...
               'ra_area_flag', true, ...
               'ra_chs', ra_channels_indices, ...
               'ra_color', cmap('ra'), ...
               'spacing', 20);    
 
           
% HFO traces 
traces = subplot(1, num_subplots, p1); 
tmin = t1('RFR'); tmax = t2('RFR');        
[~, ind_chs] = maxk(hfo_rates, 2); 

cfg = struct('shift', 2000, ...
             'chs_2_plot', sort(ind_chs), ...
             'ch_color', cmap('dark_blue'), ...
             'marker_color', cmap('gray'), ...
             'linewidth', linewidth, ...
             'fontsize', fig_fontsize, ...
             'box', 'off', ...
             'YAxis', 'off', ...
             'XAxis', 'off', ...
             'highlight_ch', find(ind_chs == tfr_hfo_ch));  
plot_hfo_channels(HFOobj, resample_frequency, cfg);

xlim([tmin tmax]) 
ylim([-cfg.shift*(3*(length(ind_chs)) + .5) cfg.shift/2])
xticks([])      

n_secs = tmax - tmin; 
vtext = ["0.5 mV", "0.02 mV", "0.01 mV"]; 
v_scale = 500; 
ms_text = '50 ms';
ms_scale = 0.05;

for ch = 1:length(cfg.chs_2_plot)
    for j = 1:3
        i = (3 * (ch-1) + j); 
        add_mv_ms_line('shift', cfg.shift, ...
                       'tmin', tmin, ...
                       'tmax', tmax, ...
                       'fig_fontsize', fig_fontsize-2, ...
                       'v_text', vtext(j), ...
                       'ms_text', ms_text, ...
                       'v_scale', v_scale, ...
                       'ms_scale', ms_scale, ...
                       'y_shift', - i * cfg.shift + cfg.shift/3, ...
                       'color', cmap('dark_gray')); 
    end 
end 
           

% tfr     
subplot(1, num_subplots, p2)
plot_tfr(patientStruct, tfr_hfo_ch, tfr_hfo_time, ...
         'freq_band', [50 256], ...
         'cmap', cmap('custom_cmap'), ...
         'nsecs', .1, ...
         'fig_fontsize', fig_fontsize, ...
         'colorbar_flag', 1, ...
         'colorbar_str', 'Power');

AddLetters2Plots({traces}, {'B'}, NV); 
            
print(fullfile(article_figs_saveroot, 'fig1_2.png'), '-dpng', '-r500');

%% Propagation row
figure('units', 'normalized', 'outerposition', [0 0 .8 0.55]); 

% electtode layout      
subplot(1, num_subplots, p3)
plot_el_layout(patientStructFull, ...
               'position', 'top', ...
               'new_fig', false, ... 
               'fontsize', fig_fontsize, ...
               'marker_size', 2, ...
               'arrows_flag', true, ...
               'colormap_flag', true, ...
               'colormap', outstr .* spike_rates, ...
               'colormap_position', 'southoutside', ...
               'colormap_str', 'Weighted outstrength', ...
               'propagation_flag', true, ...
               'graph_thr', graph_thr, ...
               'color_prop', cmap('light_gray'), ...
               'fontsize', fig_fontsize, ...
               'ra_area_flag', true, ...
               'ra_chs', ra_channels_indices, ...
               'ra_color', cmap('ra'), ...
               'prop_edge_scale', 3, ...
               'spike_rate', spike_rates, ...
               'spacing', 20);    

% spike propagation traces 
traces = subplot(1, num_subplots, p1); 

[~, chleader] = max(outstr); 
adjMatrix = get_adjMatrix(patientStructFull); 
[~, ind_chs] = maxk(adjMatrix(chleader, :) .* spike_rates, 5); 

cfg = struct('shift', 800, ...
             'chs_2_plot', sort(ind_chs), ...
             'ch_color', cmap('dark_blue'), ...
             'marker_color', cmap('gray'), ...
             'marker_style', 'trigger', ...
             'resample_fs', 200, ...
             'save_flag', false, ...
             'linewidth', linewidth, ...
             'chleader', chleader, ...
             'fontsize', fig_fontsize, ...
             'box', 'off', ...
             'YAxis', 'off', ...
             'XAxis', 'off', ...
             'highlight_ch', 1);  
         
visualizer_data_markings(cfg, patientStruct, spike_events); 

tmin = t1('prop'); tmax = t2('prop'); 

xlim([tmin tmax]);
ylim([-cfg.shift*(length(ind_chs)+1.5) cfg.shift]);
xticks([]);

add_mv_ms_line('shift', cfg.shift, ...
               'tmin', tmin, ...
               'tmax', tmax, ...
               'fig_fontsize', fig_fontsize-2, ...
               'v_text', '0.5 mV', ...    
               'v_scale', 500, ...
               'ms_text', '100 ms', ...
               'ms_scale', 0.1, ...
               'y_shift', 300, ...
               'color', cmap('dark_gray')); 
       
           
% graph 
subplot(1, num_subplots, p2)
adjMatrix = get_adjMatrix(patientStructFull); 
thr_adjMatrix = threshold_adjMatrix(adjMatrix, graph_thr); 
non_empty_channels = find((sum(thr_adjMatrix, 1)' + sum(thr_adjMatrix, 2) ~= 0) & (spike_rates > mean(spike_rates)/2)');  

plot_graph(thr_adjMatrix, ...
           'chan_names', patientStructFull.listFull, ...
           'node_colors', outstr, ...
           'marker_size', spike_rates, ...
           'non_empty_channels', non_empty_channels, ...
           'fontsize', fig_fontsize, ...
           'colormap', cmap('custom_cmap'), ...
           'edge_color', cmap('gray'), ...
           'colormap_str', 'Outstrength'); 
axis off       

AddLetters2Plots({traces}, {'C'}, NV); 
print(fullfile(article_figs_saveroot, 'fig1_3.png'), '-dpng', '-r500');
