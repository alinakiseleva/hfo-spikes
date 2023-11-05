function boxplot_fig = create_boxplot(x, g, xlabels, ylabels, colors, varargin)
% CREATE_BOXPLOT creates a boxplot with customizations.
%
%   boxplot_fig = create_boxplot(x, g, xlabels, ylabels, colors, varargin)
%   generates a boxplot of the data in 'x' grouped by 'g'. This function
%   offers various customization options and returns the handle to the
%   created boxplot figure.
%
% Input:
%   - x: Data values to create the boxplot.
%   - g: Grouping variable for boxplot.
%   - xlabels: Cell array of labels for the x-axis.
%   - ylabels: Label for the y-axis.
%   - colors: Matrix of colors for different groups.
%   - varargin: A list of optional parameter name-value pairs.
%
% Optional Parameters:
%   - 'box': Box display ('on' or 'off').
%   - 'XAxis': X-axis visibility ('on' or 'off').
%   - 'YAxis': Y-axis visibility ('on' or 'off').
%   - 'tick_length': Length of ticks [x-axis, y-axis].
%   - 'fig_fontsize': Font size for the figure.
%   - 'linewidth': Line width for boxplot elements.
%   - 'title': Title for the boxplot.
%   - 'title_color': Color for the title.
%   - 'title_background_color': Background color for the title.
%   - 'xticks': Display x-axis ticks ('on' or 'off').
%   - 'yticks': Display y-axis ticks ('on' or 'off').
%
% Output:
%   - boxplot_fig: Handle to the created boxplot figure.

    parser = inputParser();
    
    addOptional(parser, 'box', 'on'); 
    addOptional(parser, 'XAxis', 'on'); 
    addOptional(parser, 'YAxis', 'on'); 
    addOptional(parser, 'tick_length', [.01 .01]); 
    addOptional(parser, 'fig_fontsize', 10);  
    addOptional(parser, 'linewidth', 0.5);  
    addOptional(parser, 'title', '');  
    addOptional(parser, 'title_color', 'k'); 
    addOptional(parser, 'title_background_color', 'none'); 
    addOptional(parser, 'xticks', 'off');  
    addOptional(parser, 'yticks', 'off'); 
    
    parse(parser, varargin{:});
    
    box = parser.Results.box; 
    XAxis = parser.Results.XAxis;
    YAxis = parser.Results.YAxis;
    tick_length = parser.Results.tick_length; 
    fig_fontsize = parser.Results.fig_fontsize;
    linewidth = parser.Results.linewidth; 
    title_str = parser.Results.title; 
    title_color = parser.Results.title_color; 
    title_background_color = parser.Results.title_background_color;
    xticks_flag = parser.Results.xticks; 
    yticks_flag = parser.Results.yticks; 
    
    
    boxplot_fig = boxplot(x, g, ...
                          'Symbol', "r.");
    
    xticklabels(xlabels); 
    ylabel(ylabels); 
    
    h = findobj(gca, 'Tag', 'Box');
    colors = flip(colors, 1); 
    for j = 1:length(h)
        patch(get(h(j), 'XData'), ...
              get(h(j), 'YData'), colors(j,:), ...
              'FaceAlpha', .5, ...
              'EdgeColor', colors(j,:), ...
              'LineWidth', linewidth);
    end
    
    tags = ["Median", ...
            "Upper Adjacent Value", ...
            "Lower Adjacent Value", ...
            "Upper Whisker", ...
            "Lower Whisker", ...
            "Outliers"]; 
        
    for tag = tags 
        h = findobj(gca, 'Tag', tag); 
        for j = 1:length(h)
            h(j).Color = colors(j,:); 
            h(j).LineWidth = linewidth; 
            h(j).MarkerEdgeColor = colors(j,:); 
        end 
    end
    
    min_val = min(0, min(x)); 
    
    if isvector(x) & strcmp(yticks_flag, 'off')
        yticks(round([min_val max(x)], 2, "significant")); 
        yticklabels(round([min_val max(x)], 2, "significant")); 
        ylim([min_val max(x) + max(x) / 50])
    end 
 
    
    set(gca, ... 
        'box', box, ...
        'TickLength', tick_length); 

    ax = gca;    
    ax
    ax.XRuler.Axle.Visible = XAxis; 
    ax.YRuler.Axle.Visible = YAxis; 

    set(gca, 'FontSize', fig_fontsize); 
    
    t = title(title_str, 'Color', title_color, 'BackgroundColor', title_background_color); 
    
    if strcmp(xticks_flag, 'off')
        xticks([]); 
    end 
end