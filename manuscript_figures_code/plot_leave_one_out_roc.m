function plot_leave_one_out_roc(scores, labels, varargin)
% plot_leave_one_out_roc - Plot Leave-One-Out Receiver Operating Characteristic (ROC) Curve
%
% Description:
%   The `plot_leave_one_out_roc` function is used to create ROC curves for binary
%   classification tasks when applying a leave-one-out cross-validation strategy.
%
% Inputs:
%   - scores: An array of numeric values representing the classification scores
%     for the binary task.
%   - labels: An array of numeric labels (0 or 1) corresponding to the true class
%     of each sample.
%   - varargin: Optional parameter-value pairs for customizing the plot (see below).
%
% Optional Parameters (varargin):
%   - 'title_str' (default: ''): A string for the plot title.
%   - 'title_color' (default: 'k'): Color of the title text.
%   - 'title_background_color' (default: 'none'): Background color for the title.
%   - 'alpha' (default: 1): Alpha (transparency) value for the ROC curves.
%   - 'linewidth' (default: 1.5): Line width for the ROC curves.
%   - 'color' (default: 'k'): Color of the ROC curves.
%   - 'fig_fontsize' (default: 10): Font size for the plot.
%   - 'box' (default: 'off'): Box property of the plot axes.
%   - 'XAxis' (default: 'on'): X-axis visibility property.
%   - 'YAxis' (default: 'on'): Y-axis visibility property.
%   - 'tick_length' (default: [.01 .01]): Length of axis ticks.
%   - 'auc_flag' (default: false): Include the AUC (Area Under the ROC Curve) value
%     in the title.

    parser = inputParser;
    addRequired(parser, 'scores', @isnumeric);
    addRequired(parser, 'labels', @isnumeric);
    addOptional(parser, 'title_str', '');
    addOptional(parser, 'title_color', 'k'); 
    addOptional(parser, 'title_background_color', 'none'); 
    addOptional(parser, 'alpha', 1); 
    addOptional(parser, 'linewidth', 1.5);  
    addOptional(parser, 'color', 'k');  
    addOptional(parser, 'fig_fontsize', 10);  
    addOptional(parser, 'box', 'off'); 
    addOptional(parser, 'XAxis', 'on'); 
    addOptional(parser, 'YAxis', 'on'); 
    addOptional(parser, 'tick_length', [.01 .01]); 
    addOptional(parser, 'auc_flag', false); 

    parse(parser, scores, labels, varargin{:});

    scores = parser.Results.scores;
    labels = parser.Results.labels;
    title_str = parser.Results.title_str;
    title_color = parser.Results.title_color; 
    title_background_color = parser.Results.title_background_color;
    alpha = parser.Results.alpha;
    linewidth = parser.Results.linewidth;
    color = parser.Results.color;
    fig_fontsize = parser.Results.fig_fontsize;
    box = parser.Results.box; 
    XAxis = parser.Results.XAxis;
    YAxis = parser.Results.YAxis;
    tick_length = parser.Results.tick_length; 
    auc_flag = parser.Results.auc_flag; 
    
    for i = 1:length(scores)
        
        [X, Y] = perfcurve(labels([1:i-1, i+1:end]), scores([1:i-1, i+1:end]), 1);
        plot(X, Y, ...
             'LineStyle', '--', ...
             'Color', color);
        alpha(alpha); 
        hold on; 
        
    end

    [X, Y, ~, AUC, ~] = perfcurve(labels, scores, 1);
    
    plot(X, Y, 'LineWidth', linewidth, 'Color', color); 
    
    xlabel('1 - Specificity');
    ylabel('Sensitivity');
    
    if auc_flag
        title_str = [title_str + " (AUC = " + num2str(AUC) + ")"]; 
    end 
    
    t = title(title_str, 'Color', title_color, 'BackgroundColor', title_background_color);
    t.Position(2) = t.Position(2) + .02; 
    
    set(gca, ... 
        'box', box, ...
        'TickLength', tick_length); 

    yticks([0 .5 1]); 
    yticklabels([0 .5 1]); 
    
    xticks([0 .5 1]); 
    xticklabels([0 .5 1]); 
    
    ax = gca;    
    ax
    ax.XRuler.Axle.Visible = XAxis; 
    ax.YRuler.Axle.Visible = YAxis; 
    
    ax.FontSize = fig_fontsize; 
    
end
