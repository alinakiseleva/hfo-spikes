function add_p_marker(pvalue, x, y, varargin)
% add_p_marker - Add p-value markers to a plot.
%
% Input:
%   - pvalue: The p-value to be displayed.
%   - x: The x-coordinate where the marker will be placed.
%   - y: The y-coordinate where the marker will be placed.
%
% Name-Value Pairs:
%   - 'marker_size': Size of the marker (default: 10).
%   - 'marker_color': Color of the marker (default: 'b' for blue).
%   - 'yshift': Vertical shift for the marker (default: 0.01).
%   - 'marker_shape': Shape of the marker (default: 'pentagram'). 

    p = inputParser;
    addParameter(p, 'marker_size', 10);
    addParameter(p, 'marker_color', 'b');
    addParameter(p, 'yshift', .01);
    addParameter(p, 'marker_shape', 'pentagram');
    
    parse(p, varargin{:});

    marker_size = p.Results.marker_size; 
    marker_color = p.Results.marker_color; 
    yshift = p.Results.yshift; 
    marker_shape = p.Results.marker_shape; 
    
    hold on; 
    
    if pvalue <= 0.001
        
        plot([x - 2*yshift*marker_size; x; x + 2*yshift*marker_size], ...
             [y y y], ...
             marker_shape, ...
             'MarkerSize', marker_size, ...
             'MarkerFaceColor', marker_color, ...
             'MarkerEdgeColor', marker_color);

    elseif pvalue <= 0.01 
        
        plot([x - yshift*marker_size; x + yshift*marker_size], ... 
             [y y], ...
             marker_shape, ...
             'MarkerSize', marker_size, ...
             'MarkerFaceColor', marker_color, ...
             'MarkerEdgeColor', marker_color);
        
    elseif pvalue <= 0.05
        plot(x, y, ...
             marker_shape, ...
             'MarkerSize', marker_size, ...
             'MarkerFaceColor', marker_color, ...
             'MarkerEdgeColor', marker_color);
    end 
    
    hold off;

end 