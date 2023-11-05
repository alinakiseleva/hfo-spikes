good_outcome_patient = config.manuscript_figs_settings.fig_2_settings.good_outcome_patient; 
poor_outcome_patient = config.manuscript_figs_settings.fig_2_settings.poor_outcome_patient; 
graph_thr = config.manuscript_figs_settings.fig_2_settings.graph_thr;

%% load data

data = struct();
tmp_struct = struct(); 

for patient = [good_outcome_patient, poor_outcome_patient]

    paths = build_patient_paths(config, patient); 

    patientStructFull = create_patientStructFull(paths, ...
                                                 patient, ...
                                                 'flag_results', flag_results, ...
                                                 'flag_use_every_second_channel', flag_use_every_second_channel, ...
                                                 'overwrite', false, ...
                                                 'seq_win_s', seq_win_s); 

    [hfo_rates, spike_rates] = load_full_rates(paths, patientStructFull); 
    [~, outstr] = get_in_out_str(patientStructFull); 
    
    chan_names = patientStructFull.listFull;
    bad_channels = get_bad_channels(paths.bad_channels_path, paths.list_name, chan_names);
    bad_channels_hfo = get_bad_channels(paths.bad_channels_hfo_path, paths.list_name, chan_names);


    hfo_outstr_chs = intercept_channels(chan_names(hfo_rates > prctile(hfo_rates, prctile_thr))', ...
                                        chan_names(outstr > prctile(outstr, prctile_thr))'); 

    hfo_outstr_inds = get_ch_indexes(chan_names, hfo_outstr_chs);    
    
    outstr_hfo = zeros(size(hfo_rates)); 
    outstr_hfo(hfo_outstr_inds) = 1; 
    

    ra = readtable(fullfile(config.paths.save_root, 'resected_electrodes.xlsx'), ...
                   'Sheet', ['p' num2str(patient)]); 

    ra_inds = get_ch_indexes(patientStructFull.listFull, ...
                             intercept_channels(patientStructFull.listFull, table2cell(ra))); 
    
    tmp_struct = struct('patientStructFull', patientStructFull, ...
                        'hfo_rates', hfo_rates, ...
                        'spike_rates', spike_rates', ...
                        'outstr', outstr, ...
                        'outstr_hfo', outstr_hfo, ...
                        'bad_channels', bad_channels, ...
                        'bad_channels_hfo', bad_channels_hfo, ...
                        'ra_ind', ra_inds);
                    
    if patient == good_outcome_patient
        data.good_outcome = tmp_struct;
    elseif patient == poor_outcome_patient
        data.poor_outcome = tmp_struct;
    end 
    
    clear tmp_struct; 
    
end 
%%
NV = struct('FontSize', 12, ...
            'FontWeight', 'normal', ...
            'Location', 'NorthWest', ...
            'HShift', -0.04, ...
            'VShift', 0, ...
            'Color', [0 0 0], ...
            'FitLocation', false); 

subplots = reshape([1:24], 3, 8)'; 

% Propagation on electrode layout 
example_fig = figure('units','normalized','outerposition',[0 0 .7 1]); 

let_subs = []; 
i = 1; 
for outcome = [data.good_outcome, data.poor_outcome]
    let_sub = subplot(8, 3, subplots(i:i+3, 1)); 
    [brain] = plot_el_layout(outcome.patientStructFull, ...
                             'position', 'top', ...
                             'new_fig', false, ... 
                             'fontsize', fig_fontsize-1, ...
                             'marker_size', 2, ...
                             'arrows_flag', true, ...
                             'colormap_flag', true, ...
                             'colormap_position', 'southoutside', ...
                             'colormap', outcome.spike_rates .* outcome.outstr, ...
                             'colormap_str', 'Weighted outstrength', ...
                             'propagation_flag', true, ...
                             'graph_thr', graph_thr, ...
                             'color_prop', cmap('light_gray'), ...
                             'spike_rate', outcome.spike_rates, ...
                             'prop_edge_scale', 7, ...
                             'plot_cmap', cmap('custom_cmap'), ...
                             'spacing', 18, ...
                             'ra_area_flag', true, ...
                             'ra_chs', outcome.ra_ind, ...
                             'ra_color', cmap('ra')); 
    
   i = i + 4; 
   let_subs = [let_subs let_sub]; 
end 
 
% Spike and HFO rates 

out = 1; 
j = 1; 

legs = []; 

for outcome = [data.good_outcome, data.poor_outcome] 
    
    bar_color = [cmap('green') cmap('bright_green'); cmap('red') cmap('bright_red')]; 
    
    rates = [outcome.spike_rates; outcome.hfo_rates; outcome.outstr .* outcome.spike_rates; outcome.outstr_hfo]; 
    bad_chs = {outcome.bad_channels; outcome.bad_channels_hfo; outcome.bad_channels; [outcome.bad_channels_hfo outcome.bad_channels]}; 
    titlestr = ["Spike rates", "HFO rates", "Weighted outstrength", "HFO + Outstrength area"]; 
    
    for i = 1:size(rates, 1) 
        s = subplot(8, 3, subplots(j, 2:3)); 
        
        [b, r] = build_rate_bar(rates(i, :), ...
                   'xticklabels', outcome.patientStructFull.listFull, ...
                   'color', bar_color(out, 1:3), ...
                   'titlestr', "\rm" + titlestr(i), ...
                   'bad_channels', [], ...
                   'fontsize', fig_fontsize-2, ...
                   'show_chan_names', 0, ...
                   'ra_channels', outcome.ra_ind, ...
                   'ra_edge_color', 'none', ...
                   'ra_face_color', [cmap('ra') .5], ...
                   'ra_linewidth', 1.0, ...
                   'XAxis', 'off', ...
                   'YAxis', 'off', ...
                   'tick_length', [0 0], ...
                   'highlighted_channels', find(rates(i, :) > prctile(rates(i, :), prctile_thr)), ...
                   'highlight_color', bar_color(out, 4:6), ...
                   'round_labels', true); 
               
        s.Position(4) = s.Position(4) - s.Position(4) / 4; 
               
        if mod(j, 4) ~= 0       
            hold on;  
            l = line(xlim, [prctile(rates(i, :), prctile_thr), prctile(rates(i, :), prctile_thr)], ...
                'Color', cmap('light_gray'), 'LineWidth', 1);
        end 
        j = j + 1;
        
        if i == 4
            legs = [legs, b, l, r];
        end
        
    end 
    out = 2; 
    
end 


leg = legend([legs(1:2) legs(5:6) legs(3:4)], ...
             {'Good outcomes channels', 'Good outcome area channels', ...
              'Poor outcome channels', 'Poor outcome area channels', ...
              'Threshold', 'RA'}, ...
              'FontSize', fig_fontsize, ...
              'Box', 'off', ...
              'NumColumns', 3); 

leg.Position(1) = s.Position(1) + .5 * (s.Position(3) - leg.Position(3)); 
leg.Position(2) = s.Position(2) - 1.5 * leg.Position(4);

AddLetters2Plots({let_subs(1) let_subs(2)}, {'A', 'B'}, NV); 

saveas(example_fig, fullfile(article_figs_saveroot, 'fig_2_good_poor_example.png'))


%% Stats figure 

boxplot_fig = figure('units', 'normalized', 'outerposition', [0 0 .4 1]); 

% rates stats 

stat = readmatrix(fullfile(config.paths.save_root, paths.rates_stat_fname)); 
outcomes = readtable(fullfile(config.paths.save_root, paths.outcomes_fname)); 

good_outcomes = [];
poor_outcomes = []; 

for pat = stat(:, 1)'
    out = outcomes.outcome(outcomes.patient == pat);
    if ~isempty(out)
        pat_num = find(stat(:, 1) == pat); 
        switch out
            case 1
                good_outcomes = [good_outcomes; pat_num]; 
            case 0 
                poor_outcomes = [poor_outcomes; pat_num]; 
        end 
    end 
end


spikes_area = stat(:, 3);
hfo_area = stat(:, 5);
outstr_w_area = stat(:, 9);

c = subplot(3, 2, 1); 
create_boxplot([spikes_area(good_outcomes); spikes_area(poor_outcomes)], ...
              [zeros(size(good_outcomes)); ones(size(poor_outcomes))], ...
              ["", ""], ...
              "Spike rates (events per minute)", ...
              [cmap('green'); cmap('red')], ...
              'box', 'off', ...
              'YAxis', 'on', ...
              'XAxis', 'off', ...
              'tick_length', [0 0], ...
              'linewidth', 1, ...
              'title', '\rmSpike area channels', ...
              'fig_fontsize', fig_fontsize);  
          
p = ranksum(spikes_area(good_outcomes), spikes_area(poor_outcomes)); 
hold on; 
add_p_marker(p, 1.5, max(spikes_area), 'marker_color', cmap('light_gray')); 

c1 = subplot(3, 2, 2); 
create_boxplot([hfo_area(good_outcomes); hfo_area(poor_outcomes)], ...
              [zeros(size(good_outcomes)); ones(size(poor_outcomes))], ...
              {'', ''}, ...
              "HFO rates (events per minute)", ...
              [cmap('green'); cmap('red')], ...
              'box', 'off', ...
              'YAxis', 'on', ...
              'XAxis', 'off', ...
              'tick_length', [0 0], ...
              'linewidth', 1, ...
              'title', '\rmHFO area channels', ...
              'fig_fontsize', fig_fontsize);   
          
p = ranksum(hfo_area(good_outcomes), hfo_area(poor_outcomes)); 
hold on; 
add_p_marker(p, 1.5, max(hfo_area([good_outcomes; poor_outcomes])), 'marker_color', cmap('light_gray')); 

d = subplot(3, 2, 3); 
create_boxplot([outstr_w_area(good_outcomes); outstr_w_area(poor_outcomes)], ...
              [zeros(size(good_outcomes)); ones(size(poor_outcomes))], ...
              {'', ''}, ...
              "Outstrength", ...
              [cmap('green'); cmap('red')], ...
              'box', 'off', ...
              'YAxis', 'on', ...
              'XAxis', 'off', ...
              'tick_length', [0 0], ...
              'linewidth', 1, ...
              'title', '\rmOutstrength area channels', ...
              'fig_fontsize', fig_fontsize);
          
p = ranksum(outstr_w_area(good_outcomes), outstr_w_area(poor_outcomes)); 
hold on; 
add_p_marker(p, 1.5, max(outstr_w_area), 'marker_color', cmap('light_gray')); 


% spike and HFO co-occurrence stats 

stat = readmatrix(fullfile(config.paths.save_root, paths.spike_hfo_coocurrence_fname)); 

perc_coocur_all_chs = stat(:, 3) ./ stat(:, 2) .* 100; 
perc_coocur_max_ch = stat(:, 6) ./ stat(:, 5) .* 100; 

% all chs good vs bad
e = subplot(3, 2, 5); 
create_boxplot([perc_coocur_all_chs(good_outcomes); perc_coocur_all_chs(poor_outcomes)], ...
              [zeros(size(good_outcomes)); ones(size(poor_outcomes))], ...
              ["", ""], ...
              "Co-occuring spike and HFO, %", ...
              [cmap('green'); cmap('red')], ...
              'box', 'off', ...
              'YAxis', 'on', ...
              'XAxis', 'off', ...
              'tick_length', [0 0], ...
              'linewidth', 1, ...
              'title', '', ...
              'fig_fontsize', fig_fontsize);
          
ylim([0 100])
yticks([0 100])
yticklabels([0 100])

p = ranksum(perc_coocur_all_chs(good_outcomes), perc_coocur_all_chs(poor_outcomes)); 
hold on; 
add_p_marker(p, 1.5, max(perc_coocur_all_chs), 'marker_color', cmap('light_gray')); 


% travelling waves stats 

stat = readmatrix(fullfile(config.paths.save_root, paths.travelling_waves_percents_fname)); 
stat(:, 2:3) = stat(:, 2:3) * 100; 

% w outstr area chs good vs bad
d1 = subplot(3, 2, 4); 
create_boxplot([stat(good_outcomes, 3); stat(poor_outcomes, 3)], ...
              [zeros(size(good_outcomes)); ones(size(poor_outcomes))], ...
              ["", ""], ...
              "Propagating spikes, %", ...
              [cmap('green'); cmap('red')], ...
              'box', 'off', ...
              'YAxis', 'on', ...
              'XAxis', 'off', ...
              'tick_length', [0 0], ...
              'linewidth', 1, ...
              'title', '\rmWeigthed outstrength area channels', ...
              'fig_fontsize', fig_fontsize);    

ylim([0 100])
yticks([0 100])
yticklabels([0 100])

p = ranksum(stat(good_outcomes, 3), stat(poor_outcomes, 3)); 
hold on; 
add_p_marker(p, 1.5, max(stat(:, 3)), 'marker_color', cmap('light_gray')); 


% propagation speed

stat = readmatrix(fullfile(config.paths.save_root, paths.spike_velocity_fname)); 

v = subplot(3, 2, 6); 
       
violinplot([stat(good_outcomes, 2); stat(poor_outcomes, 2)], ...
           [zeros(size(good_outcomes)); ones(size(poor_outcomes))], ...
           'Width', 0.2, ...
           'ViolinColor', [cmap('green'); cmap('red')], ...
           'ViolinAlpha', .5, ...
           'EdgeColor', [0 0 0], ... 
           'MedianColor', cmap('gray'), ...
           'ShowData', false, ...
           'BoxColor', cmap('gray'), ...
           'ShowBox', true, ...
           'ShowMean', false, ...
           'ShowMedian', false);    
       
xticks([]);        
yticks(round([0 max(stat(:, 2)) / 2  max(stat(:, 2))])); 
yticklabels(round([0 max(stat(:, 2)) / 2  max(stat(:, 2))])); 
ylim([0 round(max(stat(:, 2)))]); 

h = findobj(gca, 'Type', 'Patch');
colors = flip([cmap('green'); cmap('green'); cmap('red'); cmap('red')], 1); 

for j = 1:length(h)
    patch(get(h(j), 'XData'), ...
          get(h(j), 'YData'), ...
          colors(j,:), ...
          'FaceAlpha', .5, ...
          'EdgeColor', colors(j,:), ...
          'LineWidth', 1);
    delete(h(j)); 
end


h = findobj(gca, 'Type', 'Line');
h = h([1 3]); 
colors = flip([cmap('green'); cmap('red')], 1); 

legs = []; 
for j = 1:length(h)
    leg = patch(get(h(j), 'XData'), ...
                get(h(j), 'YData'), ...
                colors(j,:), ...
                'FaceAlpha', .5, ...
                'EdgeColor', colors(j,:), ...
                'LineWidth', 1);
    legs = [legs leg]; 
    delete(h(j)); 
end


ylabel(["\rmSpike velocity, m/s"]); 
set(gca, ... 
    'TickLength', [0 0]); 

ax = gca;    
ax
box('off')
ax.XRuler.Axle.Visible = 'off'; 
ax.YRuler.Axle.Visible = 'on'; 
ax.FontSize = fig_fontsize;

p = ranksum(stat(good_outcomes, 2), stat(poor_outcomes, 2)); 
hold on; 
add_p_marker(p, 1.5, max(stat(:, 2)), 'marker_color', cmap('light_gray')); 

v.Position(1) = c1.Position(1); 
v.Position(3) = c1.Position(3); 
d1.Position(1) = c1.Position(1); 
d1.Position(3) = c1.Position(3); 
e.Position(1) = c.Position(1); 
e.Position(3) = c.Position(3); 

NV = struct('FontSize', 12, ...
            'FontWeight', 'normal', ...
            'Location', 'NorthWest', ...
            'HShift', -0.04 * 3, ...
            'VShift', 0, ...
            'Color', [0 0 0], ...
            'FitLocation', false); 

AddLetters2Plots({c d e}, {'C', 'D', 'E'}, NV); 

leg = legend(flip(legs), ...
             'String', {'Good outcome', 'Poor outcome'}, ...
             'FontSize', fig_fontsize, ...
             'Box', 'off'); 
         
leg.Position(1) = mean([e.Position(1) + e.Position(3); v.Position(1)]) - leg.Position(3) / 2; 
leg.Position(2) = e.Position(2) - 1.5 * leg.Position(4);

saveas(boxplot_fig, fullfile(article_figs_saveroot, 'fig_2_stats.png'))


