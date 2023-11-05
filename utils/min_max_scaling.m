function scaled_array = min_max_scaling(array)
% MIN_MAX_SCALING Perform min-max scaling on an input array.
%
% Syntax:
%   scaled_array = min_max_scaling(array)
%
% Description:
%   The `min_max_scaling` function scales the values in the input array to a range between 0 and 1 using the min-max scaling technique.
%
% Input:
%   - array: An input array to be scaled.
%
% Output:
%   - scaled_array: The scaled array with values in the range [0, 1].

    min_value = min(array(:)); 
    max_value = max(array(:)); 

    scaled_array = (array - min_value) / (max_value - min_value); 
    
end