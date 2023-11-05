function [adjMatrixfig, graph, cleaned_graph] = plot_propagation_patterns(patientStructFull, graph_thr, seq_win_s)
% PLOT_PROPAGATION_PATTERNS - Plot Propagation Patterns of Electrophysiological Data
%
% Syntax:
%   [adjMatrixfig, graph, cleaned_graph] = plot_propagation_patterns(patientStructFull, graph_thr, seq_win_ms)
%
% Description:
%   The `plot_propagation_patterns` function is designed to visualize the
%   propagation patterns of electrophysiological data. It generates several
%   graphs illustrating the network of connections between channels.
%
% Inputs:
%   - patientStructFull: A struct containing the patient's electrophysiological
%     data and information.
%   - graph_thr: A threshold value for graph connections.
%   - seq_win_ms: The length of the sequence window in milliseconds.
%
% Outputs:
%   - adjMatrixfig: A figure displaying the adjacency matrix.
%   - graph: A figure showing the network graph with noisy data.
%   - cleaned_graph: A figure displaying the network graph after cleaning and
%     applying the threshold.

    Fs = patientStructFull.epochsList.Fs;
    seq_win = round(seq_win_s * Fs); 

    chan_names = patientStructFull.listFull; 

    adjMatrixfig = figure('Position', get(0, 'Screensize'));
    patientStructFull = buildElectrodeCommunities(patientStructFull);

    spike_rate = get_patientStructFull_spike_rates(patientStructFull);   
    if size(spike_rate, 1) > size(spike_rate, 2) 
        spike_rate = spike_rate';
    end 
    
    [~, outstrength] = get_in_out_str(patientStructFull); 

    % plot graphs 
    adjMatrix = get_adjMatrix(patientStructFull); 

    graph = figure('Position', get(0, 'Screensize'));   
    plot_graph(adjMatrix, ...
               'chan_names', chan_names, ...
               'node_colors', outstrength, ...
               'marker_size', spike_rate); 
           

    adjMatrix = get_adjMatrix(patientStructFull); 
    thr_adjMatrix = threshold_adjMatrix(adjMatrix, graph_thr); 
    non_empty_channels = find((sum(thr_adjMatrix, 1)' + sum(thr_adjMatrix, 2) ~= 0) & (spike_rate > mean(spike_rate)/4)');  

    cleaned_graph = figure('Position', get(0, 'Screensize')); 
    plot_graph(thr_adjMatrix, ...
               'chan_names', chan_names, ...
               'node_colors', outstrength, ...
               'marker_size', spike_rate, ...
               'non_empty_channels', non_empty_channels); 
    
    
end
