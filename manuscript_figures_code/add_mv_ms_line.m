function add_mv_ms_line(varargin)
% add_mv_ms_line - Add millivolt and millisecond reference lines to a plot.
%
% Input (Name, Value Pairs):
%   - 'fig_fontsize': Font size for text (default: 10).
%   - 'shift': Vertical shift for the reference lines (default: 1000).
%   - 'tmin': Minimum time value (default: 0).
%   - 'tmax': Maximum time value (default: 10).
%   - 'v_text': Text label for millivolt reference (default: '1 mV').
%   - 'ms_text': Text label for millisecond reference (default: '100 ms').
%   - 'v_scale': Vertical scale factor for millivolt reference (default: 1000).
%   - 'ms_scale': Horizontal scale factor for millisecond reference (default: 0.1).
%   - 'y_shift': Vertical shift for text labels (default: 0).
%   - 'color': Color for reference lines and text labels (default: 'k' for black).

    p = inputParser;

    addParameter(p, 'fig_fontsize', 10);
    addParameter(p, 'shift', 1000);
    addParameter(p, 'tmin', 0);
    addParameter(p, 'tmax', 10);
    addParameter(p, 'v_text', '1 mV');
    addParameter(p, 'ms_text', '100 ms');
    addParameter(p, 'v_scale', 1000);
    addParameter(p, 'ms_scale', 0.1);
    addParameter(p, 'y_shift', 0);
    addParameter(p, 'color', 'k');
    
    parse(p, varargin{:});
    
    fig_fontsize = p.Results.fig_fontsize; 
    shift = p.Results.shift; 
    tmin = p.Results.tmin; 
    tmax = p.Results.tmax; 
    v_text = p.Results.v_text; 
    ms_text = p.Results.ms_text; 
    v_scale = p.Results.v_scale; 
    ms_scale = p.Results.ms_scale; 
    y_shift = p.Results.y_shift; 
    color = p.Results.color; 
    
    
    n_secs = tmax - tmin; 
    
    % mV
    
    line(tmax - [n_secs*0.2 n_secs*0.2], ...
         [shift/2 + y_shift, -v_scale + shift/2 + y_shift], ...
         'color', color); 
              
    text(tmax - n_secs * 0.2 - n_secs/100, ...
         mean([shift/2 + y_shift, -v_scale + shift/2 + y_shift]), ... 
         v_text, ...
         'HorizontalAlignment', 'right', ...
         'fontsize', fig_fontsize, ...
         'color', color);
    
    % ms 
    
    line((tmax - n_secs * 0.2) + [0 ms_scale], ...
         [-v_scale + shift/2 + y_shift, -v_scale + shift/2 + y_shift], ... 
         'color', color); 

    text(tmax - n_secs * 0.2 + ms_scale/2, ...
         -v_scale + shift/2 + y_shift, ...
         ms_text, ...
         'HorizontalAlignment', 'center', ...
         'VerticalAlignment', 'top', ...
         'fontsize', fig_fontsize, ...
         'color', color);
end 
               