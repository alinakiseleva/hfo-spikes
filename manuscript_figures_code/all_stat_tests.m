%% in fig 2: 

rates_stat = readmatrix(fullfile(config.paths.save_root, config.paths.stat_results_fnames.rates_stat_fname)); 
outcomes = readtable(fullfile(config.paths.save_root, config.paths.stat_results_fnames.outcomes_fname)); 

spike_hfo_coocurrence_stat = readmatrix(fullfile(config.paths.save_root, config.paths.stat_results_fnames.spike_hfo_coocurrence_fname)); 

travelling_waves_percents_stat = readmatrix(fullfile(config.paths.save_root, config.paths.stat_results_fnames.travelling_waves_percents_fname)); 

spike_velocity_stat = readmatrix(fullfile(config.paths.save_root, config.paths.stat_results_fnames.spike_velocity_fname)); 


good_outcomes = [];
poor_outcomes = []; 

for pat = rates_stat(:, 1)'
    out = outcomes.outcome(outcomes.patient == pat);
    if ~isempty(out)
        pat_num = find(rates_stat(:, 1) == pat); 
        switch out
            case 1
                good_outcomes = [good_outcomes; pat_num]; 
            case 0 
                poor_outcomes = [poor_outcomes; pat_num]; 
        end 
    end 
end

% rates stats of the biomarker areas good vs poor outcome 
spikes_area = rates_stat(:, 3);
hfo_area = rates_stat(:, 5);
outstr_w_area = rates_stat(:, 9);
fprintf('\n\nIn figure 2: ')
p = ranksum(spikes_area(good_outcomes), spikes_area(poor_outcomes));
fprintf('\nSpike area rates, good vs poor:  p = %f', p); 
p = ranksum(hfo_area(good_outcomes), hfo_area(poor_outcomes));
fprintf('\nHFO area rates, good vs poor:  p = %f', p); 
p = ranksum(outstr_w_area(good_outcomes), outstr_w_area(poor_outcomes));
fprintf('\nWeighted outstrength area rates, good vs poor:  p = %f', p); 

% spike and HFO co-occurrence stats for all chs good vs poor outcome 
perc_coocur_all_chs = spike_hfo_coocurrence_stat(:, 3) ./ spike_hfo_coocurrence_stat(:, 2) .* 100;
perc_coocur_max_ch = spike_hfo_coocurrence_stat(:, 6) ./ spike_hfo_coocurrence_stat(:, 5) .* 100;
p = ranksum(perc_coocur_all_chs(good_outcomes), perc_coocur_all_chs(poor_outcomes));
fprintf('\nSpike and HFO co-occurrence, all chs, good vs poor:  p = %f', p); 

% propagating spikes % for w outstr area chs good vs poor outcome 
travelling_waves_percents_stat(:, 2:3) = travelling_waves_percents_stat(:, 2:3) * 100;
p = ranksum(travelling_waves_percents_stat(good_outcomes, 3), travelling_waves_percents_stat(poor_outcomes, 3));
fprintf('\nPropagating spikes percent for weighted outstrength area chs, good vs poor:  p = %f', p); 

% propagation speed from max w outstr ch to all following good vs poor outcome
p = ranksum(spike_velocity_stat(good_outcomes, 2), spike_velocity_stat(poor_outcomes, 2));
fprintf('\nPropagation speed from max weighted outstrength ch to all following, good vs poor:  p = %f', p); 


%% in fig 3: 

% confusion matrices fisher's test 

final_stats = readtable(fullfile(config.paths.save_root, config.paths.stat_results_fnames.final_statistics_fname)); 
thr = config.manuscript_figs_settings.fig_3_settings.overlap_threshold; 

raw_results = [final_stats.SOZ_in_RA, ...
           final_stats.Spike_in_RA, ...
           final_stats.HFO_in_RA, ...
           final_stats.W_outstr_in_RA, ...
           final_stats.W_outstr_HFO_in_RA];
results = raw_results >= thr; 
       
titles = ["SOZ", "Spikes", "HFO", "Outstrength", "HFO + Outstrength"]; 
fprintf('\n\nIn figure 3:'); 

for i = 1:size(results, 2)
    
    scores = results(:, i);
    labels = final_stats.outcome; 
    
    if i == 5
        scores = results(~strcmp(final_stats.InterceptOutstrHFO, 'None'), i); 
        labels = final_stats.outcome(~strcmp(final_stats.InterceptOutstrHFO, 'None')); 
    end 
    
    [~, scores] = get_status(scores, labels);
    [~, p, ~] = fishertest([scores.TP, scores.FN; scores.FP, scores.TN]); 
    
    fprintf('\nFisher`s test for confusion matrix, %s:  p = %f', titles(i), p); 
    
end 

% overlap with RA 

good_out = find(final_stats.outcome == 1); 
poor_out = find(final_stats.outcome == 0); 
good_out_short = find(final_stats.outcome == 1 & ~strcmp(final_stats.InterceptOutstrHFO, 'None')); 
poor_out_short = find(final_stats.outcome == 0 & ~strcmp(final_stats.InterceptOutstrHFO, 'None')); 

results = [final_stats.SOZ_in_RA, ...
           final_stats.Spike_in_RA, ...
           final_stats.HFO_in_RA, ...
           final_stats.W_outstr_in_RA, ...
           final_stats.W_outstr_HFO_in_RA]; 

for i = 1:size(results, 2) 

    good_outcomes = good_out;
    poor_outcomes = poor_out;
    
    if i == 5
        good_outcomes = good_out_short;
        poor_outcomes = poor_out_short;
    end 

    p = ranksum(results(good_outcomes, i), results(poor_outcomes, i)); 
    fprintf('\nOverlap with RA, %s:  p = %f', titles(i), p); 
end


%% in Supplementary materials: 

% final scores 

overlap_thr = config.manuscript_figs_settings.fig_3_settings.overlap_threshold; 
final_stats = readtable(fullfile(config.paths.save_root, config.paths.stat_results_fnames.final_statistics_fname)); 

total_scores = []; 
raw_results = [final_stats.SOZ_in_RA, ...
           final_stats.Spike_in_RA, ...
           final_stats.HFO_in_RA, ...
           final_stats.W_outstr_in_RA, ...
           final_stats.W_outstr_HFO_in_RA]; 
       
results = raw_results >= overlap_thr; 
biomarker_names = ["SOZ", "Spikes", "HFO", "W_outstr", "W_outstr_HFO"];        
fprintf('\n\nIn supplementary materials:')

for i = 1:size(results, 2)
    if i == 5
        [~, scores] = get_status(results(~strcmp(final_stats.InterceptOutstrHFO, 'None'), i), ...
                                 final_stats.outcome(~strcmp(final_stats.InterceptOutstrHFO, 'None'))); 
    else
        [~, scores] = get_status(results(:, i), final_stats.outcome); 
    end 
    total_scores.(biomarker_names(i)) = scores;  
end 

t = ["Accuracy", "Sensitivity", "Specificity", "PPV", "NPV"]; 
for i = 1:length(biomarker_names)
    [Acc, Sens, Spec, PPV, NPV] = get_scores(...
                                        total_scores.(biomarker_names(i)).TP, ... 
                                        total_scores.(biomarker_names(i)).TN, ...
                                        total_scores.(biomarker_names(i)).FP, ...
                                        total_scores.(biomarker_names(i)).FN); 
    t = [t; [Acc, Sens, Spec, PPV, NPV]];                                 
end 
t = [["", biomarker_names]; t']';  

fprintf('\nFinal results for the overlap, threshold = %d \n', overlap_thr); 
disp(t); 

%% number of contacts for boimarkers, good vs poor outcome 
final_stats = readtable(fullfile(config.paths.save_root, config.paths.stat_results_fnames.final_statistics_fname)); 

good_outcomes = find(final_stats.outcome == 1); 
poor_outcomes = find(final_stats.outcome == 0); 

num_contacts = readmatrix(fullfile(config.paths.save_root, config.paths.stat_results_fnames.num_contacts_fname)); 

titles = ["Spikes", "HFO", "Outstr", "Outstr+HFO"]; 
for i = 3:6
    p = ranksum(num_contacts(good_outcomes, i), num_contacts(poor_outcomes, i)); 
    fprintf('\nNumber of contacts for %s, good vs poor outcome: p = %f', titles(i-2), p); 
end 


%% number of propagating and isolated spikes 

travelling_waves_percents_stat = readmatrix(fullfile(config.paths.save_root, config.paths.stat_results_fnames.travelling_waves_percents_fname)); 
titles = ["travelling spikes, all chs", "travelling spikes, weighted outstrength area chs", ...
          "isolated spikes, all chs", "isolated spikes, weighted outstrength area chs"]; 

for i = 4:7
    p = ranksum(travelling_waves_percents_stat(good_outcomes, i), travelling_waves_percents_stat(poor_outcomes, i)); 
    fprintf('\nNumber of %s, good vs poor outcome: p = %f', titles(i-3), p); 
end 

%% RA size 
final_stats = readtable(fullfile(config.paths.save_root, config.paths.stat_results_fnames.final_statistics_fname)); 
size_ra = final_stats.size_ra; 

p = ranksum(size_ra(good_outcomes), size_ra(poor_outcomes)); 
fprintf('\nNumber of contacts in RA, good vs poor outcome: p = %f', p); 

%% Overlap of Weighted Outstrength and HFO, % (Intercept of W Outstr with HFO / num of W outstr chs)   
outstr_hfo_perc = final_stats.outstr_hfo_perc;  

p = ranksum(outstr_hfo_perc(good_outcomes), outstr_hfo_perc(poor_outcomes)); 
fprintf('\nOverlap of Weighted Outstrength and HFO, good vs poor outcome: p = %f', p); 

%% number of onsets 
onsets = readtable(fullfile(config.paths.save_root, config.paths.stat_results_fnames.onset_numbers_fname)); 

onset_markers = [onsets.Separate_electrodes, onsets.Separate_areas]; 
titles = ["separate electrodes", "separate areas"]; 

for i = 1:size(onset_markers, 2)      
    p = ranksum(onset_markers(good_outcomes, i), onset_markers(poor_outcomes, i)); 
    fprintf('\nNum of onsets as %s, good vs poor outcome: p = %f', titles(i), p); 
end 