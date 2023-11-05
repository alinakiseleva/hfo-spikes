function h = tmp_add_marker(par)
% ADD_MARKER Add marker(s) to a 3D plot.
%
% Syntax:
%   h = add_marker(par)
%
% Input:
%   - par: A struct containing marker parameters.
%       - mni: A vector (1x3) or matrix (nx3) of MNI coordinate sets.
%       - color: Marker color, specified as an RGB triplet.
%       - marker_size: Radius of the markers in MNI units.
%       - colormap_flag: A flag indicating whether to use a colormap (true/false).
%       - arrows_flag: A flag to add arrows (true/false).
%       - position: Text position ('down', 'left', 'right', 'top', or '' for no position).
%       - chan_names: Cell array of channel names (required when arrows_flag is true).
%       - Colormap: Colormap data (required when colormap_flag is true).
%
% Output:
%   - h: Handles to marker patches.
%
% Description:
%   The `add_marker` function adds marker(s) to a 3D plot with customizable
%   properties. It can add single or multiple markers depending on the input.
%
% Reference:
%   https://github.com/robertreingit/simpleBrainSurface/tree/master

    defaults = struct('colormap_flag', false, ...
                      'colormap_str', '', ...
                      'colormap_position', 'southoutside', ... 
                      'marker_size', 3, ...
                      'color', [0.9 0.1 0.1], ...
                      'arrows_flag', false, ...
                      'position', '', ...
                      'fontsize', 10, ...
                      'spacing', 10);
    par = merge_params(defaults, par);

    if ~isfield(par, 'mni')
        error('Missing mni coordinates');
    end
    
    if par.arrows_flag && ~isfield(par, 'chan_names')
        error('Missing channel names');
    end
    
    if par.colormap_flag && ~isfield(par, 'colormap')
        error('Colormap is empty');
    end

    if isvector(par.mni)
        par.mni = par.mni(:)';
    end
    assert(size(par.mni, 2) == 3, 'Coordinates must be 3D vectors')
    
    no_marker = size(par.mni,1);
    h = zeros(no_marker,1);
    
    if size(par.color, 1) == 1
        par.color = repmat(par.color, length(par.mni), 1); 
    end
    
    switch par.position
        case 'top'
            par.mni(:, 3) = par.mni(:, 3) + 150;  
        case 'left'
            par.chan_names(par.mni(:, 1) > 0) = {''};
        case'right'
            par.chan_names(par.mni(:, 1) < 0) = {''};
    end 
    
    hold on; 
   
    for m = 1:no_marker
        marker = generate_sphere(par.mni(m,:), par.marker_size);
        if ~par.colormap_flag
            h(m) = patch('vertices', marker.vertices, ...
                          'faces', marker.faces, ...
                          'facecolor', par.color(m, :), ...
                          'facealpha', 0.6, ...
                          'edgecolor', 'none', ...
                          'facelighting', 'gouraud');
        else 
             h(m) = patch('vertices', marker.vertices, ...
                          'faces', marker.faces, ...
                          'facealpha', 1, ...
                          'edgecolor', 'none', ...
                          'FaceVertexCData', par.colormap(m), ...              
                          'FaceColor', 'flat');
        end 
    end 
    
    if par.colormap_flag

        colormap(par.plot_cmap);  
        c = colorbar(par.colormap_position, ...
                     'Ticks', [min(par.colormap), max(par.colormap)/2, max(par.colormap)], ...
                     'TickLabels', append(repmat("\color{black}", 1, 3), ...
                                          string(round([min(par.colormap), ...
                                                        max(par.colormap)/2, ...
                                                        max(par.colormap)]))));
      
        c.Label.String = par.colormap_str;
        c.Label.VerticalAlignment = 'bottom';
        c.Label.FontSize = par.fontsize; 
        
        c.TickLength = 0; 
        c.Box = 'off'; 
        c.EdgeColor = 'w'; 
        c.Label.Color = 'k'; 
        
        switch par.colormap_position
            case 'southoutside'
                c.Position(2) = c.Position(2) - 2 * c.Position(4); 
                c.Position(4) = c.Position(4) / 2;  
                c.Label.Position(2) = c.Position(2) + 1; 
        end 
       
    end
    
    if par.arrows_flag
        
        el_inds = ~cellfun(@isempty, par.chan_names);
        el_coords = par.mni(el_inds, :); 

        spacing = par.spacing;
         
        switch par.position
            
            case 'top'
                
                el_name_coords = el_coords; 
                el_name_coords(:, 3) = 250; % z
                el_name_coords(:, 1) = sign(el_name_coords(:, 1)) * 80; % x
                el_name_coords(:, 2) = el_name_coords(:, 2) - 20;
                
                [B, I] = sort(el_name_coords(:, 2), 'descend');  
                
               
                for i = 1:length(I)-1
                    
                    k = i + 1; 
                    while ~(el_name_coords(I(i), 1) == el_name_coords(I(k), 1)) && (k < length(I))
                        k = k + 1; 
                    end 
                    
                    if el_name_coords(I(i), 1) == el_name_coords(I(k), 1) && (B(i) - B(k)) < spacing
                        add = spacing - (B(i) - B(k)); 
                        B(i) = B(i) + add; 
                        for j = 1:i-1 
                            if el_name_coords(I(i), 1) == el_name_coords(I(j), 1)
                               B(j) = B(j) + add; 
                            end
                        end
                    end 
                end
                el_name_coords(I, 2) = B;
   
            case 'down'
                
            case {'right', 'left'}
                
                el_name_coords = el_coords; 
                el_name_coords(:, 3) = ((el_name_coords(:,3) >= 20) * 90) + ((el_name_coords(:,3) < 20) * -60); % z

                [B, I] = sort(el_name_coords(:, 2), 'descend');        
                for i = find(((B(1:end-1) - B(2:end)) < spacing))'
                    add = spacing - (B(i) - B(i+1)); 
                    B(i) = B(i) + add; 
                    for j = 1:i
                           B(j) = B(j) + add; 
                    end
                end
                el_name_coords(I, 2) = B; 
                
            case ''
                el_name_coords = el_coords;
        end
    
        text(el_name_coords(:, 1), ...
             el_name_coords(:, 2), ...
             el_name_coords(:, 3), ...
             par.chan_names(el_inds), ...
             'HorizontalAlignment', 'center', ...
             'VerticalAlignment', 'middle', ...
             'BackgroundColor', 'w', ...
             'Margin', .01, ...
             'fontsize', par.fontsize); 
        
        for i = 1:size(el_coords,1)
            plot3([el_coords(i, 1), el_name_coords(i, 1)], ... 
                  [el_coords(i, 2), el_name_coords(i, 2)], ... 
                  [el_coords(i, 3), el_name_coords(i, 3)], ...
                  'k', 'linewidth', 0.2); 
        end
          
    end
end


function fvc = generate_sphere(pos,radius)

    [x,y,z] = sphere(40);
    x = radius*x + pos(1);
    y = radius*y + pos(2);
    z = radius*z + pos(3);
    fvc = surf2patch(x,y,z);

end