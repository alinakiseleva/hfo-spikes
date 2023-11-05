function cmap = create_custom_colormap(colors, nColors)
% CREATE_CUSTOM_COLORMAP creates a custom colormap using the specified colors.
%
%   cmap = create_custom_colormap(colors, nColors) generates a custom
%   colormap that smoothly transitions between the specified colors. This
%   function can be used to create a more visually appealing colormap for
%   various types of plots.
%
% Input:
%   - colors: Matrix of colors (n x 3) that define the custom colormap.
%   - nColors: Number of color segments in the colormap.
%
% Output:
%   - cmap: The custom colormap matrix with nColors segments.

    cmap = zeros(nColors * (length(colors)-1), 3); 

    for i = 0:length(colors)-2
        inds = i*nColors + 1 : (i+1)*nColors; 
        cmap(inds, :) = [colors(i+1, :); ...
                         [linspace(colors(i+1, 1), colors(i+2, 1), nColors - 1); ...
                         linspace(colors(i+1, 2), colors(i+2, 2), nColors - 1); ...
                         linspace(colors(i+1, 3), colors(i+2, 3), nColors - 1)]']; 
    end 
    
end








