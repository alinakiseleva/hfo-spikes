function [bar_plot, r] = build_rate_bar(rates, varargin)
% BUILD_RATE_BAR creates a bar plot to display channel rates and annotations.
%
%   [bar_plot, r] = build_rate_bar(rates, varargin)
%   generates a bar plot to visualize channel rates. This function offers
%   various customization options, including stacked or grouped bars, channel
%   highlighting, and rate annotation. It returns handles to the plotted bars.
%
% Input:
%   - rates: Numeric array containing channel rates.
%   - varargin: A list of optional parameter name-value pairs.
%
% Optional Parameters:
%   - 'xticklabels': Cell array of channel labels.
%   - 'color': Bar color.
%   - 'titlestr': Title for the bar plot.
%   - 'ylabel': Label for the y-axis.
%   - 'bad_channels': Indices of bad channels to highlight.
%   - 'good_channels': Indices of good channels to highlight.
%   - 'highlighted_channels': Indices of channels to highlight with a different color.
%   - 'highlight_color': Color for highlighted channels.
%   - 'style': Bar style ('grouped' or 'stacked').
%   - 'legend': Legend entries.
%   - 'fontsize': Font size.
%   - 'show_chan_names': Flag to show channel names on the x-axis.
%   - 'ra_channels': Indices to create rate annotations.
%   - 'ra_edge_color': Edge color for rate annotations.
%   - 'ra_face_color': Face color for rate annotations.
%   - 'ra_linewidth': Line width for rate annotations.
%   - 'box': Box display ('on' or 'off').
%   - 'XAxis': X-axis visibility ('on' or 'off').
%   - 'YAxis': Y-axis visibility ('on' or 'off').
%   - 'tick_length': Length of ticks.
%
% Output:
%   - bar_plot: Handles to the plotted bars.
%   - r: Handles to rate annotations.

    parser = inputParser();

    addOptional(parser, 'xticklabels', []);
    addOptional(parser, 'color', [0 0.4470 0.7410]);
    addOptional(parser, 'titlestr', '');
    addOptional(parser, 'ylabel', '');
    addOptional(parser, 'bad_channels', []);
    addOptional(parser, 'good_channels', []); 
    addOptional(parser, 'highlighted_channels', []); 
    addOptional(parser, 'highlight_color', 'g'); 
    addOptional(parser, 'style', 'grouped');
    addOptional(parser, 'legend', []); 
    addOptional(parser, 'fontsize', 10); 
    addOptional(parser, 'show_chan_names', 1); 
    addOptional(parser, 'ra_channels', []); 
    addOptional(parser, 'ra_edge_color', 'g'); 
    addOptional(parser, 'ra_face_color', [0 0 0 0]); 
    addOptional(parser, 'ra_linewidth', 2); 
    addOptional(parser, 'box', 'off'); 
    addOptional(parser, 'XAxis', 'on'); 
    addOptional(parser, 'YAxis', 'on'); 
    addOptional(parser, 'tick_length', [.01 .01]); 
    addOptional(parser, 'round_labels', false); 

    parse(parser, varargin{:});

    xticklabels = parser.Results.xticklabels;
    color = parser.Results.color;
    titlestr = parser.Results.titlestr;
    y_label = parser.Results.ylabel; 
    bad_channels = parser.Results.bad_channels;
    good_channels = parser.Results.good_channels; 
    highlighted_channels = parser.Results.highlighted_channels;
    highlight_color = parser.Results.highlight_color;
    style = parser.Results.style; 
    show_chan_names = parser.Results.show_chan_names; 
    ra_channels = parser.Results.ra_channels; 
    ra_edge_color = parser.Results.ra_edge_color;
    ra_face_color = parser.Results.ra_face_color; 
    ra_linewidth = parser.Results.ra_linewidth;
    box = parser.Results.box; 
    XAxis = parser.Results.XAxis;
    YAxis = parser.Results.YAxis;
    tick_length = parser.Results.tick_length; 
    round_labels = parser.Results.round_labels; 
    
    if ~isempty(ra_channels)
        hold on 

        start = 1; 
        for i = [find(diff(ra_channels) ~= 1); length(ra_channels)]'
            cur_ra_channels = ra_channels(start:i); 

            w = length(cur_ra_channels); 
            h = max(rates); 
            x = cur_ra_channels(1) - .5; 
            y = 0;
            rectangle('Position', [x y w h], ...
                      'EdgeColor', ra_edge_color,...
                      'LineWidth', ra_linewidth, ...
                      'FaceColor', ra_face_color); 
            r = bar(zeros(size(rates)), ...              
                    'FaceColor', ra_face_color(1:3), ...
                    'EdgeColor', ra_face_color(1:3));
           
            start = i + 1; 
        end 
    else 
        r = []; 
    end 

    switch style
        case 'grouped'
            bar_plot1 = bar(rates, ...              
                           'FaceColor', color, ...
                           'EdgeColor', color);  
        case 'stacked'
            bar_plot1 = bar(rates, ...   
                           style); 
            
            if size(color, 1) < length(bar_plot1)
                color = repmat([[0 0.4470 0.7410]; ...
                               [0.8500 0.3250 0.0980]; ...
                               [0.9290 0.6940 0.1250]], ...
                               ceil(length(bar_plot1) / 3), 1); 
            end 
                       
            for i = 1:length(bar_plot1)
                bar_plot1(i).FaceColor = color(i, :); 
                bar_plot1(i).EdgeColor = color(i, :);
            end             
    end 

    title(titlestr); 
    ylabel(y_label); 
    
    if show_chan_names == 1
        xtickangle(90); 
        set(gca, 'xtick', 1:1:length(xticklabels)); 
        set(gca, 'xticklabel', xticklabels, 'fontsize', parser.Results.fontsize); 
        
    else
        del_chs = []; 
        for i = 1:length(xticklabels)-1
            if strcmp( ...
                      xticklabels{i}(1:find(isletter(xticklabels{i}), 1, 'last')), ...
                      xticklabels{i+1}(1:find(isletter(xticklabels{i+1}), 1, 'last')) ...
                      ) 
               del_chs = [del_chs; i + 1]; 
               xticklabels{i} = xticklabels{i}(1:find(isletter(xticklabels{i}), 1, 'last')); 
            end 
        end 
        xticklabels(del_chs) = {''}; 
        set(gca, 'xtick', 1:1:length(xticklabels)); 
        set(gca, 'xticklabel', xticklabels, 'fontsize', parser.Results.fontsize); 
    end 
    
    if ~isempty(bad_channels)

        ticklabels = get(gca,'xticklabel');

        for ii = bad_channels  
            ticklabels{ii} = ['\color[rgb]{.9,.1,.1}' ticklabels{ii}]; 
        end 

        set(gca, 'xticklabel', ticklabels);

    end
   
    if ~isempty(good_channels)

        ticklabels = get(gca,'xticklabel');

        for ii = good_channels  
            ticklabels{ii} = ['\color[rgb]{.07,.7,.2}' ticklabels{ii}]; 
        end 

        set(gca, 'xticklabel', ticklabels);

    end
    
    if ~isempty(highlighted_channels)
        hold on; 
        plot_bars = zeros(size(rates)); 
        plot_bars(highlighted_channels) = rates(highlighted_channels); 
       
        bar_plot2 = bar(plot_bars, ...              
                       'FaceColor', highlight_color, ...
                       'EdgeColor', highlight_color); 
    else 
        bar_plot2 = []; 
    end     
    
    bar_plot = [bar_plot1 bar_plot2]; 
    
    if ~isempty(parser.Results.legend)
        legend(parser.Results.legend);
    end
    
    
    set(gca, ... 
        'box', box, ...
        'TickLength', tick_length); 
    
    if round_labels 
        yticks(round([0 max(rates)], 2, "significant")); 
        yticklabels(round([0 max(rates)], 2, "significant")); 
        ylim([0 max(max(rates), round(max(rates), 2, "significant"))]); 
    end 
    
    ax = gca;    
    ax
    ax.XRuler.Axle.Visible = XAxis; 
    ax.YRuler.Axle.Visible = YAxis; 
    
end