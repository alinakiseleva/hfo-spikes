clear all; clc; format compact;
%% Set-up
code_folder = pwd; 

addpath(genpath(fullfile(code_folder, 'analysis')));
addpath(genpath(fullfile(code_folder, 'data_processing')));
addpath(genpath(fullfile(code_folder, 'utils')));
addpath(genpath(fullfile(code_folder, 'visualization')));
addpath(genpath(fullfile(code_folder, 'stats')));
addpath(genpath(fullfile(code_folder, 'manuscript_figures_code')));

config = ReadYaml(fullfile(code_folder, 'config.yml')); 

manuscript_patients = cell2mat(config.manuscript_figs_settings.manuscript_patients); 

seq_win_s = config.params.seq_win_s; 
flag_results = config.params.flag_results; 
flag_use_every_second_channel = config.params.flag_use_every_second_channel; 

prctile_thr = config.params.prctile_threshold; 
graph_thr = config.params.graph_thr; 

[cmap, custom_colormap] = process_config_colors(config); 

article_figs_saveroot = config.manuscript_figs_settings.manuscript_figs_saveroot; 
fig_fontsize = config.manuscript_figs_settings.manuscript_figs_fontsize;  


%% Manuscript figures 

fig_1

fig_2

fig_3

%% Additional statistics 

optimal_thresholds_confusion_fisher

supplementary_materials

all_stat_tests

num_electrodes_and_intervals

