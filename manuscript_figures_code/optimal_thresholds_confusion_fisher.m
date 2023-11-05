final_stats = readtable(fullfile(config.paths.save_root, config.paths.stat_results_fnames.final_statistics_fname)); 

results = [final_stats.SOZ_in_RA, ...
           final_stats.Spike_in_RA, ...
           final_stats.HFO_in_RA, ...
           final_stats.W_outstr_in_RA, ...
           final_stats.W_outstr_HFO_in_RA];
       
titles = ["SOZ", "Spikes", "HFO", "Outstr", "Outstr+HFO"]; 

%% find optimal threshold to use 

optimal_thresholds_stat = ["Biomarker", "FPR", "TPR", "FRP & TPR"]; 
optimal_thresholds = []; 

for i = 1:size(results, 2)  
    
    scores = results(:, i);
    labels = final_stats.outcome; 
    
    if i == 5
        scores = results(~strcmp(final_stats.InterceptOutstrHFO, 'None'), i); 
        labels = final_stats.outcome(~strcmp(final_stats.InterceptOutstrHFO, 'None')); 
    end 
    
    [X, Y, T, AUC, OPTPT] = perfcurve(labels, scores, 1);

    optimal_thresholds_stat = [optimal_thresholds_stat; ...
                            titles(i), ...
                            strjoin(string(unique(T(OPTPT(1) == X))), ', '), ...
                            strjoin(string(unique(T(OPTPT(2) == Y))), ', '), ...
                            string(intersect(T(OPTPT(1) == X), T(OPTPT(2) == Y)))]; 
      
    optimal_thresholds = [optimal_thresholds; intersect(T(OPTPT(1) == X), T(OPTPT(2) == Y))]; 
end 

disp('Optimal thresholds: ');                     
disp(optimal_thresholds_stat); 

%% Stat tests for thresholds 

thrs = unique([optimal_thresholds; 40; 50; 60; 100])'; 

fisher_test_results = zeros(size(thrs, 2), size(results, 2)+1); 

for thr = thrs 

    fisher_test_results(thrs == thr, 1) = thr;

    
    for i = 1:length(titles)
        
        thr_results = double(results >= thr);  
        outcomes = final_stats.outcome; 

        if i == 5
            thr_results = thr_results(~strcmp(final_stats.InterceptOutstrHFO, 'None'), :); 
            outcomes = outcomes(~strcmp(final_stats.InterceptOutstrHFO, 'None')); 
        end 
        
        [~, scores] = get_status(thr_results(:, i), outcomes);
        [~, p, ~] = fishertest([scores.TP, scores.FN; scores.FP, scores.TN]); 
        fisher_test_results(thr==thrs, i+1) = p;       
    end 
end 


%% plot confusion matrices for optimal thresholds 

colors = [cmap("dark_blue"); cmap("olive"); cmap("yellow"); cmap("purple"); cmap("teal")]; 

confusion_matrices_fig = figure('units', 'normalized', 'outerposition', [0 0 .7 1]); 

for thr = thrs 
    for i = 1:length(titles)
        
        thr_results = double(results >= thr);  
        outcomes = final_stats.outcome; 
        
        subplot(length(thrs), size(results, 2), i + size(results, 2) * (find(thr == thrs) - 1))
        
        if i == 1 
            y_label = {'thr = ' + string(thr), '', 'Outcome'}; 
        else
            y_label = {'Outcome'}; 
        end
        
        if optimal_thresholds(i) == thr
            diag_c = cmap('bright_green');
            off_d_c = cmap('bright_red');  
        else
            diag_c = cmap('green'); 
            off_d_c = cmap('red'); 
        end 
        
        if i == 5
            thr_results = thr_results(~strcmp(final_stats.InterceptOutstrHFO, 'None'), :); 
            outcomes = outcomes(~strcmp(final_stats.InterceptOutstrHFO, 'None')); 
        end 
        
        confusionchart(outcomes, ...
                       thr_results(:, i), ...
                       'Title', "\rm" + titles(i), ...
                       'DiagonalColor',  diag_c, ...
                       'OffDiagonalColor', off_d_c, ...
                       'GridVisible', 'on', ...
                       'XLabel', 'Resected', ...
                       'YLabel', y_label);  
    end 
end 
saveas(confusion_matrices_fig, fullfile(article_figs_saveroot, "ñonfusion_matrices.png"))


