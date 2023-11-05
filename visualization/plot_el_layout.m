function [h] = plot_el_layout(patientStructFull, varargin)
% PLOT_EL_LAYOUT - Plot Electrode Layout and Additional Data
%
% Syntax:
%   [h] = plot_el_layout(patientStructFull, varargin)
%
% Description:
%   The `plot_el_layout` function generates a visual representation of electrode
%   locations and optional additional data using a simple brain surface plot.
%
% Inputs:
%   - patientStructFull: A data structure containing information about electrode
%     positions and other data.
%
% Optional Parameters (varargin):
%   - 'new_fig' (default: true): If set to true, the function creates a new
%     figure; if false, the function adds to an existing figure.
%   - 'fontsize' (default: 10): The font size for text labels.
%   - 'marker_size' (default: 2): The size of markers representing electrode
%     positions.
%   - 'arrows_flag' (default: true): Set to true to display arrows at electrode
%     positions, indicating their orientation.
%   - 'colormap_flag' (default: false): Set to true to enable colormap customization.
%   - 'colormap' (default: []): A custom colormap to be applied to the plot.
%   - 'colormap_position' (default: 'southoutside'): Position of the colormap bar.
%   - 'colormap_str' (default: ''): Title for the colormap.
%   - 'color_el' (default: [1, 0, 0]): Color for the electrode markers.
%   - 'position' (default: 'top'): Position of the electrodes on the brain
%     (e.g., 'top', 'bottom').
%   - 'propagation_flag' (default: false): Set to true to display propagation
%     markers (propagation of electrical signals between electrodes).
%   - 'graph_thr' (default: 100): Threshold for adjacency matrix when displaying
%     propagation markers.
%   - 'color_prop' (default: 'r'): Color for the propagation markers.
%   - 'ra_area_flag' (default: false): Set to true to display a region of interest
%     (RA) area.
%   - 'ra_chs' (default: []): Indices of channels within the RA.
%   - 'ra_color' (default: 'g'): Color for the RA markers.
%   - 'spike_rate' (default: []): Optional spike rate data to filter displayed
%     channels based on their spike rates.
%   - 'plot_cmap' (default: 'parula'): Colormap used for visualizing data on the
%     brain surface.
%   - 'spacing' (default: 10): Spacing between electrodes and additional markers.
%
% Output:
%   - h: The figure handle of the generated plot.

    p = inputParser;

    addParameter(p, 'new_fig', true);
    addParameter(p, 'fontsize', 10); 
    addParameter(p, 'marker_size', 2); 
    addParameter(p, 'arrows_flag', true);
    addParameter(p, 'colormap_flag', false);
    addParameter(p, 'colormap', []);
    addParameter(p, 'colormap_position', 'southoutside'); 
    addParameter(p, 'colormap_str', ''); 
    addParameter(p, 'color_el', [1, 0, 0]);
    addParameter(p, 'position', 'top'); 
    addParameter(p, 'propagation_flag', false); 
    addParameter(p, 'graph_thr', 100); 
    addParameter(p, 'color_prop', 'r');
    addParameter(p, 'prop_edge_scale', 3); 
    addParameter(p, 'ra_area_flag', false);
    addParameter(p, 'ra_chs', []);
    addParameter(p, 'ra_color', 'g'); 
    addParameter(p, 'spike_rate', []);
    addParameter(p, 'plot_cmap', 'parula');
    addParameter(p, 'spacing', 10);
    
    parse(p, varargin{:});

    new_fig = p.Results.new_fig; 
    fontsize = p.Results.fontsize;
    marker_size = p.Results.marker_size; 
    arrows_flag = p.Results.arrows_flag; 
    colormap_flag = p.Results.colormap_flag; 
    colormap = p.Results.colormap; 
    colormap_position = p.Results.colormap_position; 
    colormap_str = p.Results.colormap_str;
    color_el = p.Results.color_el; 
    position = p.Results.position; 
    propagation_flag = p.Results.propagation_flag;
    graph_thr = p.Results.graph_thr;
    color_prop = p.Results.color_prop; 
    ra_area_flag = p.Results.ra_area_flag; 
    ra_chs = p.Results.ra_chs; 
    ra_color = p.Results.ra_color; 
    prop_edge_scale = p.Results.prop_edge_scale;
    spike_rate = p.Results.spike_rate; 
    plot_cmap = p.Results.plot_cmap; 
    spacing = p.Results.spacing; 
    chan_names = patientStructFull.epochsList.chan_names;

    % mni coordinates 
    leadLocations = patientStructFull.leadLocations; 
    coords = cell2mat(leadLocations(:, 2:4)); 
    
    % keep the name of the last contact only
    del_chs = []; 
    for i = 1:length(chan_names)-1
        if strcmp( ...
                  chan_names{i}(1:find(isletter(chan_names{i}), 1, 'last')), ...
                  chan_names{i+1}(1:find(isletter(chan_names{i+1}), 1, 'last')) ...
                  ) 
           del_chs = [del_chs; i]; 
        else 
           chan_names{i} = chan_names{i}(1:find(isletter(chan_names{i}), 1, 'last' )); 
        end 
    end 
    
    chan_names{end} = chan_names{end}(1:find(isletter(chan_names{end}), 1, 'last' )); 
    chan_names(del_chs) = {''};  

    par = struct('position', position, ...
                 'mni', coords, ...
                 'color', color_el, ...
                 'marker_size', marker_size, ...
                 'arrows_flag', arrows_flag, ...
                 'colormap_flag', colormap_flag, ...
                 'colormap_position', colormap_position, ...
                 'colormap_str', colormap_str, ...
                 'fontsize', fontsize, ...
                 'plot_cmap', plot_cmap, ...
                 'spacing', spacing);           
    par.chan_names = chan_names; 
    
    if ~isempty(colormap)
        par.colormap = colormap; 
    end 
    
    if new_fig
        figure('units', 'normalized', 'outerposition', [0 0 1 1]); 
    end
    
    h = simpleBrainSurface(par);
    tmp_add_marker(par);
    set(gca, 'FontSize', fontsize); 
    
    if propagation_flag 
        adjMatrix = get_adjMatrix(patientStructFull); 
        adjMatrix = threshold_adjMatrix(adjMatrix, graph_thr); 
        if ~isempty(spike_rate)
            
            if size(spike_rate, 1) > size(spike_rate, 2)
                spike_rate = spike_rate'; 
            end 
            
            non_empty_channels = find((sum(adjMatrix, 1)' + sum(adjMatrix, 2) ~= 0) & (spike_rate > mean(spike_rate)/2)');  
            G = digraph(adjMatrix(non_empty_channels, non_empty_channels));
            prop_coords = coords(non_empty_channels, :); 
        else 
            G = digraph(adjMatrix);
            prop_coords = coords; 
        end 
        ch_pairs = G.Edges.EndNodes;
        ch_connections = G.Edges.Weight; 
        add_propagation_markers(prop_coords, ch_pairs, ch_connections, color_prop, par.position, prop_edge_scale);
    end
    
    if ra_area_flag
        ra_coords = coords(ra_chs, :); 
        ra_coords(:, 3) = ra_coords(:, 3) - 10; 
        par = struct('position', position, ...
                     'mni', ra_coords, ...
                     'color', ra_color, ...
                     'marker_size', marker_size + 2, ...
                     'arrows_flag', false, ...
                     'colormap_flag', false, ...
                     'chan_names', []);  
        tmp_add_marker(par); 
    end 
end 