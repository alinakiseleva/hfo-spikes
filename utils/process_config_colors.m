function [cmap, custom_colormap] = process_config_colors(config) 
% process_config_colors - Process color configuration data.
%
% Input:
%   - config (struct): A structure containing color configuration data.
%
% Output:
%   - cmap (containers.Map): A MATLAB containers.Map that maps color names to
%     their RGB values. 
%   - custom_colormap (double): A custom colormap created from the provided RGB
%     values. 

    cmap = containers.Map; 
    
    color_names = fields(config.colors); 
    for color_name = color_names'
        cmap(char(color_name)) = cell2mat(config.colors.(char(color_name))); 
    end 
    
    custom_colormap = create_custom_colormap(cell2mat(config.custom_colormap_colors), 20); 
    cmap('custom_cmap') = custom_colormap;
end 

