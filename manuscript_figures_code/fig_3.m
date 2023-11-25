final_stats = readtable(fullfile(config.paths.save_root, config.paths.stat_results_fnames.final_statistics_fname)); 
thr = config.manuscript_figs_settings.fig_3_settings.overlap_threshold; 

%% leave-one-out roc curves 

results = [final_stats.SOZ_in_RA, ...
           final_stats.Spike_in_RA, ...
           final_stats.HFO_in_RA, ...
           final_stats.W_outstr_in_RA, ...
           final_stats.W_outstr_HFO_in_RA];
titles = ["SOZ", "Spikes", "HFO", "Outstrength", "HFO + Outstrength"]; 
colors = [cmap("dark_blue"); cmap("olive"); cmap("yellow"); cmap("purple"); cmap("teal")]; 

figure('units', 'normalized', 'outerposition', [0 0 1 1]); 

row1 = [];

for i = 1:size(results, 2)
    
    scores = results(:, i);
    labels = final_stats.outcome; 
    
    if i == 5
        scores = results(~strcmp(final_stats.InterceptOutstrHFO, 'None'), i); 
        labels = final_stats.outcome(~strcmp(final_stats.InterceptOutstrHFO, 'None')); 
    end 
    
    s = subplot(4, 5, i); 
    row1 = [row1; s]; 
    plot_leave_one_out_roc(scores, labels, ...
                           'title_str', titles(i), ...
                           'title_background_color', colors(i, :), ...
                           'title_color', 'w', ...
                           'linewidth', 1.5, ...
                           'color', colors(i, :), ...
                           'fig_fontsize', fig_fontsize, ...
                           'box', 'off', ...
                           'XAxis', 'on', ...
                           'YAxis', 'on', ...
                           'tick_length', [0 0], ...
                           'auc_flag', true);
                       
    [~, scores] = get_status(scores >= thr, labels);
    [~, p, ~] = fishertest([scores.TP, scores.FN; scores.FP, scores.TN]); 
    add_p_marker(p, .8, .35, 'marker_color', cmap('light_gray'), 'yshift', .005); 
end 

% confusion matrix       
row2 = []; 

for i = 1:length(titles)

    s = subplot(4, 5, i + 5); 
    row1(i).Position(2) = s.Position(2); 
    row1(i).Position(4) = row1(i).Position(4) * 2.5; 
    s.Position(1:2) = s.Position(1:2) + [.6 .3] .* s.Position(3:4); 
    s.Position(3:4) = s.Position(3:4) * .4; 
    
    scores = results(:, i);
    labels = final_stats.outcome; 
    
    if i == 5
        scores = results(~strcmp(final_stats.InterceptOutstrHFO, 'None'), i); 
        labels = final_stats.outcome(~strcmp(final_stats.InterceptOutstrHFO, 'None')); 
    end 
    
    confusionchart(labels, ...
                   double(scores >= thr), ...
                   'Title', "\rm" + titles(i), ... 
                   'DiagonalColor',  colors(i, :), ... cmap('green'), ...
                   'OffDiagonalColor', cmap('red'), ...
                   'GridVisible', 'on', ...
                   'XLabel', 'Resected', ...
                   'YLabel', 'Outcome');
               
end 


% Overlap with RA 
good_out = find(final_stats.outcome == 1); 
poor_out = find(final_stats.outcome == 0); 
good_out_short = find(final_stats.outcome == 1 & ~strcmp(final_stats.InterceptOutstrHFO, 'None')); 
poor_out_short = find(final_stats.outcome == 0 & ~strcmp(final_stats.InterceptOutstrHFO, 'None')); 

results = [final_stats.SOZ_in_RA, ...
           final_stats.Spike_in_RA, ...
           final_stats.HFO_in_RA, ...
           final_stats.W_outstr_in_RA, ...
           final_stats.W_outstr_HFO_in_RA]; 

axs = []; 
markers = [results(:, 1), results(:, 2), results(:, 3), results(:, 4), results(:, 5)]; 

for i = 1:size(markers, 2) 
    ax = subplot(4, 5, i + 10); 
    axs = [axs; ax]; 
    
    good_outcomes = good_out;
    poor_outcomes = poor_out;
    
    if i == 5
        good_outcomes = good_out_short;
        poor_outcomes = poor_out_short;
    end 
    
    create_boxplot([markers(good_outcomes, i); markers(poor_outcomes, i)], ...
                   [zeros(size(good_outcomes)); ones(size(poor_outcomes))], ...
                   [], ...
                   "Overlap with RA, %", ...
                   [colors(i, :); cmap('red')], ... cmap('green')
                   'fig_fontsize', fig_fontsize, ...
                   'title_background_color', colors(i, :), ...
                   'title_color', 'w', ...
                   'box', 'off', ...
                   'YAxis', 'on', ...
                   'XAxis', 'off', ...
                   'tick_length', [0 0], ...
                   'linewidth', 1, ...
                   'title', titles(i), ... "\rm" + 
                   'xticks', 'off');  
               ylim([0 110])
    p = ranksum(markers(good_outcomes, i), markers(poor_outcomes, i))
    hold on; 
    add_p_marker(p, 1.5, max([markers(good_outcomes, i); markers(poor_outcomes, i)]), 'marker_color', cmap('light_gray')); 
end
linkaxes(axs, 'y'); 


% leave-one-out scores plots 

results = [final_stats.All_SOZ_in_RA, ...
           final_stats.All_spikes_in_RA, ...
           final_stats.All_HFO_in_RA, ...
           final_stats.All_w_outstr_in_RA, ...
           final_stats.All_w_outstr_HFO_in_RA]; 
       
N = length(results(:,1));

lou_scores = []; 
lou_acc = [];
lou_sens = [];
lou_spec = [];
lou_ppv = [];
lou_npv = [];

for j = 1:size(results, 2)
    for n = 1:N
        lou_results = results(:, j); 
        
        if j == 5
            del = find(strcmp(final_stats.InterceptOutstrHFO, 'None')); 
            n = [n, del]; 
        end 
        
        lou_results(n) = [];
        lou_outcome = final_stats.outcome; 
        lou_outcome(n) = [];
        [~, scores] = get_status(lou_results, lou_outcome); 

        [Acc, Sens, Spec, PPV, NPV] = get_scores(scores.TP, ... 
                                                 scores.TN, ...
                                                 scores.FP, ...
                                                 scores.FN, ...
                                                 0); 
        lou_scores = [lou_scores; [Acc, Sens, Spec, PPV, NPV]]; 
        
    end 
    
    lou_acc = [lou_acc, lou_scores(:, 1)]; 
    lou_sens = [lou_sens, lou_scores(:, 2)]; 
    lou_spec = [lou_spec, lou_scores(:, 3)]; 
    lou_ppv = [lou_ppv, lou_scores(:, 4)]; 
    lou_npv = [lou_npv, lou_scores(:, 5)]; 
    lou_scores = []; 
    
end 

score_titles = ["Accuracy", "Sensitivity", "Specificity", "PPV", "NPV"]
i = 1;
for x = {lou_acc; lou_sens; lou_spec; lou_ppv; lou_npv}'
    subplot(4, 5, i + 15); 
    create_boxplot(x{1}, ...
                   [], ...
                   [], ...
                   "", ...
                   colors, ...
                   'fig_fontsize', fig_fontsize, ...
                   'YAxis', 'off', ...
                   'XAxis', 'off', ...
                   'tick_length', [0 0], ...
                   'linewidth', 1, ...
                   'title', "\rm" + score_titles(i)); 
    i = i + 1;            
end 

set(gcf, 'InvertHardCopy', 'off');
set(gcf, 'Color', 'w');
print(fullfile(article_figs_saveroot, 'fig_3.png'), '-dpng', '-r500');


