function plot_graph(adjMatrix, varargin)
% PLOT_GRAPH - Visualize a Graph Represented by an Adjacency Matrix
%
% Visualize the structure of a graph represented by its adjacency matrix. This
% function generates a plot of the graph's nodes and edges and allows for
% customization of various plot attributes.
%
% Syntax:
%   plot_graph(adjMatrix, varargin)
%
% Inputs:
%   - adjMatrix (matrix): A square adjacency matrix representing the graph
%     structure.
%
% Optional Parameters (Name-Value Pairs):
%   - 'chan_names' (cell array, default: []): An optional cell array of node
%     labels corresponding to the rows/columns of the adjacency matrix.
%   - 'node_colors' (vector, default: ones(size(adjMatrix, 1), 1)): A vector of
%     node colors to distinguish nodes in the graph.
%   - 'marker_size' (vector, default: ones(size(adjMatrix, 1), 1)): A vector
%     specifying marker sizes for nodes.
%   - 'non_empty_channels' (vector, default: channels with non-zero degree):
%     Indices indicating which channels to include in the graph visualization.
%   - 'fontsize' (double, default: 10): Font size for node labels and colorbar.
%   - 'colormap' (char, default: 'parula'): A string specifying the colormap
%     used for node colors.
%   - 'colormap_str' (char, default: ''): A title for the colorbar.
%   - 'edge_color' (RGB vector, default: [0 0.4470 0.7410]): Color of graph edges.
%   - 'box' (char, default: 'off'): Whether to display a box around the colorbar
%   - 'colormap_str_alignment' (char, default: 'bottom'): Alignment of the
%     colormap title.
%   - 'arrow_size' (double, default: 15): Size of arrows indicating edge
%     direction.
%   - 'colormap_label_color' (char, default: 'k'): Color of the colorbar label.
%   - 'colormap_edge_color' (char, default: 'w'): Color of the colorbar
%     edge.
%   - 'graph_layout' (char, default: 'force'): Layout algorithm for graph
%     visualization.

    parser = inputParser;
    parser.addRequired('adjMatrix', @ismatrix);
    parser.addOptional('chan_names', []);
    parser.addOptional('node_colors', ones(size(adjMatrix, 1), 1));
    parser.addOptional('marker_size', ones(size(adjMatrix, 1), 1));
    parser.addOptional('non_empty_channels', find((sum(adjMatrix, 1)' + sum(adjMatrix, 2)) ~= 0));
    parser.addOptional('fontsize', 10);
    parser.addOptional('colormap', 'parula');
    parser.addOptional('colormap_str', '');
    parser.addOptional('edge_color', [0 0.4470 0.7410]);
    parser.addOptional('box', 'off');
    parser.addOptional('colormap_str_alignment', 'bottom');
    parser.addOptional('arrow_size', 15);
    parser.addOptional('colormap_label_color', 'k');
    parser.addOptional('colormap_edge_color', 'w');
    parser.addOptional('graph_layout', 'force');
  
    parser.parse(adjMatrix, varargin{:});

    non_empty_channels = parser.Results.non_empty_channels; 
    chan_names = parser.Results.chan_names(non_empty_channels);
    node_colors = parser.Results.node_colors(non_empty_channels);
    marker_size = 5 * parser.Results.marker_size(non_empty_channels) / max(parser.Results.marker_size(non_empty_channels));
    fontsize = parser.Results.fontsize;
    cmap = parser.Results.colormap; 
    colormap_str = parser.Results.colormap_str; 
    edge_color = parser.Results.edge_color;
    box_flag = parser.Results.box;
    colormap_alignment = parser.Results.colormap_str_alignment; 
    arrow_size = parser.Results.arrow_size; 
    colormap_label_color = parser.Results.colormap_label_color; 
    colormap_edge_color = parser.Results.colormap_edge_color; 
    graph_layout = parser.Results.graph_layout; 
    
    G = digraph(adjMatrix(non_empty_channels, non_empty_channels), chan_names);
    
    if ~isempty(G.Edges)
        
        G.Edges.LWidths = 5 * G.Edges.Weight / max(G.Edges.Weight); 
        
        for nodename = G.Nodes.Name'
            if ~any(strcmp(nodename, G.Edges.EndNodes))
                node_colors(strcmp(nodename, G.Nodes.Name)) = [];
                marker_size(strcmp(nodename, G.Nodes.Name)) = []; 
                G = rmnode(G, nodename);              
            end 
        end 
        
        p = plot(G, ...
                 'NodeCData', node_colors, ...
                 'MarkerSize', marker_size, ...
                 'layout', graph_layout, ...
                 'NodeFontSize', fontsize, ...
                 'EdgeColor', edge_color);
             
        set(gca, 'FontSize', fontsize); 
        
        colormap(cmap);      
        c = colorbar('southoutside', ...
                     'Ticks', [min(node_colors), max(node_colors)/2, max(node_colors)], ...
                     'TickLabels', append(repmat("\color{black}", 1, 3), ...
                                          string(round( ...
                                                [min(node_colors), ...
                                                max(node_colors)/2, ...
                                                max(node_colors)], 2))));
                 
        c.Label.String = colormap_str;
        c.Label.VerticalAlignment = colormap_alignment;
        
        c.Position(2) = c.Position(2) - 2 * c.Position(4); 
        c.Position(4) = c.Position(4) / 2;                      
        c.TickLength = 0; 
        c.Box = box_flag; 
        c.EdgeColor = colormap_edge_color; 
        c.Label.Color = colormap_label_color; 
        c.Label.Position(2) = c.Position(2) + 1; 
        c.Label.FontSize = fontsize; 
        
        p.LineWidth = G.Edges.LWidths;
        p.ArrowSize = arrow_size;
        
    end
end


